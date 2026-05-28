import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useLang } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import { patientApi, publicApi } from '../../services/apiService';
import toast from 'react-hot-toast';
import Modal from '../../components/Modal';
import {
  Home, ClipboardList, User, Check, AlertTriangle,
  MapPin, Calendar, Eye, Clock, ChevronDown, Star
} from 'lucide-react';

type Tab = 'home' | 'orders' | 'profile';

export default function PatientDashboard() {
  const { t, lang } = useLang();
  const { user, updateUser } = useAuth();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('home');
  const [services, setServices] = useState<any[]>([]);
  const [areas, setAreas] = useState<any[]>([]);
  const [orders, setOrders] = useState<any[]>([]);
  const [profile, setProfile] = useState<any>(null);

  // Order flow
  const [selectedServices, setSelectedServices] = useState<string[]>([]);
  const [fullCareHours, setFullCareHours] = useState(1);
  const [fullCareGender, setFullCareGender] = useState('male');
  const [selectedArea, setSelectedArea] = useState<string>('');
  const [step, setStep] = useState<1 | 2 | 3>(1);
  const [orderPlaced, setOrderPlaced] = useState(false);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);
  const [ratingOrder, setRatingOrder] = useState<any>(null);
  const [ratingScore, setRatingScore] = useState(0);
  const [ratingComment, setRatingComment] = useState('');
  const [editAddress, setEditAddress] = useState('');

  useEffect(() => {
    loadAll();
  }, []);

  const loadAll = async () => {
    const [s, a, o, p] = await Promise.all([
      publicApi.getServices(),
      publicApi.getAreas(),
      patientApi.getOrders(),
      patientApi.getProfile(),
    ]);
    setServices(s as any);
    setAreas(a as any);
    setOrders(o as any);
    setProfile(p);
    setEditAddress(p?.address || '');
  };

  const toggleService = (id: string) => {
    setSelectedServices(prev =>
      prev.includes(id) ? prev.filter(s => s !== id) : [...prev, id]
    );
  };

  const calculateTotal = () => {
    let total = 0;
    services.forEach(s => {
      if (selectedServices.includes(s.id)) {
        total += s.perHour ? Number(s.price) * fullCareHours : Number(s.price);
      }
    });
    return total;
  };

  const getAreaPrice = () => {
    const area = areas.find(a => a.id === selectedArea);
    return Number(area?.price) || 0;
  };

  const handleSaveAddress = async () => {
    await patientApi.updateAddress(editAddress);
    setProfile((p: any) => ({ ...p, address: editAddress }));
    updateUser({ address: editAddress });
    toast.success('تم الحفظ');
  };

  const handlePlaceOrder = async () => {
    try {
      await patientApi.createOrder({
        services: selectedServices,
        area: selectedArea,
        address: profile?.address || '',
        fullCareHours,
        fullCareGender,
        totalPrice: calculateTotal() + getAreaPrice(),
      });
      setOrderPlaced(true);
      setTimeout(() => {
        setStep(1);
        setSelectedServices([]);
        setSelectedArea('');
        setOrderPlaced(false);
        setTab('orders');
        loadAll();
      }, 2500);
    } catch (err: any) {
      const msg = err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ في إرسال الطلب';
      toast.error(msg);
    }
  };

  const handleComplete = async (id: string) => {
    try {
      await patientApi.completeOrder(id);
      loadAll();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ');
    }
  };

  const handleCancel = async (id: string) => {
    if (!confirm('هل أنت متأكد من إلغاء هذا الطلب؟')) return;
    try {
      await patientApi.cancelOrder(id);
      loadAll();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ');
    }
  };

  const openRating = (order: any) => {
    setRatingOrder(order);
    setRatingScore(0);
    setRatingComment('');
  };

  const submitRating = async () => {
    if (!ratingScore) { toast.error('اختر تقييماً'); return; }
    try {
      await patientApi.rateOrder(ratingOrder.id, { score: ratingScore, comment: ratingComment });
      setRatingOrder(null);
      loadAll();
    } catch (err: any) {
      alert(err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ');
    }
  };

  const selectedFullCare = services.find(s => s.id === '8' && selectedServices.includes(s.id));

  const menu = [
    { id: 'home', icon: Home, label: t('mainPage') },
    { id: 'orders', icon: ClipboardList, label: t('myOrders') },
    { id: 'profile', icon: User, label: t('profile') },
  ] as const;

  return (
    <div className="min-h-screen bg-slate-50">
      <div className="hero-gradient text-white p-6">
        <div className="max-w-7xl mx-auto">
          <div className="text-sm opacity-80">{t('patientDashboard')}</div>
          <h1 className="text-2xl md:text-3xl font-bold">
            {t('welcome')}, {user?.firstName || user?.fullName} 👋
          </h1>
        </div>
      </div>

      <div className="max-w-7xl mx-auto grid md:grid-cols-[220px_1fr] gap-6 p-4 md:p-6">
        <aside className="bg-white rounded-2xl shadow-md p-3 h-fit sticky top-20">
          <nav className="space-y-1">
            {menu.map(m => {
              const Icon = m.icon;
              return (
                <button
                  key={m.id}
                  onClick={() => setTab(m.id)}
                  className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl transition font-semibold ${
                    tab === m.id ? 'bg-teal-600 text-white shadow-lg' : 'text-slate-600 hover:bg-slate-100'
                  }`}
                >
                  <Icon className="w-5 h-5" />
                  <span className="text-sm">{m.label}</span>
                </button>
              );
            })}
          </nav>
          <button
            onClick={() => navigate('/')}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-xl transition font-semibold text-slate-600 hover:bg-slate-100 mt-4"
          >
            <Home className="w-5 h-5" />
            <span className="text-sm">الرئيسية</span>
          </button>
        </aside>

        <main className="space-y-6">
          {tab === 'home' && (
            <>
              {step === 1 && (
                <>
                  <div className="bg-white rounded-2xl shadow-md p-6">
                    <h2 className="text-xl font-bold text-slate-800 mb-1">{t('ourServices')}</h2>
                    <p className="text-sm text-slate-500 mb-5">{t('selectServices')}</p>
                    <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
                      {services.map(s => (
                        <button
                          key={s.id}
                          onClick={() => toggleService(s.id)}
                          className={`p-4 rounded-2xl border-2 transition text-center ${
                            selectedServices.includes(s.id)
                              ? 'border-teal-500 bg-teal-50 shadow-md'
                              : 'border-slate-200 hover:border-slate-300'
                          }`}
                        >
                          <div className="w-16 h-16 mx-auto rounded-full bg-gradient-to-br from-teal-100 to-cyan-100 flex items-center justify-center text-3xl mb-3">
                            {s.icon}
                          </div>
                          <div className="text-xs font-semibold text-slate-700 mb-1 min-h-[2.5em]">
                            {lang === 'ar' ? s.nameAr : s.nameEn}
                          </div>
                          <div className="text-sm font-bold text-teal-600">
                            {s.price} {t('currency')}
                            {s.perHour && '/hr'}
                          </div>
                        </button>
                      ))}
                    </div>

                    {selectedFullCare && (
                      <div className="mt-5 p-4 bg-slate-50 rounded-xl grid md:grid-cols-2 gap-3">
                        <div>
                          <label className="text-sm font-semibold text-slate-700 mb-1 block">{t('hours')}</label>
                          <input
                            type="number"
                            min="1"
                            value={fullCareHours}
                            onChange={e => setFullCareHours(Math.max(1, +e.target.value))}
                            className="w-full px-4 py-2 border border-slate-300 rounded-lg"
                          />
                        </div>
                        <div>
                          <label className="text-sm font-semibold text-slate-700 mb-1 block">{t('selectGender')}</label>
                          <select
                            value={fullCareGender}
                            onChange={e => setFullCareGender(e.target.value)}
                            className="w-full px-4 py-2 border border-slate-300 rounded-lg"
                          >
                            <option value="male">{t('male')}</option>
                            <option value="female">{t('female')}</option>
                          </select>
                        </div>
                      </div>
                    )}

                    <div className="flex justify-between items-center mt-6 pt-4 border-t border-slate-200">
                      <div>
                        <div className="text-sm text-slate-500">{t('total')}</div>
                        <div className="text-2xl font-bold text-teal-600">{calculateTotal()} {t('currency')}</div>
                      </div>
                      <button
                        onClick={() => selectedServices.length && setStep(2)}
                        disabled={!selectedServices.length}
                        className="px-6 py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
                      >
                        {t('continue')} →
                      </button>
                    </div>
                  </div>
                </>
              )}

              {step === 2 && (
                <div className="bg-white rounded-2xl shadow-md p-6">
                  <h2 className="text-xl font-bold text-slate-800 mb-4">ملخص الطلب</h2>
                  <div className="space-y-2 mb-4">
                    {selectedServices.map(id => {
                      const s = services.find(sv => sv.id === id);
                      return s ? (
                        <div key={id} className="flex justify-between py-2 border-b border-slate-100">
                          <span className="text-slate-700">{s.icon} {lang === 'ar' ? s.nameAr : s.nameEn}</span>
                          <span className="font-bold">
                            {s.perHour ? s.price * fullCareHours : s.price} {t('currency')}
                          </span>
                        </div>
                      ) : null;
                    })}
                  </div>

                  <div className="mb-4">
                    <label className="block text-sm font-semibold text-slate-700 mb-2 flex items-center gap-1">
                      <MapPin className="w-4 h-4" />
                      {t('chooseLocation')}
                      <ChevronDown className="w-4 h-4" />
                    </label>
                    <div className="space-y-2">
                      {areas.map(a => (
                        <button
                          key={a.id}
                          onClick={() => setSelectedArea(a.id)}
                          className={`w-full flex justify-between items-center p-3 rounded-xl border-2 ${
                            selectedArea === a.id ? 'border-teal-500 bg-teal-50' : 'border-slate-200'
                          }`}
                        >
                          <span>{lang === 'ar' ? a.nameAr : a.nameEn}</span>
                          <span className="font-bold text-teal-600">+{a.price} {t('currency')}</span>
                        </button>
                      ))}
                    </div>
                  </div>

                  <div className="flex justify-between items-center pt-4 border-t border-slate-200">
                    <div>
                      <div className="text-sm text-slate-500">{t('total')}</div>
                      <div className="text-2xl font-bold text-teal-600">
                        {calculateTotal() + getAreaPrice()} {t('currency')}
                      </div>
                    </div>
                    <div className="flex gap-2">
                      <button onClick={() => setStep(1)} className="px-4 py-3 border-2 border-slate-300 rounded-xl font-semibold">
                        رجوع
                      </button>
                      <button
                        onClick={() => selectedArea && setStep(3)}
                        disabled={!selectedArea}
                        className="px-6 py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
                      >
                        {t('continue')} →
                      </button>
                    </div>
                  </div>
                </div>
              )}

              {step === 3 && !orderPlaced && (
                <div className="bg-white rounded-2xl shadow-md p-6">
                  <div className="flex items-center gap-3 mb-4">
                    <div className="w-12 h-12 rounded-full bg-amber-100 flex items-center justify-center">
                      <AlertTriangle className="w-6 h-6 text-amber-600" />
                    </div>
                    <h2 className="text-xl font-bold text-slate-800">تنبيه هام</h2>
                  </div>
                  <div className="bg-amber-50 border border-amber-200 rounded-xl p-4 text-slate-700 text-sm mb-5">
                    {t('cancelWarning')}
                  </div>
                  <div className="flex gap-2">
                    <button onClick={() => setStep(2)} className="flex-1 py-3 border-2 border-slate-300 rounded-xl font-semibold">
                      رجوع
                    </button>
                    <button
                      onClick={handlePlaceOrder}
                      className="flex-1 py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg"
                    >
                      {t('placeOrder')} ✓
                    </button>
                  </div>
                </div>
              )}

              {orderPlaced && (
                <div className="bg-white rounded-2xl shadow-md p-8 text-center fade-in">
                  <div className="w-20 h-20 rounded-full bg-emerald-100 flex items-center justify-center mx-auto mb-4">
                    <Check className="w-12 h-12 text-emerald-600" />
                  </div>
                  <h2 className="text-2xl font-bold text-slate-800">تم إرسال طلبك بنجاح!</h2>
                  <p className="text-slate-500 mt-2">سيتم التواصل معك قريباً</p>
                </div>
              )}
            </>
          )}

          {tab === 'orders' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('myOrders')}</h2>
              {orders.length === 0 ? (
                <div className="text-center py-12 text-slate-400">{t('noOrders')}</div>
              ) : (
                <div className="space-y-3">
                  {orders.map(o => (
                    <div key={o.id} className="border border-slate-200 rounded-xl p-4 hover:shadow-md transition">
                      <div className="flex justify-between items-start mb-2">
                        <div>
                          <div className="font-semibold text-slate-800">طلب #{o.orderNumber}</div>
                          <div className="text-xs text-slate-500 flex items-center gap-1">
                            <Clock className="w-3 h-3" />
                            {o.date}
                          </div>
                        </div>
                        <span className={`px-2 py-1 rounded-full text-xs font-semibold ${
                          o.status === 'pending' ? 'bg-amber-100 text-amber-700' :
                          o.status === 'completed' ? 'bg-emerald-100 text-emerald-700' :
                          o.status === 'cancelled' ? 'bg-red-100 text-red-700' :
                          o.status === 'awaiting_completion' ? 'bg-purple-100 text-purple-700' :
                          o.status === 'in_progress' ? 'bg-blue-100 text-blue-700' :
                          'bg-cyan-100 text-cyan-700'
                        }`}>
                          {o.status === 'pending' ? t('pending') :
                           o.status === 'completed' ? t('completed') :
                           o.status === 'cancelled' ? t('cancelled') :
                           o.status === 'awaiting_completion' ? 'بانتظار التأكيد' :
                           o.status === 'in_progress' ? 'قيد التنفيذ' :
                           t('active')}
                        </span>
                      </div>
                      <div className="flex justify-between items-center mt-3">
                        <div className="text-lg font-bold text-teal-600">{o.totalPrice} {t('currency')}</div>
                        <div className="flex gap-2 flex-wrap justify-end">
                          <button onClick={() => setSelectedOrder(o)} className="px-3 py-2 rounded-lg bg-slate-100 hover:bg-slate-200 flex items-center gap-1 text-sm font-semibold">
                            <Eye className="w-4 h-4" />
                            {t('viewDetails')}
                          </button>
                          {(o.status === 'in_progress' || o.status === 'awaiting_completion') && (
                            <>
                              <button onClick={() => handleComplete(o.id)} className="px-3 py-2 rounded-lg bg-emerald-100 hover:bg-emerald-200 text-emerald-700 flex items-center gap-1 text-sm font-semibold">
                                <Check className="w-4 h-4" />
                                {o.patientConfirmedCompletion ? 'بانتظار الممرض' : 'تأكيد الإنجاز'}
                              </button>
                              <button onClick={() => handleCancel(o.id)} className="px-3 py-2 rounded-lg bg-red-100 hover:bg-red-200 text-red-700 flex items-center gap-1 text-sm font-semibold">
                                إلغاء
                              </button>
                            </>
                          )}
                          {o.status === 'active' && (
                            <button onClick={() => handleCancel(o.id)} className="px-3 py-2 rounded-lg bg-red-100 hover:bg-red-200 text-red-700 flex items-center gap-1 text-sm font-semibold">
                              إلغاء
                            </button>
                          )}
                          {o.status === 'completed' && (
                            <button onClick={() => openRating(o)} className="px-3 py-2 rounded-lg bg-amber-100 hover:bg-amber-200 text-amber-700 flex items-center gap-1 text-sm font-semibold">
                              <Star className="w-4 h-4" />
                              تقييم
                            </button>
                          )}
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {tab === 'profile' && profile && (
            <div className="bg-white rounded-2xl shadow-md p-6 space-y-4">
              <h2 className="text-xl font-bold text-slate-800">{t('profile')}</h2>
              <ProfileField label={t('fullName')} value={profile.fullName} />
              <ProfileField label={t('phone')} value={profile.phone} />
              <ProfileField label={t('email')} value={profile.email} />
              <ProfileField label={t('gender')} value={profile.gender ? (profile.gender.toLowerCase() === 'male' ? t('male') : profile.gender.toLowerCase() === 'female' ? t('female') : profile.gender) : '—'} />

              <div className="pt-3 border-t border-slate-200">
                <label className="block text-sm font-semibold text-slate-700 mb-2">{t('address')}</label>
                <div className="flex gap-2">
                  <input
                    value={editAddress}
                    onChange={e => setEditAddress(e.target.value)}
                    className="flex-1 px-4 py-2 border border-slate-300 rounded-xl focus:ring-2 focus:ring-teal-500"
                  />
                  <button onClick={handleSaveAddress} className="px-4 py-2 bg-teal-600 text-white rounded-xl font-semibold hover:bg-teal-700">
                    {t('save')}
                  </button>
                </div>
                <p className="text-xs text-slate-500 mt-1">يمكنك تعديل العنوان فقط</p>
              </div>
            </div>
          )}
        </main>
      </div>

      <Modal title={t('orderDetails')} open={!!selectedOrder} onClose={() => setSelectedOrder(null)}>
        {selectedOrder && (
          <div className="space-y-3">
            <div className="text-sm font-bold text-teal-600">#{selectedOrder.orderNumber}</div>
            <DetailRow icon={Calendar} label={t('date')} value={selectedOrder.date} />
            {selectedOrder.nurseName && <DetailRow icon={User} label={t('nurseName')} value={selectedOrder.nurseName} />}
            <DetailRow icon={MapPin} label={t('location')} value={selectedOrder.area} />
            <div>
              <div className="text-sm font-semibold text-slate-500 mb-1">{t('services')}:</div>
              <div className="flex flex-wrap gap-2">
                {selectedOrder.services?.map((s: string, i: number) => (
                  <span key={i} className="px-3 py-1 bg-teal-50 text-teal-700 rounded-full text-sm">{s}</span>
                ))}
              </div>
            </div>
            <div className="flex justify-between items-center pt-3 border-t border-slate-200">
              <span className="font-semibold text-slate-700">{t('total')}</span>
              <span className="text-xl font-bold text-teal-600">{selectedOrder.totalPrice} {t('currency')}</span>
            </div>
          </div>
        )}
      </Modal>

      <Modal title="تقييم الممرض" open={!!ratingOrder} onClose={() => setRatingOrder(null)}>
        {ratingOrder && (
          <div className="space-y-4">
            <p className="text-sm text-slate-600">قيم الممرض على هذه الخدمة</p>
            <div className="flex justify-center gap-2">
              {[1, 2, 3, 4, 5].map(s => (
                <button key={s} onClick={() => setRatingScore(s)} className={`w-10 h-10 rounded-full flex items-center justify-center text-xl transition ${s <= ratingScore ? 'bg-amber-100 text-amber-500' : 'bg-slate-100 text-slate-300'}`}>
                  ★
                </button>
              ))}
            </div>
            <textarea value={ratingComment} onChange={e => setRatingComment(e.target.value)} placeholder="أضف تعليقاً (اختياري)" className="w-full px-4 py-2 border border-slate-300 rounded-xl h-20 resize-none" />
            <button onClick={submitRating} className="w-full py-3 bg-gradient-to-r from-teal-600 to-cyan-600 text-white font-bold rounded-xl hover:shadow-lg">
              إرسال التقييم
            </button>
          </div>
        )}
      </Modal>
    </div>
  );
}

function ProfileField({ label, value }: any) {
  return (
    <div className="flex justify-between py-2 border-b border-slate-100">
      <span className="text-sm font-semibold text-slate-500">{label}</span>
      <span className="text-sm text-slate-800">{value}</span>
    </div>
  );
}

function DetailRow({ icon: Icon, label, value }: any) {
  return (
    <div className="flex items-center gap-3 py-2">
      <Icon className="w-4 h-4 text-slate-400" />
      <div className="flex-1">
        <div className="text-xs text-slate-500">{label}</div>
        <div className="font-semibold text-slate-800">{value}</div>
      </div>
    </div>
  );
}
