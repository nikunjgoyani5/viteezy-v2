"use client";

import { cn } from "@/lib/utils";
import { ImageOff } from "lucide-react";
import Image, { ImageProps } from "next/image";
import { useState } from "react";

type FallbackImageProps = Omit<ImageProps, "src" | "alt"> & {
  src?: string | null;
  alt: string;
  fallbackSrc?: string;
  className?: string;
  fill?: boolean;
};

export default function FallbackImage({
  src,
  alt,
  fallbackSrc = "/images/image-fallback.png",
  className = "",
  fill = false,
  ...props
}: FallbackImageProps) {
  const isValidSrc = Boolean(typeof src === 'string' && src.trim().length > 0);

  const [hasError, setHasError] = useState(false);

  if (!isValidSrc || hasError) {
    return (
      <div
        className={cn(
          "flex items-center justify-center w-full h-full bg-gray-100",
          className
        )}
      >
        <ImageOff className="w-8 h-8 text-neutral-400" />
      </div>
    );
  }

  return (
    <Image
      {...props}
      src={src!}
      alt={alt}
      fill={fill}
      className={className}
      onError={() => setHasError(true)}
      // priority
      // unoptimized
    />
  );
}
