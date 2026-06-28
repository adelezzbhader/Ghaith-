# Integration Audit Report: Flutter Mobile App ↔ Django Backend

**Date:** 2026-06-17
**Scope:** All backend API endpoints vs Flutter mobile app consumption
**Status:** 36 issues found → 10 fixed, 26 remaining

---

## A. Issues Found & Fixed (10)

These issues were discovered during the audit and have been corrected.

| # | File | Issue | Fix |
|---|---|---|---|
| 1 | `main.dart:35` | `CheckAuthEvent` never dispatched on app startup — always redirects to login regardless of stored token | Added `BlocProvider.of<AuthBloc>(context).add(CheckAuthEvent())` in `_GhaithAppState.initState()` |
| 2 | `auth_event.dart:54` | `CheckAuthEvent` class had no `const` constructor; `main.dart` used `const CheckAuthEvent()` → compile error | Added `const CheckAuthEvent()` |
| 3 | `auth_repository_impl.dart` | `LoginResponseModel` not imported despite `_saveSession(LoginResponseModel)` call | Added import |
| 4 | `auth_repository_impl.dart` | `logout()` only cleared SecureStorage keys — never called backend `/auth/logout/` to blacklist refresh token | Added API call with fallback: if it fails, still clears local session |
| 5 | `auth_bloc.dart` | `LogoutEvent` handler used `SecureStorage` directly instead of repository | Switched to `_authRepository.logout()` |
| 6 | `app_constants.dart` | `refreshTokenKey` missing | Added `static const refreshTokenKey = 'refresh_token'` |
| 7 | `patient_repository_impl.dart:getProfile()` | Reads `data['name']` but backend returns `data['full_name']` | Changed to `data['full_name'] ?? data['name']` |
| 8 | `patient_order_model.dart` | Multiple field mapping mismatches: `status` (uppercase), `totalPrice` (field name), `patientName` (nested path), `area` (field name), `nurseName` (field name+path), `services` (field name), `patientPhone` (path) | Corrected all `fromJson`/`fromNestedJson` mappings |
| 9 | `nurse_order_model.dart` | `final_price` was 7th fallback for `totalPrice`; `patientName` prioritized wrong `patient['name']` over `patient['full_name']` | Promoted `final_price` to first priority; fixed `patientName` to read nested `patient['full_name']` |
| 10 | `patient_dashboard_screen.dart` | Missing status badges (`awaiting_completion`, `active`); action buttons not matching web gating; services not shown as chips; area price excluded from totals | Added status entries; aligned gating with web; added service chips; area-inclusive totals |

### Verification
- `dart analyze` passes with **0 errors, 0 warnings** (only pre-existing `info` level hints for deprecated `withOpacity`, style nits).

---

## B. Issues Found & Not Fixed (26)

### B1. High Priority — Functional Gaps

| # | Feature | Backend Endpoints | Flutter Status |
|---|---|---|---|
| 1 | **Token refresh** | `POST /auth/token/refresh/` | Constant defined in `api_constants.dart` but **never called**. No interceptor or manual refresh flow. When access token expires, user must re-login. |
| 2 | **Nurse earnings data mismatch** | `GET /nurse/orders/earnings/` → returns `{completed_orders, total_earnings}` (aggregate) | `EarningsModel` expects `{total_month, deducted, actual, breakdown[]}` — **completely incompatible shapes**. Tab renders zeros. |
| 3 | **Patient profile update** | `PATCH /profile/` supports `full_name`, `phone`, `address`, `gender` | Only `address` is exposed via `updateAddress()`. Name, phone, gender cannot be edited. |
| 4 | **Nurse profile update** | `PATCH /profile/` supports `full_name`, `phone`, `address`, `gender`, `wallet_number`, `profile_image` | No update UI for nurses at all. |

### B2. Medium Priority — Missing Features

| # | Feature | Backend Endpoints | Flutter Status |
|---|---|---|---|
| 5 | **User notifications** | `GET /notifications/`, `GET /notifications/unread-count/`, `POST /notifications/{id}/mark-read/`, `POST /notifications/mark-all-read/` | **Completely unimplemented.** Bell icon in nurse dashboard shows "Coming soon" snackbar. |
| 6 | **Admin dashboard** | `GET /admin/stats/` (orders count, nurses, patients, revenue) | **No admin screens exist** in the Flutter app. Admin users can only see patient/nurse dashboard depending on role, but no admin-specific UI. |
| 7 | **Admin nurse management** | `GET/PUT/PATCH/DELETE /admin/nurses/`, `POST /admin/nurses/{id}/approve/`, `POST /admin/nurses/{id}/reject/`, `POST /admin/nurses/{id}/block/` | **No admin screens.** `api_constants.dart` defines some paths but no code calls them. |
| 8 | **Admin patient management** | `GET/PUT/PATCH/DELETE /admin/patients/`, `POST /admin/patients/{id}/block/`, `GET /admin/patients/{id}/orders/` | **No admin screens.** |
| 9 | **Admin order management** | `GET/PUT/PATCH /admin/orders/`, `POST /admin/orders/{id}/change-status/`, `POST /admin/orders/{id}/cancel/` | **No admin screens.** |
| 10 | **Admin join requests** | `GET /admin/join-requests/`, `POST /admin/join-requests/{id}/approve/`, `POST /admin/join-requests/{id}/reject/` | **No admin screens.** `api_constants.dart` defines paths but no code calls them. |
| 11 | **Admin notifications** | `GET /admin/notifications/` | **No admin screens.** |
| 12 | **Admin services management** | `GET/POST/PUT/PATCH/DELETE /admin/services/` | **No admin screens.** `api_constants.dart` defines paths but no code calls them. |
| 13 | **Admin areas management** | `GET/POST/PUT/PATCH/DELETE /admin/areas/` | **No admin screens.** `api_constants.dart` defines paths but no code calls them. |

