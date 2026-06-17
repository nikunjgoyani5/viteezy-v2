"use client";

import React, { useEffect, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { DateTimePickerField, InputField } from "@/components/ui/inputs";
import RadioGroup from "@/components/ui/inputs/RadioGroup";
import { Button } from "@/components/ui/button";
import ApiError, { type ApiErrorResponse } from "@/components/common/ApiError";
import type {
  DeviceType,
  HeaderBanner,
} from "@/store/api/types/headerBanner.types";
import {
  useCreateHeaderBannerMutation,
  useUpdateHeaderBannerMutation,
} from "@/store/api/headerBannerApi";
import { ROUTES } from "@/constants/routes";
import { ChevronLeft } from "lucide-react";

type HeaderBannerFormValues = {
  text: string;
  deviceType: DeviceType;
  startDate: string;
  endDate: string;
  isActive: boolean;
};

export default function HeaderBannerForm({
  mode,
  initial,
  bannerId,
}: {
  mode: "create" | "edit";
  initial?: HeaderBanner | null;
  bannerId?: string;
}) {
  const router = useRouter();
  const [apiError, setApiError] = useState<string | ApiErrorResponse | null>(
    null
  );
  const [createBanner, { isLoading: creating }] =
    useCreateHeaderBannerMutation();
  const [updateBanner, { isLoading: updating }] =
    useUpdateHeaderBannerMutation();

  const methods = useForm<HeaderBannerFormValues>({
    defaultValues: {
      text: "",
      deviceType: "WEB",
      startDate: "",
      endDate: "",
      isActive: true,
    },
  });

  const {
    register,
    handleSubmit,
    setValue,
    watch,
    formState: { errors },
  } = methods;

  useEffect(() => {
    if (!initial) return;
    const toLocal = (iso: string | null | undefined) => {
      if (!iso) return "";
      const d = new Date(iso);
      if (Number.isNaN(d.getTime())) return "";
      // datetime-local expects YYYY-MM-DDTHH:mm
      return d.toISOString().slice(0, 16);
    };
    setValue("text", initial.text ?? "");
    setValue("deviceType", initial.deviceType ?? "WEB");
    setValue("startDate", toLocal(initial.startDate));
    setValue("endDate", toLocal(initial.endDate));
    setValue("isActive", initial.isActive ?? true);
  }, [initial, setValue]);

  const onSubmit = async (values: HeaderBannerFormValues) => {
    setApiError(null);
    const hasSchedule = !!values.startDate || !!values.endDate;

    const toIso = (local: string) => {
      if (!local) return undefined;
      // local is in local time; convert to ISO
      const d = new Date(local);
      if (Number.isNaN(d.getTime())) return undefined;
      return d.toISOString();
    };

    const startIso = toIso(values.startDate);
    const endIso = toIso(values.endDate);

    const baseBody: Record<string, unknown> = {
      text: values.text.trim(),
      deviceType: values.deviceType,
      isScheduled: hasSchedule,
      startDate: startIso ?? null,
      endDate: endIso ?? null,
    };

    if (!hasSchedule) {
      baseBody.isActive = values.isActive;
    }

    try {
      if (mode === "edit" && bannerId) {
        await updateBanner({ id: bannerId, body: baseBody }).unwrap();
      } else {
        await createBanner(baseBody).unwrap();
      }
      router.push(ROUTES.HEADER_BANNERS);
    } catch (err: unknown) {
      console.error("Failed to save header banner", err);
      const e = err as { data?: ApiErrorResponse; message?: string };
      setApiError(
        e?.data && typeof e.data === "object"
          ? e.data
          : e?.data?.message ||
              e?.message ||
              "Failed to save banner. Please try again."
      );
    }
  };

  const isSaving = creating || updating;

  const deviceType = watch("deviceType");
  const startDate = watch("startDate");
  const endDate = watch("endDate");

  const endDateMinDate = useMemo(() => {
    if (!startDate) return null;
    const d = new Date(startDate);
    return Number.isNaN(d.getTime()) ? null : d;
  }, [startDate]);

  return (
    <div>
      <div className="flex items-center justify-between mb-6">
        <button
          type="button"
          className="flex items-center gap-2 transition-colors cursor-pointer"
          onClick={() => router.back()}
          disabled={isSaving}
        >
          <ChevronLeft className="w-8 h-8" />
          <h1 className="text-2xl font-bold text-gray-900">Offer Banner</h1>
        </button>

        <div className="flex gap-3">
          <Button
            type="submit"
            form="header-banner-form"
            variant="teal"
            disabled={isSaving}
          >
            {isSaving
              ? mode === "create"
                ? "Creating..."
                : "Saving..."
              : mode === "create"
              ? "Create Banner"
              : "Save Changes"}
          </Button>
        </div>
      </div>

      <form
        id="header-banner-form"
        onSubmit={handleSubmit(onSubmit)}
        className="grid grid-cols-1 lg:grid-cols-3 gap-5"
      >
        <div className="lg:col-span-2 space-y-5">
          <ApiError error={apiError} />
          <div className="bg-white space-y-5 rounded-lg border border-gray-200 p-5">
            <InputField
              label="Offer Banner Text"
              placeholder="Subscribe & Save 20% on Essentials 💜"
              required
              {...register("text", { required: true })}
              error={errors.text && "Banner text is required"}
            />

            <RadioGroup
              className="space-y-1"
              label="Device Type"
              options={[
                { label: "Desktop (WEB)", value: "WEB" },
                { label: "Mobile (MOBILE)", value: "MOBILE" },
              ]}
              value={deviceType}
              onChange={(value) => setValue("deviceType", value as DeviceType)}
            />

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <DateTimePickerField
                label="Start Date & Time"
                value={startDate}
                onChange={(v) => setValue("startDate", v)}
                placeholder="Select start date"
                timeLabel="Select Start Time"
                showTime
              />
              <DateTimePickerField
                label="End Date & Time"
                value={endDate}
                onChange={(v) => setValue("endDate", v)}
                placeholder="Select end date"
                timeLabel="Select End Time"
                showTime
                minDate={endDateMinDate}
              />
            </div>
            <p className="text-xs 3xl:text-sm text-gray-500 ">
              If you set a start or end date, the banner will automatically run
              during that time. <br /> If no dates are set, you can control whether the
              banner is visible using the Visibility option.
            </p>
          </div>
        </div>

        <div className="lg:col-span-1">
          <div className="bg-white space-y-4 rounded-lg border border-gray-200 p-5">
            <RadioGroup
              className="space-y-1"
              label="Visibility"
              options={[
                { label: "Visible", value: true },
                { label: "Hidden", value: false },
              ]}
              value={watch("isActive")}
              onChange={(value) => setValue("isActive", value as boolean)}
            />
          </div>
        </div>
      </form>
    </div>
  );
}
