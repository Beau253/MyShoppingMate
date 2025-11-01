import express from 'express';
import cors from 'cors';
import bodyParser from 'body-parser';
import { GoogleGenAI } from '@google/genai';
import { ShoppingList, ListItem, Product, ProductPriceData, TripPlan, Store } from '../src/types';

const app = express();
const port = process.env.PORT || 3001;

// Ensure API keys are loaded from environment variables
if (!process.env.API_KEY || !process.env.COLES_API_KEY) {
  const missingKeys = [];
  if (!process.env.API_KEY) missingKeys.push("API_KEY");
  if (!process.env.COLES_API_KEY) missingKeys.push("COLES_API_KEY");
  throw new Error(`Missing required environment variable(s): ${missingKeys.join(', ')}`);
}
const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
const COLES_API_KEY = process.env.COLES_API_KEY;


app.use(cors());
app.use(bodyParser.json());

// --- IN-MEMORY DATABASE SIMULATION (DEVELOPMENT ONLY) ---
// Per "Database Technical Blueprint V2.0", this MUST be replaced with a proper database architecture.
// - User/List data -> PostgreSQL
// - Product Catalog -> MongoDB
// - Price Data -> TimescaleDB
let userLists: ShoppingList[] = [];
let userWatchedItems: Product[] = [];
let userProductBarcodes: { [productId: string]: string } = {};
let userStoreIds: string[] = [];


// --- EXTERNAL API SERVICES (Server-side) ---
const searchWoolworths = async (query: string): Promise<any[] | null> => {
    const WOOLWORTHS_API_URL = 'https://www.woolworths.com.au/apis/ui/Search/products';
    const payload = { SearchTerm: query, PageNumber: 1, PageSize: 36, SortType: "TraderRelevance" };
    try {
        const response = await fetch(WOOLWORTHS_API_URL, {
            method: 'POST',
            headers: { 
              'Content-Type': 'application/json',
              'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
              'Accept': 'application/json, text/plain, */*'
            },
            body: JSON.stringify(payload),
        });
        if (!response.ok) {
           console.error(`Woolworths API request failed: ${response.status}`);
           return null;
        }
        const data = await response.json();
        return data.Products?.flatMap((pg: any) => pg.Products) || [];
    } catch (error) {
        console.error("Error fetching from Woolworths:", error);
        return null;
    }
};

const searchColes = async (query: string): Promise<any[] | null> => {
    const COLES_API_URL = `https://www.coles.com.au/api/bff/products/search?q=${encodeURIComponent(query)}&storeId=0584&page=1`;
    try {
        const response = await fetch(COLES_API_URL, {
            headers: { 
              "Ocp-Apim-Subscription-Key": COLES_API_KEY!,
              "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36",
            }
        });
        if (!response.ok) {
          console.error(`Coles API request failed: ${response.status}`);
          return null;
        }
        const data = await response.json();
        return data.results?.filter((item: any) => item._type === "PRODUCT") || [];
    } catch (error) {
        console.error("Error fetching from Coles:", error);
        return null;
    }
};

const searchAldi = async (query: string): Promise<any[] | null> => {
     const makeAldiApiUrl = (offset: number, limit: number) => `https://api.aldi.com.au/v3/product-search?q=${encodeURIComponent(query)}&limit=${limit}&offset=${offset}&sort=relevance`;
    try {
        const initialResponse = await fetch(makeAldiApiUrl(0, 30), {
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/123.0.0.0 Safari/537.36',
          }
        });
        if (!initialResponse.ok) {
           console.error(`ALDI API request failed: ${initialResponse.status}`);
           return null;
        }
        const initialData = await initialResponse.json();
        let allProducts = initialData.data || [];
        const totalCount = initialData.meta?.pagination?.totalCount || 0;
        if (totalCount > 30) {
            const remainingPages = Math.ceil((totalCount - 30) / 30);
            const pagePromises = Array.from({ length: remainingPages }, (_, i) =>
                fetch(makeAldiApiUrl((i + 1) * 30, 30)).then(res => res.json())
            );
            const additionalResults = await Promise.all(pagePromises);
            additionalResults.forEach(page => allProducts.push(...(page.data || [])));
        }
        return allProducts;
    } catch (error) {
        console.error("Error fetching from ALDI:", error);
        return null;
    }
};


// --- API ROUTES ---

// Search Route
app.post('/api/search', async (req, res) => {
    const { query, stores } = req.body;
    if (!query || !stores || !Array.isArray(stores)) {
        return res.status(400).json({ error: 'Invalid search parameters' });
    }

    const promises = stores.map(storeId => {
        if (storeId === 'store-woolworths') return searchWoolworths(query);
        if (storeId === 'store-coles') return searchColes(query);
        if (storeId === 'store-aldi') return searchAldi(query);
        return Promise.resolve(null);
    });

    const results = await Promise.allSettled(promises);
    res.json(results);
});