### B3. Low Priority — Missing Endpoint Constants

| # | Endpoint | Missing From `api_constants.dart` |
|---|---|---|
| 14 | `POST /admin/nurses/{id}/approve/` | Not defined |
| 15 | `POST /admin/nurses/{id}/reject/` | Not defined |
| 16 | `POST /admin/nurses/{id}/block/` | Not defined |
| 17 | `POST /admin/patients/{id}/block/` | Not defined |
| 18 | `POST /admin/orders/{id}/change-status/` | Not defined |
| 19 | `GET /notifications/unread-count/` | Not defined |
| 20 | `POST /notifications/{id}/mark-read/` | Not defined |
| 21 | `POST /notifications/mark-all-read/` | Not defined |

### B4. Info — Not Expected in Mobile

| # | Feature | Rationale |
|---|---|---|
| 22 | Django Admin (`/admin/`) | Browser-only admin panel, not expected on mobile |
| 23 | API Schema (`/schema/`, `/docs/`) | Dev tools, not expected on mobile |
| 24 | Password reset | Not implemented on backend either — no endpoint exists |
| 25 | Coupons/promotions | Not implemented on backend |
| 26 | Payment integration | Not implemented on backend |

---

## C. Architecture & Data Flow (What Works)

### C1. Authentication Flow
```
Login Screen
  → AuthBloc(LoginEvent)
    → AuthRepositoryImpl.login()
      → AuthRemoteDataSource.login() → POST /auth/login/
      ← LoginResponseModel(token, refresh, user)
    ← User logged in state
  → Navigate to PatientDashboard or NurseDashboard

[FIXED] App Startup
  → _GhaithAppState.initState()
    → AuthBloc(CheckAuthEvent)
      → AuthRepositoryImpl.checkAuth()
        → SecureStorage.hasToken()
      ← Authenticated or Unauthenticated
    → Navigate accordingly
```

### C2. Patient Order Flow
```
PatientDashboard
  → PatientBloc(GetOrdersEvent)
    → PatientRepositoryImpl.getOrders()
      → PatientRemoteDataSource.getOrders() → GET /patient/orders/
      ← List<PatientOrderModel>
    ← Orders loaded

Create Order
  → OrderWizardScreen (3 steps: services → area → confirm)
    → PatientBloc(CreateOrderEvent)
      → PatientRepositoryImpl.createOrder()
        → PatientRemoteDataSource.createOrder() → POST /patient/orders/
      ← Order created

Order Actions (Complete / Cancel / Rate)
  → PatientBloc(CompleteOrderEvent / CancelOrderEvent / RateOrderEvent)
    → PatientRemoteDataSource.completeOrder / cancelOrder / rateOrder
      → POST /patient/orders/{id}/complete|cancel|rate/
```

### C3. Nurse Order Flow
```
NurseDashboard (OrderTapController with tabs)
  → NurseBloc(GetActiveOrdersEvent / GetMyOrdersEvent)
    → NurseRepositoryImpl()
      → NurseRemoteDataSource.getActiveOrders() → GET /nurse/orders/active/
      → NurseRemoteDataSource.getMyOrders()    → GET /nurse/orders/
    ← Orders displayed per tab

Order Actions (Accept / Complete / Cancel)
  → NurseBloc(AcceptOrderEvent / CompleteOrderEvent / CancelOrderEvent)
    → NurseRemoteDataSource.acceptOrder / completeOrder / cancelOrder
      → POST /nurse/orders/{id}/accept|complete|cancel/
```

### C4. Home Screen
```
HomeScreen
  → HomeBloc(GetHomeDataEvent)
    → HomeRepositoryImpl()
      → HomeRemoteDataSource.getServices() → GET /services/
      → HomeRemoteDataSource.getAreas()    → GET /areas/
      → HomeRemoteDataSource.getStats()    → GET /stats/
    ← Home data loaded
```

---

## D. Backend API Reference (All Endpoints)

