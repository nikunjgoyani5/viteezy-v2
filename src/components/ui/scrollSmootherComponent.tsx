"use client";

import { useEffect } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";
import { ScrollSmoother } from "gsap/ScrollSmoother";
import { usePathname } from "next/navigation";

gsap.registerPlugin(ScrollTrigger, ScrollSmoother);

export default function ScrollSmootherComponent() {
  const pathname = usePathname();

  useEffect(() => {
    const shouldDisableSmoothScroll = pathname.startsWith("/checkout");
    const wrapperEl = document.querySelector("#smooth-wrapper") as HTMLElement | null;
    const contentEl = document.querySelector("#smooth-content") as HTMLElement | null;

    if (shouldDisableSmoothScroll) {
      const existingSmoother = ScrollSmoother.get();
      if (existingSmoother) {
        existingSmoother.kill();
      }
      // Restore native scroll behavior for checkout so CSS sticky works.
      if (wrapperEl) {
        wrapperEl.style.overflow = "visible";
        wrapperEl.style.height = "auto";
      }
      if (contentEl) {
        contentEl.style.willChange = "auto";
      }
      ScrollTrigger.refresh();
      return;
    }

    // Re-apply smoother container styles on non-checkout routes.
    if (wrapperEl) {
      wrapperEl.style.overflow = "hidden";
      wrapperEl.style.height = "100%";
    }
    if (contentEl) {
      contentEl.style.willChange = "transform";
    }

    let smoother = ScrollSmoother.get();

    if (!smoother) {
      smoother = ScrollSmoother.create({
        wrapper: "#smooth-wrapper",
        content: "#smooth-content",
        smooth: 1,
        effects: true,
        smoothTouch: 0.1,
      });
    }

    const refreshAnimations = () => {
      // Wait for the browser to finish layout so GSAP/AOS read correct positions.
      requestAnimationFrame(() => {
        smoother?.refresh();
        ScrollTrigger.refresh();
      });
    };

    const handleResize = () => refreshAnimations();

    // Refresh when dynamic content changes height (e.g., empty -> results).
    // This is more robust than relying only on window resize.
    let resizeObserver: ResizeObserver | null = null;
    const smoothContentEl = document.querySelector(
      "#smooth-content"
    ) as HTMLElement | null;
    if (smoothContentEl && typeof ResizeObserver !== "undefined") {
      let t: number | undefined;
      resizeObserver = new ResizeObserver(() => {
        window.clearTimeout(t);
        t = window.setTimeout(() => refreshAnimations(), 50);
      });
      resizeObserver.observe(smoothContentEl);
    }

    window.addEventListener("resize", handleResize);

    return () => {
      window.removeEventListener("resize", handleResize);
      resizeObserver?.disconnect();
    };
  }, [pathname]);

  return null;
}
