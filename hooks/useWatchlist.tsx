import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { Product } from '../types';
import { apiClient } from '../services/apiClient';

interface WatchlistContextType {
  watchedItems: Product[];
  isLoading: boolean;
  addToWatchlist: (product: Product) => Promise<void>;
  removeFromWatchlist: (gtin: string) => Promise<void>;
  isWatched: (gtin: string) => boolean;
}

const WatchlistContext = createContext<WatchlistContextType | undefined>(undefined);

export const WatchlistProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [watchedItems, setWatchedItems] = useState<Product[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchWatchlist = async () => {
      try {
        const serverItems = await apiClient.get('/api/watchlist');
        setWatchedItems(serverItems);
      } catch (error) {
        console.error("Failed to fetch watchlist:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchWatchlist();
  }, []);

  const addToWatchlist = async (product: Product) => {
    if (!watchedItems.some(item => item.gtin === product.gtin)) {
      setWatchedItems(prevItems => [...prevItems, product]); // Optimistic update
      try {
        await apiClient.post('/api/watchlist', { product });
      } catch (error) {
        console.error("Failed to add to watchlist:", error);
        // Revert on error
        setWatchedItems(prevItems => prevItems.filter(item => item.gtin !== product.gtin));
      }
    }
  };

  const removeFromWatchlist = async (gtin: string) => {
    const originalItems = watchedItems;
    setWatchedItems(prevItems => prevItems.filter(item => item.gtin !== gtin)); // Optimistic update
    try {
      await apiClient.delete(`/api/watchlist/${gtin}`);
    } catch (error) {
      console.error("Failed to remove from watchlist:", error);
      setWatchedItems(originalItems); // Revert on error
    }
  };

  const isWatched = (gtin: string) => {
    return watchedItems.some(item => item.gtin === gtin);
  };

  return (
    <WatchlistContext.Provider value={{ watchedItems, isLoading, addToWatchlist, removeFromWatchlist, isWatched }}>
      {children}
    </WatchlistContext.Provider>
  );
};

export const useWatchlist = () => {
  const context = useContext(WatchlistContext);
  if (context === undefined) {
    throw new Error('useWatchlist must be used within a WatchlistProvider');
  }
  return context;
};
