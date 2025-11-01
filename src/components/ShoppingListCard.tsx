import React, { useState, useRef, useEffect } from 'react';
import { ShoppingList } from '../types';
import { ChevronRight, ShoppingCart, MoreVertical, Edit, Trash2, Download, Upload } from 'lucide-react';

interface ShoppingListCardProps {
  list: ShoppingList;
  onNavigate: () => void;
  onEdit: () => void;
  onDelete: () => void;
  onExport: () => void;
  onImport: () => void;
}

const ShoppingListCard: React.FC<ShoppingListCardProps> = ({ list, onNavigate, onEdit, onDelete, onExport, onImport }) => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);
  const itemCount = list.items.length;
  const checkedCount = list.items.filter(item => item.isChecked).length;

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setIsMenuOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const handleMenuAction = (action: () => void) => {
    action();
    setIsMenuOpen(false);
  };

  return (
    <div className="bg-white dark:bg-slate-800 rounded-lg shadow-md hover:shadow-lg transition-shadow duration-200 p-4 flex items-center justify-between">
      <div onClick={onNavigate} className="flex items-center flex-grow cursor-pointer min-w-0">
        <div className="p-3 bg-primary-100 dark:bg-primary-900/50 rounded-full mr-4">
            <ShoppingCart className="text-primary-600 dark:text-primary-400" size={24}/>
        </div>
        <div className="min-w-0">
          <h3 className="font-bold text-lg text-slate-800 dark:text-slate-100 truncate">{list.name}</h3>
          <p className="text-sm text-slate-500 dark:text-slate-400">
            {checkedCount} / {itemCount} items
          </p>
        </div>
      </div>
      <div className="flex items-center pl-2">
        <div onClick={onNavigate} className="cursor-pointer">
            <ChevronRight className="text-slate-400 dark:text-slate-500" />
        </div>
        <div className="relative ml-2" ref={menuRef}>
            <button 
                onClick={(e) => {
                    e.stopPropagation();
                    setIsMenuOpen(prev => !prev);
                }}
                className="p-2 rounded-full hover:bg-slate-100 dark:hover:bg-slate-700 text-slate-500 dark:text-slate-400"
                aria-label="List options"
            >
                <MoreVertical size={20} />
            </button>
            {isMenuOpen && (
                <div className="absolute right-0 top-full mt-2 w-48 bg-white dark:bg-slate-800 rounded-md shadow-lg border border-slate-200 dark:border-slate-700 z-10">
                    <ul className="py-1">
                        <li><button onClick={() => handleMenuAction(onEdit)} className="w-full text-left flex items-center px-4 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700"><Edit size={16} className="mr-2"/> Edit Name</button></li>
                        <li><button onClick={() => handleMenuAction(onImport)} className="w-full text-left flex items-center px-4 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700"><Upload size={16} className="mr-2"/> Import Items</button></li>
                        <li><button onClick={() => handleMenuAction(onExport)} className="w-full text-left flex items-center px-4 py-2 text-sm text-slate-700 dark:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700"><Download size={16} className="mr-2"/> Export as JSON</button></li>
                        <li><hr className="my-1 border-slate-200 dark:border-slate-700" /></li>
                        <li><button onClick={() => handleMenuAction(onDelete)} className="w-full text-left flex items-center px-4 py-2 text-sm text-red-600 dark:text-red-400 hover:bg-red-50 dark:hover:bg-red-900/20"><Trash2 size={16} className="mr-2"/> Delete List</button></li>
                    </ul>
                </div>
            )}
        </div>
       </div>
    </div>
  );
};

export default ShoppingListCard;