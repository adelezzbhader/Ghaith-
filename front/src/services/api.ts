// ============================================================================
// ⚙️ API Configuration - Change BASE_URL here to connect to your backend
// ============================================================================

import axios, { AxiosError } from 'axios';

/**
 * Convert snake_case string to camelCase
 */
const snakeToCamel = (str: string): string =>
  str.replace(/_([a-z])/g, (_, c) => c.toUpperCase());

/**
 * Recursively convert object keys from snake_case to camelCase
 */
const convertKeys = (data: any): any => {
  if (data === null || data === undefined) return data;
  if (Array.isArray(data)) return data.map(convertKeys);
  if (typeof data === 'object' && !(data instanceof File)) {
    const result: Record<string, any> = {};
    for (const [key, value] of Object.entries(data)) {
      result[snakeToCamel(key)] = convertKeys(value);
    }
    return result;
  }
  return data;
};

/**
 * 🔧 غيّر هذا الرابط ليشير إلى الـ backend الخاص بك
 * مثال: 'http://localhost:5000/api' أو 'https://api.ghaith.com/api'
 */
/**
 * 🔧 Change BASE_URL to point to your Django backend
 * Default: http://localhost:8000/api/v1
 * Set VITE_API_URL env var to override
 */
export const BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:8000/api/v1';

/**
 * 🔧 All endpoints - these match the Django backend routes under /api/v1/
 */
export const ENDPOINTS = {
  // Auth
  login: '/auth/login/',
  registerNurse: '/auth/register/nurse/',
  registerPatient: '/auth/register/patient/',
  logout: '/auth/logout/',
  tokenRefresh: '/auth/token/refresh/',
  profile: '/profile/',

  // Nurse
  nurseActiveOrders: '/nurse/orders/active/',
  nurseOrders: '/nurse/orders/',
  nurseAcceptOrder: (id: string) => `/nurse/orders/${id}/accept/`,
  nurseCompleteOrder: (id: string) => `/nurse/orders/${id}/complete/`,
  nurseCancelOrder: (id: string) => `/nurse/orders/${id}/cancel/`,
  nurseEarnings: '/nurse/orders/earnings/',
  nurseRatings: '/nurse/orders/ratings/',
  nurseStats: '/nurse/stats/',

  // Patient
  patientOrders: '/patient/orders/',
  patientCreateOrder: '/patient/orders/',
  patientCompleteOrder: (id: string) => `/patient/orders/${id}/complete/`,
  patientCancelOrder: (id: string) => `/patient/orders/${id}/cancel/`,
  patientRateOrder: (id: string) => `/patient/orders/${id}/rate/`,

  // Public data
  services: '/services/',
  areas: '/areas/',
  siteStats: '/stats/',

  // Admin
  adminStats: '/admin/stats/',
  adminJoinRequests: '/admin/join-requests/',
  adminApproveNurse: (id: string) => `/admin/join-requests/${id}/approve/`,
  adminRejectNurse: (id: string) => `/admin/join-requests/${id}/reject/`,
  adminBlockNurse: (id: string) => `/admin/nurses/${id}/block/`,
  adminNurses: '/admin/nurses/',
  adminUpdateNurse: (id: string) => `/admin/nurses/${id}/`,
  adminDeleteNurse: (id: string) => `/admin/nurses/${id}/`,
  adminPatients: '/admin/patients/',
  adminUpdatePatient: (id: string) => `/admin/patients/${id}/`,
  adminDeletePatient: (id: string) => `/admin/patients/${id}/`,
  adminPatientOrders: (id: string) => `/admin/patients/${id}/orders/`,
  adminBlockPatient: (id: string) => `/admin/patients/${id}/block/`,
  adminOrders: '/admin/orders/',
  adminUpdateOrder: (id: string) => `/admin/orders/${id}/`,
  adminChangeOrderStatus: (id: string) => `/admin/orders/${id}/change-status/`,
  adminCancelOrder: (id: string) => `/admin/orders/${id}/cancel/`,
  adminServices: '/admin/services/',
  adminAddService: '/admin/services/',
  adminDeleteService: (id: string) => `/admin/services/${id}/`,
  adminAreas: '/admin/areas/',
  adminAddArea: '/admin/areas/',
  adminDeleteArea: (id: string) => `/admin/areas/${id}/`,
};

// Create axios instance with auth token
export const api = axios.create({
  baseURL: BASE_URL,
  timeout: 15000,
});

// Attach token to every request
api.interceptors.request.use((config) => {
  const token = localStorage.getItem('ghaith_token');
  if (token) {
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

/**
 * Response interceptor:
 * 1. Unwrap backend envelope: { success, message, data } -> data
 * 2. Convert snake_case keys to camelCase for frontend consistency
 * 3. Handle 401 globally (clear auth state)
 */
api.interceptors.response.use(
  (res) => {
    if (res.data && typeof res.data === 'object' && 'success' in res.data && 'data' in res.data && res.data.success) {
      res.data = res.data.data;
    }
    res.data = convertKeys(res.data);
    return res;
  },
  (err: AxiosError) => {
    if (err.response?.status === 401) {
      localStorage.removeItem('ghaith_token');
      localStorage.removeItem('ghaith_user');
    }
    return Promise.reject(err);
  }
);