| Method | Endpoint | Purpose | Consumed? |
|--------|----------|---------|-----------|
| POST | `/auth/register/patient/` | Register patient | ✅ Yes |
| POST | `/auth/register/nurse/` | Register nurse (multipart) | ✅ Yes |
| POST | `/auth/login/` | Login | ✅ Yes |
| POST | `/auth/logout/` | Logout (blacklist refresh) | ✅ Yes (FIXED) |
| POST | `/auth/token/refresh/` | Refresh access token | ❌ No |
| GET/PATCH | `/profile/` | Get/update profile | ⚠️ Partial |
| GET | `/stats/` | Site statistics | ✅ Yes |
| GET | `/services/` | List services | ✅ Yes |
| GET | `/areas/` | List areas | ✅ Yes |
| GET | `/nurse/stats/` | Nurse statistics | ✅ Yes |
| GET | `/patient/orders/` | List patient orders | ✅ Yes |
| POST | `/patient/orders/` | Create order | ✅ Yes |
| POST | `/patient/orders/{id}/complete/` | Patient complete | ✅ Yes |
| POST | `/patient/orders/{id}/cancel/` | Patient cancel | ✅ Yes |
| POST | `/patient/orders/{id}/rate/` | Rate order | ✅ Yes |
| GET | `/nurse/orders/` | List nurse orders | ✅ Yes |
| GET | `/nurse/orders/active/` | Active available orders | ✅ Yes |
| POST | `/nurse/orders/{id}/accept/` | Nurse accept | ✅ Yes |
| POST | `/nurse/orders/{id}/complete/` | Nurse complete | ✅ Yes |
| POST | `/nurse/orders/{id}/cancel/` | Nurse cancel | ✅ Yes |
| GET | `/nurse/orders/earnings/` | Nurse earnings | ⚠️ Shape mismatch |
| GET | `/nurse/orders/ratings/` | Nurse ratings | ✅ Yes |
| GET | `/notifications/` | User notifications | ❌ No |
| GET | `/notifications/unread-count/` | Unread count | ❌ No |
| POST | `/notifications/{id}/mark-read/` | Mark read | ❌ No |
| POST | `/notifications/mark-all-read/` | Mark all read | ❌ No |
| GET | `/admin/stats/` | Admin dashboard stats | ❌ No |
| GET/PUT/PATCH/DELETE | `/admin/nurses/` | Manage nurses | ❌ No |
| POST | `/admin/nurses/{id}/approve/` | Approve nurse | ❌ No |
| POST | `/admin/nurses/{id}/reject/` | Reject nurse | ❌ No |
| POST | `/admin/nurses/{id}/block/` | Block nurse | ❌ No |
| GET/PUT/PATCH/DELETE | `/admin/patients/` | Manage patients | ❌ No |
| POST | `/admin/patients/{id}/block/` | Block patient | ❌ No |
| GET | `/admin/patients/{id}/orders/` | Patient orders | ❌ No |
| GET/PUT/PATCH | `/admin/orders/` | Manage orders | ❌ No |
| POST | `/admin/orders/{id}/change-status/` | Change status | ❌ No |
| POST | `/admin/orders/{id}/cancel/` | Cancel order | ❌ No |
| GET/POST/PUT/PATCH/DELETE | `/admin/services/` | Manage services | ❌ No |
| GET/POST/PUT/PATCH/DELETE | `/admin/areas/` | Manage areas | ❌ No |
| GET | `/admin/join-requests/` | Join requests | ❌ No |
| POST | `/admin/join-requests/{id}/approve/` | Approve request | ❌ No |
| POST | `/admin/join-requests/{id}/reject/` | Reject request | ❌ No |
| GET | `/admin/notifications/` | Admin notifications | ❌ No |

---

## E. Recommendations

### Immediate (High Impact, Low Effort)

1. **Implement token refresh interceptor** — Add a `QueuedInterceptor` in Dio that catches 401, calls `/auth/token/refresh/` with the stored refresh token, retries the original request. This prevents users from being logged out mid-session.

2. **Fix earnings data model** — Either:
   - Change `EarningsModel` to match backend's `{completed_orders, total_earnings}` (preferred — matches what backend actually returns), OR
   - Add a backend endpoint/aggregation that returns detailed breakdown with `total_month`, `deducted`, `actual`, `breakdown[]`.

3. **Add nurse profile editing** — Add an edit button on nurse profile tab that opens a form for `full_name`, `phone`, `address`, `gender`, `wallet_number`.

4. **Add patient profile editing** — Extend `updateAddress()` to `updateProfile()` supporting `full_name`, `phone`, `gender` in addition to `address`.

### Medium Term

5. **Build admin mobile screens** — The backend has 22+ admin endpoints. Prioritize nurse approval workflow and dashboard stats.

6. **Implement notification UI** — Bell icon should show unread count badge, open a notification list, and support mark-read actions.

7. **Add password reset flow** — Requires backend work first (no endpoint exists yet).

### Future

8. **Payment gateway integration** — Not in backend; would need Stripe/PayMob/whatever Egypt uses.

9. **Real-time updates** — Consider WebSocket for order status changes instead of polling.

10. **Push notifications** — Integrate with FCM for real-time order alerts.
