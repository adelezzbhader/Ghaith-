/**
 * 🔌 Unified API service - All API calls go through here.
 * Falls back to mock data when backend is unreachable.
 * 🔧 Change endpoints in ./api.ts
 *
 * IMPORTANT: Field name mapping between frontend (camelCase) and backend (snake_case):
 * - Login/register sends camelCase to frontend forms, converts to snake_case for backend
 * - Backend responses use snake_case, frontend components access via mapped getters
 */

import { api, ENDPOINTS } from './api';
import * as mock from './mockData';

type BackendData = Record<string, any>;

/** Only fall back to mock data on network errors (backend unreachable),
 *  not on HTTP errors (400/401/500) — so real errors are visible. */
const tryApi = async <T>(fn: () => Promise<T>, fallback: T): Promise<T> => {
  try {
    return await fn();
  } catch (err: any) {
    if (!err.response) {
      console.warn('⚠️ Backend unreachable, using mock data:', err.message);
      return fallback;
    }
    throw err;
  }
};

/** Convert camelCase keys to snake_case for backend */
const toSnake = (obj: BackendData): BackendData => {
  const result: BackendData = {};
  for (const [key, value] of Object.entries(obj)) {
    const snake = key.replace(/[A-Z]/g, letter => `_${letter.toLowerCase()}`);
    result[snake] = value;
  }
  return result;
};

/** Normalize order from backend (nested patient/items) to flat format for cards */
const normalizeOrder = (o: any) => ({
  ...o,
  patientName: o.patient?.fullName || o.patientName || '—',
  patientPhone: o.patient?.phone || o.patientPhone || '—',
  patientAddress: o.address || o.patientAddress || '—',
  area: o.areaNameAr || o.areaNameEn || o.area || '—',
  services: o.items?.map((i: any) => i.serviceNameAr || i.serviceNameEn) || o.services || [],
  totalPrice: o.finalPrice ?? o.totalPrice ?? 0,
  date: o.createdAt?.split('T')[0] || o.date || o.createdAt || '—',
  nurseName: o.nurse?.fullName || o.nurseName || null,
  status: (o.status || '').toLowerCase(),
  nurseConfirmedCompletion: o.nurseConfirmedCompletion ?? false,
  patientConfirmedCompletion: o.patientConfirmedCompletion ?? false,
});

// ===== AUTH =====
export const authApi = {
  login: async (email: string, password: string, role: 'nurse' | 'patient' | 'admin') => {
    if (email.toLowerCase() === 'admin@ghaith.com' && role === 'admin') {
      return tryApi(async () => {
        const res = await api.post(ENDPOINTS.login, { email, password });
        return {
          access: res.data.access,
          refresh: res.data.refresh,
          user: { ...res.data.user },
        };
      }, { access: 'mock-token-admin', refresh: 'mock-refresh-admin', user: { id: 'admin', fullName: 'المدير العام', email: 'admin@ghaith.com', role: 'admin' } });
    }
    const res = await api.post(ENDPOINTS.login, { email, password });
    return {
      access: res.data.access,
      refresh: res.data.refresh,
      user: { ...res.data.user },
    };
  },
  registerNurse: async (data: any) => {
    const formData = new FormData();
    const fieldMap: BackendData = {
      fullName: 'full_name',
      phone: 'phone',
      email: 'email',
      address: 'address',
      wallet: 'wallet_number',
      gender: 'gender',
      password: 'password',
      interviewDate: 'interview_date',
    };
    for (const [frontField, backField] of Object.entries(fieldMap)) {
      if (data[frontField] !== undefined && data[frontField] !== '') {
        let value = data[frontField];
        if (frontField === 'gender') value = value.toUpperCase();
        if (frontField === 'interviewDate') value = value.split('T')[0];
        formData.append(backField, value);
      }
    }
    if (data.photo instanceof File) formData.append('profile_image', data.photo);
    if (data.certificate instanceof File) formData.append('graduation_certificate', data.certificate);
    if (data.syndicateCard instanceof File) formData.append('syndicate_card', data.syndicateCard);
    const res = await api.post(ENDPOINTS.registerNurse, formData);
    return res.data;
  },
  registerPatient: async (data: any) => {
    const payload = toSnake(data);
    if (payload.gender) payload.gender = payload.gender.toUpperCase();
    payload.accepted_terms = true;
    const res = await api.post(ENDPOINTS.registerPatient, payload);
    return {
      access: res.data.access,
      user: { ...res.data.user, role: 'patient' },
    };
  },
};

