"use client";

import React, { useEffect, useRef, useState } from "react";
import { X } from "../icons";
import { cn } from "@/lib/utils";

interface BackdropProps {
  isOpen: boolean;
  onClose: () => void;
  className?: string;
  zIndex?: number;
  handleScrollLock?: boolean;
  transitionDuration?: number;
  closeOnHover?: boolean;
}

const Backdrop: React.FC<BackdropProps> = ({
  isOpen,
  onClose,
  className = "",
  zIndex = 40,
  handleScrollLock = true,
  transitionDuration = 500,
  closeOnHover = false,
}) => {
  const [mousePosition, setMousePosition] = useState({ x: 0, y: 0 });
  const [isVisible, setIsVisible] = useState(false);
  const scrollYRef = useRef(0);

  // Scroll lock
  useEffect(() => {
    if (!handleScrollLock) return;

    const el = document.querySelector("#app-scroll") as HTMLElement | null;
    if (!el) return;

    if (isOpen) {
      scrollYRef.current = el.scrollTop;
      el.style.overflow = "hidden";
    } else {
      el.style.overflow = "";
      el.scrollTop = scrollYRef.current;
    }

    return () => {
      el.style.overflow = "";
      el.scrollTop = scrollYRef.current;
    };
  }, [isOpen, handleScrollLock]);

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    setMousePosition({ x: e.clientX, y: e.clientY });
    setIsVisible(true);
  };

  const handleMouseLeave = () => {
    setIsVisible(false);
  };

  const handleClose = () => {
    onClose();
    setMousePosition({ x: -100, y: -100 });
    setIsVisible(false);
  };

  return (
    <div
      className={cn(
        "fixed inset-0 bg-black/60 backdrop-blur-md transition-opacity",
        isOpen
          ? "opacity-100 pointer-events-auto"
          : "opacity-0 pointer-events-none",
        className
      )}
      style={{
        zIndex,
        transitionDuration: `${transitionDuration}ms`,
        cursor: "none",
      }}
      onClick={handleClose}
      onMouseEnter={closeOnHover ? handleClose : undefined}
      onMouseMove={handleMouseMove}
      onMouseLeave={handleMouseLeave}
    >
      {/* Cursor Close Icon */}
      <div
        className={cn(
          "fixed transition-opacity duration-200 pointer-events-none",
          isVisible ? "opacity-100" : "opacity-0"
        )}
        style={{
          left: `${mousePosition.x}px`,
          top: `${mousePosition.y}px`,
          transform: "translate(-50%, -50%)",
        }}
      >
        <X className="h-12 w-12 text-black bg-white rounded-full p-3" />
      </div>
    </div>
  );
};

export default Backdrop;
