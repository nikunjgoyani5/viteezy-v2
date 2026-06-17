"use client";

import { SIDEBAR_ITEMS } from "@/data/sidebarData";
import { useSidebar } from "@/providers/sidebarState";
import { useMediaQuery } from "@/lib/useMediaQuery";
import Link from "next/link";
import { usePathname } from "next/navigation";
import AppImage from "../ui/appImage";
import React, { useMemo, useState, useEffect, useCallback } from "react";
import { ChevronDown, ChevronRight, X } from "lucide-react";
import { ROUTES } from "@/constants/routes";

const cn = (...c: Array<string | false | undefined | null>) =>
  c.filter(Boolean).join(" ");

const LG_BREAKPOINT = "(min-width: 1024px)";

export function Sidebar() {
  const pathname = usePathname();
  const { expanded, mobileOpen, setMobileOpen } = useSidebar();
  const isDesktop = useMediaQuery(LG_BREAKPOINT);
  const isOverlay = !isDesktop;
  const effectiveExpanded = isOverlay ? true : expanded;

  // keep your "text appears after 200ms" behavior
  const [showText, setShowText] = useState(effectiveExpanded);

  useEffect(() => {
    if (effectiveExpanded) {
      const t = setTimeout(() => setShowText(true), 200);
      return () => clearTimeout(t);
    } else {
      setShowText(false);
    }
  }, [effectiveExpanded]);

  // find the parent whose child is active (initial open)
  const initialOpenKey = useMemo(() => {
    const parent = SIDEBAR_ITEMS.find((item) =>
      item.children?.some(
        (c) => pathname === c.path || pathname.startsWith(c.path + "/")
      )
    );
    return parent?.key ?? null;
  }, [pathname]);

  // ONLY ONE open at a time
  const [openKey, setOpenKey] = useState<string | null>(initialOpenKey);

  const sidebarContent = (
    <>
      <Link
        href={ROUTES.DASHBOARD}
        className="min-h-6 max-h-6 mt-7 mb-5 px-4.5 cursro-pointer block"
        onClick={isOverlay ? () => setMobileOpen(false) : undefined}
      >
        {effectiveExpanded ? (
          <AppImage
            src="/logos/fullLogo.svg"
            alt="logo"
            width={218}
            height={24}
            className="mx-auto"
          />
        ) : (
          <AppImage
            src="/logos/logo.svg"
            alt="logo"
            width={30}
            height={24}
            className="mx-auto"
          />
        )}
      </Link>

      <nav
        className={`${
          effectiveExpanded ? "overflow-y-auto" : ""
        } py-2 space-y-1 max-h-[calc(100vh-80px)]  pb-15 custom-scrollbar-2`}
      >
        {SIDEBAR_ITEMS.map((item) => (
          <SidebarParentRow
            key={item.key}
            item={item}
            expanded={effectiveExpanded}
            showText={showText}
            pathname={pathname}
            openKey={openKey}
            setOpenKey={setOpenKey}
            onNavigate={isOverlay ? () => setMobileOpen(false) : undefined}
          />
        ))}
      </nav>

      {!isOverlay && (
        <>
          <span className="absolute top-0 left-full w-4 h-4 bg-primary">
            <span className="absolute bg-white w-4 h-4 rounded-tl-2xl"></span>
          </span>
          <span className="absolute bottom-0 left-full w-4 h-4 bg-primary">
            <span className="absolute bg-surface-light w-4 h-4 rounded-bl-2xl"></span>
          </span>
        </>
      )}
    </>
  );

  if (isOverlay) {
    return (
      <>
        {mobileOpen && (
          <div
            role="button"
            tabIndex={-1}
            className="fixed inset-0 bg-black/50 z-40 transition-opacity"
            onClick={() => setMobileOpen(false)}
            onKeyDown={(e) => e.key === "Escape" && setMobileOpen(false)}
            aria-hidden
          />
        )}
        <aside
          className={cn(
            "fixed left-0 top-0 z-50 h-screen bg-primary text-primary-foreground",
            "w-60 3xl:w-80 transition-transform duration-300 ease-out overflow-visible",
            "overflow-y-auto custom-scrollbar-2",
            mobileOpen ? "translate-x-0" : "-translate-x-full"
          )}
        >
          {sidebarContent}
        </aside>
      </>
    );
  }

  return (
    <aside
      className={cn(
        "h-screen bg-primary text-primary-foreground sticky top-0 shrink-0",
        "transition-[width] duration-500 overflow-visible relative z-[45]",
        "hidden lg:block",
        effectiveExpanded ? "w-60 3xl:w-80" : "w-22"
      )}
    >
      {sidebarContent}
    </aside>
  );
}

