import Sidebar from "./Sidebar";
import Header from "./Header";
import { Outlet } from "react-router-dom";

export default function Layout() {
  return (
    <div className="bg-[#F5F7FB] min-h-screen">

      <Sidebar />
      <Header />

      <main className="ml-64 pt-20 p-6">
        <Outlet />
      </main>

    </div>
  );
}