import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { useParams } from 'react-router-dom';
import Header from '../components/Header';
import { useShoppingList } from '../hooks/useShoppingList';
import { useStores } from '../hooks/useStores';
import { optimizeTrip, searchProducts } from '../services/geminiService';
import { TripPlan, ListItem, Product, ShoppingList } from '../types';
import { Loader2, Lightbulb, ShoppingBag, DollarSign, Sparkles, ChevronRight, RefreshCw } from 'lucide-react';
import { AugmentedSearchResult } from './Search';
import SwapProductModal from '../components/SwapProductModal';

type PlannerStep = 'loading-equivalents' | 'review' | 'loading-plan' | 'plan-results' | 'error';
type Selections = { [itemId: string]: Product | null };
type Alternatives = { [itemId: string]: AugmentedSearchResult[] };

const TripPlanner: React.FC = () => {
  const { listId } = useParams<{ listId: string }>();
  const { getList } = useShoppingList();
  const { priceData, userStores, addPrice } = useStores();
  const [plan, setPlan] = useState<TripPlan | null>(null);
  const [step, setStep] = useState<PlannerStep>('loading-equivalents');
  const [error, setError] = useState<string | null>(null);
  const [selections, setSelections] = useState<Selections>({});
  const [alternatives, setAlternatives] = useState<Alternatives>({});
  const [swappingItem, setSwappingItem] = useState<ListItem | null>(null);

  const list = useMemo(() => listId ? getList(listId) : undefined, [listId, getList]);

  const findAndSelectEquivalents = useCallback(async () => {
    if (!list || userStores.length === 0) {
      setError("No list or stores found.");
      setStep('error');
      return;
    }
    setStep('loading-equivalents');
    
    const genericItems = list.items.filter(item => item.isGeneric && !item.isChecked);
    const newAlternatives: Alternatives = {};
    const newSelections: Selections = {};

    await Promise.all(genericItems.map(async item => {
        const allProducts = await searchProducts(item.name, userStores);
        allProducts.forEach(p => addPrice(p.product.gtin, p.storeId, p.price));

        if (allProducts.length > 0) {
            newAlternatives[item.id] = allProducts;
            const cheapestProduct = allProducts.reduce((cheapest, current) => (current.price < cheapest.price ? current : cheapest));
            newSelections[item.id] = cheapestProduct.product;
        } else {
            newSelections[item.id] = null;
        }
    }));
    
    setAlternatives(newAlternatives);
    setSelections(newSelections);
    setStep('review');

  }, [list, userStores, addPrice]);

  useEffect(() => { findAndSelectEquivalents(); }, [findAndSelectEquivalents]);
  
  const handleGeneratePlan = async () => {
    if (!list) return;
    setStep('loading-plan');
    const finalItems = list.items.filter(i => !i.isChecked).map(item => {
        if (item.isGeneric) {
            const selectedProduct = selections[item.id];
            return selectedProduct ? { ...item, product: selectedProduct, isGeneric: false, name: selectedProduct.name } : null;
        }
        return item;
    }).filter((item): item is ListItem => item !== null && item.product !== null);
    
    const finalizedList: ShoppingList = { ...list, items: finalItems };

    try {
      const result = await optimizeTrip(finalizedList, priceData, userStores.map(s => ({id: s.id, name: s.name})));
      setPlan(result);
      if (result) {
        setStep('plan-results');
      } else {
        setError("Could not generate a trip plan. The AI service may be unavailable or returned an invalid response.");
        setStep('error');
      }
    } catch (e) {
      setError("An error occurred while creating the plan.");
      setStep('error');
    }
  };

  const handleSelectProduct = (item: ListItem, product: Product) => {
    setSelections(prev => ({ ...prev, [item.id]: product }));
    setSwappingItem(null);
  };
  
  const renderLoadingEquivalents = () => (
    <div className="flex flex-col items-center justify-center text-center py-20">
      <Loader2 size={40} className="animate-spin text-primary-500" />
      <p className="mt-4 text-lg font-semibold">Finding best value products...</p>
      <p className="text-slate-500">Searching for items that match your list.</p>
    </div>
  );

  const renderReview = () => (
    <div className="space-y-4">
        <h2 className="text-xl font-bold">Review Selections</h2>
        <p className="text-sm text-slate-500">We've selected the cheapest options. Swap them if you prefer another brand.</p>
        {list?.items.filter(i => !i.isChecked).map(item => {
            const selectedProduct = item.isGeneric ? selections[item.id] : item.product;
            const priceInfo = selectedProduct ? priceData[selectedProduct.gtin] : undefined;
            const bestPrice = priceInfo ? Math.min(...priceInfo.map(p => p.price)) : null;
            return (
                <div key={item.id} className="bg-white dark:bg-slate-800 rounded-lg shadow p-3">
                    <div className="flex items-start space-x-3">
                       {selectedProduct ? <img src={selectedProduct.imageUrl} alt={selectedProduct.name} className="w-16 h-16 object-cover rounded-md flex-shrink-0" /> : <div className="w-16 h-16 bg-slate-100 dark:bg-slate-700 rounded-md flex items-center justify-center"><ShoppingBag className="text-slate-400"/></div>}
                       <div className="flex-grow min-w-0">
                           <p className="font-semibold">{item.name}</p>
                           {item.isGeneric && selectedProduct && <p className="text-xs text-slate-500">Selected: {selectedProduct.name}</p>}
                           {bestPrice !== null && <p className="text-sm font-bold text-primary-600 mt-1">${bestPrice.toFixed(2)}</p>}
                       </div>
                       {item.isGeneric && alternatives[item.id]?.length > 1 && <button onClick={() => setSwappingItem(item)} className="flex items-center text-sm text-primary-600 font-semibold"><RefreshCw size={14} className="mr-1"/> Swap</button>}
                       {!selectedProduct && item.isGeneric && <p className="text-xs text-red-500">Not found</p>}
                    </div>
                </div>
            );
        })}
        <button onClick={handleGeneratePlan} className="w-full flex items-center justify-center py-4 px-4 bg-primary-600 text-white font-bold rounded-xl shadow-lg hover:bg-primary-700">
            Generate Optimized Plan <ChevronRight size={20} className="ml-2"/>
        </button>
    </div>
  );

  const renderLoadingPlan = () => (
    <div className="flex flex-col items-center justify-center text-center py-20">
      <Loader2 size={40} className="animate-spin text-primary-500" />
      <p className="mt-4 text-lg font-semibold">Calculating your savings...</p>
      <p className="text-slate-500">Our AI is finding the best deals for your chosen items.</p>
    </div>
  );

  const renderPlanResults = () => plan && (
    <div className="space-y-6">
      <div className="bg-primary-50 dark:bg-primary-900/30 border border-primary-200 dark:border-primary-500/30 p-4 rounded-lg text-center">
        <Sparkles className="mx-auto text-primary-500 mb-2" />
        <p className="text-2xl font-bold text-primary-700 dark:text-primary-300">Total Cost: ${plan.totalCost.toFixed(2)}</p>
        {plan.totalSavings > 0 && <p className="text-green-600 dark:text-green-400 font-semibold">You're saving ~${plan.totalSavings.toFixed(2)}!</p>}
      </div>
      <div className="bg-yellow-50 dark:bg-yellow-900/20 p-4 rounded-lg flex items-start space-x-3">
          <Lightbulb className="text-yellow-600 dark:text-yellow-400 mt-1 flex-shrink-0"/>
          <div>
              <h3 className="font-semibold text-yellow-800 dark:text-yellow-300">Pro Tip</h3>
              <p className="text-sm text-yellow-700 dark:text-yellow-400/90">{plan.notes}</p>
          </div>
      </div>
      {plan.optimizedTrip.map(storeTrip => (
        <div key={storeTrip.storeName} className="bg-white dark:bg-slate-800 rounded-lg shadow-md">
          <div className="p-4 border-b flex items-center justify-between"><div className="flex items-center"><ShoppingBag className="text-primary-500 mr-3" /><h2 className="text-xl font-bold">{storeTrip.storeName}</h2></div><div className="flex items-center text-lg font-bold text-primary-600"><DollarSign size={18} className="mr-1"/>{storeTrip.subtotal.toFixed(2)}</div></div>
          <ul className="divide-y divide-slate-100 dark:divide-slate-700">
            {storeTrip.itemsToBuy.map(item => <li key={item.itemName} className="px-4 py-3 flex justify-between items-center"><div><p className="font-medium">{item.itemName}</p><p className="text-sm text-slate-500">Qty: {item.quantity}</p></div><p className="font-semibold">${item.price.toFixed(2)}</p></li>)}
          </ul>
        </div>
      ))}
    </div>
  );

  const renderError = () => (
    <div className="text-center py-20 px-4 bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg">
      <p className="font-semibold text-red-600 dark:text-red-400">Oops! Something went wrong.</p>
      <p className="text-sm text-red-500 dark:text-red-400/80 mt-1">{error}</p>
    </div>
  );

  return (
    <div>
      <Header title="Optimized Trip Plan" showBackButton />
      <div className="p-4">
        {step === 'loading-equivalents' && renderLoadingEquivalents()}
        {step === 'review' && renderReview()}
        {step === 'loading-plan' && renderLoadingPlan()}
        {step === 'plan-results' && renderPlanResults()}
        {step === 'error' && renderError()}
      </div>
      {swappingItem && <SwapProductModal isOpen={!!swappingItem} onClose={() => setSwappingItem(null)} currentItemName={swappingItem.name} products={alternatives[swappingItem.id] || []} onSelectProduct={(product) => handleSelectProduct(swappingItem, product)} />}
    </div>
  );
};

export default TripPlanner;