import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom';
import { LangProvider } from './contexts/LanguageContext';
import { AuthProvider } from './contexts/AuthContext';
import { Toaster } from 'react-hot-toast';
import Navbar from './components/Navbar';
import Footer, { WhatsAppFloat } from './components/Footer';
import ProtectedRoute from './components/ProtectedRoute';

import Home from './pages/Home';
import Login from './pages/Login';
import NurseRegister from './pages/NurseRegister';
import PatientRegister from './pages/PatientRegister';
import NurseDashboard from './pages/nurse/NurseDashboard';
import PatientDashboard from './pages/patient/PatientDashboard';
import AdminDashboard from './pages/admin/AdminDashboard';

function AppContent() {
  const location = useLocation();
  const isDashboard = location.pathname.startsWith('/nurse') || 
                      location.pathname.startsWith('/patient') || 
                      location.pathname.startsWith('/admin');
  const hideFooter = isDashboard && location.pathname !== '/nurse-register' && location.pathname !== '/patient-register';

  return (
    <div className="min-h-screen flex flex-col">
      <Toaster position="top-center" toastOptions={{ duration: 4000, style: { direction: 'rtl' } }} />
      <Navbar />
      <div className="flex-1">
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/nurse-register" element={<NurseRegister />} />
          <Route path="/patient-register" element={<PatientRegister />} />
          <Route
            path="/nurse/*"
            element={
              <ProtectedRoute role="nurse">
                <NurseDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/patient/*"
            element={
              <ProtectedRoute role="patient">
                <PatientDashboard />
              </ProtectedRoute>
            }
          />
          <Route
            path="/admin/*"
            element={
              <ProtectedRoute role="admin">
                <AdminDashboard />
              </ProtectedRoute>
            }
          />
          <Route path="*" element={<Home />} />
        </Routes>
      </div>
      {!hideFooter && <Footer />}
      <WhatsAppFloat />
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <LangProvider>
        <AuthProvider>
          <AppContent />
        </AuthProvider>
      </LangProvider>
    </BrowserRouter>
  );
}
