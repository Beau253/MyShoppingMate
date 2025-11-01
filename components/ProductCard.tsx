import React, { useState } from 'react';
import { AugmentedSearchResult } from '../pages/Search';
import { Product } from '../types';
import { useWatchlist } from '../hooks/useWatchlist';
import { useProductData } from '../hooks/useProductData';
import { Plus, Check, DollarSign, Heart, ChevronDown, ChevronUp, Edit2, ScanBarcode } from 'lucide-react';

interface ProductCardProps {
  result: AugmentedSearchResult;
  onAddItem: (product: Product) => void;
  selectedListId: string | null;
  addedProductGtin: string | null;
  onScanBarcodeForProduct: (productId: string) => void;
}

const DetailRow: React.FC<{ label: string; value: any }> = ({ label, value }) => {
    if (value === null || value === undefined || value === '') return null;
    return (
        <div className="grid grid-cols-3 gap-2 text-xs py-1.5 border-b border-slate-200 dark:border-slate-700">
            <span className="font-semibold text-slate-500 dark:text-slate-400 col-span-1">{label}</span>
            <span className="text-slate-700 dark:text-slate-300 col-span-2 break-words">{String(value)}</span>
        </div>
    );
}

const getUnitPriceString = (result: AugmentedSearchResult): string | null => {
    const data = result.product.raw_data;
    if (!data) return null;

    switch (result.storeId) {
        case 'store-woolworths':
            return data.CupString || null;
        case 'store-coles':
            return data.pricing?.comparable || null;
        case 'store-aldi':
            return data.price?.comparisonDisplay || null;
        default:
            return null;
    }
}

