import React, { createContext, useContext, useState, useEffect, ReactNode, useCallback } from 'react';
import { ShoppingList, ListItem, Product } from '../types';
import { apiClient } from '../services/apiClient';

interface ShoppingListContextType {
  lists: ShoppingList[];
  isLoading: boolean;
  addList: (name: string) => Promise<ShoppingList>;
  getList: (id: string) => ShoppingList | undefined;
  updateList: (updatedList: ShoppingList) => Promise<void>;
  deleteList: (id: string) => Promise<void>;
  addItemToList: (listId: string, product: Product, quantity: number) => Promise<void>;
  addGenericItemToList: (listId: string, itemName: string, quantity: number) => Promise<void>;
  updateItemInList: (listId: string, updatedItem: ListItem) => Promise<void>;
  removeItemFromList: (listId: string, itemId: string) => Promise<void>;
  addItemsToList: (listId: string, items: { product: Product, quantity: number }[]) => Promise<void>;
}

const ShoppingListContext = createContext<ShoppingListContextType | undefined>(undefined);

export const ShoppingListProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [lists, setLists] = useState<ShoppingList[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    const fetchLists = async () => {
      try {
        const serverLists = await apiClient.get('/api/lists');
        setLists(serverLists);
      } catch (error) {
        console.error("Failed to fetch shopping lists:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchLists();
  }, []);

  const getList = useCallback((id: string) => lists.find(list => list.id === id), [lists]);

  const addList = async (name: string) => {
    const newListPayload = {
      name,
      items: [],
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    };
    const savedList = await apiClient.post('/api/lists', newListPayload);
    setLists(prevLists => [...prevLists, savedList]);
    return savedList;
  };

  const updateList = async (updatedList: ShoppingList) => {
    const listWithTimestamp = { ...updatedList, updatedAt: new Date().toISOString() };
    await apiClient.put(`/api/lists/${updatedList.id}`, listWithTimestamp);
    setLists(prevLists =>
      prevLists.map(list => (list.id === updatedList.id ? listWithTimestamp : list))
    );
  };
  
  const deleteList = async (id: string) => {
    await apiClient.delete(`/api/lists/${id}`);
    setLists(prevLists => prevLists.filter(list => list.id !== id));
  };
  
  const addItemToListHelper = async (listId: string, newItem: ListItem) => {
      const list = getList(listId);
      if (list) {
          const updatedList = { ...list, items: [...list.items, newItem] };
          await updateList(updatedList);
      }
  };

  const addGenericItemToList = async (listId: string, itemName: string, quantity: number) => {
     const newItem: ListItem = {
            id: `item-${Date.now()}`,
            product: null,
            name: itemName,
            isGeneric: true,
            quantity,
            isChecked: false,
        };
      await addItemToListHelper(listId, newItem);
  };
  
  const addItemToList = async (listId: string, product: Product, quantity: number) => {
      const list = getList(listId);
      if (list) {
          const existingItem = list.items.find(item => !item.isGeneric && item.product?.gtin === product.gtin);
          if (existingItem) {
              await updateItemInList(listId, {...existingItem, quantity: existingItem.quantity + quantity});
          } else {
              const newItem: ListItem = {
                  id: `item-${Date.now()}`,
                  product,
                  name: product.name,
                  isGeneric: false,
                  quantity,
                  isChecked: false,
              };
              await addItemToListHelper(listId, newItem);
          }
      }
  };

  const addItemsToList = async (listId: string, newItems: { product: Product, quantity: number }[]) => {
      // This is a bulk operation, could be optimized with a dedicated backend endpoint
      const list = getList(listId);
      if (list) {
          // This is not the most efficient way, but it works for client-side logic
          for (const item of newItems) {
              await addItemToList(listId, item.product, item.quantity);
          }
      }
  };

  const updateItemInList = async (listId: string, updatedItem: ListItem) => {
    const list = getList(listId);
    if (list) {
      const updatedItems = list.items.map(item =>
        item.id === updatedItem.id ? updatedItem : item
      );
      await updateList({ ...list, items: updatedItems });
    }
  };

  const removeItemFromList = async (listId: string, itemId: string) => {
    const list = getList(listId);
    if (list) {
      const updatedItems = list.items.filter(item => item.id !== itemId);
      await updateList({ ...list, items: updatedItems });
    }
  };

  return (
    <ShoppingListContext.Provider
      value={{ lists, isLoading, addList, getList, updateList, deleteList, addItemToList, addGenericItemToList, addItemsToList, updateItemInList, removeItemFromList }}
    >
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