// ===== PUBLIC =====
export const publicApi = {
  getServices: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.services);
      const services = Array.isArray(res.data) ? res.data : res.data.results || [];
      return services.map((s: any) => ({ ...s, perHour: s.perHour ?? s.isHourly, icon: s.icon || '💉' }));
    }, mock.mockServices);
  },
  getAreas: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.areas);
      const areas = Array.isArray(res.data) ? res.data : res.data.results || [];
      return areas.map((a: any) => ({ ...a, price: a.price ?? a.transportationFee }));
    }, mock.mockAreas);
  },
  getStats: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.siteStats);
      return res.data;
    }, mock.mockSiteStats);
  },
};

// ===== NURSE =====
export const nurseApi = {
  getProfile: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.profile);
      return res.data;
    }, { id: 'n1', fullName: 'ممرض تجريبي', role: 'nurse', phone: '01145107113', email: 'nurse@ghaith.com', address: 'القاهرة', gender: 'male' });
  },
  getActiveOrders: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.nurseActiveOrders);
      const orders = Array.isArray(res.data) ? res.data : res.data.results || [];
      return orders.map(normalizeOrder);
    }, mock.mockActiveOrders);
  },
  getMyOrders: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.nurseOrders);
      const orders = Array.isArray(res.data) ? res.data : res.data.results || [];
      return orders.map(normalizeOrder);
    }, [...mock.mockPendingOrders, ...mock.mockCompletedOrders]);
  },
  acceptOrder: async (id: string) => {
    const res = await api.post(ENDPOINTS.nurseAcceptOrder(id));
    return res.data;
  },
  completeOrder: async (id: string) => {
    const res = await api.post(ENDPOINTS.nurseCompleteOrder(id));
    return res.data;
  },
  cancelOrder: async (id: string) => {
    const res = await api.post(ENDPOINTS.nurseCancelOrder(id));
    return res.data;
  },
  getEarnings: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.nurseEarnings);
      return res.data;
    }, mock.mockEarnings);
  },
  getRatings: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.nurseRatings);
      return Array.isArray(res.data) ? res.data : res.data.results || [];
    }, mock.mockRatings);
  },
  getStats: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.nurseStats);
      return res.data;
    }, { totalVisits: 87, monthlyEarnings: 4500, avgRating: 4.8, activeOrders: 3 });
  },
};

// ===== PATIENT =====
export const patientApi = {
  getProfile: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.profile);
      return res.data;
    }, { id: 'p1', fullName: 'مريض تجريبي', role: 'patient', phone: '01012345678', email: 'patient@ghaith.com', address: 'الجيزة', gender: 'female' });
  },
  updateAddress: async (address: string) => {
    const res = await api.patch(ENDPOINTS.profile, { address });
    return res.data;
  },
  getOrders: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.patientOrders);
      const orders = Array.isArray(res.data) ? res.data : res.data.results || [];
      return orders.map(normalizeOrder);
    }, [...mock.mockPendingOrders, ...mock.mockCompletedOrders]);
  },
  createOrder: async (data: any) => {
    const payload: BackendData = {
      area_id: data.area,
      address: data.address || '',
      services: (data.services || []).map((id: string) => ({ service_id: id, quantity: 1 })),
    };
    const res = await api.post(ENDPOINTS.patientCreateOrder, payload);
    return res.data;
  },
  completeOrder: async (id: string) => {
    const res = await api.post(ENDPOINTS.patientCompleteOrder(id));
    return res.data;
  },
  cancelOrder: async (id: string) => {
    const res = await api.post(ENDPOINTS.patientCancelOrder(id));
    return res.data;
  },
  rateOrder: async (id: string, data: { score: number; comment?: string }) => {
    const res = await api.post(ENDPOINTS.patientRateOrder(id), data);
    return res.data;
  },
};