const ProductCard: React.FC<ProductCardProps> = ({ result, onAddItem, selectedListId, addedProductGtin, onScanBarcodeForProduct }) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [isAddingBarcode, setIsAddingBarcode] = useState(false);
  const [newBarcode, setNewBarcode] = useState('');

  const { isWatched, addToWatchlist, removeFromWatchlist } = useWatchlist();
  const { productBarcodes, addBarcode } = useProductData();
  
  const watched = isWatched(result.product.gtin);
  const unitPrice = getUnitPriceString(result);
  const priceIsAvailable = typeof result.price === 'number' && !isNaN(result.price);
  
  const toggleWatchlist = () => {
    if (watched) {
      removeFromWatchlist(result.product.gtin);
    } else {
      addToWatchlist(result.product);
    }
  };

  const isTempGtin = result.product.gtin.startsWith('coles-') || result.product.gtin.startsWith('aldi-');
  const userBarcode = productBarcodes[result.product.gtin];

  const handleSaveBarcode = () => {
    if (newBarcode.trim()) {
        addBarcode(result.product.gtin, newBarcode.trim());
        setIsAddingBarcode(false);
        setNewBarcode('');
    }
  }

  const getDetailValue = (key: string): string | number | undefined => {
    const data = result.product.raw_data;
    if (!data) return undefined;

    switch (result.storeId) {
        case 'store-woolworths':
            if (key === 'size') return data.PackageSize;
            if (key === 'unit') return data.Unit;
            if (key === 'sku') return data.Stockcode;
            if (key === 'brand') return data.Brand;
            break;
        case 'store-coles':
            if (key === 'size') return data.size;
            if (key === 'unit') return data.pricing?.unit?.ofMeasure;
            if (key === 'sku') return data.id;
            if (key === 'brand') return data.brand;
            break;
        case 'store-aldi':
            if (key === 'size') return data.sellingSize;
            if (key === 'unit') return data.quantityUnit;
            if (key === 'sku') return data.sku;
            if (key === 'brand') return data.brandName;
            break;
    }
    return undefined;
  }


  return (
    <div className="bg-white dark:bg-slate-800 rounded-lg shadow-md overflow-hidden transition-all duration-300">
        <div className="flex" onClick={() => setIsExpanded(!isExpanded)}>
            <img
                src={result.product.imageUrl}
                alt={result.product.name}
                className="w-28 h-28 object-cover flex-shrink-0"
                onError={(e) => (e.currentTarget.src = 'https://via.placeholder.com/200')}
            />
            <div className="p-4 flex-grow flex flex-col justify-between min-w-0 relative">
                {result.storeLogoUrl && <img src={result.storeLogoUrl} alt={result.storeId} className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white p-1 shadow-md object-contain" />}
                <div>
                    <p className="text-sm text-slate-500 dark:text-slate-400 truncate">{result.product.brand}</p>
                    <h3 className="font-bold text-slate-800 dark:text-slate-100 line-clamp-2">{result.product.name}</h3>
                </div>
                <div className="flex justify-between items-center mt-2">
                    <div>
                        {priceIsAvailable ? (
                             <div className="flex items-center text-lg font-bold text-primary-600 dark:text-primary-400">
                                 <DollarSign size={16} className="mr-1" />
                                 <span>{result.price.toFixed(2)}</span>
                             </div>
                        ) : (
                             <div className="text-sm font-semibold text-slate-400 dark:text-slate-500">
                                N/A
                             </div>
                        )}
                        {unitPrice && priceIsAvailable && (
                            <p className="text-xs text-slate-500 dark:text-slate-400 mt-0.5">{unitPrice}</p>
                        )}
                    </div>
                     <button onClick={(e) => { e.stopPropagation(); toggleWatchlist(); }} className="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-700">
                        <Heart size={20} className={`transition-colors ${watched ? 'text-red-500 fill-current' : 'text-slate-400'}`} />
                    </button>
                </div>
            </div>
        </div>

        {isExpanded && (
            <div className="p-4 border-t border-slate-200 dark:border-slate-700">
                <h4 className="font-bold mb-2 text-slate-800 dark:text-slate-100">Product Details</h4>
                <div className="space-y-1">
                    <DetailRow label="Name" value={result.product.name} />
                    <DetailRow label="Brand" value={getDetailValue('brand')} />
                    <DetailRow label="Size" value={getDetailValue('size')} />
                    <DetailRow label="Unit" value={getDetailValue('unit')} />
                    <DetailRow label="SKU" value={getDetailValue('sku')} />
                    
                    <div className="grid grid-cols-3 gap-2 text-xs py-1.5 items-center">
                         <span className="font-semibold text-slate-500 dark:text-slate-400 col-span-1">Barcode</span>
                         <div className="text-slate-700 dark:text-slate-300 col-span-2">
                            { !isTempGtin ? (
                                <span className="font-mono bg-slate-100 dark:bg-slate-700 px-2 py-1 rounded">{result.product.gtin}</span>
                            ) : userBarcode ? (
                                <span className="font-mono bg-slate-100 dark:bg-slate-700 px-2 py-1 rounded">{userBarcode}</span>
                            ) : isAddingBarcode ? (
                                <div className="flex items-center space-x-2">
                                    <input 
                                        type="text" value={newBarcode} onChange={(e) => setNewBarcode(e.target.value)}
                                        onClick={e => e.stopPropagation()} placeholder="Enter or scan barcode"
                                        className="w-full text-xs bg-white dark:bg-slate-900 border-slate-300 dark:border-slate-600 rounded-md py-1 px-2"
                                    />
                                    <button 
                                       onClick={(e) => { e.stopPropagation(); onScanBarcodeForProduct(result.product.gtin); }}
                                       className="p-1.5 bg-slate-200 dark:bg-slate-600 rounded-md text-slate-600 dark:text-slate-300"
                                       aria-label="Scan barcode"
                                   >
                                       <ScanBarcode size={16}/>
                                   </button>
                                    <button onClick={(e) => {e.stopPropagation(); handleSaveBarcode()}} className="px-2 py-1 bg-primary-600 text-white rounded-md text-xs">Save</button>
                                </div>
                            ) : (
                               <button onClick={(e) => { e.stopPropagation(); setIsAddingBarcode(true); }} className="flex items-center text-xs text-primary-600 dark:text-primary-400 hover:underline">
                                  <Edit2 size={12} className="mr-1"/> Add Barcode
                               </button>
                            )}
                         </div>
                    </div>
                </div>
            </div>
        )}

        <button
            onClick={(e) => { e.stopPropagation(); onAddItem(result.product); }}
            disabled={!selectedListId || addedProductGtin === result.product.gtin}
            className="w-full flex items-center justify-center p-3 bg-primary-600 text-white font-semibold hover:bg-primary-700 disabled:bg-slate-400 dark:disabled:bg-slate-600 transition-colors"
        >
            {addedProductGtin === result.product.gtin ? <Check size={20} className="mr-2" /> : <Plus size={20} className="mr-2" />}
            {addedProductGtin === result.product.gtin ? 'Added!' : 'Add to List'}
        </button>
    </div>
  );
};

export default ProductCard;