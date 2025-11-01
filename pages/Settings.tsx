import React, { useState, useMemo, useRef, useEffect } from 'react';
import Header from '../components/Header';
import { useStores } from '../hooks/useStores';
import { Sun, Moon, X, Search, Loader2 } from 'lucide-react';
import { Store } from '../types';

interface SettingsProps {
    theme: string;
    toggleTheme: () => void;
}

const Settings: React.FC<SettingsProps> = ({ theme, toggleTheme }) => {
  const { allStores, userStores, addUserStore, removeUserStore, isLoading } = useStores();
  const [searchQuery, setSearchQuery] = useState('');
  const userStoreIds = useMemo(() => new Set(userStores.map(s => s.id)), [userStores]);
  const searchContainerRef = useRef<HTMLDivElement>(null);
  const [isSearchFocused, setIsSearchFocused] = useState(false);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (searchContainerRef.current && !searchContainerRef.current.contains(event.target as Node)) {
        setIsSearchFocused(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const suggestions = useMemo(() => {
    if (!searchQuery) return [];
    return allStores.filter(store =>
      !userStoreIds.has(store.id) &&
      store.name.toLowerCase().includes(searchQuery.toLowerCase())
    );
  }, [searchQuery, allStores, userStoreIds]);

  const handleAddStore = (store: Store) => {
    addUserStore(store.id);
    setSearchQuery('');
    setIsSearchFocused(false);
  };

  return (
    <div>
      <Header title="Settings" />
      <div className="p-4 space-y-8">
        
        <div className="bg-white dark:bg-slate-800 p-4 rounded-lg shadow-sm">
          <h2 className="text-lg font-semibold mb-3 text-slate-800 dark:text-slate-100">Appearance</h2>
          <div className="flex items-center justify-between">
            <span className="text-slate-600 dark:text-slate-300">Theme</span>
            <button onClick={toggleTheme} className="flex items-center space-x-2 px-3 py-1 bg-slate-100 dark:bg-slate-700 rounded-full">
              <Sun size={16} className={`${theme === 'light' ? 'text-primary-500' : 'text-slate-400'}`} />
              <div className="relative w-10 h-5 bg-slate-200 dark:bg-slate-600 rounded-full">
                  <div className={`absolute top-0.5 left-0.5 w-4 h-4 bg-white rounded-full transition-transform duration-300 ${theme === 'dark' ? 'translate-x-5' : ''}`}></div>
              </div>
              <Moon size={16} className={`${theme === 'dark' ? 'text-primary-500' : 'text-slate-400'}`} />
            </button>
          </div>
        </div>

        <div className="bg-white dark:bg-slate-800 p-4 rounded-lg shadow-sm">
          <h2 className="text-lg font-semibold mb-1 text-slate-800 dark:text-slate-100">My Stores</h2>
          <p className="text-sm text-slate-500 dark:text-slate-400 mb-4">Search and add the stores you shop at for personalized price comparisons.</p>
          
          {isLoading ? (
             <div className="flex justify-center items-center py-4"><Loader2 size={24} className="animate-spin text-primary-500"/></div>
          ) : (
            <div className="flex flex-wrap gap-2 mb-4">
                {userStores.length > 0 ? userStores.map(store => (
                <div key={store.id} className="flex items-center bg-primary-100 dark:bg-primary-900/50 text-primary-700 dark:text-primary-300 text-sm font-medium px-3 py-1 rounded-full">
                    <img src={store.logoUrl} alt={store.name} className="w-5 h-5 rounded-full mr-2" />
                    <span>{store.name}</span>
                    <button onClick={() => removeUserStore(store.id)} className="ml-2 text-primary-500 hover:text-primary-700 dark:hover:text-primary-200"><X size={14} /></button>
                </div>
                )) : <p className="text-sm text-slate-400 italic">No stores selected. Add one below.</p>}
            </div>
          )}

          <div className="relative" ref={searchContainerRef}>
             <div className="relative">
                <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={18}/>
                <input
                    type="text" value={searchQuery} onChange={(e) => setSearchQuery(e.target.value)} onFocus={() => setIsSearchFocused(true)}
                    placeholder="Add a store..."
                    className="w-full pl-10 pr-4 py-2 bg-slate-100 dark:bg-slate-700 border-transparent focus:ring-primary-500 focus:border-primary-500 rounded-md"
                />
             </div>
             {isSearchFocused && searchQuery && (
                <div className="absolute top-full mt-1 w-full bg-white dark:bg-slate-800 border border-slate-200 dark:border-slate-700 rounded-md shadow-lg z-10 max-h-48 overflow-y-auto">
                    {suggestions.length > 0 ? (
                        <ul>
                            {suggestions.map(store => (
                                <li key={store.id}>
                                    <button onClick={() => handleAddStore(store)} className="w-full text-left flex items-center px-4 py-2 text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700">
                                      <img src={store.logoUrl} alt={store.name} className="w-6 h-6 rounded-full mr-3" />
                                      {store.name}
                                    </button>
                                </li>
                            ))}
                        </ul>
                    ) : (
                        <p className="p-4 text-sm text-slate-500 dark:text-slate-400">No matching stores found.</p>
                    )}
                </div>
             )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Settings;
