import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../contexts/LanguageContext';
import { publicApi } from '../services/apiService';
import {
  UserRound,
  Stethoscope,
  TrendingUp,
  ShieldCheck,
  Users,
  Target,
  Eye,
  Award,
  CalendarCheck,
  MapPin,
  Clock,
  HeartHandshake,
  Phone,
  Mail,
} from 'lucide-react';

const serviceIcons: Record<string, string> = {
  '💉': '💉', '🩹': '🩹', '🩺': '🩺', '⚕️': '⚕️',
  '💊': '💊', '🫁': '🫁', '🏥': '🏥',
};

export default function Home() {
  const { t, lang } = useLang();
  const [stats, setStats] = useState({ dailyRequests: 0, clientTrust: 0, activeNurses: 0 });
  const [services, setServices] = useState<any[]>([]);
  const [servicesLoading, setServicesLoading] = useState(true);

  useEffect(() => {
    publicApi.getStats().then(setStats);
    publicApi.getServices()
      .then(setServices)
      .finally(() => setServicesLoading(false));
  }, []);

  const features = [
    { icon: Award, label: t('certifiedNurses'), desc: t('certifiedNursesDesc'), color: 'from-teal-500 to-emerald-600' },
    { icon: CalendarCheck, label: t('easyBooking'), desc: t('easyBookingDesc'), color: 'from-cyan-500 to-blue-600' },
    { icon: TrendingUp, label: t('fairPrices'), desc: t('fairPricesDesc'), color: 'from-emerald-500 to-green-600' },
    { icon: HeartHandshake, label: t('support247'), desc: t('support247Desc'), color: 'from-violet-500 to-purple-600' },
  ];

  const steps = [
    { icon: Stethoscope, label: t('step1Title'), desc: t('step1Desc') },
    { icon: MapPin, label: t('step2Title'), desc: t('step2Desc') },
    { icon: Clock, label: t('step3Title'), desc: t('step3Desc') },
  ];

  return (
    <div className="min-h-screen">
      {/* Hero Section */}
      <section className="hero-gradient text-white relative overflow-hidden">
        <div className="absolute inset-0 opacity-10">
          <div className="absolute top-20 right-10 w-72 h-72 bg-white rounded-full blur-3xl"></div>
          <div className="absolute bottom-20 left-10 w-96 h-96 bg-cyan-300 rounded-full blur-3xl"></div>
        </div>

        <div className="max-w-7xl mx-auto px-4 py-16 md:py-24 relative">
          <div className="text-center mb-10">
            <h1 className="text-6xl md:text-8xl font-black mb-4 drop-shadow-lg">
              {t('brand')}
            </h1>
            <p className="text-xl md:text-2xl opacity-95 font-light">{t('tagline')}</p>
          </div>

          {/* Role Selection Box */}
          <div className="max-w-3xl mx-auto bg-white/95 backdrop-blur-lg rounded-3xl shadow-2xl p-8 md:p-10 fade-in">
            <h2 className="text-2xl md:text-3xl font-bold text-slate-800 text-center mb-8">
              {t('chooseRole')}
            </h2>

            <div className="grid md:grid-cols-2 gap-6">
              <Link
                to="/nurse-register"
                className="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-teal-500 to-teal-700 p-8 text-white shadow-lg hover:shadow-2xl transition-all hover:-translate-y-1"
              >
                <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500"></div>
                <Stethoscope className="w-14 h-14 mb-4" />
                <h3 className="text-2xl font-bold mb-2">{t('nurse')}</h3>
                <p className="text-white/90 mb-4">{t('nurseDesc')}</p>
                <div className="inline-block bg-white text-teal-700 px-6 py-2 rounded-full font-bold group-hover:bg-teal-50 transition">
                  {t('enterAsNurse')}
                </div>
              </Link>

              <Link
                to="/patient-register"
                className="group relative overflow-hidden rounded-2xl bg-gradient-to-br from-cyan-500 to-cyan-700 p-8 text-white shadow-lg hover:shadow-2xl transition-all hover:-translate-y-1"
              >
                <div className="absolute top-0 right-0 w-32 h-32 bg-white/10 rounded-full -mr-16 -mt-16 group-hover:scale-150 transition-transform duration-500"></div>
                <UserRound className="w-14 h-14 mb-4" />
                <h3 className="text-2xl font-bold mb-2">{t('patient')}</h3>
                <p className="text-white/90 mb-4">{t('patientDesc')}</p>
                <div className="inline-block bg-white text-cyan-700 px-6 py-2 rounded-full font-bold group-hover:bg-cyan-50 transition">
                  {t('enterAsPatient')}
                </div>
              </Link>
            </div>
          </div>
        </div>
      </section>

      {/* Stats Bar */}
      <section className="max-w-7xl mx-auto px-4 -mt-8 relative z-10 mb-20">
        <div className="grid md:grid-cols-3 gap-4">
          <div className="bg-white rounded-2xl shadow-lg p-6 flex items-center gap-4 border border-teal-100">
            <div className="w-14 h-14 rounded-xl bg-teal-100 flex items-center justify-center">
              <TrendingUp className="w-7 h-7 text-teal-600" />
            </div>
            <div>
              <div className="text-sm text-slate-500">{t('dailyRequests')}</div>
              <div className="text-2xl font-bold text-slate-800">{stats.dailyRequests}+</div>
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 flex items-center gap-4 border border-teal-100">
            <div className="w-14 h-14 rounded-xl bg-cyan-100 flex items-center justify-center">
              <ShieldCheck className="w-7 h-7 text-cyan-600" />
            </div>
            <div>
              <div className="text-sm text-slate-500">{t('clientTrust')}</div>
              <div className="text-2xl font-bold text-slate-800">{stats.clientTrust}%</div>
            </div>
          </div>

          <div className="bg-white rounded-2xl shadow-lg p-6 flex items-center gap-4 border border-teal-100">
            <div className="w-14 h-14 rounded-xl bg-emerald-100 flex items-center justify-center">
              <Users className="w-7 h-7 text-emerald-600" />
            </div>
            <div>
              <div className="text-sm text-slate-500">{t('activeNurses')}</div>
              <div className="text-2xl font-bold text-slate-800">{stats.activeNurses}+</div>
            </div>
          </div>
        </div>
      </section>

      {/* About Us Section */}
      <section className="bg-gradient-to-br from-slate-50 to-white py-20">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-14">
            <h2 className="text-4xl md:text-5xl font-black text-slate-800 mb-4">{t('aboutUs')}</h2>
            <div className="w-20 h-1.5 bg-gradient-to-r from-teal-400 to-cyan-400 mx-auto rounded-full"></div>
          </div>
          <div className="max-w-4xl mx-auto text-center mb-16">
            <p className="text-lg text-slate-600 leading-relaxed mb-6">{t('aboutUsDesc1')}</p>
            <p className="text-lg text-slate-600 leading-relaxed">{t('aboutUsDesc2')}</p>
          </div>

          {/* Mission & Vision */}
          <div className="grid md:grid-cols-2 gap-8 max-w-4xl mx-auto">
            <div className="bg-white rounded-3xl p-8 shadow-lg border border-teal-100 hover:shadow-xl transition">
              <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-teal-400 to-teal-600 flex items-center justify-center mb-6">
                <Target className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-2xl font-bold text-slate-800 mb-3">{t('ourMission')}</h3>
              <p className="text-slate-600 leading-relaxed">{t('ourMissionDesc')}</p>
            </div>
            <div className="bg-white rounded-3xl p-8 shadow-lg border border-cyan-100 hover:shadow-xl transition">
              <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-cyan-400 to-cyan-600 flex items-center justify-center mb-6">
                <Eye className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-2xl font-bold text-slate-800 mb-3">{t('ourVision')}</h3>
              <p className="text-slate-600 leading-relaxed">{t('ourVisionDesc')}</p>
            </div>
          </div>
        </div>
      </section>

      {/* Why Choose Us */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-14">
            <h2 className="text-4xl md:text-5xl font-black text-slate-800 mb-4">{t('whyChooseUs')}</h2>
            <p className="text-xl text-slate-500">{t('whyChooseUsDesc')}</p>
            <div className="w-20 h-1.5 bg-gradient-to-r from-teal-400 to-cyan-400 mx-auto rounded-full mt-4"></div>
          </div>
          <div className="grid md:grid-cols-4 gap-6">
            {features.map((f, i) => (
              <div key={i} className="group bg-white rounded-3xl p-8 shadow-md hover:shadow-2xl transition-all hover:-translate-y-2 border border-slate-100">
                <div className={`w-16 h-16 rounded-2xl bg-gradient-to-br ${f.color} flex items-center justify-center mb-5 shadow-lg group-hover:scale-110 transition`}>
                  <f.icon className="w-8 h-8 text-white" />
                </div>
                <h3 className="text-xl font-bold text-slate-800 mb-3">{f.label}</h3>
                <p className="text-slate-500 leading-relaxed">{f.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="bg-gradient-to-br from-teal-50 to-cyan-50 py-20">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-14">
            <h2 className="text-4xl md:text-5xl font-black text-slate-800 mb-4">{t('howItWorks')}</h2>
            <div className="w-20 h-1.5 bg-gradient-to-r from-teal-400 to-cyan-400 mx-auto rounded-full"></div>
          </div>
          <div className="grid md:grid-cols-3 gap-8 max-w-4xl mx-auto">
            {steps.map((s, i) => (
              <div key={i} className="relative text-center">
                {i < steps.length - 1 && (
                  <div className="hidden md:block absolute top-12 left-[60%] w-[80%] h-0.5 border-t-2 border-dashed border-teal-300"></div>
                )}
                <div className="w-24 h-24 rounded-full bg-gradient-to-br from-teal-400 to-cyan-500 flex items-center justify-center mx-auto mb-6 shadow-lg">
                  <s.icon className="w-10 h-10 text-white" />
                </div>
                <div className="bg-white rounded-2xl p-6 shadow-md">
                  <div className="w-8 h-8 rounded-full bg-teal-100 text-teal-600 font-bold flex items-center justify-center mx-auto mb-3">
                    {i + 1}
                  </div>
                  <h3 className="text-xl font-bold text-slate-800 mb-2">{s.label}</h3>
                  <p className="text-slate-500">{s.desc}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Medical Services */}
      <section className="py-20">
        <div className="max-w-7xl mx-auto px-4">
          <div className="text-center mb-14">
            <h2 className="text-4xl md:text-5xl font-black text-slate-800 mb-4">{t('ourServices')}</h2>
            <p className="text-xl text-slate-500">{t('selectServices')}</p>
            <div className="w-20 h-1.5 bg-gradient-to-r from-teal-400 to-cyan-400 mx-auto rounded-full mt-4"></div>
          </div>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {servicesLoading ? (
              <div className="col-span-full text-center py-8 text-slate-400">{t('loading')}</div>
            ) : services.length === 0 ? (
              <div className="col-span-full text-center py-8 text-slate-400">{t('noServices')}</div>
            ) : services.map((s, i) => (
              <div key={s.id || i} className="bg-white rounded-2xl p-6 shadow-md hover:shadow-xl transition-all hover:-translate-y-1 text-center border border-slate-100">
                <div className="text-5xl mb-3">{serviceIcons[s.icon] || s.icon || '💉'}</div>
                <div className="font-semibold text-slate-700 text-sm">{lang === 'ar' ? s.nameAr : s.nameEn}</div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Contact / CTA Section */}
      <section className="bg-gradient-to-br from-teal-600 to-cyan-700 py-20">
        <div className="max-w-4xl mx-auto px-4 text-center text-white">
          <h2 className="text-4xl md:text-5xl font-black mb-6">{t('contactUs')}</h2>
          <p className="text-xl opacity-90 mb-10">{t('tagline')}</p>
          <div className="flex flex-col md:flex-row items-center justify-center gap-8 mb-10">
            <div className="flex items-center gap-3 bg-white/10 backdrop-blur rounded-2xl px-6 py-4">
              <Phone className="w-6 h-6" />
              <span className="text-lg font-semibold" dir="ltr">+20 100 000 0000</span>
            </div>
            <div className="flex items-center gap-3 bg-white/10 backdrop-blur rounded-2xl px-6 py-4">
              <Mail className="w-6 h-6" />
              <span className="text-lg font-semibold">info@ghaith.com</span>
            </div>
          </div>
          <div className="flex flex-col md:flex-row gap-4 justify-center">
            <Link
              to="/patient-register"
              className="bg-white text-teal-700 px-10 py-4 rounded-2xl font-bold text-lg hover:bg-teal-50 transition shadow-lg"
            >
              {t('enterAsPatient')}
            </Link>
            <Link
              to="/nurse-register"
              className="bg-white/10 backdrop-blur text-white border-2 border-white px-10 py-4 rounded-2xl font-bold text-lg hover:bg-white/20 transition"
            >
              {t('enterAsNurse')}
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}