const SidebarParentRow = React.memo(function SidebarParentRow({
  item,
  expanded,
  showText,
  pathname,
  openKey,
  setOpenKey,
  onNavigate,
}: {
  item: (typeof SIDEBAR_ITEMS)[number];
  expanded: boolean;
  showText: boolean;
  pathname: string;
  openKey: string | null;
  setOpenKey: React.Dispatch<React.SetStateAction<string | null>>;
  onNavigate?: () => void;
}) {
  const Icon = item.icon;
  const LightIcon = item.lightIcon;
  const hasChildren = !!item.children?.length;

  const isChildActive = item.children?.some(
    (c) => pathname === c.path || pathname.startsWith(c.path + "/")
  );

  // keep your existing parent-active logic EXACTLY
  const isParentActive =
    pathname === item.path || pathname.startsWith(item.path + "/");
  const active = isParentActive || isChildActive;

  const isOpen = hasChildren && openKey === item.key;

  const handleToggle = useCallback(
    (e: React.MouseEvent) => {
      e.preventDefault();
      e.stopPropagation();
      if (!expanded || !hasChildren || !showText) return;

      setOpenKey((prev) => (prev === item.key ? null : item.key));
    },
    [expanded, hasChildren, showText, item.key, setOpenKey]
  );

  // EXPANDED but text not visible yet => icons only (no accordion)
  if (expanded && !showText) {
    return (
      <div className="relative">
        <div className="flex flex-col items-center">
          {hasChildren ? (
            <div
              className={cn(
                "flex items-center justify-center rounded-md h-10 w-12 mx-auto",
                "text-primary-foreground cursor-pointer relative",
                active
                  ? "bg-primary-foreground/40 text-white"
                  : "hover:bg-white/10"
              )}
              aria-label={item.label}
            >
              {active && (
                <span className="absolute bg-white top-1/2 -translate-y-1/2 left-px w-0.5 h-[50%] rounded-e-xl" />
              )}
              {active ? (
                <LightIcon className="h-5 w-5" />
              ) : (
                <Icon className="h-5 w-5" />
              )}
            </div>
          ) : (
            <Link
              href={item.path || ""}
              className={cn(
                "flex items-center justify-center rounded-md h-10 w-12 mx-auto",
                "text-primary-foreground relative",
                isParentActive
                  ? "bg-primary-foreground/40 text-white"
                  : "hover:bg-white/10"
              )}
              aria-label={item.label}
              onClick={() => {
                setOpenKey(null);
                onNavigate?.();
              }}
            >
              {active && (
                <span className="absolute bg-white top-1/2 -translate-y-1/2 left-px w-0.5 h-[70%] rounded-e-xl" />
              )}
              {active ? (
                <LightIcon className="h-5 w-5" />
              ) : (
                <Icon className="h-5 w-5" />
              )}
            </Link>
          )}
        </div>
      </div>
    );
  }

  // Expanded (text visible): accordion rows
  if (expanded && showText) {
    return (
      <div className="px-4.5">
        <div
          className={cn(
            "flex items-center gap-2.5 rounded-md px-3 ",
            "text-primary-foreground cursor-pointer transition-colors relative font-medium",
            isParentActive
              ? "bg-primary-foreground/40 text-white"
              : "hover:bg-white/5"
          )}
          onClick={hasChildren ? handleToggle : undefined}
        >
          {isParentActive && (
            <span className="absolute bg-white top-1/2 -translate-y-1/2 left-px w-0.5 h-[50%] rounded-e-xl" />
          )}

          {isParentActive ? (
            <LightIcon className="h-4.5 w-4.5 3xl:h-5.5 3xl:w-5.5 shrink-0" />
          ) : (
            <Icon className="h-4.5 w-4.5 3xl:h-5.5 3xl:w-5.5 shrink-0" />
          )}

          <span className="whitespace-nowrap flex-1 min-w-0 truncate">
            {hasChildren ? (
              <span className="block py-3 font-medium text-sm 3xl:text-base truncate">
                {item.label}
              </span>
            ) : (
              <Link
                href={item.path || ""}
                className="block w-full py-3 font-medium text-sm 3xl:text-base min-w-0 truncate"
                onClick={(e) => {
                  e.stopPropagation();
                  setOpenKey(null);
                  onNavigate?.();
                }}
              >
                {item.label}
              </Link>
            )}
          </span>

          {hasChildren && (
            <button
              type="button"
              onClick={handleToggle}
              className="hover:bg-primary/60 rounded"
              aria-label={isOpen ? "Collapse submenu" : "Expand submenu"}
              aria-expanded={isOpen}
            >
              {isOpen ? (
                <ChevronDown className="h-4 w-4" />
              ) : (
                <ChevronRight className="h-4 w-4" />
              )}
            </button>
          )}
        </div>

        {hasChildren && (
          <div
            className={cn(
              "grid transition-[grid-template-rows,opacity] duration-200 ease-out",
              isOpen
                ? "grid-rows-[1fr] opacity-100 pt-2"
                : "grid-rows-[0fr] opacity-0"
            )}
          >
            <div className="overflow-hidden min-w-0">
              <div className="pl-7.5 space-y-1 font-medium min-w-0">
                {item.children!.map((c) => {
                  const childActive =
                    pathname === c.path || pathname.startsWith(c.path + "/");
                  return (
                    <Link
                      key={c.key}
                      href={c.path}
                      className={cn(
                        "block rounded-md px-3.5 py-2 transition-colors text-sm 3xl:text-base truncate",
                        childActive
                          ? "bg-primary-foreground/40 text-white"
                          : "hover:bg-white/5"
                      )}
                      onClick={() => onNavigate?.()}
                    >
                      {c.label}
                    </Link>
                  );
                })}
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }

  // Collapsed: icons + hover submenu for children
  return (
    <div className="relative group">
      <div className="flex flex-col items-center">
        {hasChildren ? (
          <div
            className={cn(
              "flex items-center justify-center rounded-md h-10 w-12 mx-auto",
              "text-primary-foreground cursor-pointer relative",
              active
                ? "bg-primary-foreground/40 text-white"
                : "hover:bg-white/10"
            )}
            aria-label={item.label}
          >
            {active && (
              <span className="absolute bg-white top-1/2 -translate-y-1/2 left-px w-0.5 h-[50%] rounded-e-xl" />
            )}
            {active ? (
              <LightIcon className="h-5 w-5" />
            ) : (
              <Icon className="h-5 w-5" />
            )}
          </div>
        ) : (
          <Link
            href={item.path || ""}
            className={cn(
              "flex items-center justify-center rounded-md h-10 w-12 mx-auto",
              "text-primary-foreground relative",
              isParentActive
                ? "bg-primary-foreground/40 text-white"
                : "hover:bg-white/10"
            )}
            aria-label={item.label}
            onClick={() => onNavigate?.()}
          >
            {active && (
              <span className="absolute bg-white top-1/2 -translate-y-1/2 left-px w-0.5 h-[50%] rounded-e-xl" />
            )}
            {active ? (
              <LightIcon className="h-5 w-5" />
            ) : (
              <Icon className="h-5 w-5" />
            )}
          </Link>
        )}

        {!expanded && hasChildren && (
          <div
            className={cn(
              "absolute left-[5.25rem] top-0",
              "min-w-56 rounded-md border bg-popover text-popover-foreground shadow",
              "opacity-0 translate-x-1 pointer-events-none",
              "group-hover:opacity-100 group-hover:translate-x-0 group-hover:pointer-events-auto",
              "transition-all duration-150 z-50"
            )}
          >
            <div className="p-1">
              {item.children!.map((c) => {
                const childActive =
                  pathname === c.path || pathname.startsWith(c.path + "/");
                return (
                  <Link
                    key={c.key}
                    href={c.path}
                    className={cn(
                      "block rounded-md px-3 py-2 text-sm transition-colors truncate",
                      "hover:bg-accent hover:text-accent-foreground",
                      childActive &&
                        "bg-accent text-accent-foreground font-medium"
                    )}
                    onClick={() => onNavigate?.()}
                  >
                    {c.label}
                  </Link>
                );
              })}
            </div>
          </div>
        )}
      </div>
    </div>
  );
});
