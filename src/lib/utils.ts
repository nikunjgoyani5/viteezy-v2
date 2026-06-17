import { createElement, Fragment, useEffect, useState, type ReactNode } from "react";
import { clsx, type ClassValue } from "clsx";
import { createPortal } from "react-dom";
import { twMerge } from "tailwind-merge";

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs));
}

const LOCALIZED_FALLBACK_LOCALES = ["en", "nl", "de", "fr", "es", "hi"] as const;

/** Resolve API fields that may be a plain string or `{ en, nl, de, ... }` locale map. */
export function resolveLocalizedValue(
  value: unknown,
  locale = "en"
): string {
  if (value == null) return "";
  if (typeof value === "string") return value;
  if (typeof value === "number" || typeof value === "boolean") {
    return String(value);
  }

  if (typeof value === "object") {
    const record = value as Record<string, unknown>;
    const normalizedLocale = locale.toLowerCase();

    const direct = record[normalizedLocale] ?? record[normalizedLocale.toUpperCase()];
    if (typeof direct === "string") return direct;

    for (const key of LOCALIZED_FALLBACK_LOCALES) {
      const candidate = record[key];
      if (typeof candidate === "string" && candidate.trim()) return candidate;
    }

    for (const candidate of Object.values(record)) {
      if (typeof candidate === "string" && candidate.trim()) return candidate;
    }
  }

  return "";
}

/** Upgrade http/ws to https/wss when the page is served over HTTPS (avoids mixed-content blocks). */
export function resolveSecureSocketUrl(url?: string): string | null {
  if (!url?.trim()) return null;

  if (typeof window === "undefined") return url.trim();

  if (window.location.protocol !== "https:") return url.trim();

  try {
    const parsed = new URL(url.trim());
    if (parsed.protocol === "http:") {
      parsed.protocol = "https:";
    } else if (parsed.protocol === "ws:") {
      parsed.protocol = "wss:";
    }
    return parsed.toString().replace(/\/$/, "");
  } catch {
    return null;
  }
}

/**
 * Map language code to ISO 3166-1 alpha-2 country code for flag image.
 * flagcdn.com supports: h24 (height 24px), 24x18, w40 – 24x24 returns 404.
 */
export function getLanguageFlagCode(langCode?: string): string {
  if (!langCode) return "us";
  const code = langCode.toLowerCase();
  const map: Record<string, string> = {
    en: "us",
    nl: "nl",
    de: "de",
    fr: "fr",
    es: "es",
  };
  return map[code] ?? code;
}

/** Get flag image URL for language code (height 24px from flagcdn.com) */
export function getLanguageFlagUrl(langCode?: string): string {
  const country = getLanguageFlagCode(langCode);
  return `https://flagcdn.com/h24/${country}.png`;
}

/** Get currency symbol from currency code (e.g. EUR → €, USD → $) */
export function getCurrencySymbol(currency?: string): string {
  if (!currency) return "$";
  switch (currency.toUpperCase()) {
    case "USD":
      return "$";
    case "EUR":
      return "€";
    case "GBP":
      return "£";
    case "INR":
      return "₹";
    default:
      return currency + " "; // Fallback: show code with space if no symbol
  }
}

// Helper function to determine media type
export const getMediaType = (src: string) => {
  const extension = src.split(".").pop()?.toLowerCase();
  if (extension === "mp4" || extension === "webm" || extension === "mov") {
    return "video";
  }
  if (extension === "gif") {
    return "gif";
  }
  return "image";
};

export function FixedPortal({ children }: { children: ReactNode }) {
  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  // Render in-place on server and first client paint so the DOM tree matches.
  if (!mounted) {
    return createElement(Fragment, null, children);
  }

  return createPortal(children, document.body);
}

// Reusable date formatter for ISO strings or Date objects
export function formatDate(
  dateInput?: string | Date,
  locale: string = "en-US",
  options: Intl.DateTimeFormatOptions = {
    year: "numeric",
    month: "short",
    day: "numeric",
  }
) {
  if (!dateInput) return "";
  try {
    const date =
      typeof dateInput === "string" ? new Date(dateInput) : dateInput;
    if (isNaN(date.getTime())) return "";
    return date.toLocaleDateString(locale, options);
  } catch {
    return "";
  }
}

export function getUserFromStorage() {
  if (typeof window === "undefined") return null;
  const userData = localStorage.getItem("user");
  return userData ? JSON.parse(userData) : null;
}

/** Email from the logged-in user stored in localStorage (set at login). */
export function getLoggedInUserEmail(): string {
  const user = getUserFromStorage();
  const email = user?.email;
  return typeof email === "string" ? email.trim() : "";
}

export function hasAuthToken(): boolean {
  if (typeof window === "undefined") return false;
  return Boolean(localStorage.getItem("accessToken"));
}

// Sanitize and format HTML content from API
export function sanitizeHtml(html: string): string {
  if (!html) return "";

  // Replace escaped newlines with actual line breaks
  let cleaned = html.replace(/\\n/g, "<br />");

  // Remove any remaining backslashes that might be escaping quotes
  cleaned = cleaned.replace(/\\/g, "");

  return cleaned;
}

export function getFirstLetter(value?: string) {
  const user = value || getUserFromStorage()?.firstName;
  if (user) {
    return user?.charAt(0).toUpperCase();
  }
  return "";
}

