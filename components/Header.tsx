
import React from 'react';
import { ArrowLeft } from 'lucide-react';
import { useNavigate } from 'react-router-dom';

interface HeaderProps {
  title: string;
  showBackButton?: boolean;
}

const Header: React.FC<HeaderProps> = ({ title, showBackButton = false }) => {
  const navigate = useNavigate();

  return (
    <header className="sticky top-0 bg-slate-50/80 dark:bg-slate-900/80 backdrop-blur-sm z-40 p-4">
      <div className="relative flex items-center justify-center">
        {showBackButton && (
          <button onClick={() => navigate(-1)} className="absolute left-0 text-slate-600 dark:text-slate-300">
            <ArrowLeft size={24} />
          </button>
        )}
        <h1 className="text-xl font-bold text-slate-800 dark:text-slate-100">{title}</h1>
      </div>
    </header>
  );
};

export default Header;
