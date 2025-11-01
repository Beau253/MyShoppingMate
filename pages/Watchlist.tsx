import React, { useState } from 'react';
import Header from '../components/Header';
import { useWatchlist } from '../hooks/useWatchlist';
import { useStores } from '../hooks/useStores';
import { useShoppingList } from '../hooks/useShoppingList';
import { useProductData } from '../hooks/useProductData';
import ProductCard from '../components/ProductCard';
import BarcodeScanner from '../components/BarcodeScanner';
import { AugmentedSearchResult } from './Search';
import { Product } from '../types';
import { Loader2 } from 'lucide-react';

const Watchlist: React.FC = () => {
  const { watchedItems, isLoading: isWatchlistLoading } = useWatchlist();
  const { priceData, allStores, userStores } = useStores();
  const { lists, addItemToList } = useShoppingList();
  const { addBarcode } = useProductData();

  const [selectedListId, setSelectedListId] = useState<string | null>(lists.length > 0 ? lists[0].id : null);
  const [addedProductGtin, setAddedProductGtin] = useState<string | null>(null);
  const [isScannerOpen, setIsScannerOpen] = useState(false);
  const [scanningForProductId, setScanningForProductId] = useState<string | null>(null);

  const handleAddItem = async (product: Product) => {
    if (selectedListId) {
      await addItemToList(selectedListId, product, 1);
      setAddedProductGtin(product.gtin);
      setTimeout(() => setAddedProductGtin(null), 2000);
    } else {
      alert("Please create a shopping list first.");
    }
  };

  const handleScanBarcodeForProduct = (productId: string) => {
    setScanningForProductId(productId);
    setIsScannerOpen(true);
  };
  
  const handleScanSuccess = (decodedText: string) => {
    setIsScannerOpen(false);
    if (scanningForProductId) {
      addBarcode(scanningForProductId, decodedText);
      setScanningForProductId(null);
    }
  };

  const getBestPriceInfo = (gtin: string) => {
    const prices = priceData[gtin];
    if (!prices) return null;
    const availablePrices = prices.filter(p => userStores.some(us => us.id === p.storeId));
    if (availablePrices.length === 0) return null;
    const bestPrice = Math.min(...availablePrices.map(p => p.price));
    const storeId = availablePrices.find(p => p.price === bestPrice)?.storeId;
    const store = allStores.find(s => s.id === storeId);
    if (!store) return null;
    return { price: bestPrice, storeId: store.id, storeLogoUrl: store.logoUrl };
  };

  const augmentedWatchlistItems: AugmentedSearchResult[] = watchedItems.map(product => {
    const bestPriceInfo = getBestPriceInfo(product.gtin);
    return {
      product: product,
      price: bestPriceInfo?.price ?? NaN,
      storeId: bestPriceInfo?.storeId ?? '',
      storeLogoUrl: bestPriceInfo?.storeLogoUrl ?? '',
    };
  });

  return (
    <div>
      <Header title="My Watchlist" />
      {isScannerOpen && <BarcodeScanner onScanSuccess={handleScanSuccess} onClose={() => { setIsScannerOpen(false); setScanningForProductId(null); }} />}
      <div className="p-4 space-y-4">
        {isWatchlistLoading ? (
            <div className="flex justify-center items-center py-10"><Loader2 size={32} className="animate-spin text-primary-500"/></div>
        ) : watchedItems.length === 0 ? (
          <div className="text-center py-10 px-4 bg-slate-100 dark:bg-slate-800 rounded-lg">
            <p className="text-slate-500 dark:text-slate-400">You haven't watched any items yet.</p>
            <p className="text-sm text-slate-400 mt-1">Use the heart icon on the Search page to add items.</p>
          </div>
        ) : (
          <>
            {lists.length > 0 && (
              <div>
                <label htmlFor="list-select-watchlist" className="block text-sm font-medium text-slate-700 dark:text-slate-300">Add to list:</label>
                <select
                  id="list-select-watchlist" value={selectedListId ?? ''} onChange={e => setSelectedListId(e.target.value)}
                  className="mt-1 block w-full pl-3 pr-10 py-2 text-base bg-white dark:bg-slate-800 border-slate-300 dark:border-slate-600 focus:outline-none focus:ring-primary-500 focus:border-primary-500 sm:text-sm rounded-md"
                >
                  {lists.map(list => <option key={list.id} value={list.id}>{list.name}</option>)}
                </select>
              </div>
            )}
            <div className="space-y-4">
              {augmentedWatchlistItems.map(result => (
                <ProductCard
                  key={result.product.gtin} result={result}
                  onAddItem={handleAddItem} selectedListId={selectedListId}
                  addedProductGtin={addedProductGtin} onScanBarcodeForProduct={handleScanBarcodeForProduct}
                />
              ))}
            </div>
          </>
        )}
      </div>
    </div>
  );
};

export default Watchlist;