export function formatDuration(days: number, separator: string = " "): string {
  if (!Number.isInteger(days) || days < 0) {
    return "";
  }
  if (days === 0) {
    return `0${separator}days`;
  }
  if (days === 1) {
    return `1${separator}day`;
  }
  if (days < 30) {
    return `${days}${separator}days`;
  }
  if (days === 30) {
    return `1${separator}month`;
  }
  if (days < 365) {
    const months = Math.round(days / 30);
    const unit = months === 1 ? "month" : "months";
    return `${months}${separator}${unit}`;
  }
  const years = Math.round(days / 365);
  const unit = years === 1 ? "year" : "years";
  return `${years}${separator}${unit}`;
}

export function formatDateFn(
  dateInput?: string | Date,
  format: string = "DD MMM YYYY"
): string {
  if (!dateInput) return "";

  let date: Date;
  try {
    date = typeof dateInput === "string" ? new Date(dateInput) : dateInput;
    if (isNaN(date.getTime())) return "";
  } catch {
    return "";
  }

  const day = date.getDate();
  const month = date.getMonth();
  const year = date.getFullYear();

  const pad = (num: number) => String(num).padStart(2, "0");

  const monthShort = date.toLocaleDateString("en-US", { month: "short" });
  const monthLong = date.toLocaleDateString("en-US", { month: "long" });

  const replacements: Record<string, string> = {
    YYYY: String(year),
    YY: String(year).slice(-2),
    MMMM: monthLong,
    MMM: monthShort,
    MM: pad(month + 1),
    M: String(month + 1),
    DD: pad(day),
    D: String(day),
  };

  const sortedTokens = Object.keys(replacements).sort(
    (a, b) => b.length - a.length
  );

  let formatted = format;

  const placeholders: Record<string, string> = {};
  let markerCode = 0xe000;

  for (const token of sortedTokens) {
    const marker = String.fromCharCode(markerCode++);
    placeholders[marker] = replacements[token];

    const escapedToken = token.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const regex = new RegExp(escapedToken, "g");
    formatted = formatted.replace(regex, marker);
  }

  for (const [marker, value] of Object.entries(placeholders)) {
    formatted = formatted.replace(new RegExp(marker, "g"), value);
  }

  return formatted;
}

// Enhanced date formatter with month translation support
export function formatDateWithTranslation(
  dateInput?: string | Date,
  format: string = "DD MMM YYYY",
  t?: (key: string) => string
): string {
  if (!dateInput) return "";

  let date: Date;
  try {
    date = typeof dateInput === "string" ? new Date(dateInput) : dateInput;
    if (isNaN(date.getTime())) return "";
  } catch {
    return "";
  }

  const day = date.getDate();
  const month = date.getMonth();
  const year = date.getFullYear();

  const pad = (num: number) => String(num).padStart(2, "0");

  // Use translation function if available, otherwise fallback to English
  const getMonthTranslation = (key: string) => {
    if (t) {
      try {
        return t(key);
      } catch {
        // Fallback to English if translation fails
      }
    }
    // Fallback to English month names
    const englishMonths: Record<string, string> = {
      january: "January", february: "February", march: "March", april: "April",
      mayLong: "May", june: "June", july: "July", august: "August",
      september: "September", october: "October", november: "November", december: "December",
      jan: "Jan", feb: "Feb", mar: "Mar", apr: "Apr", may: "May",
      jun: "Jun", jul: "Jul", aug: "Aug", sep: "Sep", oct: "Oct", nov: "Nov", dec: "Dec"
    };
    return englishMonths[key] || key;
  };

  const monthKeys = ["january", "february", "march", "april", "mayLong", "june", "july", "august", "september", "october", "november", "december"];
  const monthShortKeys = ["jan", "feb", "mar", "apr", "may", "jun", "jul", "aug", "sep", "oct", "nov", "dec"];

  const replacements: Record<string, string> = {
    YYYY: String(year),
    YY: String(year).slice(-2),
    MMMM: getMonthTranslation(monthKeys[month]),
    MMM: getMonthTranslation(monthShortKeys[month]),
    MM: pad(month + 1),
    M: String(month + 1),
    DD: pad(day),
    D: String(day),
  };

  const sortedTokens = Object.keys(replacements).sort(
    (a, b) => b.length - a.length
  );

  let formatted = format;

  const placeholders: Record<string, string> = {};
  let markerCode = 0xe000;

  for (const token of sortedTokens) {
    const marker = String.fromCharCode(markerCode++);
    placeholders[marker] = replacements[token];

    const escapedToken = token.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
    const regex = new RegExp(escapedToken, "g");
    formatted = formatted.replace(regex, marker);
  }

  for (const [marker, value] of Object.entries(placeholders)) {
    formatted = formatted.replace(new RegExp(marker, "g"), value);
  }

  return formatted;
}

/**
 * Ingredient DRI label: append `%` only for finite numbers (e.g. API numeric DRI%).
 * Non-numeric values (e.g. "trace") are returned as-is without `%`.
 */
export function formatIngredientDriDisplay(value: unknown): string | null {
  if (value === null || value === undefined) return null;
  if (typeof value === "number") {
    return Number.isFinite(value) ? `${value}%` : null;
  }
  if (typeof value === "string") {
    const s = value.trim();
    return s.length > 0 ? s : null;
  }
  return null;
}
