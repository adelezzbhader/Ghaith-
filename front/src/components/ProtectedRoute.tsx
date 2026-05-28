import { Navigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';

type Props = {
  children: React.ReactNode;
  role?: 'nurse' | 'patient' | 'admin';
};

export default function ProtectedRoute({ children, role }: Props) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" replace />;
  const userRole = (user.role || '').toLowerCase();
  if (role && userRole !== role) {
    return <Navigate to="/login" replace />;
  }
  return <>{children}</>;
}
