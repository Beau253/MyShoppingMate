import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { apiClient } from '../services/apiClient';

type ProductBarcodeMap = {
  [productId: string]: string;
};

interface ProductDataContextType {
  productBarcodes: ProductBarcodeMap;
  isLoading: boolean;
  addBarcode: (productId: string, gtin: string) => Promise<void>;
  getBarcode: (productId: string) => string | undefined;
}

const ProductDataContext = createContext<ProductDataContextType | undefined>(undefined);

export const ProductDataProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [productBarcodes, setProductBarcodes] = useState<ProductBarcodeMap>({});
  const [isLoading, setIsLoading] = useState(true);
  
  useEffect(() => {
    const fetchBarcodes = async () => {
      try {
        const serverBarcodes = await apiClient.get('/api/barcodes');
        setProductBarcodes(serverBarcodes);
      } catch (error) {
        console.error("Failed to fetch product barcodes:", error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchBarcodes();
  }, []);

  const addBarcode = async (productId: string, gtin: string) => {
    const oldBarcodes = productBarcodes;
    setProductBarcodes(prev => ({ ...prev, [productId]: gtin })); // Optimistic update
    try {
        await apiClient.post('/api/barcodes', { productId, gtin });
    } catch (error) {
        console.error("Failed to save barcode:", error);
        setProductBarcodes(oldBarcodes); // Revert on error
    }
  };

  const getBarcode = (productId: string) => {
    return productBarcodes[productId];
  };

  return (
    <ProductDataContext.Provider value={{ productBarcodes, isLoading, addBarcode, getBarcode }}>
      {children}
    </ProductDataContext.Provider>
  );
};

export const useProductData = () => {
  const context = useContext(ProductDataContext);
  if (context === undefined) {
    throw new Error('useProductData must be used within a ProductDataProvider');
  }
  return context;
};