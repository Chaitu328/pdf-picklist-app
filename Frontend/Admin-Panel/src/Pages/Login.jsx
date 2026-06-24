import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { 
  Mail, 
  Lock, 
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
  X
} from "lucide-react";

/* ─── Toast Notification ─── */
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

/* ─── Feature Item for Left Panel ─── */
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
function InputField({ 
  label, 
  type, 
  value, 
  onChange, 
  placeholder, 
  icon: Icon, 
  error 
}) {
  const [showPassword, setShowPassword] = useState(false);
  const isPassword = type === "password";
  const inputType = isPassword ? (showPassword ? "text" : "password") : type;

  return (
    <div className="space-y-1.5">
      <label className="block text-sm font-semibold text-gray-700">
        {label}
      </label>
      <div className="relative group">
        <div className="absolute left-3.5 top-1/2 -translate-y-1/2 text-gray-400 group-focus-within:text-indigo-500 transition-colors duration-200">
          <Icon className="w-5 h-5" />
        </div>
        <input
          type={inputType}
          value={value}
          onChange={onChange}
          placeholder={placeholder}
          className={`w-full pl-11 pr-${isPassword ? '11' : '4'} py-3 bg-gray-50 border rounded-xl text-sm text-gray-900 placeholder:text-gray-400 outline-none transition-all duration-200 ${
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

/* ─── Main Login Page ─── */
export default function Login() {
  const navigate = useNavigate();

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [errors, setErrors] = useState({});
  const [toast, setToast] = useState(null);

  const showToast = (message, type) => {
    setToast({ message, type });
    setTimeout(() => setToast(null), 5000);
  };

  const validate = () => {
    const newErrors = {};
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
    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!validate()) return;

    setIsLoading(true);
    setErrors({});

    try {
      const res = await fetch("http://localhost:3000/api/login", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ email, password }),
      });

      const data = await res.json();

      if (!res.ok) {
        showToast(data.message || "Invalid credentials", "error");
        return;
      }

      localStorage.setItem("token", data.token);
      localStorage.setItem("user", JSON.stringify(data.user));
      if (rememberMe) {
        localStorage.setItem("rememberEmail", email);
      } else {
        localStorage.removeItem("rememberEmail");
      }

      showToast("Welcome back! Redirecting...", "success");
      
      setTimeout(() => {
        navigate("/dashboard");
      }, 800);

    } catch (err) {
      console.error(err);
      showToast("Unable to connect to server. Please try again.", "error");
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen w-full flex bg-white">
      {/* Toast */}
      {toast && (
        <Toast 
          message={toast.message} 
          type={toast.type} 
          onClose={() => setToast(null)} 
        />
      )}

      {/* ─── LEFT PANEL (Branding) ─── */}
      <div className="hidden lg:flex lg:w-1/2 xl:w-[55%] relative overflow-hidden">
        {/* Background Gradient */}
        <div className="absolute inset-0 bg-gradient-to-br from-indigo-900 via-purple-900 to-indigo-950" />
        
        {/* Subtle Pattern Overlay */}
        <div className="absolute inset-0 opacity-10 bg-[radial-gradient(circle_at_1px_1px,white_1px,transparent_0)] bg-[length:24px_24px]" />
        
        {/* Decorative Blurs */}
        <div className="absolute top-20 left-20 w-72 h-72 bg-purple-500/30 rounded-full blur-3xl" />
        <div className="absolute bottom-20 right-20 w-96 h-96 bg-indigo-500/20 rounded-full blur-3xl" />

        {/* Content */}
        <div className="relative z-10 flex flex-col justify-between p-12 xl:p-16 w-full">
          {/* Logo */}
          <div className="flex items-center gap-3">
            <div className="p-2.5 bg-white/10 backdrop-blur-md rounded-xl border border-white/10">
              <Warehouse className="w-7 h-7 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-bold text-white tracking-tight">
                PickList Manager
              </h1>
              <p className="text-xs text-white/50 font-medium uppercase tracking-widest">
                Warehouse Intelligence
              </p>
            </div>
          </div>

          {/* Middle Content */}
          <div className="space-y-8 max-w-md">
            <div>
              <h2 className="text-4xl xl:text-5xl font-bold text-white leading-tight">
                Streamline your <br />
                <span className="text-transparent bg-clip-text bg-gradient-to-r from-purple-300 to-indigo-300">
                  warehouse operations
                </span>
              </h2>
              <p className="mt-4 text-base text-white/60 leading-relaxed">
                Extract, manage, and submit pick lists with intelligent PDF parsing. 
                Built for modern logistics teams.
              </p>
            </div>

            <div className="space-y-4 pt-4">
              <FeatureItem icon={PackageCheck} text="Automated PDF picklist extraction" />
              <FeatureItem icon={Truck} text="Real-time inventory tracking" />
              <FeatureItem icon={BarChart3} text="Advanced analytics & reporting" />
            </div>
          </div>

          {/* Footer */}
          <div className="flex items-center gap-6 text-white/40 text-sm">
            <span>© 2026 PickList Manager</span>
            <span className="w-1 h-1 rounded-full bg-white/30" />
            <span>v2.4.0</span>
          </div>
        </div>
      </div>

      {/* ─── RIGHT PANEL (Login Form) ─── */}
      <div className="w-full lg:w-1/2 xl:w-[45%] flex flex-col justify-center items-center p-6 sm:p-12 bg-gray-50/50">
        
        {/* Mobile Logo */}
        <div className="lg:hidden flex items-center gap-3 mb-8">
          <div className="p-2 bg-indigo-600 rounded-lg">
            <Warehouse className="w-6 h-6 text-white" />
          </div>
          <div>
            <h1 className="text-lg font-bold text-gray-900">PickList Manager</h1>
            <p className="text-xs text-gray-500 uppercase tracking-wider">Warehouse Intelligence</p>
          </div>
        </div>

        {/* Login Card */}
        <div className="w-full max-w-md space-y-8">
          <div className="text-center space-y-2">
            <h2 className="text-2xl font-bold text-gray-900">Welcome back</h2>
            <p className="text-sm text-gray-500">
              Enter your credentials to access your dashboard
            </p>
          </div>

          <form onSubmit={handleSubmit} className="bg-white rounded-2xl shadow-xl shadow-gray-200/50 border border-gray-100 p-8 space-y-6">
            
            <InputField
              label="Email Address"
              type="email"
              value={email}
              onChange={(e) => {
                setEmail(e.target.value);
                if (errors.email) setErrors(prev => ({ ...prev, email: null }));
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
                if (errors.password) setErrors(prev => ({ ...prev, password: null }));
              }}
              placeholder="••••••••"
              icon={Lock}
              error={errors.password}
            />

            <div className="flex items-center justify-between">
              <label className="flex items-center gap-2.5 cursor-pointer group">
                <div className="relative">
                  <input
                    type="checkbox"
                    checked={rememberMe}
                    onChange={(e) => setRememberMe(e.target.checked)}
                    className="peer sr-only"
                  />
                  <div className="w-5 h-5 rounded-md border-2 border-gray-300 peer-checked:bg-indigo-600 peer-checked:border-indigo-600 transition-all duration-200" />
                  <CheckCircle2 className="w-3.5 h-3.5 text-white absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 opacity-0 peer-checked:opacity-100 transition-opacity duration-200" />
                </div>
                <span className="text-sm font-medium text-gray-600 group-hover:text-gray-900 transition-colors">
                  Remember me
                </span>
              </label>

              <button 
                type="button"
                className="text-sm font-semibold text-indigo-600 hover:text-indigo-700 transition-colors"
              >
                Forgot password?
              </button>
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full relative flex items-center justify-center gap-2 py-3 px-4 bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 text-white rounded-xl font-semibold text-sm shadow-lg shadow-indigo-500/25 hover:shadow-indigo-500/40 hover:-translate-y-0.5 active:translate-y-0 disabled:opacity-60 disabled:cursor-not-allowed disabled:hover:translate-y-0 transition-all duration-200 overflow-hidden group"
            >
              {isLoading ? (
                <>
                  <Loader2 className="w-4 h-4 animate-spin" />
                  <span>Authenticating...</span>
                </>
              ) : (
                <>
                  <span>Sign In</span>
                  <ArrowRight className="w-4 h-4 group-hover:translate-x-0.5 transition-transform duration-200" />
                </>
              )}
            </button>
          </form>

          <p className="text-center text-sm text-gray-500">
            Don't have an account?{" "}
            <button className="font-semibold text-indigo-600 hover:text-indigo-700 transition-colors">
              Contact your administrator
            </button>
          </p>
        </div>
      </div>
    </div>
  );
}