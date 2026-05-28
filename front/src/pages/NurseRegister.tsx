import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useLang } from '../contexts/LanguageContext';
import { authApi } from '../services/apiService';
import { Stethoscope, Upload, CheckCircle } from 'lucide-react';

export default function NurseRegister() {
  const { t } = useLang();
  const navigate = useNavigate();
  const [form, setForm] = useState({
    fullName: '',
    phone: '',
    email: '',
    address: '',
    wallet: '',
    gender: '',
    password: '',
    confirmPassword: '',
    interviewDate: '',
  });
  const [photo, setPhoto] = useState<File | null>(null);
  const [certificate, setCertificate] = useState<File | null>(null);
  const [syndicateCard, setSyndicateCard] = useState<File | null>(null);
  const [errors, setErrors] = useState<Record<string, string>>({});
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);

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
    if (!form.interviewDate) e.interviewDate = t('required');
    if (!photo) e.photo = t('required');
    if (!certificate) e.certificate = t('required');
    if (!syndicateCard) e.syndicateCard = t('required');
    setErrors(e);
    return Object.keys(e).length === 0;
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!validate()) return;
    setLoading(true);
    try {
      await authApi.registerNurse({
        ...form,
        photo,
        certificate,
        syndicateCard,
      });
      setSuccess(true);
      setTimeout(() => navigate('/login'), 3000);
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

  if (success) {
    return (
      <div className="min-h-[calc(100vh-4rem)] flex items-center justify-center p-4">
        <div className="bg-white rounded-3xl shadow-2xl max-w-md w-full p-8 text-center fade-in">
          <div className="w-20 h-20 rounded-full bg-green-100 flex items-center justify-center mx-auto mb-4">
            <CheckCircle className="w-12 h-12 text-green-600" />
          </div>
          <h2 className="text-2xl font-bold text-slate-800 mb-2">{t('register')} ✓</h2>
          <p className="text-slate-600">{t('interviewNotification')}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="max-w-3xl mx-auto p-4 py-8">
      <div className="bg-white rounded-3xl shadow-2xl overflow-hidden fade-in">
        <div className="hero-gradient p-8 text-white text-center">
          <div className="inline-block w-16 h-16 rounded-full bg-white/20 flex items-center justify-center mb-3">
            <Stethoscope className="w-8 h-8" />
          </div>
          <h1 className="text-3xl font-bold">{t('registerAsNurse')}</h1>
          <p className="text-white/90 text-sm mt-2">{t('brand')}</p>
        </div>

        <form onSubmit={handleSubmit} className="p-6 md:p-8 space-y-4">
          <div className="grid md:grid-cols-2 gap-4">
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

            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('email')} *</label>
              <input type="email" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} className={inputCls('email')} />
              {errors.email && <p className="text-red-500 text-xs mt-1">{errors.email}</p>}
            </div>

            <div className="md:col-span-2">
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('address')} *</label>
              <input type="text" value={form.address} onChange={e => setForm({ ...form, address: e.target.value })} className={inputCls('address')} />
              {errors.address && <p className="text-red-500 text-xs mt-1">{errors.address}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('wallet')}</label>
              <input type="text" value={form.wallet} onChange={e => setForm({ ...form, wallet: e.target.value })} className={inputCls('wallet')} placeholder="Optional" />
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('gender')} *</label>
              <select value={form.gender} onChange={e => setForm({ ...form, gender: e.target.value })} className={inputCls('gender')}>
                <option value="">--</option>
                <option value="male">{t('male')}</option>
                <option value="female">{t('female')}</option>
              </select>
              {errors.gender && <p className="text-red-500 text-xs mt-1">{errors.gender}</p>}
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

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('photo')} *</label>
              <label className="flex items-center gap-2 px-4 py-3 border border-dashed border-slate-300 rounded-xl cursor-pointer hover:bg-slate-50">
                <Upload className="w-5 h-5 text-slate-500" />
                <span className="text-sm text-slate-600 truncate">{photo ? photo.name : t('chooseFile')}</span>
                <input type="file" accept="image/*" onChange={e => setPhoto(e.target.files?.[0] || null)} className="hidden" />
              </label>
              {errors.photo && <p className="text-red-500 text-xs mt-1">{errors.photo}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('certificate')} *</label>
              <label className="flex items-center gap-2 px-4 py-3 border border-dashed border-slate-300 rounded-xl cursor-pointer hover:bg-slate-50">
                <Upload className="w-5 h-5 text-slate-500" />
                <span className="text-sm text-slate-600 truncate">{certificate ? certificate.name : t('chooseFile')}</span>
                <input type="file" accept="image/*,.pdf" onChange={e => setCertificate(e.target.files?.[0] || null)} className="hidden" />
              </label>
              {errors.certificate && <p className="text-red-500 text-xs mt-1">{errors.certificate}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('syndicateCard')} *</label>
              <label className="flex items-center gap-2 px-4 py-3 border border-dashed border-slate-300 rounded-xl cursor-pointer hover:bg-slate-50">
                <Upload className="w-5 h-5 text-slate-500" />
                <span className="text-sm text-slate-600 truncate">{syndicateCard ? syndicateCard.name : t('chooseFile')}</span>
                <input type="file" accept="image/*,.pdf" onChange={e => setSyndicateCard(e.target.files?.[0] || null)} className="hidden" />
              </label>
              {errors.syndicateCard && <p className="text-red-500 text-xs mt-1">{errors.syndicateCard}</p>}
            </div>

            <div>
              <label className="block text-sm font-semibold text-slate-700 mb-2">{t('interviewDate')} *</label>
              <input type="datetime-local" value={form.interviewDate} onChange={e => setForm({ ...form, interviewDate: e.target.value })} className={inputCls('interviewDate')} />
              {errors.interviewDate && <p className="text-red-500 text-xs mt-1">{errors.interviewDate}</p>}
            </div>
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg transition disabled:opacity-50"
          >
            {loading ? '...' : t('register')}
          </button>

          <div className="text-center text-sm text-slate-600">
            {t('haveAccount')}{' '}
            <Link to="/login" className="text-teal-600 font-semibold hover:underline">
              {t('login')}
            </Link>
          </div>
        </form>
      </div>
    </div>
  );
}
