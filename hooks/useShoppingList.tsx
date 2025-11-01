import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import { ShoppingList, ListItem, Product } from '../types';
import { apiClient } from '../services/apiClient';

interface ShoppingListContextType {
  lists: ShoppingList[];
  isLoading: boolean;
  addList: (name: string) => Promise<ShoppingList>;
  updateList: (list: ShoppingList) => Promise<void>;
  deleteList: (listId: string) => Promise<void>;
  addItemsToList: (listId: string, items: { product: Product; quantity: number }[]) => Promise<void>;
}

const ShoppingListContext = createContext<ShoppingListContextType | undefined>(undefined);

export const ShoppingListProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [lists, setLists] = useState<ShoppingList[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchLists = useCallback(async () => {
    setIsLoading(true);
    try {
      const data = await apiClient.get('/api/lists');
      setLists(data);
    } catch (error) {
      console.error("Failed to fetch shopping lists:", error);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchLists();
  }, [fetchLists]);

  const addList = async (name: string): Promise<ShoppingList> => {
    const newList = await apiClient.post('/api/lists', { name, items: [] });
    setLists(prev => [...prev, newList]);
    return newList;
  };

  const updateList = async (list: ShoppingList) => {
    await apiClient.put(`/api/lists/${list.id}`, list);
    setLists(prev => prev.map(l => l.id === list.id ? list : l));
  };

  const deleteList = async (listId: string) => {
    await apiClient.delete(`/api/lists/${listId}`);
    setLists(prev => prev.filter(l => l.id !== listId));
  };

  const addItemsToList = async (listId: string, items: { product: Product; quantity: number }[]) => {
    // This logic would likely be more complex, involving updating a specific list
    // For now, we'll just refetch to show the update
    const list = lists.find(l => l.id === listId);
    if (list) {
        // A proper implementation would merge items on the backend
        // Here we just simulate by refetching
        await fetchLists();
    }
  };

  const value = { lists, isLoading, addList, updateList, deleteList, addItemsToList };

  return (
    <ShoppingListContext.Provider value={value}>
      {children}
    </ShoppingListContext.Provider>
  );
};

export const useShoppingList = () => {
  const context = useContext(ShoppingListContext);
  if (context === undefined) {
    throw new Error('useShoppingList must be used within a ShoppingListProvider');
  }
  return context;
};