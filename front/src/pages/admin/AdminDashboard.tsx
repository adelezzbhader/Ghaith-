import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import toast from 'react-hot-toast';
import { useLang } from '../../contexts/LanguageContext';
import { adminApi, publicApi } from '../../services/apiService';
import Modal from '../../components/Modal';
import {
  LayoutDashboard, Users, UserPlus, Stethoscope,
  Settings, ClipboardList, Clock, Check, X,
  Eye, Pencil, Trash2, Plus, Calendar, Phone,
  DollarSign, Shield, AlertTriangle
} from 'lucide-react';

type Tab = 'home' | 'join' | 'nurses' | 'patients' | 'settings' | 'orders';
type OrderTab = 'active' | 'pending' | 'completed' | 'cancelled';

export default function AdminDashboard() {
  const { t, lang } = useLang();
  const navigate = useNavigate();
  const [tab, setTab] = useState<Tab>('home');
  const [orderTab, setOrderTab] = useState<OrderTab>('active');
  const [stats, setStats] = useState<any>({});
  const [joinRequests, setJoinRequests] = useState<any[]>([]);
  const [nurses, setNurses] = useState<any[]>([]);
  const [patients, setPatients] = useState<any[]>([]);
  const [services, setServices] = useState<any[]>([]);
  const [areas, setAreas] = useState<any[]>([]);
  const [orders, setOrders] = useState<any[]>([]);

  const [selectedItem, setSelectedItem] = useState<any>(null);
  const [modalType, setModalType] = useState<null | 'join' | 'nurse' | 'patient' | 'order' | 'service' | 'area' | 'patientOrders'>(null);
  const [editForm, setEditForm] = useState<any>({});
  const [nurseSearch, setNurseSearch] = useState('');
  const [patientSearch, setPatientSearch] = useState('');
  const [orderSearch, setOrderSearch] = useState('');
  const [patientOrders, setPatientOrders] = useState<any[]>([]);

  // Admin session lock (only one admin open)
  useEffect(() => {
    const lockKey = 'ghaith_admin_lock';
    const myId = Date.now().toString();
    localStorage.setItem(lockKey, myId);

    const handleStorage = (e: StorageEvent) => {
      if (e.key === lockKey && e.newValue && e.newValue !== myId) {
        toast.error('تم فتح لوحة الإدارة في مكان آخر');
      }
    };
    window.addEventListener('storage', handleStorage);
    return () => {
      window.removeEventListener('storage', handleStorage);
      if (localStorage.getItem(lockKey) === myId) {
        localStorage.removeItem(lockKey);
      }
    };
  }, []);

  useEffect(() => { loadAll(); }, []);
  useEffect(() => { if (tab === 'orders') loadOrders(); }, [tab]);

  const loadAll = async () => {
    const [s, jr, n, p, sv, a] = await Promise.all([
      adminApi.getStats(),
      adminApi.getJoinRequests(),
      adminApi.getNurses(),
      adminApi.getPatients(),
      publicApi.getServices(),
      publicApi.getAreas(),
    ]);
    setStats(s);
    setJoinRequests(jr as any);
    setNurses(n as any);
    setPatients(p as any);
    setServices(sv as any);
    setAreas(a as any);
  };

  const loadOrders = async () => {
    const o = await adminApi.getOrders();
    setOrders(o as any);
  };

  const handleApprove = async (id: string) => {
    await adminApi.approveNurse(id);
    setJoinRequests(prev => prev.filter(r => r.id !== id));
  };
  const handleReject = async (id: string) => {
    await adminApi.rejectNurse(id);
    setJoinRequests(prev => prev.filter(r => r.id !== id));
  };

  const handleSaveNurse = async () => {
    await adminApi.updateNurse(editForm.id, editForm);
    setModalType(null);
    loadAll();
  };
  const handleSavePatient = async () => {
    await adminApi.updatePatient(editForm.id, editForm);
    setModalType(null);
    loadAll();
  };
  const handleDeleteNurse = async (id: string) => {
    if (!confirm('تأكيد الحذف؟')) return;
    await adminApi.deleteNurse(id);
    loadAll();
  };

  const handleSaveOrder = async () => {
    await adminApi.updateOrder(editForm.id, editForm);
    setModalType(null);
    loadOrders();
  };
  const handleCancelOrder = async (id: string) => {
    if (!confirm('إلغاء الطلب؟')) return;
    await adminApi.cancelOrder(id);
    loadOrders();
  };
  const handleRevertToPending = async (id: string) => {
    await adminApi.updateOrder(id, { status: 'pending' });
    loadOrders();
  };

  const handleAddService = async () => {
    if (!editForm.nameAr || !editForm.price) return;
    await adminApi.addService(editForm);
    setEditForm({});
    setModalType(null);
    loadAll();
  };
  const handleAddArea = async () => {
    if (!editForm.nameAr || !editForm.price) return;
    await adminApi.addArea(editForm);
    setEditForm({});
    setModalType(null);
    loadAll();
  };
  const handleDeleteService = async (id: string) => {
    if (!confirm('حذف؟')) return;
    await adminApi.deleteService(id);
    loadAll();
  };
  const handleDeleteArea = async (id: string) => {
    if (!confirm('حذف؟')) return;
    await adminApi.deleteArea(id);
    loadAll();
  };

  const menu = [
    { id: 'home', icon: LayoutDashboard, label: t('mainPage') },
    { id: 'join', icon: UserPlus, label: t('joinRequests'), badge: joinRequests.length },
    { id: 'nurses', icon: Stethoscope, label: t('nurseManagement') },
    { id: 'patients', icon: Users, label: t('patients') },
    { id: 'settings', icon: Settings, label: t('settingsPrices') },
    { id: 'orders', icon: ClipboardList, label: t('orders') },
  ] as const;

  const filteredOrders = orders.filter(o => {
    if (o.status !== orderTab) return false;
    if (!orderSearch) return true;
    const q = orderSearch.toLowerCase();
    const orderNum = o.orderNumber?.toString() || '';
    return orderNum.includes(q)
      || (o.patientName || '').toLowerCase().includes(q)
      || (o.patientPhone || '').toLowerCase().includes(q)
      || (o.area || '').toLowerCase().includes(q)
      || (o.nurseName || '').toLowerCase().includes(q);
  });

  const viewPatientOrders = async (patientId: string) => {
    const ords = await adminApi.getPatientOrders(patientId);
    setPatientOrders(ords);
    setModalType('patientOrders');
  };

  return (
    <div className="min-h-screen bg-slate-50">
      <div className="hero-gradient text-white p-6">
        <div className="max-w-7xl mx-auto">
          <div className="flex items-center gap-2 text-sm opacity-80">
            <Shield className="w-4 h-4" />
            {t('adminDashboard')}
          </div>
          <h1 className="text-2xl md:text-3xl font-bold mt-1">{t('welcomeAdmin')}</h1>
          <p className="text-sm opacity-80 mt-1">{t('generalManager')}</p>
        </div>
      </div>

      <div className="max-w-7xl mx-auto grid md:grid-cols-[240px_1fr] gap-6 p-4 md:p-6">
        <aside className="bg-white rounded-2xl shadow-md p-3 h-fit sticky top-20">
          <nav className="space-y-1">
            {menu.map(m => {
              const Icon = m.icon;
              return (
                <button
                  key={m.id}
                  onClick={() => setTab(m.id)}
                  className={`w-full flex items-center justify-between px-4 py-3 rounded-xl transition font-semibold ${
                    tab === m.id ? 'bg-teal-600 text-white shadow-lg' : 'text-slate-600 hover:bg-slate-100'
                  }`}
                >
                  <span className="flex items-center gap-3">
                    <Icon className="w-5 h-5" />
                    <span className="text-sm">{m.label}</span>
                  </span>
                  {'badge' in m && m.badge ? (
                    <span className="bg-red-500 text-white text-xs rounded-full px-2 py-0.5">{m.badge}</span>
                  ) : null}
                </button>
              );
            })}
          </nav>
          <button
            onClick={() => navigate('/')}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-xl transition font-semibold text-slate-600 hover:bg-slate-100 mt-4"
          >
            <LayoutDashboard className="w-5 h-5" />
            <span className="text-sm">الرئيسية</span>
          </button>
        </aside>

        <main className="space-y-6">
          {/* HOME */}
          {tab === 'home' && (
            <>
              <div className="grid grid-cols-2 lg:grid-cols-4 gap-4">
                <AdminStatCard icon={Stethoscope} label={t('nurseManagement')} value={stats.nurses || 0} color="teal" />
                <AdminStatCard icon={Users} label={t('patients')} value={stats.patients || 0} color="cyan" />
                <AdminStatCard icon={ClipboardList} label={t('orders')} value={stats.orders || 0} color="amber" />
                <AdminStatCard icon={DollarSign} label="الإيرادات" value={`${stats.revenue || 0}`} color="emerald" />
              </div>
              <div className="bg-white rounded-2xl shadow-md p-6">
                <h2 className="text-xl font-bold text-slate-800 mb-2">{t('platformManagement')}</h2>
                <p className="text-slate-500 text-sm">اختر من القائمة الجانبية لإدارة المنصة</p>
              </div>
            </>
          )}

          {/* JOIN REQUESTS */}
          {tab === 'join' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4 flex items-center gap-2">
                <UserPlus className="w-5 h-5 text-teal-600" />
                {t('joinRequests')}
              </h2>
              {joinRequests.length === 0 ? (
                <div className="text-center py-12 text-slate-400">لا توجد طلبات حالياً</div>
              ) : (
                <div className="space-y-3">
                  {joinRequests.map(r => (
                    <div key={r.id} className="border border-slate-200 rounded-xl p-4 hover:shadow-md transition">
                      <div className="flex justify-between items-start mb-2 flex-wrap gap-2">
                        <div>
                          <div className="font-bold text-slate-800">{r.fullName}</div>
                          <div className="text-sm text-slate-500">{r.email}</div>
                        </div>
                        <div className="flex gap-2">
                          <button onClick={() => { setSelectedItem(r); setModalType('join'); }} className="p-2 rounded-lg bg-slate-100 hover:bg-slate-200">
                            <Eye className="w-4 h-4" />
                          </button>
                          <button onClick={() => handleApprove(r.id)} className="p-2 rounded-lg bg-emerald-100 hover:bg-emerald-200 text-emerald-700">
                            <Check className="w-4 h-4" />
                          </button>
                          <button onClick={() => handleReject(r.id)} className="p-2 rounded-lg bg-red-100 hover:bg-red-200 text-red-700">
                            <X className="w-4 h-4" />
                          </button>
                        </div>
                      </div>
                      <div className="flex gap-3 text-sm text-slate-600 mt-2 flex-wrap">
                        <span className="flex items-center gap-1"><Phone className="w-3 h-3" /> {r.phone}</span>
                        <span className="flex items-center gap-1"><Calendar className="w-3 h-3" /> المقابلة: {r.interviewDate}</span>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}

          {/* NURSES */}
          {tab === 'nurses' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('nurseManagement')}</h2>
              <input value={nurseSearch} onChange={e => setNurseSearch(e.target.value)} placeholder="ابحث عن ممرض..." className="w-full px-4 py-2 border border-slate-300 rounded-xl mb-4" />
              <div className="grid md:grid-cols-2 gap-4">
                {nurses.filter(n => !nurseSearch || (n.fullName || '').includes(nurseSearch) || (n.email || '').includes(nurseSearch) || (n.phone || '').includes(nurseSearch)).map(n => (
                  <div key={n.id} className="border border-slate-200 rounded-xl p-4 hover:shadow-md transition">
                    <div className="flex justify-between items-start mb-2">
                      <div className="flex items-center gap-2">
                        <div className={`w-3 h-3 rounded-full ${n.availabilityStatus === 'busy' ? 'bg-red-500 animate-pulse' : n.availabilityStatus === 'free' ? 'bg-emerald-500' : 'bg-slate-300'}`} title={n.availabilityStatus === 'busy' ? 'ف خدمة' : n.availabilityStatus === 'free' ? 'فاضي' : 'غير متصل'} />
                        <div>
                          <div className="font-bold text-slate-800">{n.fullName}</div>
                          <div className="text-sm text-slate-500">{n.email}</div>
                        </div>
                      </div>
                      <div className="flex gap-1">
                        <button onClick={() => { setEditForm({ ...n }); setModalType('nurse'); }} className="p-2 rounded-lg bg-amber-100 hover:bg-amber-200 text-amber-700">
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button onClick={() => handleDeleteNurse(n.id)} className="p-2 rounded-lg bg-red-100 hover:bg-red-200 text-red-700">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                    <div className="flex gap-3 text-xs text-slate-600 mt-2 flex-wrap">
                      <span>{n.phone}</span>
                      <span>★ {n.rating}</span>
                      <span>{n.totalVisits} زيارة</span>
                      <span className={`font-semibold ${
                        n.availabilityStatus === 'busy' ? 'text-red-600' :
                        n.availabilityStatus === 'free' ? 'text-emerald-600' : 'text-slate-400'
                      }`}>
                        {n.availabilityStatus === 'busy' ? 'ف خدمة' :
                         n.availabilityStatus === 'free' ? 'فاضي' : 'غير متصل'}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* PATIENTS */}
          {tab === 'patients' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('patients')}</h2>
              <input value={patientSearch} onChange={e => setPatientSearch(e.target.value)} placeholder="ابحث عن مريض..." className="w-full px-4 py-2 border border-slate-300 rounded-xl mb-4" />
              <div className="grid md:grid-cols-2 gap-4">
                {patients.filter(p => !patientSearch || (p.fullName || '').includes(patientSearch) || (p.email || '').includes(patientSearch) || (p.phone || '').includes(patientSearch)).map(p => (
                  <div key={p.id} className="border border-slate-200 rounded-xl p-4 hover:shadow-md transition">
                    <div className="flex justify-between items-start mb-2">
                      <div>
                        <div className="font-bold text-slate-800">{p.fullName}</div>
                        <div className="text-sm text-slate-500">{p.email}</div>
                        <div className="text-xs text-slate-500 mt-1">{p.address}</div>
                      </div>
                      <div className="flex gap-1">
                        <button onClick={() => viewPatientOrders(p.id)} className="p-2 rounded-lg bg-cyan-100 hover:bg-cyan-200 text-cyan-700">
                          <Eye className="w-4 h-4" />
                        </button>
                        <button onClick={() => { setEditForm({ ...p }); setModalType('patient'); }} className="p-2 rounded-lg bg-amber-100 hover:bg-amber-200 text-amber-700">
                          <Pencil className="w-4 h-4" />
                        </button>
                        <button onClick={async () => { if (confirm('تأكيد حذف المريض؟')) { await adminApi.deletePatient(p.id); loadAll(); } }} className="p-2 rounded-lg bg-red-100 hover:bg-red-200 text-red-700">
                          <Trash2 className="w-4 h-4" />
                        </button>
                      </div>
                    </div>
                    <div className="text-xs text-slate-600 mt-2">{p.phone}</div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* SETTINGS */}
          {tab === 'settings' && (
            <>
              <div className="bg-white rounded-2xl shadow-md p-6">
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-xl font-bold text-slate-800">{t('services')}</h2>
                  <button
                    onClick={() => { setEditForm({}); setModalType('service'); }}
                    className="flex items-center gap-1 px-3 py-2 bg-teal-600 text-white rounded-lg text-sm font-semibold hover:bg-teal-700"
                  >
                    <Plus className="w-4 h-4" /> {t('addService')}
                  </button>
                </div>
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-3">
                  {services.map(s => (
                    <div key={s.id} className="border border-slate-200 rounded-xl p-4 flex justify-between items-center">
                      <div>
                        <div className="font-semibold text-slate-800">{s.icon} {lang === 'ar' ? s.nameAr : s.nameEn}</div>
                        <div className="text-sm text-teal-600 font-bold">{s.price} {t('currency')}{s.perHour && '/hr'}</div>
                      </div>
                      <button onClick={() => handleDeleteService(s.id)} className="p-2 rounded-lg bg-red-100 text-red-700 hover:bg-red-200">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>

              <div className="bg-white rounded-2xl shadow-md p-6">
                <div className="flex justify-between items-center mb-4">
                  <h2 className="text-xl font-bold text-slate-800">المناطق</h2>
                  <button
                    onClick={() => { setEditForm({}); setModalType('area'); }}
                    className="flex items-center gap-1 px-3 py-2 bg-teal-600 text-white rounded-lg text-sm font-semibold hover:bg-teal-700"
                  >
                    <Plus className="w-4 h-4" /> {t('addArea')}
                  </button>
                </div>
                <div className="grid md:grid-cols-2 gap-3">
                  {areas.map(a => (
                    <div key={a.id} className="border border-slate-200 rounded-xl p-4 flex justify-between items-center">
                      <div>
                        <div className="font-semibold text-slate-800">{lang === 'ar' ? a.nameAr : a.nameEn}</div>
                        <div className="text-sm text-teal-600 font-bold">+{a.price} {t('currency')}</div>
                      </div>
                      <button onClick={() => handleDeleteArea(a.id)} className="p-2 rounded-lg bg-red-100 text-red-700 hover:bg-red-200">
                        <Trash2 className="w-4 h-4" />
                      </button>
                    </div>
                  ))}
                </div>
              </div>
            </>
          )}

          {/* ORDERS */}
          {tab === 'orders' && (
            <div className="bg-white rounded-2xl shadow-md p-6">
              <h2 className="text-xl font-bold text-slate-800 mb-4">{t('orders')}</h2>
              <input
                value={orderSearch}
                onChange={e => setOrderSearch(e.target.value)}
                placeholder="ابحث برقم الطلب أو اسم المريض..."
                className="w-full px-4 py-2 border border-slate-300 rounded-xl mb-4"
              />
              <div className="flex gap-2 mb-4 flex-wrap">
                {(['active', 'pending', 'completed', 'cancelled'] as OrderTab[]).map(ot => (
                  <button
                    key={ot}
                    onClick={() => setOrderTab(ot)}
                    className={`px-4 py-2 rounded-lg text-sm font-semibold transition ${
                      orderTab === ot ? 'bg-teal-600 text-white' : 'bg-slate-100 text-slate-600 hover:bg-slate-200'
                    }`}
                  >
                    {ot === 'active' ? t('active') : ot === 'pending' ? t('pending') : ot === 'completed' ? t('completed') : t('cancelled')}
                    <span className="ms-1 opacity-70">({orders.filter(o => o.status === ot).length})</span>
                  </button>
                ))}
              </div>
              {filteredOrders.length === 0 ? (
                <div className="text-center py-12 text-slate-400">لا توجد طلبات</div>
              ) : (
                <div className="space-y-3">
                  {filteredOrders.map(o => (
                    <div key={o.id} className="border border-slate-200 rounded-xl p-4 hover:shadow-md transition">
                      <div className="flex justify-between items-start mb-2 flex-wrap gap-2">
                        <div>
                          <div className="flex items-center gap-2">
                            <span className="text-sm font-bold text-teal-600">#{o.orderNumber}</span>
                            <span className="font-bold text-slate-800">{o.patientName}</span>
                          </div>
                          <div className="text-xs text-slate-500">{o.date} • {o.area}</div>
                          {o.nurseName && <div className="text-xs text-teal-600 mt-1">الممرض: {o.nurseName}</div>}
                        </div>
                        <div className="flex gap-1 flex-wrap">
                          <button onClick={() => { setEditForm({ ...o }); setModalType('order'); }} className="p-2 rounded-lg bg-slate-100 hover:bg-slate-200">
                            <Eye className="w-4 h-4" />
                          </button>
                          {o.status === 'completed' && (
                            <button onClick={() => handleRevertToPending(o.id)} className="p-2 rounded-lg bg-amber-100 text-amber-700 hover:bg-amber-200" title="إرجاع للمعالجة">
                              <Clock className="w-4 h-4" />
                            </button>
                          )}
                          {o.status !== 'cancelled' && (
                            <button onClick={() => handleCancelOrder(o.id)} className="p-2 rounded-lg bg-red-100 text-red-700 hover:bg-red-200">
                              <X className="w-4 h-4" />
                            </button>
                          )}
                        </div>
                      </div>
                      <div className="flex justify-between items-center mt-2">
                        <div className="text-sm text-slate-600">{o.services?.join(' • ')}</div>
                        <div className="font-bold text-teal-600">{o.totalPrice} {t('currency')}</div>
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          )}
        </main>
      </div>

      {/* Modals */}
      <Modal title={t('orderDetails')} open={modalType === 'join'} onClose={() => setModalType(null)}>
        {selectedItem && (
          <div className="space-y-3">
            <AdminField label={t('fullName')} value={selectedItem.fullName} />
            <AdminField label={t('email')} value={selectedItem.email} />
            <AdminField label={t('phone')} value={selectedItem.phone} />
            <AdminField label={t('gender')} value={selectedItem.gender} />
            <AdminField label={t('address')} value={selectedItem.address} />
            <AdminField label={t('interviewDate')} value={selectedItem.interviewDate} />
            <AdminField label={t('date')} value={selectedItem.createdAt} />
            {selectedItem.profileImage && (
              <div>
                <span className="text-sm font-semibold text-slate-500 block mb-1">{t('photo')}</span>
                <a href={selectedItem.profileImage} target="_blank" rel="noopener noreferrer" className="text-teal-600 underline text-sm">فتح الصورة</a>
              </div>
            )}
            {selectedItem.graduationCertificate && (
              <div>
                <span className="text-sm font-semibold text-slate-500 block mb-1">{t('certificate')}</span>
                <a href={selectedItem.graduationCertificate} target="_blank" rel="noopener noreferrer" className="text-teal-600 underline text-sm">فتح الملف</a>
              </div>
            )}
            {selectedItem.syndicateCard && (
              <div>
                <span className="text-sm font-semibold text-slate-500 block mb-1">{t('syndicateCard')}</span>
                <a href={selectedItem.syndicateCard} target="_blank" rel="noopener noreferrer" className="text-teal-600 underline text-sm">فتح الملف</a>
              </div>
            )}
          </div>
        )}
      </Modal>

      <Modal title={t('edit')} open={modalType === 'nurse'} onClose={() => setModalType(null)}>
        <div className="space-y-3">
          <Input label={t('fullName')} value={editForm.fullName || ''} onChange={(v: string) => setEditForm({ ...editForm, fullName: v })} />
          <Input label={t('phone')} value={editForm.phone || ''} onChange={(v: string) => setEditForm({ ...editForm, phone: v })} />
          <Input label={t('email')} value={editForm.email || ''} onChange={(v: string) => setEditForm({ ...editForm, email: v })} />
          <Input label={t('address')} value={editForm.address || ''} onChange={(v: string) => setEditForm({ ...editForm, address: v })} />
          <div className="flex gap-2 mt-4">
            <button onClick={() => setModalType(null)} className="flex-1 py-2 border-2 border-slate-300 rounded-lg">إلغاء</button>
            <button onClick={handleSaveNurse} className="flex-1 py-2 bg-teal-600 text-white rounded-lg font-semibold">{t('save')}</button>
          </div>
        </div>
      </Modal>

      <Modal title={t('edit')} open={modalType === 'patient'} onClose={() => setModalType(null)}>
        <div className="space-y-3">
          <Input label={t('fullName')} value={editForm.fullName || ''} onChange={(v: string) => setEditForm({ ...editForm, fullName: v })} />
          <Input label={t('phone')} value={editForm.phone || ''} onChange={(v: string) => setEditForm({ ...editForm, phone: v })} />
          <Input label={t('address')} value={editForm.address || ''} onChange={(v: string) => setEditForm({ ...editForm, address: v })} />
          <div className="flex gap-2 mt-4">
            <button onClick={() => setModalType(null)} className="flex-1 py-2 border-2 border-slate-300 rounded-lg">إلغاء</button>
            <button onClick={handleSavePatient} className="flex-1 py-2 bg-teal-600 text-white rounded-lg font-semibold">{t('save')}</button>
          </div>
        </div>
      </Modal>

      <Modal title={t('orderDetails')} open={modalType === 'order'} onClose={() => setModalType(null)}>
        {editForm && (
          <div className="space-y-3">
            <div className="p-3 bg-amber-50 border border-amber-200 rounded-lg text-sm text-amber-800 flex gap-2">
              <AlertTriangle className="w-5 h-5 flex-shrink-0" />
              <span>الأدمن فقط له صلاحية التعديل</span>
            </div>
            <AdminField label="Patient" value={editForm.patientName} />
            <AdminField label="Phone" value={editForm.patientPhone} />
            <AdminField label="Address" value={editForm.patientAddress} />
            <AdminField label="Area" value={editForm.area} />
            <div>
              <label className="text-sm font-semibold text-slate-500">Status</label>
              <select
                value={editForm.status}
                onChange={e => setEditForm({ ...editForm, status: e.target.value })}
                className="w-full px-3 py-2 border border-slate-300 rounded-lg mt-1"
              >
                <option value="active">Active</option>
                <option value="pending">Pending</option>
                <option value="completed">Completed</option>
                <option value="cancelled">Cancelled</option>
              </select>
            </div>
            <div className="flex gap-2 mt-4">
              <button onClick={() => setModalType(null)} className="flex-1 py-2 border-2 border-slate-300 rounded-lg">إلغاء</button>
              <button onClick={handleSaveOrder} className="flex-1 py-2 bg-teal-600 text-white rounded-lg font-semibold">{t('save')}</button>
            </div>
          </div>
        )}
      </Modal>

      <Modal title={t('addService')} open={modalType === 'service'} onClose={() => setModalType(null)}>
        <div className="space-y-3">
          <Input label="الاسم بالعربية" value={editForm.nameAr || ''} onChange={(v: string) => setEditForm({ ...editForm, nameAr: v })} />
          <Input label="الاسم بالإنجليزية" value={editForm.nameEn || ''} onChange={(v: string) => setEditForm({ ...editForm, nameEn: v })} />
          <Input label="الإيموجي" value={editForm.icon || ''} onChange={(v: string) => setEditForm({ ...editForm, icon: v })} />
          <Input label={t('price')} value={editForm.price || ''} onChange={(v: string) => setEditForm({ ...editForm, price: +v })} type="number" />
          <label className="flex items-center gap-2">
            <input type="checkbox" checked={!!editForm.perHour} onChange={e => setEditForm({ ...editForm, perHour: e.target.checked })} />
            <span className="text-sm">بالساعة</span>
          </label>
          <div className="flex gap-2 mt-4">
            <button onClick={() => setModalType(null)} className="flex-1 py-2 border-2 border-slate-300 rounded-lg">إلغاء</button>
            <button onClick={handleAddService} className="flex-1 py-2 bg-teal-600 text-white rounded-lg font-semibold">{t('addService')}</button>
          </div>
        </div>
      </Modal>

      <Modal title={t('addArea')} open={modalType === 'area'} onClose={() => setModalType(null)}>
        <div className="space-y-3">
          <Input label="الاسم بالعربية" value={editForm.nameAr || ''} onChange={(v: string) => setEditForm({ ...editForm, nameAr: v })} />
          <Input label="الاسم بالإنجليزية" value={editForm.nameEn || ''} onChange={(v: string) => setEditForm({ ...editForm, nameEn: v })} />
          <Input label={t('price')} value={editForm.price || ''} onChange={(v: string) => setEditForm({ ...editForm, price: +v })} type="number" />
          <div className="flex gap-2 mt-4">
            <button onClick={() => setModalType(null)} className="flex-1 py-2 border-2 border-slate-300 rounded-lg">إلغاء</button>
            <button onClick={handleAddArea} className="flex-1 py-2 bg-teal-600 text-white rounded-lg font-semibold">{t('addArea')}</button>
          </div>
        </div>
      </Modal>

      <Modal title="طلبات المريض" open={modalType === 'patientOrders'} onClose={() => setModalType(null)}>
        {patientOrders.length === 0 ? (
          <div className="text-center py-8 text-slate-400">لا توجد طلبات</div>
        ) : (
          <div className="space-y-3 max-h-96 overflow-y-auto">
              {patientOrders.map((o, i) => (
              <div key={o.id} className="border border-slate-200 rounded-xl p-3 text-sm">
                <div className="flex justify-between items-center mb-1">
                  <span className="font-bold text-slate-800">طلب #{o.orderNumber || (i + 1)}</span>
                  <span className={`px-2 py-0.5 rounded-full text-xs font-semibold ${
                    o.status === 'completed' ? 'bg-emerald-100 text-emerald-700' :
                    o.status === 'cancelled' ? 'bg-red-100 text-red-700' :
                    o.status === 'awaiting_completion' ? 'bg-purple-100 text-purple-700' :
                    o.status === 'in_progress' ? 'bg-blue-100 text-blue-700' :
                    'bg-cyan-100 text-cyan-700'
                  }`}>{o.status}</span>
                </div>
                <div className="text-xs text-slate-500">{o.date} • {o.area}</div>
                {o.nurseName && <div className="text-xs text-teal-600 mt-1">الممرض: {o.nurseName}</div>}
                <div className="text-xs text-slate-600 mt-1">الخدمات: {o.services?.join('، ')}</div>
                <div className="text-xs font-bold text-teal-600 mt-1">{o.totalPrice} ج.م</div>
                <div className="text-xs text-slate-400 mt-1 font-mono" dir="ltr">{o.id}</div>
              </div>
            ))}
          </div>
        )}
      </Modal>
    </div>
  );
}

function AdminStatCard({ icon: Icon, label, value, color }: any) {
  const colors: any = {
    teal: 'bg-teal-100 text-teal-600',
    cyan: 'bg-cyan-100 text-cyan-600',
    amber: 'bg-amber-100 text-amber-600',
    emerald: 'bg-emerald-100 text-emerald-600',
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

function AdminField({ label, value }: any) {
  return (
    <div className="flex justify-between py-2 border-b border-slate-100">
      <span className="text-sm font-semibold text-slate-500">{label}</span>
      <span className="text-sm text-slate-800">{value}</span>
    </div>
  );
}

function Input({ label, value, onChange, type = 'text' }: { label: string; value: any; onChange: (v: string) => void; type?: string }) {
  return (
    <div>
      <label className="block text-sm font-semibold text-slate-700 mb-1">{label}</label>
      <input
        type={type}
        value={value}
        onChange={e => onChange(e.target.value)}
        className="w-full px-3 py-2 border border-slate-300 rounded-lg focus:ring-2 focus:ring-teal-500"
      />
    </div>
  );
}
