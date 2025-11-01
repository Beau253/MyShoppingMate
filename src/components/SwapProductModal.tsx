import React from 'react';
import { AugmentedSearchResult } from '../pages/Search';
import { Product } from '../types';
import { X, DollarSign } from 'lucide-react';

interface SwapProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  currentItemName: string;
  products: AugmentedSearchResult[];
  onSelectProduct: (product: Product) => void;
}

const SwapProductModal: React.FC<SwapProductModalProps> = ({
  isOpen,
  onClose,
  currentItemName,
  products,
  onSelectProduct,
}) => {
  if (!isOpen) return null;

  const sortedProducts = [...products].sort((a, b) => a.price - b.price);

  return (
    <div
      className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4"
      onClick={onClose}
    >
      <div
        className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-xl w-full max-w-lg max-h-[90vh] flex flex-col"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="flex justify-between items-center mb-4">
          <h3 className="text-xl font-bold text-slate-800 dark:text-slate-100">
            Swap for "{currentItemName}"
          </h3>
          <button
            onClick={onClose}
            className="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-700"
          >
            <X size={24} />
          </button>
        </div>
        <div className="flex-grow overflow-y-auto space-y-3 pr-2 -mr-2">
          {sortedProducts.length > 0 ? (
            sortedProducts.map((result) => (
              <div
                key={`${result.product.gtin}-${result.storeId}`}
                className="flex items-center p-3 bg-slate-50 dark:bg-slate-800/50 rounded-lg"
              >
                <img
                  src={result.product.imageUrl}
                  alt={result.product.name}
                  className="w-16 h-16 object-cover rounded-md flex-shrink-0 mr-4"
                />
                <div className="flex-grow min-w-0">
                  <p className="text-sm font-semibold truncate text-slate-800 dark:text-slate-100">
                    {result.product.name}
                  </p>
                  <p className="text-xs text-slate-500 dark:text-slate-400">
                    {result.product.brand}
                  </p>
                   <div className="flex items-center text-sm font-bold text-primary-600 dark:text-primary-400 mt-1">
                      <DollarSign size={14} className="mr-0.5" />
                      <span>{result.price.toFixed(2)}</span>
                   </div>
                </div>
                <button
                  onClick={() => onSelectProduct(result.product)}
                  className="ml-4 px-3 py-1.5 bg-primary-600 text-white text-sm font-semibold rounded-md hover:bg-primary-700"
                >
                  Select
                </button>
              </div>
            ))
          ) : (
            <p className="text-slate-500 dark:text-slate-400 text-center py-8">
              No other options found.
            </p>
          )}
        </div>
      </div>
    </div>
  );
};

export default SwapProductModal;