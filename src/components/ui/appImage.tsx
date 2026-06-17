"use client";

import Image, { ImageProps } from "next/image";
import { useState } from "react";

type AppImageProps = Omit<ImageProps, "src"> &
  (
    | { fill: true; width?: never; height?: never }
    | { fill?: false; width: number; height: number }
  ) & {
    src: string;
    alt: string;
    fallbackSrc?: string;
  };

// CDN hosts that return 403 when Next.js Image Optimization fetches them server-side.
// For these we use unoptimized so the browser loads the image directly.
const UNOPTIMIZED_HOSTS = [
  "blr1.digitaloceanspaces.com",
  "milestone.blr1.digitaloceanspaces.com",
  "guardianshot.blr1.digitaloceanspaces.com",
];

function isUnoptimizedHost(url: string): boolean {
  try {
    const host = new URL(url, "https://x").hostname;
    return UNOPTIMIZED_HOSTS.some((h) => host === h);
  } catch {
    return false;
  }
}

// Strip surrounding double quotes (e.g. from JSON/double-encoded API values)
function normalizeSrc(value: string): string {
  let s = value.trim();
  while (s.length >= 2 && s.startsWith('"') && s.endsWith('"')) {
    s = s.slice(1, -1).trim();
  }
  while (s.startsWith('"')) {
    s = s.slice(1).trim();
  }
  while (s.endsWith('"')) {
    s = s.slice(0, -1).trim();
  }
  return s;
}

const AppImage: React.FC<AppImageProps> = ({
  src,
  fallbackSrc = "/images/noImage.webp",
  alt,
  unoptimized: unoptimizedProp,
  ...props
}) => {
  const rawSrc = src && src.trim() ? normalizeSrc(src) : "";
  const safeSrc = src && src.trim() ? src.trim() : fallbackSrc;
  // Track which src failed so we show fallback only for that url; when safeSrc changes we try it
  const [failedSrc, setFailedSrc] = useState<string | null>(null);

  const imgSrc = failedSrc === safeSrc ? fallbackSrc : safeSrc;

  // Bypass Next.js image optimization for CDN URLs that return 403 when fetched server-side
  const unoptimized = unoptimizedProp ?? isUnoptimizedHost(imgSrc);

  return (
    <Image
      {...props}
      src={imgSrc}
      unoptimized={unoptimized}
      onError={() => setFailedSrc(safeSrc)}
      alt={alt || "image"}
    />
  );
};

export default AppImage;
