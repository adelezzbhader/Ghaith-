import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useLang } from '../../contexts/LanguageContext';
import { useAuth } from '../../contexts/AuthContext';
import { nurseApi, publicApi } from '../../services/apiService';
import Modal from '../../components/Modal';
import {
  Home, ClipboardList, CheckCircle, User, DollarSign, Star,
  Activity, Calendar, MapPin, Phone, Eye, Play, Check
} from 'lucide-react';

type Tab = 'home' | 'active' | 'orders' | 'profile' | 'earnings' | 'ratings';

export default function NurseDashboard() {
  const { t } = useLang();
  const { user } = useAuth();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('home');
  const [stats, setStats] = useState({ totalVisits: 0, monthlyEarnings: 0, avgRating: 0, activeOrders: 0 });
  const [activeOrders, setActiveOrders] = useState<any[]>([]);
  const [myOrders, setMyOrders] = useState<any[]>([]);
  const [earnings, setEarnings] = useState<any>({});
  const [ratings, setRatings] = useState<any[]>([]);
  const [selectedOrder, setSelectedOrder] = useState<any>(null);
  const [profile, setProfile] = useState<any>(null);
  const [services, setServices] = useState<any[]>([]);

  useEffect(() => {
    loadAll();
  }, []);

  const loadAll = async () => {
    const [s, a, m, e, r, p, svc] = await Promise.all([
      nurseApi.getStats(),
      nurseApi.getActiveOrders(),
      nurseApi.getMyOrders(),
      nurseApi.getEarnings(),
      nurseApi.getRatings(),
      nurseApi.getProfile(),
      publicApi.getServices(),
    ]);
    setStats(s as any);
    setActiveOrders(a as any);
    setMyOrders(m as any);
    setEarnings(e);
    setRatings(r as any);
    setProfile(p);
    setServices(svc as any);
  };

  const handleAccept = async (id: string) => {
    try {
      await nurseApi.acceptOrder(id);
      setActiveOrders(prev => prev.filter(o => o.id !== id));
      loadAll();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ في قبول الطلب');
    }
  };

  const handleComplete = async (id: string) => {
    try {
      await nurseApi.completeOrder(id);
      loadAll();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ');
    }
  };

  const handleCancel = async (id: string) => {
    if (!confirm('إلغاء هذا الطلب وإعادته للطلبات المتاحة؟')) return;
    try {
      await nurseApi.cancelOrder(id);
      loadAll();
    } catch (err: any) {
      toast.error(err?.response?.data?.message || err?.response?.data?.detail || 'حدث خطأ');
    }
  };

  const menu = [
    { id: 'home', icon: Home, label: t('mainPage') },
    { id: 'active', icon: Activity, label: t('activeOrders') },
    { id: 'orders', icon: ClipboardList, label: t('myOrders') },
    { id: 'profile', icon: User, label: t('profile') },
    { id: 'earnings', icon: DollarSign, label: t('earnings') },
    { id: 'ratings', icon: Star, label: t('ratings') },
  ] as const;

  return (
    <div className="min-h-screen bg-slate-50">
      {/* Header */}
      <div className="hero-gradient text-white p-6">
        <div className="max-w-7xl mx-auto">
          <div className="text-sm opacity-80">{t('nurseDashboard')}</div>
          <h1 className="text-2xl md:text-3xl font-bold">
            {t('welcome')}, {user?.firstName || user?.fullName} 👋
          </h1>
        </div>
      </div>

      <div className="max-w-7xl mx-auto grid md:grid-cols-[240px_1fr] gap-6 p-4 md:p-6">
        {/* Sidebar */}
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

        {/* Content */}
        <main className="space-y-6">
          {tab === 'home' && (
            <>
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <StatCard icon={ClipboardList} label={t('activeOrders')} value={stats.activeOrders} color="cyan" />
                <StatCard icon={CheckCircle} label={t('totalVisits')} value={stats.totalVisits} color="emerald" />
                <StatCard icon={DollarSign} label={t('monthlyEarnings')} value={`${stats.monthlyEarnings} ${t('currency')}`} color="amber" />
                <StatCard icon={Star} label={t('avgRating')} value={stats.avgRating.toFixed(1)} color="purple" />
              </div>

              <div className="bg-white rounded-2xl shadow-md p-6">
                <h2 className="text-xl font-bold text-slate-800 mb-4">{t('ourServices')}</h2>
                {services.length === 0 ? (
                  <div className="text-center py-4 text-slate-400">{t('loading')}</div>
                ) : (
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
                    {services.map((s, i) => (
                      <div key={s.id || i} className="bg-slate-50 rounded-xl p-4 text-center border border-slate-100">
                        <div className="text-3xl mb-1">{s.icon || '💉'}</div>
                        <div className="font-semibold text-slate-700 text-sm">{s.nameAr || s.nameEn}</div>
                        <div className="text-xs text-teal-600 mt-1">{s.price} {t('currency')}</div>
                      </div>
                    ))}
                  </div>
                )}
              </div>

              <div className="bg-white rounded-2xl shadow-md p-6">
                <h2 className="text-xl font-bold text-slate-800 mb-4 flex items-center gap-2">
                  <Activity className="w-5 h-5 text-teal-600" />
                  {t('activeOrders')}
                </h2>
                {activeOrders.length === 0 ? (
                  <div className="text-center py-12 text-slate-400">{t('noOrders')}</div>
                ) : (
                  <div className="grid md:grid-cols-2 gap-4">
                    {activeOrders.slice(0, 4).map(o => (
                      <OrderCard key={o.id} order={o} onView={setSelectedOrder} onAccept={() => handleAccept(o.id)} showAccept />
                    ))}
                  </div>
                )}
              </div>
            </>
          )}

          {tab === 'active' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('activeOrders')}</h2>
              {activeOrders.length === 0 ? (
                <div className="text-center py-12 text-slate-400">{t('noOrders')}</div>
              ) : (
                <div className="grid md:grid-cols-2 gap-4">
                  {activeOrders.map(o => (
                    <OrderCard key={o.id} order={o} onView={setSelectedOrder} onAccept={() => handleAccept(o.id)} showAccept />
                  ))}
                </div>
              )}
            </div>
          )}

          {tab === 'orders' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('myOrders')}</h2>
              {myOrders.length === 0 ? (
                <div className="text-center py-12 text-slate-400">{t('noOrders')}</div>
              ) : (
                <div className="space-y-3">
                  {myOrders.map(o => (
                    <OrderCard
                      key={o.id}
                      order={o}
                      onView={setSelectedOrder}
                      onComplete={(o.status === 'in_progress' || o.status === 'awaiting_completion') ? () => handleComplete(o.id) : undefined}
                      showComplete={o.status === 'in_progress' || o.status === 'awaiting_completion'}
                      onCancel={() => handleCancel(o.id)}
                      showCancel={o.status === 'in_progress' || o.status === 'awaiting_completion'}
                    />
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
              <ProfileField label={t('address')} value={profile.address} />
              <ProfileField label={t('gender')} value={profile.gender?.toLowerCase() === 'male' ? t('male') : profile.gender?.toLowerCase() === 'female' ? t('female') : profile.gender || '—'} />
              {(profile.wallet || profile.walletNumber) && <ProfileField label={t('wallet')} value={profile.wallet || profile.walletNumber} />}
            </div>
          )}

          {tab === 'earnings' && (
            <div className="space-y-4">
              <div className="grid md:grid-cols-3 gap-4">
                <div className="bg-white rounded-2xl shadow-md p-6 text-center">
                  <div className="text-sm text-slate-500">إجمالي الشهر</div>
                  <div className="text-3xl font-bold text-teal-600 mt-2">{earnings.totalMonth || 0} {t('currency')}</div>
                </div>
                <div className="bg-white rounded-2xl shadow-md p-6 text-center">
                  <div className="text-sm text-slate-500">المخصوم</div>
                  <div className="text-3xl font-bold text-red-500 mt-2">{earnings.deducted || 0} {t('currency')}</div>
                </div>
                <div className="bg-white rounded-2xl shadow-md p-6 text-center">
                  <div className="text-sm text-slate-500">الفعلي</div>
                  <div className="text-3xl font-bold text-emerald-600 mt-2">{earnings.actual || 0} {t('currency')}</div>
                </div>
              </div>
              <div className="bg-white rounded-2xl shadow-md p-6">
                <h3 className="font-bold text-slate-800 mb-3">التفصيل</h3>
                {earnings.breakdown?.map((b: any, i: number) => (
                  <div key={i} className="flex justify-between py-2 border-b border-slate-100">
                    <span className="text-slate-600">{b.date}</span>
                    <span className="font-bold text-teal-600">+{b.amount} {t('currency')}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {tab === 'ratings' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('ratings')}</h2>
              <div className="space-y-3">
                {ratings.map(r => (
                  <div key={r.id} className="p-4 border border-slate-200 rounded-xl">
                    <div className="flex justify-between items-center mb-2">
                      <div className="font-semibold text-slate-800">{r.patientName}</div>
                      <div className="flex items-center gap-1 text-amber-500">
                        {'★'.repeat(r.rating)}{'☆'.repeat(5 - r.rating)}
                      </div>
                    </div>
                    <p className="text-slate-600 text-sm">{r.comment}</p>
                    <div className="text-xs text-slate-400 mt-2">{r.date}</div>
                  </div>
                ))}
                {ratings.length === 0 && <div className="text-center py-12 text-slate-400">{t('noOrders')}</div>}
              </div>
            </div>
          )}
        </main>
      </div>

      {/* Order Details Modal */}
      <Modal title={t('orderDetails')} open={!!selectedOrder} onClose={() => setSelectedOrder(null)}>
        {selectedOrder && (
          <div className="space-y-3">
            <DetailRow icon={User} label={t('patientName')} value={selectedOrder.patientName} />
            <DetailRow icon={Phone} label={t('patientPhone')} value={selectedOrder.patientPhone || '—'} />
            <DetailRow icon={MapPin} label={t('patientAddress')} value={selectedOrder.patientAddress} />
            <DetailRow icon={MapPin} label={t('location')} value={selectedOrder.area} />
            <DetailRow icon={Calendar} label={t('date')} value={selectedOrder.date} />
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
    </div>
  );
}

function StatCard({ icon: Icon, label, value, color }: any) {
  const colors: any = {
    cyan: 'bg-cyan-100 text-cyan-600',
    emerald: 'bg-emerald-100 text-emerald-600',
    amber: 'bg-amber-100 text-amber-600',
    purple: 'bg-purple-100 text-purple-600',
  };
  return (
    <div className="bg-white rounded-2xl shadow-md p-5">
      <div className={`w-10 h-10 rounded-xl flex items-center justify-center mb-3 ${colors[color]}`}>
        <Icon className="w-5 h-5" />
      </div>
      <div className="text-xs text-slate-500">{label}</div>
      <div className="text-2xl font-bold text-slate-800 mt-1">{value}</div>
    </div>
  );
}

function OrderCard({ order, onView, onAccept, onComplete, onCancel, showAccept, showComplete, showCancel }: any) {
  const { t } = useLang();
  const statusLabel =
    order.status === 'pending' ? t('pending') :
    order.status === 'completed' ? t('completed') :
    order.status === 'cancelled' ? t('cancelled') :
    order.status === 'awaiting_completion' ? 'بانتظار التأكيد' :
    order.status === 'in_progress' ? 'قيد التنفيذ' :
    t('active');
  const statusColor =
    order.status === 'pending' ? 'bg-amber-100 text-amber-700' :
    order.status === 'completed' ? 'bg-emerald-100 text-emerald-700' :
    order.status === 'cancelled' ? 'bg-red-100 text-red-700' :
    order.status === 'awaiting_completion' ? 'bg-purple-100 text-purple-700' :
    order.status === 'in_progress' ? 'bg-blue-100 text-blue-700' :
    'bg-cyan-100 text-cyan-700';
  return (
    <div className="border border-slate-200 rounded-xl p-4 hover:shadow-md transition">
      <div className="flex justify-between items-start mb-2">
        <div>
          <div className="font-semibold text-slate-800">{order.patientName}</div>
          <div className="text-xs text-slate-500">
            {order.orderNumber ? <span className="ml-2">طلب #{order.orderNumber}</span> : null}
            {order.date}
          </div>
        </div>
        <span className={`px-2 py-1 rounded-full text-xs font-semibold ${statusColor}`}>{statusLabel}</span>
      </div>
      <div className="text-sm text-slate-600 mb-3">
        {order.services?.slice(0, 2).join(' • ')}
      </div>
      <div className="flex justify-between items-center">
        <div className="text-lg font-bold text-teal-600">{order.totalPrice} {t('currency')}</div>
        <div className="flex gap-2">
          <button onClick={() => onView(order)} className="p-2 rounded-lg bg-slate-100 hover:bg-slate-200" title={t('viewDetails')}>
            <Eye className="w-4 h-4" />
          </button>
          {showAccept && (
            <button onClick={onAccept} className="px-3 py-2 rounded-lg bg-teal-600 text-white text-sm font-semibold hover:bg-teal-700 flex items-center gap-1">
              <Play className="w-4 h-4" /> {t('acceptOrder')}
            </button>
          )}
          {showComplete && (
            <button onClick={onComplete} className="px-3 py-2 rounded-lg bg-emerald-600 text-white text-sm font-semibold hover:bg-emerald-700 flex items-center gap-1">
              <Check className="w-4 h-4" /> {t('markDone')}
            </button>
          )}
          {showCancel && (
            <button onClick={onCancel} className="px-3 py-2 rounded-lg bg-red-500 text-white text-sm font-semibold hover:bg-red-600 flex items-center gap-1">
              إلغاء
            </button>
          )}
        </div>
      </div>
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
