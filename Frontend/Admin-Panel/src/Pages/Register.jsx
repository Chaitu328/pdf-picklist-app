import { useState } from "react";
import { useNavigate, Link } from "react-router-dom";
import { 
  Mail, 
  Lock, 
  User, 
  ShieldCheck,
  Loader2, 
  AlertCircle, 
  CheckCircle2, 
  Warehouse, 
  ArrowRight, 
  PackageCheck, 
  Truck, 
  BarChart3,
  Eye,
  EyeOff,
  X,
  ChevronDown
} from "lucide-react";

/* ─── Toast ─── */
function Toast({ message, type, onClose }) {
  return (
    <div className="fixed top-6 right-6 z-50 animate-in fade-in slide-in-from-right-full duration-300">
      <div className={`flex items-center gap-3 px-5 py-4 rounded-xl shadow-xl border backdrop-blur-sm ${
        type === "success" 
          ? "bg-white/95 border-green-200 text-green-800" 
          : "bg-white/95 border-red-200 text-red-800"
      }`}>
        {type === "success" ? (
          <CheckCircle2 className="w-5 h-5 text-green-500 shrink-0" />
        ) : (
          <AlertCircle className="w-5 h-5 text-red-500 shrink-0" />
        )}
        <p className="text-sm font-semibold">{message}</p>
        <button 
          onClick={onClose}
          className="ml-2 text-gray-400 hover:text-gray-600 transition-colors"
        >
          <X className="w-4 h-4" />
        </button>
      </div>
    </div>
  );
}

/* ─── Feature Item ─── */
function FeatureItem({ icon: Icon, text }) {
  return (
    <div className="flex items-center gap-3 text-white/80">
      <div className="p-1.5 rounded-lg bg-white/10 backdrop-blur-sm">
        <Icon className="w-4 h-4 text-white" />
      </div>
      <span className="text-sm font-medium">{text}</span>
    </div>
  );
}

/* ─── Input Field ─── */
function InputField({ label, type, value, onChange, placeholder, icon: Icon, error }) {
  const [showPassword, setShowPassword] = useState(false);
  const isPassword = type === "password";
  const inputType = isPassword ? (showPassword ? "text" : "password") : type;

  return (
    <div className="space-y-1.5">
      <label className="block text-sm font-semibold text-gray-700">{label}</label>
      <div className="relative group">
        <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-indigo-500 transition-colors duration-200">
          <Icon className="w-5 h-5" />
        </div>
        <input
          type={inputType}
          value={value}
          onChange={onChange}
          placeholder={placeholder}
          className={`w-full pl-11 ${isPassword ? 'pr-11' : 'pr-4'} py-3 bg-gray-50 border rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none transition-all duration-200 ${
            error 
              ? "border-red-300 focus:border-red-500 focus:ring-4 focus:ring-red-500/10 bg-red-50/30" 
              : "border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 hover:border-gray-300"
          }`}
        />
        {isPassword && (
          <button
            type="button"
            onClick={() => setShowPassword(!showPassword)}
            className="absolute right-3.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors"
          >
            {showPassword ? <Eye className="w-4 h-4" /> : <EyeOff className="w-4 h-4" /> }
          </button>
        )}
      </div>
      {error && (
        <p className="text-xs font-medium text-red-500 flex items-center gap-1">
          <AlertCircle className="w-3 h-3" />
          {error}
        </p>
      )}
    </div>
  );
}

/* ─── Select Field ─── */
function SelectField({ label, value, onChange, options, icon: Icon, error }) {
  return (
    <div className="space-y-1.5">
      <label className="block text-sm font-semibold text-gray-700">{label}</label>
      <div className="relative group">
        <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-indigo-500 transition-colors duration-200">
          <Icon className="w-5 h-5" />
        </div>
        <select
          value={value}
          onChange={onChange}
          className={`w-full pl-11 pr-10 py-3 bg-gray-50 border rounded-xl text-sm text-gray-900 outline-none appearance-none transition-all duration-200 ${
            error 
              ? "border-red-300 focus:border-red-500 focus:ring-4 focus:ring-red-500/10 bg-red-50/30" 
              : "border-gray-200 focus:border-indigo-500 focus:ring-4 focus:ring-indigo-500/10 hover:border-gray-300"
          }`}
        >
          {options.map(opt => (
            <option key={opt.value} value={opt.value}>{opt.label}</option>
          ))}
        </select>
        <ChevronDown className="absolute right-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 pointer-events-none" />
      </div>
      {error && (
        <p className="text-xs font-medium text-red-500 flex items-center gap-1">
          <AlertCircle className="w-3 h-3" />
          {error}
        </p>
      )}
    </div>
  );
}

