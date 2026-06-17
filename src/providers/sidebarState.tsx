"use client";

import * as React from "react";

type SidebarState = {
  expanded: boolean;
  toggle: () => void;
  setExpanded: (v: boolean) => void;
  mobileOpen: boolean;
  setMobileOpen: (v: boolean) => void;
};

const SidebarContext = React.createContext<SidebarState | null>(null);

const STORAGE_KEY = "sidebar:expanded";

function getInitialExpanded() {
  if (typeof window === "undefined") return true;

  try {
    const saved = window.localStorage.getItem(STORAGE_KEY);
    if (saved === null) return true;
    return saved === "true";
  } catch {
    return true;
  }
}

export function SidebarProvider({ children }: { children: React.ReactNode }) {
  const [expanded, setExpandedState] =
    React.useState<boolean>(getInitialExpanded);
  const [mobileOpen, setMobileOpen] = React.useState(false);

  const setExpanded = React.useCallback((v: boolean) => {
    setExpandedState(v);
    try {
      window.localStorage.setItem(STORAGE_KEY, String(v));
    } catch {}
  }, []);

  const toggle = React.useCallback(() => {
    setExpandedState((prev) => {
      const next = !prev;
      try {
        window.localStorage.setItem(STORAGE_KEY, String(next));
      } catch {}
      return next;
    });
  }, []);

  const value = React.useMemo(
    () => ({ expanded, toggle, setExpanded, mobileOpen, setMobileOpen }),
    [expanded, toggle, setExpanded, mobileOpen, setMobileOpen]
  );

  return (
    <SidebarContext.Provider value={value}>{children}</SidebarContext.Provider>
  );
}

export function useSidebar() {
  const ctx = React.useContext(SidebarContext);
  if (!ctx) throw new Error("useSidebar must be used within SidebarProvider");
  return ctx;
}
