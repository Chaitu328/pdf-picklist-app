import { BrowserRouter, Routes, Route, Navigate } from "react-router-dom";
import Layout from "./Layout/Layout";
import "./App.css";

import Dashboard from "./Pages/Dashboard";
import PickListPage from "./Pages/PickListPage";
import PickListDetail from "./Pages/PickListDetail";
import Login from "./Pages/Login";
import Register from "./Pages/Register";
import Delivery from "./Pages/Delivery";
import PickListDownload from "./Pages/Reports";
import Workers from "./Pages/Worker";
import ProtectedRoute from "./ProtectedRoute";
import Audit from "./Pages/Audit";

function App() {
  return (
    <BrowserRouter>
      <Routes>

        {/* 🔁 DEFAULT ROUTE → ALWAYS GO TO LOGIN */}
        <Route path="/" element={<Navigate to="/login" replace />} />

        {/* 🔓 PUBLIC ROUTES */}
        <Route path="/login" element={<Login />} />
        <Route path="/register" element={<Register />} />

        {/* 🔒 PRIVATE ROUTES */}
        <Route
          path="/"
          element={
            <ProtectedRoute>
              <Layout />
            </ProtectedRoute>
          }
        >
          <Route index element={<Dashboard />} />
          <Route path="dashboard" element={<Dashboard />} />
          <Route path="picklists" element={<PickListPage />} />
          <Route path="delivery" element={<Delivery />} />
          <Route path="workers" element={<Workers />} />
          <Route path="picklists/:id" element={<PickListDetail />} />
          <Route path="reports" element={<PickListDownload />} />
          <Route path="audit" element={<Audit />} />
        </Route>

        {/* ❌ CATCH UNKNOWN ROUTES */}
        <Route path="*" element={<Navigate to="/login" replace />} />

      </Routes>
    </BrowserRouter>
  );
}

export default App;