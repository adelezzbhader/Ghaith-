import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { translations, Lang } from '../i18n/translations';

type LangContextType = {
  lang: Lang;
  setLang: (l: Lang) => void;
  t: (key: keyof typeof translations.ar) => string;
  dir: 'rtl' | 'ltr';
};

const LangContext = createContext<LangContextType | null>(null);

export function LangProvider({ children }: { children: ReactNode }) {
  const [lang, setLangState] = useState<Lang>(() => {
    return (localStorage.getItem('ghaith_lang') as Lang) || 'ar';
  });

  const setLang = (l: Lang) => {
    setLangState(l);
    localStorage.setItem('ghaith_lang', l);
  };

  useEffect(() => {
    document.documentElement.lang = lang;
    document.documentElement.dir = lang === 'ar' ? 'rtl' : 'ltr';
  }, [lang]);

  const t = (key: keyof typeof translations.ar) => {
    return (translations[lang] as any)[key] || key;
  };

  const dir: 'rtl' | 'ltr' = lang === 'ar' ? 'rtl' : 'ltr';

  return (
    <LangContext.Provider value={{ lang, setLang, t, dir }}>
      {children}
    </LangContext.Provider>
  );
}

export const useLang = () => {
  const ctx = useContext(LangContext);
  if (!ctx) throw new Error('useLang must be used within LangProvider');
  return ctx;
};