// Gemini Trip Optimization
app.post('/api/optimize-trip', async (req, res) => {
    const { list, prices, stores } = req.body as { list: ShoppingList; prices: ProductPriceData; stores: {id: string, name: string}[] };

    if (!list || !prices || !stores) {
        return res.status(400).json({ error: "Missing list, prices, or stores data." });
    }

    try {
        const prompt = `
            You are a shopping optimization expert. Given a shopping list, a list of stores, and the price of each item at each available store, create the most cost-effective shopping trip.

            Rules:
            1. The user wants to minimize their total cost.
            2. A user can visit one or more stores.
            3. If the savings from visiting an additional store are minimal (e.g., less than a dollar or two), advise the user that it might not be worth the extra trip for the small savings, but still provide the fully optimized breakdown.
            4. Provide the output as a JSON object adhering to the specified TripPlan interface.
            5. The final output must only be the JSON object, with no surrounding text, code fences, or explanations.

            Here is the TypeScript interface for the response:
            interface OptimizedTripStore {
              storeName: string;
              itemsToBuy: {
                itemName: string;
                quantity: number;
                price: number;
              }[];
              subtotal: number;
            }

            interface TripPlan {
              optimizedTrip: OptimizedTripStore[];
              totalCost: number;
              totalSavings: number; // Calculate the difference between the most expensive single-store trip and the optimized trip.
              notes: string; // Your friendly advice based on rule #3.
            }
            
            Here is the data:
            - Stores available for this trip: ${JSON.stringify(stores.map(s => s.name))}
            - Shopping List with quantities: ${JSON.stringify(list.items.map(item => ({ name: item.name, quantity: item.quantity, gtin: item.product?.gtin })))}
            - Price data (product gtin -> [storeId, price]): ${JSON.stringify(prices)}
            - Store ID to Name mapping: ${JSON.stringify(Object.fromEntries(stores.map(s => [s.id, s.name])))}

            Generate the JSON output now.
        `;
        
        const response = await ai.models.generateContent({
            model: 'gemini-2.5-flash',
            contents: prompt,
        });

        // Defensive parsing to prevent crashes from malformed AI responses
        try {
            const text = response.text.trim().replace(/```json/g, '').replace(/```/g, '');
            const plan = JSON.parse(text);
            res.json(plan);
        } catch (parseError) {
            console.error('Gemini response parsing Error:', parseError, "Raw text:", response.text);
            res.status(500).json({ error: "Failed to parse trip plan from AI response." });
        }

    } catch (error) {
        console.error('Gemini API Error:', error);
        res.status(500).json({ error: "Failed to generate trip plan from AI." });
    }
});


// Shopping Lists CRUD
app.get('/api/lists', (req, res) => res.json(userLists));
app.post('/api/lists', (req, res) => {
    const newList: ShoppingList = { ...req.body, id: `list-${Date.now()}` };
    userLists.push(newList);
    res.status(201).json(newList);
});
app.put('/api/lists/:id', (req, res) => {
    const { id } = req.params;
    const updatedList = req.body;
    const index = userLists.findIndex(l => l.id === id);
    if (index > -1) {
        userLists[index] = updatedList;
        res.json(updatedList);
    } else {
        res.status(404).json({ error: 'List not found' });
    }
});
app.delete('/api/lists/:id', (req, res) => {
    const { id } = req.params;
    userLists = userLists.filter(l => l.id !== id);
    res.status(204).send();
});

// User Stores
app.get('/api/user-stores', (req, res) => res.json(userStoreIds));
app.post('/api/user-stores', (req, res) => {
    userStoreIds = req.body.storeIds;
    res.json(userStoreIds);
});


// Watchlist CRUD
app.get('/api/watchlist', (req, res) => res.json(userWatchedItems));
app.post('/api/watchlist', (req, res) => {
    const product = req.body.product;
    if (!userWatchedItems.some(p => p.gtin === product.gtin)) {
        userWatchedItems.push(product);
    }
    res.status(201).json(userWatchedItems);
});
app.delete('/api/watchlist/:gtin', (req, res) => {
    const { gtin } = req.params;
    userWatchedItems = userWatchedItems.filter(p => p.gtin !== gtin);
    res.status(204).send();
});

// Product Barcodes
app.get('/api/barcodes', (req, res) => res.json(userProductBarcodes));
app.post('/api/barcodes', (req, res) => {
    const { productId, gtin } = req.body;
    userProductBarcodes[productId] = gtin;
    res.status(201).json(userProductBarcodes);
});


app.listen(port, () => {
  console.log(`My Shopping Mate backend listening at http://localhost:${port}`);
});
