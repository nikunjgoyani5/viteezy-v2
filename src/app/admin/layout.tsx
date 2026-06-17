import { Header } from "@/components/layout/Header";
import { Sidebar } from "@/components/layout/Sidebar";
import { SidebarProvider } from "@/providers/sidebarState";
import React from "react";

const AdminLayout = ({ children }: { children: React.ReactNode }) => {
  return (
    <SidebarProvider>
      <div className="flex min-h-screen">
        <Sidebar />
        <div className="relative z-0 flex bg-surface-light min-w-0 flex-1 flex-col h-screen overflow-y-auto">
          <Header />
          <main className=" w-full flex-1 p-5">{children}</main>
        </div>
      </div>
    </SidebarProvider>
  );
};

export default AdminLayout;
