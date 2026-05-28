import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useLang } from '../contexts/LanguageContext';
import { useAuth } from '../contexts/AuthContext';
import { Menu, X, Globe, LogOut, Heart } from 'lucide-react';
import { useState } from 'react';

export default function Navbar() {
  const { t, lang, setLang } = useLang();
  const { user, logout } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [open, setOpen] = useState(false);

  const links = [
    { to: '/', label: t('home') },
    { to: '/nurse-register', label: t('nurse') },
    { to: '/patient-register', label: t('patient') },
    { to: '/login', label: t('login') },
  ];

  const isActive = (path: string) => location.pathname === path;

  const handleLogout = () => {
    logout();
    navigate('/');
  };

  return (
    <nav className="sticky top-0 z-50 glass shadow-md border-b border-teal-100">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex justify-between items-center h-16">
          {/* Logo */}
          <Link to="/" className="flex items-center gap-2 group">
            <div className="w-10 h-10 rounded-full hero-gradient flex items-center justify-center shadow-lg group-hover:scale-110 transition">
              <Heart className="w-5 h-5 text-white" fill="white" />
            </div>
            <div>
              <div className="text-2xl font-black bg-gradient-to-r from-teal-600 to-cyan-600 bg-clip-text text-transparent">
                {t('brand')}
              </div>
              <div className="text-[10px] text-slate-500 -mt-1 hidden sm:block">Ghaith Medical</div>
            </div>
          </Link>

          {/* Desktop Nav */}
          <div className="hidden md:flex items-center gap-1">
            {links.map(link => (
              <Link
                key={link.to}
                to={link.to}
                className={`px-4 py-2 rounded-lg text-sm font-semibold transition ${
                  isActive(link.to)
                    ? 'bg-teal-100 text-teal-700'
                    : 'text-slate-600 hover:bg-slate-100'
                }`}
              >
                {link.label}
              </Link>
            ))}

            {user && (
              <>
                <Link
                  to={user.role === 'nurse' ? '/nurse' : user.role === 'patient' ? '/patient' : '/admin'}
                  className="px-4 py-2 rounded-lg text-sm font-semibold bg-teal-600 text-white hover:bg-teal-700 transition"
                >
                  {t('mainPage')}
                </Link>
                <button
                  onClick={handleLogout}
                  className="p-2 rounded-lg text-slate-600 hover:bg-red-50 hover:text-red-600 transition"
                  title={t('logout')}
                >
                  <LogOut className="w-5 h-5" />
                </button>
              </>
            )}

            <button
              onClick={() => setLang(lang === 'ar' ? 'en' : 'ar')}
              className="px-3 py-2 rounded-lg text-sm font-semibold bg-slate-100 hover:bg-slate-200 transition flex items-center gap-1"
            >
              <Globe className="w-4 h-4" />
              {lang === 'ar' ? 'EN' : 'ع'}
            </button>
          </div>

          {/* Mobile Toggle */}
          <div className="md:hidden flex items-center gap-2">
            <button
              onClick={() => setLang(lang === 'ar' ? 'en' : 'ar')}
              className="p-2 rounded-lg bg-slate-100"
            >
              <Globe className="w-5 h-5" />
            </button>
            <button
              onClick={() => setOpen(!open)}
              className="p-2 rounded-lg hover:bg-slate-100"
            >
              {open ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
            </button>
          </div>
        </div>

        {/* Mobile Menu */}
        {open && (
          <div className="md:hidden py-4 border-t border-slate-100 space-y-1">
            {links.map(link => (
              <Link
                key={link.to}
                to={link.to}
                onClick={() => setOpen(false)}
                className={`block px-4 py-3 rounded-lg text-sm font-semibold ${
                  isActive(link.to) ? 'bg-teal-100 text-teal-700' : 'text-slate-600'
                }`}
              >
                {link.label}
              </Link>
            ))}
            {user && (
              <>
                <Link
                  to={user.role === 'nurse' ? '/nurse' : user.role === 'patient' ? '/patient' : '/admin'}
                  onClick={() => setOpen(false)}
                  className="block px-4 py-3 rounded-lg text-sm font-semibold bg-teal-600 text-white"
                >
                  {t('mainPage')}
                </Link>
                <button
                  onClick={() => { handleLogout(); setOpen(false); }}
                  className="block w-full text-start px-4 py-3 rounded-lg text-sm font-semibold text-red-600 hover:bg-red-50"
                >
                  {t('logout')}
                </button>
              </>
            )}
          </div>
        )}
      </div>
    </nav>
  );
}
