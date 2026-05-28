import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useLang } from '../contexts/LanguageContext';
import { useAuth } from '../contexts/AuthContext';
import { authApi } from '../services/apiService';
import { LogIn, User, Stethoscope, Shield } from 'lucide-react';

export default function Login() {
  const { t } = useLang();
  const { login } = useAuth();
  const navigate = useNavigate();
  const [role, setRole] = useState<'nurse' | 'patient' | 'admin'>('patient');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      const res = await authApi.login(email, password, role);
      const normalizedRole = (res.user?.role || '').toLowerCase();
      if (normalizedRole !== role) {
        const roleNames: Record<string, string> = { admin: 'مدير عام', nurse: 'ممرض', patient: 'مريض' };
        throw { response: { data: { message: `هذا الحساب ليس ${roleNames[role] || role}` } } };
      }
      login(res.access, { ...res.user, role: normalizedRole });
      navigate(normalizedRole === 'nurse' ? '/nurse' : normalizedRole === 'patient' ? '/patient' : '/admin');
    } catch (err: any) {
      setError(err.response?.data?.message || err.response?.data?.detail || 'خطأ في تسجيل الدخول');
    } finally {
      setLoading(false);
    }
  };

  const roles = [
    { value: 'patient', label: t('patient'), icon: User, color: 'cyan' },
    { value: 'nurse', label: t('nurse'), icon: Stethoscope, color: 'teal' },
    { value: 'admin', label: t('generalManager'), icon: Shield, color: 'purple' },
  ] as const;

  return (
    <div className="min-h-[calc(100vh-4rem)] flex items-center justify-center p-4">
      <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full overflow-hidden fade-in">
        <div className="hero-gradient p-8 text-center text-white">
          <div className="inline-block w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mb-3">
            <LogIn className="w-8 h-8" />
          </div>
          <h1 className="text-3xl font-bold">{t('loginTitle')}</h1>
          <p className="text-white/90 text-sm mt-2">{t('loginSubtitle')}</p>
        </div>

        <form onSubmit={handleSubmit} className="p-6 space-y-4">
          {/* Role Selector */}
          <div className="grid grid-cols-3 gap-2">
            {roles.map(r => {
              const Icon = r.icon;
              return (
                <button
                  key={r.value}
                  type="button"
                  onClick={() => setRole(r.value)}
                  className={`p-3 rounded-xl border-2 transition flex flex-col items-center gap-1 ${
                    role === r.value
                      ? `border-${r.color}-500 bg-${r.color}-50 text-${r.color}-700`
                      : 'border-slate-200 text-slate-500 hover:border-slate-300'
                  }`}
                  style={role === r.value ? {
                    borderColor: '#0d9488',
                    background: '#f0fdfa',
                    color: '#0f766e',
                  } : {}}
                >
                  <Icon className="w-5 h-5" />
                  <span className="text-xs font-semibold">{r.label}</span>
                </button>
              );
            })}
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('email')}</label>
            <input
              type="email"
              required
              value={email}
              onChange={e => setEmail(e.target.value)}
              className="w-full px-4 py-3 border border-slate-300 rounded-xl focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
              placeholder="example@email.com"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('password')}</label>
            <input
              type="password"
              required
              value={password}
              onChange={e => setPassword(e.target.value)}
              className="w-full px-4 py-3 border border-slate-300 rounded-xl focus:ring-2 focus:ring-teal-500 focus:border-teal-500"
              placeholder="••••••••"
            />
          </div>

          {error && (
            <div className="p-3 bg-red-50 border border-red-200 rounded-xl text-red-700 text-sm">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg transition disabled:opacity-50"
          >
            {loading ? '...' : t('login')}
          </button>

          <div className="text-center text-sm text-slate-600">
            {t('noAccount')}{' '}
            <Link to={role === 'nurse' ? '/nurse-register' : '/patient-register'} className="text-teal-600 font-semibold hover:underline">
              {t('register')}
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
