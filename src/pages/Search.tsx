import React, { useState, useMemo, useRef } from 'react';
import { useShoppingList } from '../hooks/useShoppingList';
import Header from '../components/Header';
import { searchProducts } from '../services/geminiService';
import { Product } from '../types';
import { useStores } from '../hooks/useStores';
import { useProductData } from '../hooks/useProductData';
import { Search as SearchIcon, X, Loader2, ScanBarcode } from 'lucide-react';
import BarcodeScanner from '../components/BarcodeScanner';
import ProductCard from '../components/ProductCard';

type SortOption = 'relevance' | 'alpha' | 'price_asc' | 'price_desc';

export interface AugmentedSearchResult {
  product: Product;
  price: number;
  storeId: string;
  storeLogoUrl: string;
}

const Search: React.FC = () => {
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<AugmentedSearchResult[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [addedProductGtin, setAddedProductGtin] = useState<string | null>(null);
  const [sortOption, setSortOption] = useState<SortOption>('relevance');
  const [isScannerOpen, setIsScannerOpen] = useState(false);
  const [scanningForProductId, setScanningForProductId] = useState<string | null>(null);
  const formRef = useRef<HTMLFormElement>(null);

  const { lists, addItemToList } = useShoppingList();
  const { userStores, addPrice } = useStores();
  // Initialize with the first list's ID if available, or an empty string to avoid uncontrolled component warnings.
  const [selectedListId, setSelectedListId] = useState<string>(lists.length > 0 ? lists[0].id : '');
  const { addBarcode } = useProductData();

  const sortedResults = useMemo(() => {
    if (sortOption === 'relevance') return results;
    const sortable = [...results];
    switch (sortOption) {
      case 'alpha': return sortable.sort((a, b) => a.product.name.localeCompare(b.product.name));
      case 'price_asc': return sortable.sort((a, b) => a.price - b.price);
      case 'price_desc': return sortable.sort((a, b) => b.price - a.price);
      default: return results;
    }
  }, [results, sortOption]);

  const handleSearch = async (e?: React.FormEvent) => {
    e?.preventDefault();
    if (!query.trim() || userStores.length === 0) return;

    setIsLoading(true);
    setError(null);
    setResults([]);
    try {
      const allProducts = await searchProducts(query, userStores);
      if (allProducts.length > 0) {
        setResults(allProducts);
        // Populate price data
        allProducts.forEach(p => addPrice(p.product.gtin, p.storeId, p.price));
      } else {
        setError("Could not find any products. Try a different search.");
      }
    } catch (err) {
      setError("An error occurred while searching.");
    } finally {
      setIsLoading(false);
    }
  };

  const handleScanSuccess = (decodedText: string) => {
    setIsScannerOpen(false);
    if (scanningForProductId) {
      addBarcode(scanningForProductId, decodedText);
      setScanningForProductId(null);
    } else {
      setQuery(decodedText);
      // Use requestSubmit on the form ref to ensure the state update is processed before submission.
      // This is more reliable than a timeout.
      formRef.current?.requestSubmit();
    }
  };
  
  return (
    <div>
      <Header title="Search Products" />
      <div className="p-4 space-y-4">
        <form ref={formRef} onSubmit={handleSearch} className="flex items-center space-x-2">
          <div className="relative flex-grow">
            <input
              type="text" value={query} onChange={(e) => setQuery(e.target.value)}
              placeholder="e.g., 'Organic whole milk'"
              className="w-full pl-10 pr-4 py-3 bg-white dark:bg-slate-800 border-slate-300 dark:border-slate-600 rounded-full focus:ring-primary-500 focus:border-primary-500"
            />
            <SearchIcon className="absolute left-3 top-1/2 -translate-y-1/2 text-slate-400" size={20} />
            {query && <button type="button" onClick={() => { setQuery(''); setResults([]); setError(null); }} className="absolute right-3 top-1/2 -translate-y-1/2"><X size={20} className="text-slate-400" /></button>}
          </div>
          <button type="button" onClick={() => setIsScannerOpen(true)} className="p-3 bg-white dark:bg-slate-800 border border-slate-300 dark:border-slate-600 rounded-full text-slate-500 dark:text-slate-400 hover:bg-slate-100 dark:hover:bg-slate-700" aria-label="Scan barcode">
            <ScanBarcode size={20} />
          </button>
        </form>

        {isScannerOpen && <BarcodeScanner onScanSuccess={handleScanSuccess} onClose={() => { setIsScannerOpen(false); setScanningForProductId(null); }} />}

        {userStores.length === 0 && (
          <div className="text-center py-4 px-4 bg-yellow-50 dark:bg-yellow-900/20 rounded-lg">
            <p className="text-sm text-yellow-800 dark:text-yellow-300">Add a store in settings to enable live product search</p>
          </div>
        )}

        {isLoading && <div className="flex justify-center items-center py-10"><Loader2 size={32} className="animate-spin text-primary-500" /><p className="ml-4 text-slate-500 dark:text-slate-400">Searching...</p></div>}
        {error && <p className="text-center text-red-500">{error}</p>}

        {results.length > 0 && (
          <div className="space-y-4">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label htmlFor="list-select" className="block text-sm font-medium text-slate-700 dark:text-slate-300">Add to list:</label>
                <select id="list-select" value={selectedListId} onChange={e => setSelectedListId(e.target.value)} className="mt-1 block w-full pl-3 pr-10 py-2 text-base bg-white dark:bg-slate-800 border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md">
                  <option value="" disabled>Select a list</option>
                  {lists.map(list => <option key={list.id} value={list.id}>{list.name}</option>)}
                </select>
              </div>
               <div>
                <label htmlFor="sort-select" className="block text-sm font-medium text-slate-700 dark:text-slate-300">Sort by:</label>
                <select id="sort-select" value={sortOption} onChange={e => setSortOption(e.target.value as SortOption)} className="mt-1 block w-full pl-3 pr-10 py-2 text-base bg-white dark:bg-slate-800 border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md">
                    <option value="relevance">Relevance</option>
                    <option value="alpha">Name (A-Z)</option>
                    <option value="price_asc">Price: Low to High</option>
                    <option value="price_desc">Price: High to Low</option>
                </select>
             </div>
            </div>
            {sortedResults.map(result => (
              <ProductCard
                key={`${result.product.gtin}-${result.storeId}`} result={result}
                onAddItem={(product) => {
                    if (selectedListId) {
                      addItemToList(selectedListId, product, 1);
                      setAddedProductGtin(product.gtin);
                      setTimeout(() => setAddedProductGtin(null), 2000);
                    } else { alert("Please select a list first."); }
                }}
                selectedListId={selectedListId} addedProductGtin={addedProductGtin}
                onScanBarcodeForProduct={(productId) => { setScanningForProductId(productId); setIsScannerOpen(true); }}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  );
};

export default Search;