// ===== ADMIN =====
export const adminApi = {
  getStats: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminStats);
      return res.data;
    }, { nurses: 43, patients: 218, orders: 512, revenue: 128500 });
  },
  getJoinRequests: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminJoinRequests);
      return Array.isArray(res.data) ? res.data : res.data.results || [];
    }, mock.mockJoinRequests);
  },
  approveNurse: async (id: string) => {
    const res = await api.post(ENDPOINTS.adminApproveNurse(id));
    return res.data;
  },
  rejectNurse: async (id: string) => {
    const res = await api.post(ENDPOINTS.adminRejectNurse(id), { reason: '' });
    return res.data;
  },
  getNurses: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminNurses);
      return Array.isArray(res.data) ? res.data : res.data.results || [];
    }, mock.mockNurses);
  },
  updateNurse: async (id: string, data: any) => {
    const res = await api.patch(ENDPOINTS.adminUpdateNurse(id), toSnake(data));
    return res.data;
  },
  deleteNurse: async (id: string) => {
    const res = await api.delete(ENDPOINTS.adminDeleteNurse(id));
    return res.data;
  },
  getPatients: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminPatients);
      return Array.isArray(res.data) ? res.data : res.data.results || [];
    }, mock.mockPatients);
  },
  updatePatient: async (id: string, data: any) => {
    const res = await api.patch(ENDPOINTS.adminUpdatePatient(id), toSnake(data));
    return res.data;
  },
  deletePatient: async (id: string) => {
    const res = await api.delete(ENDPOINTS.adminDeletePatient(id));
    return res.data;
  },
  getPatientOrders: async (id: string) => {
    const res = await api.get(ENDPOINTS.adminPatientOrders(id));
    const orders = Array.isArray(res.data) ? res.data : res.data.results || [];
    return orders.map(normalizeOrder);
  },
  getOrders: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminOrders);
      const orders = Array.isArray(res.data) ? res.data : res.data.results || [];
      return orders.map(normalizeOrder);
    }, [...mock.mockActiveOrders, ...mock.mockPendingOrders, ...mock.mockCompletedOrders]);
  },
  updateOrder: async (id: string, data: any) => {
    const res = await api.patch(ENDPOINTS.adminUpdateOrder(id), toSnake(data));
    return res.data;
  },
  cancelOrder: async (id: string) => {
    const res = await api.post(ENDPOINTS.adminCancelOrder(id));
    return res.data;
  },
  getServices: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminServices);
      const services = Array.isArray(res.data) ? res.data : res.data.results || [];
      return services.map((s: any) => ({ ...s, perHour: s.perHour ?? s.isHourly, icon: s.icon || '💉' }));
    }, mock.mockServices);
  },
  addService: async (data: any) => {
    const payload = toSnake(data);
    if (payload.per_hour !== undefined) {
      payload.is_hourly = payload.per_hour;
      delete payload.per_hour;
    }
    const res = await api.post(ENDPOINTS.adminAddService, payload);
    return res.data;
  },
  deleteService: async (id: string) => {
    const res = await api.delete(ENDPOINTS.adminDeleteService(id));
    return res.data;
  },
  getAreas: async () => {
    return tryApi(async () => {
      const res = await api.get(ENDPOINTS.adminAreas);
      const areas = Array.isArray(res.data) ? res.data : res.data.results || [];
      return areas.map((a: any) => ({ ...a, price: a.price ?? a.transportationFee }));
    }, mock.mockAreas);
  },
  addArea: async (data: any) => {
    const payload = toSnake(data);
    if (payload.price !== undefined) {
      payload.transportation_fee = payload.price;
      delete payload.price;
    }
    const res = await api.post(ENDPOINTS.adminAddArea, payload);
    return res.data;
  },
  deleteArea: async (id: string) => {
    const res = await api.delete(ENDPOINTS.adminDeleteArea(id));
    return res.data;
  },
};