/* ─── Register Page ─── */
export default function Register() {
  const navigate = useNavigate();

  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [role, setRole] = useState("manager");
  const [isLoading, setIsLoading] = useState(false);
  const [errors, setErrors] = useState({});
  const [toast, setToast] = useState(null);

  const showToast = (message, type) => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 5000);
  };

  const validate = () => {
    const newErrors = {};
    if (!name.trim()) newErrors.name = "Full name is required";
    if (!email.trim()) {
      newErrors.email = "Email is required";
    } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      newErrors.email = "Please enter a valid email";
    }
    if (!password) {
      newErrors.password = "Password is required";
    } else if (password.length < 6) {
      newErrors.password = "Password must be at least 6 characters";
    }
    if (!role) newErrors.role = "Role is required";
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!validate()) return;

    setIsLoading(true);
    setErrors({});

    try {
      const res = await fetch("https://pick-list.onrender.com/api/register", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ name, email, password, role }),
      });

      const data = await res.json();

      if (!res.ok) {
        showToast(data.message || "Registration failed", "error");
        return;
      }

      localStorage.setItem("token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));

      showToast("Account created! Redirecting...", "success");
      setTimeout(() => navigate("/dashboard"), 800);

    } catch (err) {
      console.error(err);
      showToast("Unable to connect to server. Please try again.", "error");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full flex bg-white">
      {toast && <Toast message={toast.message} type={toast.type} onClose={() => setToast(null)} />}

      {/* LEFT PANEL */}
      <div className="hidden lg:flex lg:w-1/2 xl:w-[55%] relative overflow-hidden">
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-900 via-purple-900 to-indigo-950" />
        <div className="absolute inset-0 opacity-10 bg-[radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] bg-[length:24px_24px]" />
        <div className="absolute top-20 left-20 w-72 h-72 bg-purple-500/30 rounded-full blur-3xl" />
        <div className="absolute bottom-20 right-20 w-96 h-96 bg-indigo-500/20 rounded-full blur-3xl" />

        <div className="relative z-10 flex flex-col justify-between p-12 xl:p-16 w-full">
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-white/10 backdrop-blur-md rounded-xl border border-white/10">
              <Warehouse className="w-7 h-7 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-white tracking-tight">PickList Manager</h1>
              <p className="text-xs text-white/50 font-medium uppercase tracking-widest">Warehouse Intelligence</p>
            </div>
          </div>

          <div className="space-y-8 max-w-md">
            <div>
              <h2 className="text-4xl xl:text-5xl font-bold text-white leading-tight">
                Join the future of <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-purple-300 to-indigo-300">
                  warehouse management
                </span>
              </h2>
              <p className="mt-4 text-base text-white/60 leading-relaxed">
                Get started with intelligent picklist extraction and real-time inventory insights in minutes.
              </p>
            </div>
            <div className="space-y-4 pt-4">
              <FeatureItem icon={ShieldCheck} text="Secure, enterprise-grade authentication" />
              <FeatureItem icon={PackageCheck} text="Instant PDF data extraction" />
              <FeatureItem icon={Truck} text="End-to-end logistics tracking" />
            </div>
          </div>

          <div className="flex items-center gap-6 text-white/40 text-sm">
            <span>© 2026 PickList Manager</span>
            <span className="w-1 h-1 rounded-full bg-white/30" />
            <span>v2.4.0</span>
          </div>
        </div>
      </div>

      {/* RIGHT PANEL */}
      <div className="w-full lg:w-1/2 xl:w-[45%] flex flex-col justify-center items-center p-6 sm:p-12 bg-gray-50/50">
        <div className="lg:hidden flex items-center gap-3 mb-8">
          <div className="p-2 bg-indigo-600 rounded-lg">
            <Warehouse className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-gray-900">PickList Manager</h1>
            <p className="text-xs text-gray-500 uppercase tracking-wider">Warehouse Intelligence</p>
          </div>
        </div>

        <div className="w-full max-w-md space-y-8">
          <div className="text-center space-y-2">
            <h2 className="text-2xl font-bold text-gray-900">Create your account</h2>
            <p className="text-sm text-gray-500">Start managing your warehouse operations today</p>
          </div>

          <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-xl shadow-gray-200/50 border border-gray-100 p-8 space-y-5">
            <InputField
              label="Full Name"
              type="text"
              value={name}
              onChange={(e) => {
                setName(e.target.value);
                if (errors.name) setErrors(p => ({ ...p, name: null }));
              }}
              placeholder="John Doe"
              icon={User}
              error={errors.name}
            />

            <InputField
              label="Email Address"
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                if (errors.email) setErrors(p => ({ ...p, email: null }));
              }}
              placeholder="you@company.com"
              icon={Mail}
              error={errors.email}
            />

            <InputField
              label="Password"
              type="password"
              value={password}
              onChange={(e) => {
                setPassword(e.target.value);
                if (errors.password) setErrors(p => ({ ...p, password: null }));
              }}
              placeholder="••••••••"
              icon={Lock}
              error={errors.password}
            />

            <SelectField
              label="Role"
              value={role}
              onChange={(e) => {
                setRole(e.target.value);
                if (errors.role) setErrors(p => ({ ...p, role: null }));
              }}
              icon={ShieldCheck}
              error={errors.role}
              options={[
                { value: "manager", label: "Manager" },
                { value: "worker", label: "Worker" }
              ]}
            />

            <button
              type="submit"
              disabled={isLoading}
              className="w-full relative flex items-center justify-center gap-2 py-3 px-4 bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-xl font-semibold text-sm shadow-lg shadow-indigo-500/25 hover:shadow-indigo-500/40 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200 overflow-hidden group"
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span>Creating account...</span>
                </>
              ) : (
                <>
                  <span>Create Account</span>
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-0.5 transition-transform duration-200" />
                </>
              )}
            </button>
          </form>

          <p className="text-center text-sm text-gray-500">
            Already have an account?{" "}
            <Link to="/login" className="font-semibold text-indigo-600 hover:text-indigo-700 transition-colors">
              Sign in instead
            </Link>
          </p>
        </div>
      </div>
    </div>
  );
}