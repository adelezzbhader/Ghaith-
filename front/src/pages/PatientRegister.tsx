import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useLang } from '../contexts/LanguageContext';
import { useAuth } from '../contexts/AuthContext';
import { authApi } from '../services/apiService';
import { UserRound, AlertTriangle } from 'lucide-react';

export default function PatientRegister() {
  const { t } = useLang();
  const { login } = useAuth();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    fullName: '',
    phone: '',
    email: '',
    address: '',
    gender: '',
    password: '',
    confirmPassword: '',
  });
  const [showDisclaimer, setShowDisclaimer] = useState(false);
  const [agreed, setAgreed] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(false);

  const validate = () => {
    const e: Record<string, string> = {};
    if (!/^[A-Za-z\u0600-\u06FF\s]{3,}$/.test(form.fullName)) e.fullName = t('nameLettersOnly');
    if (!/^(010|011|012|015)\d{8}$/.test(form.phone)) e.phone = t('phoneEgyptian');
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(form.email)) e.email = t('invalidEmail');
    if (!form.address) e.address = t('required');
    if (!form.gender) e.gender = t('required');
    if (form.password.length < 8 || !/[A-Za-z]{2,}/.test(form.password) || !/[^A-Za-z0-9]/.test(form.password))
      e.password = t('passwordMin');
    if (form.password !== form.confirmPassword) e.confirmPassword = t('passwordMismatch');
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;
    setShowDisclaimer(true);
  };

  const handleFinalRegister = async () => {
    if (!agreed) return;
    setLoading(true);
    try {
      const res = await authApi.registerPatient(form);
      login(res.access, { ...res.user, role: 'patient' });
      navigate('/patient');
    } catch (err: any) {
      const d = err?.response?.data;
      const fields = d?.data && typeof d.data === 'object' ? Object.values(d.data).flat().join(' • ') : null;
      const msg = fields || d?.message || d?.detail || 'حدث خطأ في التسجيل';
      toast.error(msg);
    } finally {
      setLoading(false);
    }
  };

  const inputCls = (name: string) =>
    `w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-teal-500 focus:border-teal-500 ${
      errors[name] ? 'border-red-400 bg-red-50' : 'border-slate-300'
    }`;

  return (
    <div className="max-w-2xl mx-auto p-4 py-8">
      <div className="bg-white rounded-3xl shadow-2xl overflow-hidden fade-in">
        <div className="hero-gradient p-8 text-white text-center">
          <div className="inline-block w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mb-3">
            <UserRound className="w-8 h-8" />
          </div>
          <h1 className="text-3xl font-bold">{t('registerAsPatient')}</h1>
          <p className="text-white/90 text-sm mt-2">{t('brand')}</p>
        </div>

        <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-4">
          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('fullName')} *</label>
            <input type="text" value={form.fullName} onChange={e => setForm({ ...form, fullName: e.target.value })} className={inputCls('fullName')} />
            {errors.fullName && <p className="text-red-500 text-xs mt-1">{errors.fullName}</p>}
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('phone')} *</label>
            <input type="tel" value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} className={inputCls('phone')} placeholder="01xxxxxxxxx" />
            {errors.phone && <p className="text-red-500 text-xs mt-1">{errors.phone}</p>}
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('email')} *</label>
            <input type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} className={inputCls('email')} />
            {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('address')} *</label>
            <input type="text" value={form.address} onChange={e => setForm({ ...form, address: e.target.value })} className={inputCls('address')} />
            {errors.address && <p className="text-red-500 text-xs mt-1">{errors.address}</p>}
          </div>

          <div className="grid grid-cols-2 gap-4">
            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('gender')} *</label>
              <select value={form.gender} onChange={e => setForm({ ...form, gender: e.target.value })} className={inputCls('gender')}>
                <option value="">--</option>
                <option value="male">{t('male')}</option>
                <option value="female">{t('female')}</option>
              </select>
              {errors.gender && <p className="text-red-500 text-xs mt-1">{errors.gender}</p>}
            </div>

            <div></div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('password')} *</label>
            <input type="password" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} className={inputCls('password')} />
            {errors.password && <p className="text-red-500 text-xs mt-1">{errors.password}</p>}
          </div>

          <div>
            <label className="block text-sm font-semibold text-slate-700 mb-2">{t('confirmPassword')} *</label>
            <input type="password" value={form.confirmPassword} onChange={e => setForm({ ...form, confirmPassword: e.target.value })} className={inputCls('confirmPassword')} />
            {errors.confirmPassword && <p className="text-red-500 text-xs mt-1">{errors.confirmPassword}</p>}
          </div>

          <button
            type="submit"
            className="w-full py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg transition"
          >
            {t('register')}
          </button>

          <div className="text-center text-sm text-slate-600">
            {t('haveAccount')}{' '}
            <Link to="/login" className="text-teal-600 font-semibold hover:underline">
              {t('login')}
            </Link>
          </div>
        </form>
      </div>

      {/* Disclaimer Modal */}
      {showDisclaimer && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/60 backdrop-blur-sm fade-in">
          <div className="bg-white rounded-3xl shadow-2xl max-w-lg w-full p-6">
            <div className="flex items-center gap-3 mb-4">
              <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center">
                <AlertTriangle className="w-6 h-6 text-amber-600" />
              </div>
              <h3 className="text-xl font-bold text-slate-800">{t('brand')}</h3>
            </div>

            <div className="bg-slate-50 border border-slate-200 rounded-2xl p-4 text-sm text-slate-700 leading-relaxed max-h-64 overflow-y-auto">
              {t('disclaimer')}
            </div>

            <label className="flex items-start gap-3 mt-4 p-3 rounded-xl border-2 cursor-pointer hover:bg-slate-50"
              style={{ borderColor: agreed ? '#0d9488' : '#e2e8f0' }}>
              <input
                type="checkbox"
                checked={agreed}
                onChange={e => setAgreed(e.target.checked)}
                className="w-5 h-5 mt-0.5 accent-teal-600"
              />
              <span className="text-sm font-semibold text-slate-700">{t('agreeDisclaimer')}</span>
            </label>

            <div className="flex gap-2 mt-5">
              <button
                onClick={() => setShowDisclaimer(false)}
                className="flex-1 py-3 border-2 border-slate-300 rounded-xl font-semibold text-slate-700 hover:bg-slate-50"
              >
                رجوع
              </button>
              <button
                onClick={handleFinalRegister}
                disabled={!agreed || loading}
                className="flex-1 py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                {loading ? '...' : t('register')}
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
