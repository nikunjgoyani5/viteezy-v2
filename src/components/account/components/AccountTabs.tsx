"use client";

import React, { Suspense } from "react";
import Link from "next/link";
import { useSearchParams } from "next/navigation";
import { AccountTabsProps } from "@/components/types/account";
import { useTranslations } from "next-intl";

function tabLabelKey(
  id: string,
): `tabs.${"profile" | "addresses" | "orders" | "favorites"}` | null {
  if (id === "profile" || id === "addresses" || id === "orders" || id === "favorites") {
    return `tabs.${id}`;
  }
  return null;
}

function settingsTabLabelKey(
  id: string,
): "subscriptions" | "membership" | "settingsSubMembers" | "changePassword" | null {
  if (id === "subscribe") return "subscriptions";
  if (id === "membership") return "membership";
  if (id === "sub-members") return "settingsSubMembers";
  if (id === "change-password") return "changePassword";
  return null;
}

function AccountTabsContent({ tabs }: AccountTabsProps) {
  const searchParams = useSearchParams();
  const currentTab = searchParams.get("tab") || "profile";
  const t = useTranslations("Common");
  const tAccount = useTranslations("Account");

  const resolveTabLabel = (tab: { id: string; label?: string; href: string }) => {
    if (tab.label) return tab.label;
    const key = tabLabelKey(tab.id);
    if (key) return tAccount(key);
    if (tab.id === "membership") return t("membership");
    const settingsKey = settingsTabLabelKey(tab.id);
    return settingsKey ? tAccount(settingsKey) : tab.id;
  };

  return (
    <div className="flex flex-wrap items-center justify-between gap-3 w-full">
      <div className="flex flex-wrap items-center gap-2 min-w-0 flex-1">
        {tabs.map((tab) => {
          const isActive = currentTab === tab.id;
          return (
            <Link
              key={tab.id}
              href={tab.href}
              className={`
          shrink-0 px-3 4xl:px-5 py-1.5 4xl:py-2 rounded-full text-sm 4xl:text-base font-medium 4xl:font-semibold transition-colors border border-transparent
          ${
            isActive
              ? "bg-teal-500 text-white font-normal"
              : "bg-slate-50-color text-gray-700 hover:bg-gray-100 hover:border-gray-200"
          }
          `}
            >
              {resolveTabLabel(tab)}
            </Link>
          );
        })}
      </div>
      {/* Logout button intentionally removed from account nav; use banner logout */}
    </div>
  );
}

export default function AccountTabs({ tabs }: AccountTabsProps) {
  return (
    <Suspense
      fallback={
        <div className="flex items-center gap-2 flex-wrap">
          {tabs.map((tab) => (
            <div
              key={tab.id}
              className="h-9 min-w-24 rounded-full bg-gray-100 animate-pulse"
              aria-hidden
            />
          ))}
        </div>
      }
    >
      <AccountTabsContent tabs={tabs} />
    </Suspense>
  );
}
