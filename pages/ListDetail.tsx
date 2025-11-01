import React, { useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { useShoppingList } from '../hooks/useShoppingList';
import Header from '../components/Header';
import { ListItem } from '../types';
import { Trash2, Plus, Minus, Map } from 'lucide-react';
import { useStores } from '../hooks/useStores';

const ListDetail: React.FC = () => {
  const { listId } = useParams<{ listId: string }>();
  const { getList, updateItemInList, removeItemFromList, addGenericItemToList } = useShoppingList();
  const { priceData, userStores } = useStores();
  const navigate = useNavigate();
  const [quickAddItemName, setQuickAddItemName] = useState('');

  if (!listId) {
    return <div>List not found</div>;
  }

  const list = getList(listId);

  if (!list) {
    // Could add a loading state here from useShoppingList
    return <div>List not found or is loading...</div>;
  }

  const handleQuickAdd = async (e: React.FormEvent) => {
    e.preventDefault();
    if (quickAddItemName.trim() && listId) {
        await addGenericItemToList(listId, quickAddItemName.trim(), 1);
        setQuickAddItemName('');
    }
  };
  
  const handleItemCheck = (item: ListItem) => {
    updateItemInList(listId, { ...item, isChecked: !item.isChecked });
  };

  const handleQuantityChange = (item: ListItem, delta: number) => {
    const newQuantity = Math.max(1, item.quantity + delta);
    updateItemInList(listId, { ...item, quantity: newQuantity });
  };

  const getBestPrice = (item: ListItem) => {
    if (item.isGeneric || !item.product) return null;
    const prices = priceData[item.product.gtin];
    if (!prices) return null;
    const availablePrices = prices.filter(p => userStores.some(us => us.id === p.storeId));
    if (availablePrices.length === 0) return null;
    return Math.min(...availablePrices.map(p => p.price));
  };
  
  const uncheckedItems = list.items.filter(item => !item.isChecked);
  const checkedItems = list.items.filter(item => item.isChecked);

  return (
    <div className="flex flex-col h-full">
      <Header title={list.name} showBackButton />
      <div className="p-4 space-y-4">
        <form onSubmit={handleQuickAdd} className="flex items-center space-x-2">
            <input 
                type="text"
                value={quickAddItemName}
                onChange={(e) => setQuickAddItemName(e.target.value)}
                placeholder="Quick add an item (e.g., 'bread')"
                className="w-full bg-white dark:bg-slate-800 border-slate-300 dark:border-slate-600 rounded-md shadow-sm focus:ring-primary-500 focus:border-primary-500"
            />
            <button type="submit" className="p-2.5 bg-primary-600 text-white rounded-md shadow-sm hover:bg-primary-700 disabled:bg-slate-400" disabled={!quickAddItemName.trim()}>
                <Plus size={20}/>
            </button>
        </form>

        {list.items.length === 0 ? (
          <div className="text-center py-10 px-4 bg-slate-100 dark:bg-slate-800 rounded-lg">
            <p className="text-slate-500 dark:text-slate-400">This list is empty. Add items from the Search tab or use the Quick Add above.</p>
          </div>
        ) : (
          <>
            <div className="space-y-3">
              {uncheckedItems.map(item => (
                <div key={item.id} className="bg-white dark:bg-slate-800 rounded-lg shadow p-3 flex items-start space-x-3">
                  <input
                    type="checkbox"
                    checked={item.isChecked}
                    onChange={() => handleItemCheck(item)}
                    className="mt-1 h-5 w-5 rounded border-slate-300 text-primary-600 focus:ring-primary-500"
                  />
                  <div className="flex-grow">
                    <span className="font-medium text-slate-800 dark:text-slate-100">{item.name}</span>
                    {item.isGeneric && <span className="ml-2 text-xs bg-slate-200 dark:bg-slate-700 text-slate-600 dark:text-slate-300 px-2 py-0.5 rounded-full">Generic</span>}
                    <div className="flex items-center justify-between mt-2">
                        <div className="flex items-center space-x-2">
                            <button onClick={() => handleQuantityChange(item, -1)} className="p-1 rounded-full bg-slate-200 dark:bg-slate-700"><Minus size={14} /></button>
                            <span>{item.quantity}</span>
                            <button onClick={() => handleQuantityChange(item, 1)} className="p-1 rounded-full bg-slate-200 dark:bg-slate-700"><Plus size={14} /></button>
                        </div>
                        <span className="text-sm font-semibold text-primary-600 dark:text-primary-400">
                            {getBestPrice(item) ? `$${getBestPrice(item)?.toFixed(2)}` : 'N/A'}
                        </span>
                    </div>
                  </div>
                  <button onClick={() => removeItemFromList(listId, item.id)} className="text-slate-400 hover:text-red-500">
                    <Trash2 size={20} />
                  </button>
                </div>
              ))}
            </div>
             {checkedItems.length > 0 && (
              <div>
                <h3 className="text-sm font-semibold text-slate-500 dark:text-slate-400 my-4 border-b border-slate-200 dark:border-slate-700 pb-2">Completed ({checkedItems.length})</h3>
                <div className="space-y-3">
                  {checkedItems.map(item => (
                    <div key={item.id} className="bg-white dark:bg-slate-800/50 rounded-lg p-3 flex items-center space-x-3 opacity-60">
                      <input type="checkbox" checked={item.isChecked} onChange={() => handleItemCheck(item)} className="h-5 w-5 rounded border-slate-300 text-primary-600 focus:ring-primary-500"/>
                      <span className="flex-grow line-through text-slate-500 dark:text-slate-400">{item.name}</span>
                      <button onClick={() => removeItemFromList(listId, item.id)} className="text-slate-400 hover:text-red-500"><Trash2 size={20} /></button>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </>
        )}
      </div>
      {uncheckedItems.length > 0 && (
         <div className="sticky bottom-20 p-4 bg-transparent">
             <button
               onClick={() => navigate(`/list/${listId}/planner`)}
               className="w-full flex items-center justify-center py-4 px-4 bg-primary-600 text-white font-bold rounded-xl shadow-lg hover:bg-primary-700 transition-all duration-200 transform hover:scale-105"
             >
               <Map size={22} className="mr-2" />
               Plan My Shopping Trip
             </button>
         </div>
      )}
    </div>
  );
};

export default ListDetail;
