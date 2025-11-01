import React, { useState, useEffect } from 'react';
import { HashRouter, Routes, Route, Navigate } from 'react-router-dom';
import Dashboard from './pages/Dashboard';
import ListDetail from './pages/ListDetail';
import TripPlanner from './pages/TripPlanner';
import Search from './pages/Search';
import Settings from './pages/Settings';
import Watchlist from './pages/Watchlist';
import BottomNav from './components/BottomNav';


function App() {
  const [theme, setTheme] = useState(localStorage.getItem('theme') || 'light');

  useEffect(() => {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark');
      localStorage.setItem('theme', 'dark');
    } else {
      document.documentElement.classList.remove('dark');
      localStorage.setItem('theme', 'light');
    }
  }, [theme]);

  const toggleTheme = () => {
    setTheme(prevTheme => (prevTheme === 'light' ? 'dark' : 'light'));
  };

  return (
    <HashRouter>
      <div className="min-h-screen bg-slate-50 dark:bg-slate-900 text-slate-800 dark:text-slate-200 font-sans antialiased">
        <div className="container mx-auto max-w-lg h-screen flex flex-col">
          <main className="flex-grow overflow-y-auto pb-20">
            <Routes>
              <Route path="/" element={<Navigate to="/dashboard" />} />
              <Route path="/dashboard" element={<Dashboard />} />
              <Route path="/list/:listId" element={<ListDetail />} />
              <Route path="/list/:listId/planner" element={<TripPlanner />} />
              <Route path="/search" element={<Search />} />
              <Route path="/watchlist" element={<Watchlist />} />
              <Route path="/settings" element={<Settings theme={theme} toggleTheme={toggleTheme} />} />
            </Routes>
          </main>
          <BottomNav />
        </div>
      </div>
    </HashRouter>
  );
}

export default App;