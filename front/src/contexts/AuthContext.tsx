import { createContext, useContext, useState, useEffect, ReactNode } from 'react';

export type User = {
  id: string;
  fullName: string;
  firstName: string;
  email: string;
  phone?: string;
  address?: string;
  gender?: string;
  role: 'nurse' | 'patient' | 'admin';
  rating?: number;
  [key: string]: any;
};

type AuthContextType = {
  user: User | null;
  token: string | null;
  login: (token: string, user: User) => void;
  logout: () => void;
  updateUser: (u: Partial<User>) => void;
  isAdmin: () => boolean;
  isNurse: () => boolean;
  isPatient: () => boolean;
};

const AuthContext = createContext<AuthContextType | null>(null);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(() => {
    const stored = localStorage.getItem('ghaith_user');
    return stored ? JSON.parse(stored) : null;
  });
  const [token, setToken] = useState<string | null>(() => localStorage.getItem('ghaith_token'));

  useEffect(() => {
    if (user) localStorage.setItem('ghaith_user', JSON.stringify(user));
    else localStorage.removeItem('ghaith_user');
    if (token) localStorage.setItem('ghaith_token', token);
    else localStorage.removeItem('ghaith_token');
  }, [user, token]);

  const login = (newToken: string, newUser: User) => {
    setToken(newToken);
    setUser({ ...newUser, firstName: newUser.firstName || newUser.fullName?.split(' ')[0] || '' });
  };

  const logout = () => {
    setToken(null);
    setUser(null);
  };

  const updateUser = (updates: Partial<User>) => {
    if (user) setUser({ ...user, ...updates });
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        token,
        login,
        logout,
        updateUser,
        isAdmin: () => user?.role === 'admin',
        isNurse: () => user?.role === 'nurse',
        isPatient: () => user?.role === 'patient',
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
};
