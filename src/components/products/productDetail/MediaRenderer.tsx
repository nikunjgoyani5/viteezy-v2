"use client";
import Image from "next/image";
import { getMediaType } from "@/lib/utils";

interface MediaRendererProps {
  src: string;
  alt: string;
  width: number;
  height: number;
  className: string;
}

export const MediaRenderer = ({
  src,
  alt,
  width,
  height,
  className,
}: MediaRendererProps) => {
  const mediaType = getMediaType(src);

  if (mediaType === "video") {
    return (
      <video
        src={src}
        width={width}
        height={height}
        className={className}
        autoPlay
        loop
        muted
        playsInline
        poster="/videoThumb.webp"
      />
    );
  }

  // For both regular images and GIFs, use Next.js Image component
  return (
    <Image
      src={src}
      alt={alt}
      width={width}
      height={height}
      className={className}
      unoptimized // Disable optimization for GIFs to preserve animation
    />
  );
};
