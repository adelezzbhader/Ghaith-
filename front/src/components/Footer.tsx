import { MessageCircle, Heart } from 'lucide-react';
import { useLang } from '../contexts/LanguageContext';

export default function Footer() {
  const { t } = useLang();
  return (
    <footer className="bg-slate-900 text-slate-300 py-8 mt-16">
      <div className="max-w-7xl mx-auto px-4 text-center space-y-4">
        <div className="flex items-center justify-center gap-2">
          <Heart className="w-5 h-5 text-teal-400" fill="currentColor" />
          <span className="font-bold text-white text-lg">{t('brand')}</span>
        </div>
        <p className="text-sm">{t('footer')}</p>
      </div>
    </footer>
  );
}

export function WhatsAppFloat() {
  const { t } = useLang();
  return (
    <a
      href="https://wa.me/201145107113"
      target="_blank"
      rel="noopener noreferrer"
      className="fixed bottom-6 left-6 z-40 flex flex-col items-center group"
    >
      <div className="relative w-16 h-16 rounded-full bg-green-500 flex items-center justify-center shadow-2xl pulse-glow group-hover:scale-110 transition">
        <MessageCircle className="w-8 h-8 text-white" fill="white" />
      </div>
      <span className="mt-2 px-3 py-1 bg-slate-900 text-white text-xs rounded-full shadow-lg opacity-0 group-hover:opacity-100 transition">
        {t('contactUs')}
      </span>
      <span className="mt-1 text-xs text-slate-600 font-semibold">01145107113</span>
    </a>
  );
}
