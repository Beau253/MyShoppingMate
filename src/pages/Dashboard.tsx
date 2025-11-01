import React, { useState, useRef } from 'react';
import { useNavigate } from 'react-router-dom';
import { useShoppingList } from '../hooks/useShoppingList';
import Header from '../components/Header';
import ShoppingListCard from '../components/ShoppingListCard';
import { Plus, FileText, FileSpreadsheet, FileType, Loader2 } from 'lucide-react';
import { ShoppingList } from '../types';
import { jsPDF } from 'jspdf';


const Dashboard: React.FC = () => {
  const { lists, addList, updateList, deleteList, addItemsToList, isLoading } = useShoppingList();
  const navigate = useNavigate();
  const [newListName, setNewListName] = useState('');
  const [isAdding, setIsAdding] = useState(false);

  const [editingList, setEditingList] = useState<ShoppingList | null>(null);
  const [importingList, setImportingList] = useState<ShoppingList | null>(null);
  const [exportingList, setExportingList] = useState<ShoppingList | null>(null);
  const [editedName, setEditedName] = useState('');
  const fileInputRef = useRef<HTMLInputElement>(null);

  const handleAddList = async (e: React.FormEvent) => {
    e.preventDefault();
    if (newListName.trim()) {
      const newList = await addList(newListName.trim());
      setNewListName('');
      setIsAdding(false);
      navigate(`/list/${newList.id}`);
    }
  };
  
  const handleOpenEditModal = (list: ShoppingList) => {
    setEditingList(list);
    setEditedName(list.name);
  };

  const handleEditSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (editingList && editedName.trim()) {
      await updateList({ ...editingList, name: editedName.trim() });
    }
    setEditingList(null);
    setEditedName('');
  };

  const handleDelete = async (listId: string) => {
    if (window.confirm("Are you sure you want to delete this list? This action cannot be undone.")) {
      await deleteList(listId);
    }
  };

  const handlePerformExport = async (list: ShoppingList, format: 'pdf' | 'csv' | 'txt' | 'json') => {
    const cleanListName = list.name.replace(/[^a-z0-9]/gi, '_').toLowerCase();
    let blob: Blob;
    let fileName: string;
    let mimeType: string;

    const itemsToExport = list.items.map(item => ({
        name: item.product?.name || item.name,
        brand: item.product?.brand || 'N/A',
        quantity: item.quantity,
        checked: item.isChecked
    }));
    
    if (format === 'csv') {
        const header = "Checked,Product Name,Brand,Quantity\n";
        const csvContent = itemsToExport.map(i => `${i.checked},"${i.name}","${i.brand}",${i.quantity}`).join('\n');
        blob = new Blob([header + csvContent], { type: 'text/csv;charset=utf-8;' });
        fileName = `${cleanListName}_list.csv`;
        mimeType = 'text/csv';
    } else if (format === 'txt') {
        const textContent = `${list.name}\n\n` + itemsToExport.map(i => `${i.checked ? '[x]' : '[ ]'} ${i.name} (${i.brand}) - Qty: ${i.quantity}`).join('\n');
        blob = new Blob([textContent], { type: 'text/plain;charset=utf-8;' });
        fileName = `${cleanListName}_list.txt`;
        mimeType = 'text/plain';
    } else if (format === 'pdf') {
        const doc = new jsPDF();
        doc.setFontSize(18);
        doc.text(list.name, 14, 22);
        doc.setFontSize(11);
        let y = 35;
        itemsToExport.forEach(item => {
            if (y > 280) { doc.addPage(); y = 20; }
            doc.text(`${item.checked ? '[x]' : '[ ]'} ${item.name} (${item.brand}) - Qty: ${item.quantity}`, 14, y);
            y += 8;
        });
        blob = doc.output('blob');
        fileName = `${cleanListName}_list.pdf`;
        mimeType = 'application/pdf';
    } else { // JSON
         blob = new Blob([JSON.stringify(list.items.filter(item => !item.isGeneric).map(item => ({product: item.product, quantity: item.quantity})), null, 2)], { type: 'application/json' });
         fileName = `${cleanListName}_list.json`;
         mimeType = 'application/json';
    }

    const file = new File([blob], fileName, { type: mimeType });

    if (navigator.share && navigator.canShare && navigator.canShare({ files: [file] })) {
        try {
            await navigator.share({ title: `Shopping List: ${list.name}`, files: [file] });
        } catch (error) {
            console.error('Sharing failed:', error);
        }
    } else {
        const link = document.createElement('a');
        link.href = URL.createObjectURL(blob);
        link.download = fileName;
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        URL.revokeObjectURL(link.href);
    }
    setExportingList(null);
  };

  const handleOpenImportModal = (list: ShoppingList) => {
    setImportingList(list);
  };

  const handleImportFileChange = async (e: React.ChangeEvent<HTMLInputElement>) => {
    if (!e.target.files || !importingList) return;
    const file = e.target.files[0];
    if (file && file.type === 'application/json') {
      const reader = new FileReader();
      reader.onload = async (event) => {
          try {
              const content = event.target?.result as string;
              const itemsToImport = JSON.parse(content);
              if (!Array.isArray(itemsToImport)) throw new Error("Invalid format.");
              await addItemsToList(importingList.id, itemsToImport);
              alert(`${itemsToImport.length} items imported successfully!`);
          } catch (error) {
              alert(`Error importing file: ${error instanceof Error ? error.message : 'Unknown error'}`);
          } finally {
              setImportingList(null);
          }
      };
      reader.readAsText(file);
    } else {
        alert('Please select a valid JSON file.');
    }
    e.target.value = '';
  };


  return (
    <>
      <div className="h-full">
        <Header title="My Shopping Mate" />
        <div className="p-4 space-y-6">
          <div>
            <h2 className="text-2xl font-bold text-slate-800 dark:text-slate-100">Your Lists</h2>
            <p className="text-slate-500 dark:text-slate-400">Select a list to start shopping or create a new one.</p>
          </div>

          {isLoading ? (
            <div className="flex justify-center items-center py-10">
                <Loader2 size={32} className="animate-spin text-primary-500"/>
            </div>
          ) : lists.length > 0 ? (
            <div className="space-y-4">
              {lists.map(list => (
                  <ShoppingListCard 
                    key={list.id} 
                    list={list} 
                    onNavigate={() => navigate(`/list/${list.id}`)}
                    onEdit={() => handleOpenEditModal(list)}
                    onDelete={() => handleDelete(list.id)}
                    onExport={() => setExportingList(list)}
                    onImport={() => handleOpenImportModal(list)}
                  />
              ))}
            </div>
          ) : (
            <div className="text-center py-10 px-4 bg-slate-100 dark:bg-slate-800 rounded-lg">
              <p className="text-slate-500 dark:text-slate-400">No lists yet. Create your first one!</p>
            </div>
          )}

          {isAdding ? (
            <form onSubmit={handleAddList} className="bg-white dark:bg-slate-800 p-4 rounded-lg shadow-md space-y-2">
              <input type="text" value={newListName} onChange={(e) => setNewListName(e.target.value)} placeholder="New list name..." className="w-full bg-slate-100 dark:bg-slate-700 border-transparent focus:ring-primary-500 focus:border-primary-500 rounded-md" autoFocus />
              <div className="flex justify-end space-x-2">
                <button type="button" onClick={() => setIsAdding(false)} className="px-4 py-2 rounded-md text-sm font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700">Cancel</button>
                <button type="submit" className="px-4 py-2 rounded-md text-sm font-medium text-white bg-primary-600 hover:bg-primary-700">Create</button>
              </div>
            </form>
          ) : (
            <button onClick={() => setIsAdding(true)} className="w-full flex items-center justify-center py-3 px-4 bg-primary-600 text-white font-semibold rounded-lg shadow-md hover:bg-primary-700 transition-colors duration-200">
              <Plus size={20} className="mr-2" /> Create New List
            </button>
          )}
        </div>
      </div>
      
      {editingList && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setEditingList(null)}>
          <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-xl w-full max-w-sm" onClick={e => e.stopPropagation()}>
            <h3 className="text-lg font-bold mb-4 text-slate-800 dark:text-slate-100">Edit List Name</h3>
            <form onSubmit={handleEditSubmit}>
              <input type="text" value={editedName} onChange={(e) => setEditedName(e.target.value)} className="w-full bg-slate-100 dark:bg-slate-700 border-transparent focus:ring-primary-500 focus:border-primary-500 rounded-md" autoFocus />
              <div className="flex justify-end space-x-2 mt-4">
                <button type="button" onClick={() => setEditingList(null)} className="px-4 py-2 rounded-md text-sm font-medium text-slate-600 dark:text-slate-300 hover:bg-slate-100 dark:hover:bg-slate-700">Cancel</button>
                <button type="submit" className="px-4 py-2 rounded-md text-sm font-medium text-white bg-primary-600 hover:bg-primary-700">Save</button>
              </div>
            </form>
          </div>
        </div>
      )}

      {importingList && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setImportingList(null)}>
              <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-xl w-full max-w-sm text-center" onClick={e => e.stopPropagation()}>
                  <h3 className="text-lg font-bold mb-2">Import Items</h3>
                  <p className="text-sm text-slate-500 mb-4">Import into "<strong>{importingList.name}</strong>" from a JSON file.</p>
                  <input type="file" accept=".json" ref={fileInputRef} onChange={handleImportFileChange} className="hidden" />
                  <button onClick={() => fileInputRef.current?.click()} className="w-full px-4 py-2 rounded-md font-medium text-white bg-primary-600 hover:bg-primary-700 mb-2">Select JSON File</button>
                  <button type="button" onClick={() => setImportingList(null)} className="w-full px-4 py-2 rounded-md text-sm font-medium text-slate-600 hover:bg-slate-100">Cancel</button>
              </div>
          </div>
      )}

       {exportingList && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4" onClick={() => setExportingList(null)}>
              <div className="bg-white dark:bg-slate-800 p-6 rounded-lg shadow-xl w-full max-w-sm" onClick={e => e.stopPropagation()}>
                  <h3 className="text-lg font-bold mb-4">Export List: {exportingList.name}</h3>
                  <div className="space-y-3">
                    <button onClick={() => handlePerformExport(exportingList, 'pdf')} className="w-full flex items-center text-left p-3 rounded-md font-medium bg-slate-100 hover:bg-slate-200"><FileType size={20} className="mr-3 text-red-500"/> Export as PDF</button>
                    <button onClick={() => handlePerformExport(exportingList, 'csv')} className="w-full flex items-center text-left p-3 rounded-md font-medium bg-slate-100 hover:bg-slate-200"><FileSpreadsheet size={20} className="mr-3 text-green-500"/> Export as CSV</button>
                    <button onClick={() => handlePerformExport(exportingList, 'txt')} className="w-full flex items-center text-left p-3 rounded-md font-medium bg-slate-100 hover:bg-slate-200"><FileText size={20} className="mr-3 text-blue-500"/> Export as Text</button>
                    <button onClick={() => handlePerformExport(exportingList, 'json')} className="w-full flex items-center text-left p-3 rounded-md font-medium bg-slate-100 hover:bg-slate-200"><FileText size={20} className="mr-3 text-yellow-500"/> Export as JSON</button>
                  </div>
                  <button type="button" onClick={() => setExportingList(null)} className="w-full px-4 py-2 rounded-md text-sm font-medium mt-4 hover:bg-slate-100">Cancel</button>
              </div>
          </div>
      )}
    </>
  );
};

export default Dashboard;