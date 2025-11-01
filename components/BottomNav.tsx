
import React from 'react';
import { NavLink } from 'react-router-dom';
import { Home, Search, Settings, Heart } from 'lucide-react';

const NavItem: React.FC<{ to: string; icon: React.ReactNode; label: string }> = ({ to, icon, label }) => {
  const activeClass = 'text-primary-500';
  const inactiveClass = 'text-slate-500 dark:text-slate-400';

  return (
    <NavLink
      to={to}
      className={({ isActive }) =>
        `flex flex-col items-center justify-center w-full pt-2 pb-1 transition-colors duration-200 ${isActive ? activeClass : inactiveClass}`
      }
    >
      {icon}
      <span className="text-xs mt-1">{label}</span>
    </NavLink>
  );
};

const BottomNav: React.FC = () => {
  return (
    <footer className="fixed bottom-0 left-0 right-0 h-16 bg-white dark:bg-slate-800 border-t border-slate-200 dark:border-slate-700 z-50 max-w-lg mx-auto">
      <div className="flex justify-around items-center h-full">
        <NavItem to="/dashboard" icon={<Home size={24} />} label="Home" />
        <NavItem to="/search" icon={<Search size={24} />} label="Search" />
        <NavItem to="/watchlist" icon={<Heart size={24} />} label="Watchlist" />
        <NavItem to="/settings" icon={<Settings size={24} />} label="Settings" />
      </div>
    </footer>
  );
};

export default BottomNav;
