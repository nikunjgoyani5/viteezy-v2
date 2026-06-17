import { ApiErrorResponse } from "@/components/common/ApiError";
import { formatDistanceToNowStrict } from "date-fns";

/**
 * Converts a camelCase or lowercase key into a human-readable label:
 * split at capitals, capitalize first letter of each word, join with space.
 * e.g. "activeCoupons" → "Active Coupons", "total_revenue" → "Total Revenue"
 */
export function keyToLabel(key: string): string {
  if (!key || typeof key !== "string") return "";
  const withSpaces = key
    .replace(/([A-Z])/g, " $1")
    .replace(/[-_]/g, " ")
    .trim();
  return withSpaces
    .split(/\s+/)
    .map(
      (word) =>
        word.charAt(0).toUpperCase() + word.slice(1).toLowerCase()
    )
    .join(" ");
}

export const formatCurrencyCompact = (value: number, currency = "USD") => {
  const sign = value < 0 ? "-" : "";
  const abs = Math.abs(value);

  if (abs >= 1_000_000) return `${sign}$${(abs / 1_000_000).toFixed(1)}M`;
  if (abs >= 1_000) return `${sign}$${(abs / 1_000).toFixed(1)}K`;
  return `${sign}$${abs.toFixed(0)}`;
};

export const formatCurrencyDashboard = (value: number, currency = "USD") => {
  const sign = value < 0 ? "-" : "";
  const abs = Math.abs(value);

  const getCurrencySymbol = (curr: string): string => {
    try {
      return new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: curr,
        minimumFractionDigits: 0,
        maximumFractionDigits: 0,
      })
        .format(0)
        .replace(/\d/g, "")
        .trim();
    } catch {
      return curr;
    }
  };

  const symbol = getCurrencySymbol(currency);

  if (abs >= 100_000) {
    if (abs >= 1_000_000) {
      return `${sign}${symbol}${(abs / 1_000_000).toFixed(1)}M`;
    }
    return `${sign}${symbol}${(abs / 1_000).toFixed(1)}K`;
  }

  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency,
    maximumFractionDigits: 0,
  }).format(value);
};

export function timeAgo(date: string | Date | null | undefined) {
  if (!date) return "-";
  const d = typeof date === "string" ? new Date(date) : date;
  if (!(d instanceof Date) || isNaN(d.getTime())) return "-";
  return formatDistanceToNowStrict(d, { addSuffix: true });
}

export function getInitials(name: string, email: string): string {
  if (name?.trim()) {
    const parts = name.trim().split(/\s+/);
    if (parts.length >= 2) {
      return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
    }
    return name.slice(0, 2).toUpperCase();
  }
  if (email?.trim()) {
    return email.slice(0, 2).toUpperCase();
  }
  return "AU";
}

export function normalizeDeleteError(e: unknown): ApiErrorResponse {
  if (e && typeof e === "object" && "data" in e) {
    const data = (e as { data?: ApiErrorResponse }).data;
    if (data && typeof data === "object") return data as ApiErrorResponse;
  }
  if (e && typeof e === "object" && "message" in e)
    return { message: String((e as { message: unknown }).message) };
  return { message: "Failed to execute. Please try again." };
}