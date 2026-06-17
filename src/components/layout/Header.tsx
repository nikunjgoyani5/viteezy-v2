"use client";

import React, { useState, useEffect } from "react";
import { useSidebar } from "@/providers/sidebarState";
import { useMediaQuery } from "@/lib/useMediaQuery";
import { HiMenuAlt2 } from "react-icons/hi";
import { LogOut } from "lucide-react";
import { getUser, handleLogout, type StoredUser } from "@/lib/token";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { cn } from "@/lib/utils";
import { getInitials } from "@/lib/common";

const LG_BREAKPOINT = "(min-width: 1024px)";

export function Header() {
  const { toggle, setMobileOpen } = useSidebar();
  const isDesktop = useMediaQuery(LG_BREAKPOINT);
  const [user, setUser] = useState<StoredUser | null>(null);

  // Load user data only on client side after hydration
  useEffect(() => {
    setUser(getUser());
  }, []);

  const rawName = user?.name ?? "Admin User";
  const displayName =
    rawName.charAt(0).toUpperCase() + rawName.slice(1).toLowerCase();
  const displayEmail = user?.email ?? "admin@example.com";
  const initials = getInitials(displayName, displayEmail);

  return (
    <header className="min-h-14 3xl:min-h-15 border-b border-border-extra-light-gray bg-background flex items-center justify-between px-5 w-full  sticky top-0 z-10">
      <div className="flex gap-4 items-center">
        <button
          type="button"
          onClick={() => (isDesktop ? toggle() : setMobileOpen(true))}
          className="w-9 h-9 inline-flex items-center justify-center rounded-md hover:bg-accent cursor-pointer"
          aria-label={isDesktop ? "Toggle sidebar" : "Open menu"}
        >
          <HiMenuAlt2 className="w-6 h-6" />
        </button>
      </div>

      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <button
            type="button"
            className="flex items-center gap-3 rounded-lg py-1.5 pr-1 pl-2 outline-none cursor-pointer"
          >
            <div
              className={cn(
                "w-9 h-9 shrink-0 rounded-full flex items-center justify-center text-white font-semibold text-sm",
                "bg-gradient-to-r from-teal-500 to-[#F7A173]"
              )}
            >
              {initials}
            </div>
            <div className="text-left hidden sm:block">
              <div className="text-sm 3xl:text-base font-medium text-gray-900 leading-tight truncate max-w-[240px]">
                {/* {displayName} */}Admin
              </div>
              <div className="text-xs 3xl:text-sm text-gray-500 leading-tight truncate max-w-[200px]">
                {displayEmail}
              </div>
            </div>
          </button>
        </DropdownMenuTrigger>
        <DropdownMenuContent align="end" className="w-48">
          <DropdownMenuItem
            variant="destructive"
            onClick={() => handleLogout()}
            className="cursor-pointer py-2"
          >
            <LogOut className="w-4 h-4" />
            Logout
          </DropdownMenuItem>
        </DropdownMenuContent>
      </DropdownMenu>
    </header>
  );
}
