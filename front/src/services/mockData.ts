/**
 * 📦 Mock Data - Used as fallback when backend is not connected yet.
 * Once your backend is running, the real API will be called instead.
 */

export const mockServices = [
  { id: '1', nameAr: 'تركيب محاليل', nameEn: 'IV Drip', price: 100, icon: '💉' },
  { id: '2', nameAr: 'رعاية جرح', nameEn: 'Wound Care', price: 120, icon: '🩹' },
  { id: '3', nameAr: 'قياس ضغط وسكر', nameEn: 'BP & Sugar', price: 50, icon: '🩺' },
  { id: '4', nameAr: 'تغيير على قسطرة', nameEn: 'Catheter Change', price: 70, icon: '⚕️' },
  { id: '5', nameAr: 'حقن عضل', nameEn: 'IM Injection', price: 20, icon: '💊' },
  { id: '6', nameAr: 'حقن وريد', nameEn: 'IV Injection', price: 40, icon: '💉' },
  { id: '7', nameAr: 'جلسة تنفس', nameEn: 'Breathing Session', price: 80, icon: '🫁' },
  { id: '8', nameAr: 'رعاية كاملة', nameEn: 'Full Care', price: 50, icon: '🏥', perHour: true },
];

export const mockAreas = [
  { id: '1', nameAr: 'داخل المدينة', nameEn: 'Inside City', price: 50 },
  { id: '2', nameAr: 'الشرق', nameEn: 'East', price: 70 },
];

export const mockSiteStats = {
  dailyRequests: 127,
  clientTrust: 96,
  activeNurses: 43,
};

export const mockActiveOrders = [
  {
    id: 'o1',
    patientName: 'محمد أحمد',
    patientPhone: '01012345678',
    patientAddress: 'القاهرة - المعادي',
    services: ['تركيب محاليل', 'قياس ضغط وسكر'],
    totalPrice: 150,
    area: 'داخل المدينة',
    status: 'active',
    date: '2026-01-15',
  },
  {
    id: 'o2',
    patientName: 'فاطمة حسن',
    patientPhone: '01098765432',
    patientAddress: 'الجيزة - الهرم',
    services: ['حقن عضل'],
    totalPrice: 70,
    area: 'الشرق',
    status: 'active',
    date: '2026-01-15',
  },
  {
    id: 'o3',
    patientName: 'يوسف علي',
    patientPhone: '01111222333',
    patientAddress: 'الإسكندرية - سموحة',
    services: ['جلسة تنفس'],
    totalPrice: 130,
    area: 'داخل المدينة',
    status: 'active',
    date: '2026-01-14',
  },
];

export const mockPendingOrders = [
  {
    id: 'o4',
    patientName: 'خالد محمود',
    patientPhone: '01055667788',
    patientAddress: 'القاهرة - مدينة نصر',
    services: ['رعاية جرح'],
    totalPrice: 170,
    area: 'الشرق',
    status: 'pending',
    date: '2026-01-14',
    nurseName: 'أحمد محمد',
  },
];

export const mockCompletedOrders = [
  {
    id: 'o5',
    patientName: 'منى سعيد',
    patientPhone: '01234567890',
    patientAddress: 'القاهرة - مصر الجديدة',
    services: ['تركيب محاليل'],
    totalPrice: 150,
    area: 'داخل المدينة',
    status: 'completed',
    date: '2026-01-13',
    nurseName: 'أحمد محمد',
    rating: 5,
  },
  {
    id: 'o6',
    patientName: 'عمر خالد',
    patientPhone: '01299887766',
    patientAddress: 'الجيزة - 6 أكتوبر',
    services: ['قياس ضغط وسكر', 'حقن وريد'],
    totalPrice: 140,
    area: 'الشرق',
    status: 'completed',
    date: '2026-01-12',
    nurseName: 'أحمد محمد',
    rating: 4,
  },
];

export const mockJoinRequests = [
  {
    id: 'jr1',
    fullName: 'محمد إبراهيم',
    phone: '01098765432',
    email: 'mohamed.ibrahim@example.com',
    gender: 'male',
    address: 'القاهرة - المعادي',
    interviewDate: '2026-01-20',
    createdAt: '2026-01-10',
  },
  {
    id: 'jr2',
    fullName: 'نورا أحمد',
    phone: '01112345678',
    email: 'noura.ahmed@example.com',
    gender: 'female',
    address: 'الإسكندرية',
    interviewDate: '2026-01-22',
    createdAt: '2026-01-11',
  },
];

export const mockNurses = [
  { id: 'n1', fullName: 'أحمد محمد', firstName: 'أحمد', phone: '01145107113', email: 'nurse@ghaith.com', address: 'القاهرة', gender: 'male', wallet: '', rating: 4.8, totalVisits: 87, monthlyEarnings: 4500, status: 'approved' },
  { id: 'n2', fullName: 'مريم السيد', firstName: 'مريم', phone: '01099887766', email: 'mariam@ghaith.com', address: 'الإسكندرية', gender: 'female', wallet: '', rating: 4.9, totalVisits: 112, monthlyEarnings: 5800, status: 'approved' },
];

export const mockPatients = [
  { id: 'p1', fullName: 'مريض تجريبي', firstName: 'مريض', phone: '01012345678', email: 'patient@ghaith.com', address: 'الجيزة', gender: 'female' },
  { id: 'p2', fullName: 'علي حسن', firstName: 'علي', phone: '01055667788', email: 'ali@ghaith.com', address: 'القاهرة - مدينة نصر', gender: 'male' },
];

export const mockEarnings = {
  totalMonth: 4500,
  deducted: 300,
  actual: 4200,
  breakdown: [
    { date: '2026-01-10', amount: 500, order: 'o5' },
    { date: '2026-01-12', amount: 700, order: 'o6' },
    { date: '2026-01-13', amount: 450, order: 'o7' },
  ],
};

export const mockRatings = [
  { id: 'r1', orderId: 'o5', patientName: 'منى سعيد', rating: 5, comment: 'خدمة ممتازة جداً', date: '2026-01-13' },
  { id: 'r2', orderId: 'o6', patientName: 'عمر خالد', rating: 4, comment: 'جيد جداً', date: '2026-01-12' },
];
