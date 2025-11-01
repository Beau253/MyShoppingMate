import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Store, ProductPriceData } from '../types';
import { apiClient } from '../services/apiClient';

interface StoreContextType {
  allStores: Store[];
  userStores: Store[];
  isLoading: boolean;
  addUserStore: (storeId: string) => Promise<void>;
  removeUserStore: (storeId: string) => Promise<void>;
  priceData: ProductPriceData;
  addPrice: (gtin: string, storeId: string, price: number) => void;
}

const StoreContext = createContext<StoreContextType | undefined>(undefined);

const ALL_STORES: Store[] = [
  { id: 'store-woolworths', name: 'Woolworths', chain: 'Woolworths', logoUrl: 'https://e7.pngegg.com/pngimages/87/110/png-clipart-logo-woolworths-supermarkets-brand-woolworths-epsom-woolworths-st-clair-netball-text-trademark.png' },
  { id: 'store-coles', name: 'Coles', chain: 'Coles', logoUrl: 'https://e7.pngegg.com/pngimages/792/16/png-clipart-brand-logo-coles-upper-coomera-coles-supermarkets-coles-robina-palm-reading-signs-red-text-trademark.png' },
  { id: 'store-aldi', name: 'ALDI', chain: 'ALDI', logoUrl: 'https://p7.hiclipart.com/preview/687/518/570/aldi-grocery-store-supermarket-chicago-company-aldi-logo.jpg' },
];

export const StoreProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [userStoreIds, setUserStoreIds] = useState<string[]>([]);
  const [priceData, setPriceData] = useState<ProductPriceData>({});
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchUserStores = async () => {
      try {
        const storedIds = await apiClient.get('/api/user-stores');
        setUserStoreIds(storedIds);
      } catch (error) {
        console.error("Failed to fetch user stores:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchUserStores();
  }, []);

  const userStores = ALL_STORES.filter(store => userStoreIds.includes(store.id));

  const persistUserStores = async (storeIds: string[]) => {
    try {
      await apiClient.post('/api/user-stores', { storeIds });
    } catch (error) {
      console.error("Failed to save user stores:", error);
    }
  };

  const addUserStore = async (storeId: string) => {
    const newIds = [...new Set([...userStoreIds, storeId])];
    setUserStoreIds(newIds);
    await persistUserStores(newIds);
  };

  const removeUserStore = async (storeId: string) => {
    const newIds = userStoreIds.filter(id => id !== storeId);
    setUserStoreIds(newIds);
    await persistUserStores(newIds);
  };
  
  const addPrice = (gtin: string, storeId: string, price: number) => {
    setPriceData(prevData => {
      const existingPrices = prevData[gtin] ? [...prevData[gtin]] : [];
      const storePriceIndex = existingPrices.findIndex(p => p.storeId === storeId);
      if (storePriceIndex === -1) {
        return { ...prevData, [gtin]: [...existingPrices, { storeId, price }] };
      }
      return prevData;
    });
  };

  return (
    <StoreContext.Provider value={{ allStores: ALL_STORES, userStores, isLoading, addUserStore, removeUserStore, priceData, addPrice }}>
      {children}
    </StoreContext.Provider>
  );
};

export const useStores = () => {
  const context = useContext(StoreContext);
  if (context === undefined) {
    throw new Error('useStores must be used within a StoreProvider');
  }
  return context;
};