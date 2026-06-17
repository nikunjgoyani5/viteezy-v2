"use client";

import React, { useCallback, useEffect, useMemo, useRef, useState } from "react";
import { FormProvider, useForm, useWatch } from "react-hook-form";
import type { Resolver } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import { cn } from "@/lib/utils";
import { useMediaQuery } from "@/lib/useMediaQuery";
import { X } from "lucide-react";

import LandingPreviewFrame from "./LandingPreviewFrame";

import {
  LandingFormValues,
  landingSchema,
  LANDING_DEFAULT_VALUES,
} from "./landing.schema";

import { useDebounce } from "@/hooks/useDebounce";
import LandingSidebarFormUI from "./sidebar";
import {
  useGetLandingPagesQuery,
  useUpdateLandingPageMutation,
} from "@/store/api/landingPageApi";
import { mapApiResponseToFormValues } from "./landingPageMapper";
import { buildLandingPageFormData } from "./buildLandingPageFormData";
import toast from "react-hot-toast";
import { Loader2 } from "lucide-react";
import { useRouter } from "next/navigation";
import { ROUTES } from "@/constants/routes";

const PREVIEW_URL =
  process.env.NEXT_PUBLIC_LANDING_PREVIEW_URL ??
  "https://staging-v2.viteezy.com";

const PREVIEW_ORIGIN = new URL(PREVIEW_URL).origin;
const XL_BREAKPOINT = "(min-width: 1280px)"; // xl breakpoint

type DeviceView = "desktop" | "mobile";

