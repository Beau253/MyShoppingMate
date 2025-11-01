import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import { StoreProvider } from './hooks/useStores';
import { ShoppingListProvider } from '../hooks/useShoppingList';
import { WatchlistProvider } from '../hooks/useWatchlist';
import { ProductDataProvider } from '../hooks/useProductData';

const rootElement = document.getElementById('root');
if (!rootElement) {
  throw new Error("Could not find root element to mount to");
}

const root = ReactDOM.createRoot(rootElement);
root.render(
  <React.StrictMode>
    <StoreProvider>
      <ShoppingListProvider>
        <WatchlistProvider>
          <ProductDataProvider>
            <App />
          </ProductDataProvider>
        </WatchlistProvider>
      </ShoppingListProvider>
    </StoreProvider>
  </React.StrictMode>
);