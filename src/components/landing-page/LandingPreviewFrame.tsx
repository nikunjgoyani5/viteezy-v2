"use client";

import React, { useEffect, useState, useRef } from "react";
import { Monitor, Smartphone, Menu, ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import { ROUTES } from "@/constants/routes";

type DeviceView = "desktop" | "mobile";

type Props = {
  className?: string;
  iframeRef?: React.RefObject<HTMLIFrameElement | null>;
  device?: DeviceView;
  onDeviceChange?: (device: DeviceView) => void;
  onToggleSidebar?: () => void;
  onSave?: () => void;
  isSaving?: boolean;
};

const PREVIEW_URL =
  process.env.NEXT_PUBLIC_LANDING_PREVIEW_URL ??
  "https://staging-v2.viteezy.com/preview-landing";

const DESKTOP_WIDTH = 1200;
const DESKTOP_HEIGHT = 1080;
const MOBILE_WIDTH = 425;
const MOBILE_HEIGHT = 667;

export default function LandingPreviewFrame({
  className,
  iframeRef,
  device: externalDevice,
  onDeviceChange,
  onToggleSidebar,
  onSave,
  isSaving = false,
}: Props) {
  const containerRef = useRef<HTMLDivElement>(null);
  const [scale, setScale] = useState(1);
  const [internalDevice, setInternalDevice] = useState<DeviceView>("desktop");

  const device = externalDevice ?? internalDevice;
  const handleDeviceChange = (newDevice: DeviceView) => {
    if (onDeviceChange) {
      onDeviceChange(newDevice);
    } else {
      setInternalDevice(newDevice);
    }
  };

  const isMobile = device === "mobile";
  const frameWidth = isMobile ? MOBILE_WIDTH : DESKTOP_WIDTH;
  const frameHeight = isMobile ? MOBILE_HEIGHT : DESKTOP_HEIGHT;

  useEffect(() => {
    const updateScale = () => {
      if (!containerRef.current) return;

      const containerWidth = containerRef.current.offsetWidth;
      const availableWidth = Math.max(containerWidth - 32, 300); // Account for padding, min 300px
      const calculatedScale = Math.min(1, availableWidth / frameWidth);

      setScale(Math.max(0.3, calculatedScale)); // Minimum scale of 0.3
    };

    // Initial calculation
    updateScale();

    // Use ResizeObserver for better performance
    const resizeObserver = new ResizeObserver(updateScale);
    if (containerRef.current) {
      resizeObserver.observe(containerRef.current);
    }

    // Fallback for older browsers
    window.addEventListener("resize", updateScale);

    return () => {
      resizeObserver.disconnect();
      window.removeEventListener("resize", updateScale);
    };
  }, [frameWidth]);

  return (
    <div className={className || "w-full"}>
      <div className="flex items-center justify-between gap-3 mb-4">
        <Link
          href={ROUTES.ALL_PAGES}
          type="button"
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
        >
          <ChevronLeft className="w-5 h-5" />
          <h1 className="text-2xl font-bold text-gray-900">Edit page</h1>
        </Link>
        <div className="flex items-center gap-3">
          {/* Sidebar Toggle Button (only shown on screens below xl) */}
          {onToggleSidebar && (
            <button
              type="button"
              onClick={onToggleSidebar}
              className="w-9 h-9 inline-flex items-center justify-center rounded-md hover:bg-gray-100 cursor-pointer"
              aria-label="Toggle sidebar"
            >
              <Menu className="w-5 h-5" />
            </button>
          )}

          <div className="flex items-center bg-gray-100 rounded-lg p-1">
            <button
              type="button"
              onClick={() => handleDeviceChange("desktop")}
              className={`
              flex items-center justify-center gap-2 px-2 py-1.5 rounded-md transition-all cursor-pointer
              ${
                device === "desktop"
                  ? "bg-white border border-gray-300 shadow-sm"
                  : "text-gray-600 hover:text-gray-900"
              }
            `}
            >
              <Monitor className="w-4 h-4" />
            </button>
            <button
              type="button"
              onClick={() => handleDeviceChange("mobile")}
              className={`
              flex items-center justify-center gap-2 px-2 py-1.5 rounded-md transition-all cursor-pointer
              ${
                device === "mobile"
                  ? "bg-white border border-gray-300 shadow-sm"
                  : "text-gray-600 hover:text-gray-900"
              }
            `}
            >
              <Smartphone className="w-4 h-4" />
            </button>
          </div>

          <Button
            variant="teal"
            className="text-base"
            onClick={onSave}
            disabled={isSaving || !onSave}
          >
            {isSaving ? "Saving..." : "Save"}
          </Button>
        </div>
      </div>

      <div
        ref={containerRef}
        className="bg-white border rounded-lg overflow-hidden p-4 w-full"
        style={{
          // maxHeight: `calc(100vh - 120px)`,
          overflowY: "auto",
        }}
      >
        <div
          style={{
            width: `${frameWidth}px`,
            height: `${frameHeight}px`,
            transform: `scale(${scale})`,
            transformOrigin: "top left",
            marginBottom: scale < 1 ? `${frameHeight * (1 - scale)}px` : "0",
            marginLeft: isMobile ? "auto" : "0",
            marginRight: isMobile ? "auto" : "0",
          }}
        >
          <iframe
            ref={iframeRef}
            src={PREVIEW_URL}
            title="Landing page preview"
            style={{
              width: `${frameWidth}px`,
              height: `${frameHeight}px`,
              border: "none",
              display: "block",
            }}
            sandbox="allow-same-origin allow-scripts allow-forms allow-popups"
          />
        </div>
      </div>
    </div>
  );
}
