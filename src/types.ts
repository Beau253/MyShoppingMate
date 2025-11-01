export interface Product {
  gtin: string;
  name: string;
  brand: string;
  description: string;
  imageUrl: string;
  raw_data?: any;
}

export interface ListItem {
  id: string;
  product: Product | null; // Can be null for generic items
  name: string; // Holds the name for both generic and specific items
  isGeneric: boolean; // Flag to identify generic items
  quantity: number;
  isChecked: boolean;
}

export interface ShoppingList {
  id: string;
  name: string;
  items: ListItem[];
  createdAt: string;
  updatedAt: string;
}

export interface Store {
  id: string;
  name: string;
  chain: string;
  logoUrl: string;
}

export interface PriceInfo {
  storeId: string;
  price: number;
}

export interface ProductPriceData {
  [gtin: string]: PriceInfo[];
}

export interface OptimizedTripStore {
  storeName: string;
  itemsToBuy: {
    itemName: string;
    quantity: number;
    price: number;
  }[];
  subtotal: number;
}

export interface TripPlan {
  optimizedTrip: OptimizedTripStore[];
  totalCost: number;
  totalSavings: number;
  notes: string;
}