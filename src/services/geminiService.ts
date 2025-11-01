import { apiClient } from './apiClient';
import { ShoppingList, ProductPriceData, TripPlan, Product, Store } from '../types';
import { AugmentedSearchResult } from '../pages/Search';

export const searchProducts = async (query: string, stores: Store[]): Promise<AugmentedSearchResult[]> => {
    const storeIds = stores.map(s => s.id);
    const settledResults = await apiClient.post('/api/search', { query, stores: storeIds });

    const allProducts: AugmentedSearchResult[] = [];
    
    (settledResults as any[]).forEach((result, index) => {
        if (result.status === 'fulfilled' && result.value) {
            const store = stores[index];
            const products = result.value;

            // Map each product based on its store's data structure
            if (store.id === 'store-woolworths') {
                products.forEach((p: any) => {
                     if (p.Barcode && p.Price && p.DisplayName) {
                        allProducts.push({
                            product: {
                                gtin: p.Barcode,
                                name: p.DisplayName,
                                brand: p.Brand || 'Woolworths',
                                description: p.Description || p.DisplayName,
                                imageUrl: p.LargeImageFile || `https://via.placeholder.com/200?text=${encodeURIComponent(p.DisplayName)}`,
                                raw_data: p,
                            },
                            price: p.Price,
                            storeId: store.id,
                            storeLogoUrl: store.logoUrl,
                        });
                    }
                });
            } else if (store.id === 'store-coles') {
                 products.forEach((item: any) => {
                    if (item.pricing?.now) {
                        allProducts.push({
                            product: {
                                gtin: `coles-${item.id}`,
                                name: item.name,
                                brand: item.brand,
                                description: item.description || item.name,
                                imageUrl: item.image ? `https://www.coles.com.au${item.image}` : `https://via.placeholder.com/200?text=${encodeURIComponent(item.name)}`,
                                raw_data: item,
                            },
                            price: item.pricing.now,
                            storeId: store.id,
                            storeLogoUrl: store.logoUrl,
                        });
                    }
                });
            } else if (store.id === 'store-aldi') {
                products.forEach((item: any) => {
                    if (item.price?.amount) {
                        let imageUrl = `https://via.placeholder.com/200?text=${encodeURIComponent(item.name)}`;
                        if (item.assets && item.assets[0]?.url) {
                            imageUrl = item.assets[0].url.replace('{width}', '300').replace('{slug}', item.urlSlugText || 'product');
                        }
                        allProducts.push({
                             product: {
                                gtin: `aldi-${item.sku}`,
                                name: item.name,
                                brand: item.brandName || 'ALDI',
                                description: item.name,
                                imageUrl: imageUrl,
                                raw_data: item,
                            },
                            price: item.price.amount / 100,
                            storeId: store.id,
                            storeLogoUrl: store.logoUrl,
                        });
                    }
                });
            }
        }
    });

    return allProducts;
};


export const optimizeTrip = async (list: ShoppingList, prices: ProductPriceData, stores: {id: string, name: string}[]): Promise<TripPlan | null> => {
  try {
    const tripPlan = await apiClient.post('/api/optimize-trip', { list, prices, stores });
    return tripPlan as TripPlan;
  } catch (error) {
    console.error("Error optimizing trip:", error);
    // In a real app, you might want to return a more specific error or a fallback plan
    return null;
  }
};