export default function LandingPageManage() {
  const iframeRef = useRef<HTMLIFrameElement>(null);
  const [deviceView, setDeviceView] = useState<DeviceView>("desktop");
  const [sidebarOpen, setSidebarOpen] = useState(false);
  const [sidebarRenderKey, setSidebarRenderKey] = useState(0);
  const isXlScreen = useMediaQuery(XL_BREAKPOINT);
  const isDrawerMode = !isXlScreen;

  const router = useRouter();

  // Fetch landing pages data
  const { data: landingPagesData, isLoading: isLoadingLandingPages } =
    useGetLandingPagesQuery();

  const [updateLandingPage, { isLoading: isSaving }] =
    useUpdateLandingPageMutation();

  // Memoized callbacks for device and sidebar handlers
  const handleDeviceChange = useCallback((device: DeviceView) => {
    setDeviceView(device);
  }, []);

  const handleToggleSidebar = useCallback(() => {
    setSidebarOpen(true);
  }, []);

  const handleCloseSidebar = useCallback(() => {
    setSidebarOpen(false);
  }, []);

  const handleBackdropClick = useCallback(() => {
    setSidebarOpen(false);
  }, []);

  const handleBackdropKeyDown = useCallback((e: React.KeyboardEvent) => {
    if (e.key === "Escape") {
      setSidebarOpen(false);
    }
  }, []);

  // Compute default values from API data
  const formDefaultValues = useMemo(() => {
    if (landingPagesData?.data && landingPagesData.data.length > 0) {
      const firstLandingPage = landingPagesData.data[0];
      return mapApiResponseToFormValues(firstLandingPage);
    }
    return LANDING_DEFAULT_VALUES;
  }, [landingPagesData]);

  // Get landing page ID
  const landingPageId = useMemo(() => {
    return landingPagesData?.data?.[0]?._id || null;
  }, [landingPagesData]);

  const methods = useForm<LandingFormValues>({
    resolver: yupResolver(landingSchema) as Resolver<LandingFormValues>,
    defaultValues: formDefaultValues,
    mode: "onChange", // Validate on change to populate errors - errors shown only after submit via hooks
    reValidateMode: "onChange", // Re-validate on change after submit to update errors when values change
    shouldUnregister: false,
  });

  const { handleSubmit } = methods;

  // Reset form when default values change - only when landing page data loads
  const prevLandingPageIdRef = useRef<string | null>(null);
  useEffect(() => {
    const currentId = landingPagesData?.data?.[0]?._id || null;
    // Only reset if landing page ID changed (new data loaded)
    if (currentId && currentId !== prevLandingPageIdRef.current) {
      methods.reset(formDefaultValues, { keepErrors: false });
      // Ensure accordion sections/hooks (especially field arrays) re-initialize with reset values.
      setSidebarRenderKey((prev) => prev + 1);
      prevLandingPageIdRef.current = currentId;
    }
  }, [landingPagesData?.data?.[0]?._id, formDefaultValues, methods]);

  // watch entire form for live preview - use debounced watch to reduce re-renders
  const values = useWatch({ control: methods.control });

  // debounce to avoid spamming postMessage - increased debounce for better performance
  const debouncedValues = useDebounce(values, 300);

  // Memoize message object to prevent unnecessary postMessage calls
  const message = useMemo(() => {
    return {
      type: "LANDING_PREVIEW",
      payload: debouncedValues,
    };
  }, [debouncedValues]);

  // post on changes - use message directly in dependency
  useEffect(() => {
    const win = iframeRef.current?.contentWindow;
    if (!win) return;
    win.postMessage(message, PREVIEW_ORIGIN);
  }, [message]); // Depend on message which is memoized

  // send once after iframe loads - use message directly
  useEffect(() => {
    const iframe = iframeRef.current;
    if (!iframe) return;

    const onLoad = () => {
      iframe.contentWindow?.postMessage(message, PREVIEW_ORIGIN);
    };

    iframe.addEventListener("load", onLoad);
    return () => iframe.removeEventListener("load", onLoad);
  }, [message]); // Depend on message for initial load

  // Handle save - use handleSubmit to properly increment submitCount
  // handleSubmit already returns a stable function reference, no need for useCallback
  const handleSave = handleSubmit(async (formValues) => {
    if (!landingPageId) {
      toast.error("Landing page ID not found");
      return;
    }

    try {
      const formData = buildLandingPageFormData(formValues);

      const result = await updateLandingPage({
        id: landingPageId,
        body: formData,
      }).unwrap();

      if (result.success) {
        toast.success(result.message || "Landing page updated successfully");
        router.push(ROUTES.ALL_PAGES);
      } else {
        toast.error(result.message || "Failed to update landing page");
      }
    } catch (error: any) {
      toast.error(
        error?.data?.message ||
          error?.message ||
          "Failed to update landing page"
      );
    }
  });

  // Show full screen loader while loading
  if (isLoadingLandingPages) {
    return (
      <div className="fixed inset-0 z-50 bg-white flex items-center justify-center">
        <div className="flex flex-col items-center gap-3">
          <Loader2 className="h-8 w-8 animate-spin text-teal-500" />
          <p className="text-sm text-gray-600">Loading landing page...</p>
        </div>
      </div>
    );
  }

  return (
    <FormProvider {...methods}>
      <div className="flex flex-col lg:flex-row gap-5">
        <div className="sticky top-20 self-start w-full lg:flex-1 lg:min-w-0">
          <LandingPreviewFrame
            iframeRef={iframeRef}
            device={deviceView}
            onDeviceChange={handleDeviceChange}
            onToggleSidebar={isDrawerMode ? handleToggleSidebar : undefined}
            onSave={handleSave}
            isSaving={isSaving}
          />
        </div>

        {/* Sidebar - Drawer mode on screens below xl */}
        {isDrawerMode ? (
          <>
            {/* Backdrop */}
            {sidebarOpen && (
              <div
                role="button"
                tabIndex={-1}
                className="fixed inset-0 bg-black/50 z-40 transition-opacity"
                onClick={handleBackdropClick}
                onKeyDown={handleBackdropKeyDown}
                aria-hidden
              />
            )}
            {/* Drawer Sidebar */}
            <aside
              className={cn(
                "fixed right-0 top-0 z-50 h-screen bg-white",
                "w-full max-w-md transition-transform duration-300 ease-out",
                "overflow-y-auto custom-scrollbar",
                sidebarOpen ? "translate-x-0" : "translate-x-full"
              )}
            >
              {/* Close Button */}
              <div className="sticky top-0 bg-white border-b border-gray-200 p-4 flex justify-end z-10">
                <button
                  type="button"
                  onClick={handleCloseSidebar}
                  className="w-8 h-8 inline-flex items-center justify-center rounded-md hover:bg-gray-100 cursor-pointer"
                  aria-label="Close sidebar"
                >
                  <X className="w-5 h-5" />
                </button>
              </div>
              <div className="p-5">
                <LandingSidebarFormUI key={`landing-sidebar-${sidebarRenderKey}`} />
              </div>
            </aside>
          </>
        ) : (
          /* Normal Sidebar on xl and above */
          <div className="w-full lg:w-96 xl:w-[300px] 3xl:w-[350px] shrink-0">
            <LandingSidebarFormUI key={`landing-sidebar-${sidebarRenderKey}`} />
          </div>
        )}
      </div>
    </FormProvider>
  );
}
