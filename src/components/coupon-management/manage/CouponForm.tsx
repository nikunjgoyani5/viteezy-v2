"use client";

import React, { useEffect } from "react";
import { FormProvider, useForm, Controller } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import { useRouter } from "next/navigation";

import ApiError, { ApiErrorResponse } from "@/components/common/ApiError";
import InputField from "@/components/ui/inputs/input";
import SelectField from "@/components/ui/inputs/select";
import { Button } from "@/components/ui/button";

import type { CreateCouponPayload } from "@/store/api/types/coupon.types";
import { createCouponSchema } from "./coupon.schema";
import { Checkbox, ToggleSwitch } from "@/components/ui/table";
import { generateCouponCode } from "@/lib/couponUtils";
import { ChevronLeft } from "lucide-react";

const maxCouponCodeLength = 20;

type CouponFormMode = "create" | "edit";

type CouponFormProps = {
  mode: CouponFormMode;
  initialValues?: Partial<CreateCouponPayload> | null;
  onSubmit: (values: CreateCouponPayload) => Promise<void> | void;
  isSubmitting?: boolean;
  apiError?: ApiErrorResponse | string | null;
  /** Call when coupon code changes (typing or generate) so parent can clear API error */
  onCodeChange?: () => void;
};

const getTodayIso = () => {
  return new Date().toISOString();
};

const COUPON_DEFAULT_VALUES: CreateCouponPayload = {
  code: "",
  name: "",
  description: "",
  type: "Fixed",
  value: undefined,
  minOrderAmount: undefined,
  maxDiscountAmount: undefined,
  usageLimit: undefined,
  userUsageLimit: undefined,
  validFrom: getTodayIso(),
  validUntil: "",
  isActive: true,
  isRecurring: false,
  oneTimeUse: true,
  recurringMonths: undefined,
};

export default function CouponForm({
  mode,
  initialValues,
  onSubmit,
  isSubmitting,
  apiError,
  onCodeChange,
}: CouponFormProps) {
  const router = useRouter();

  const methods = useForm<CreateCouponPayload>({
    // Cast resolver because yup's TS types don't perfectly match RHF's Resolver generic
    resolver: yupResolver(createCouponSchema) as any,
    defaultValues: {
      ...COUPON_DEFAULT_VALUES,
      ...(initialValues ?? {}),
    },
    mode: "onSubmit",
    reValidateMode: "onChange",
  });

  const {
    register,
    control,
    handleSubmit,
    formState,
    setValue,
    clearErrors,
    reset,
  } = methods;
  const { errors } = formState;

  // When initialValues change (e.g. after fetching for edit), update the form.
  useEffect(() => {
    if (initialValues) {
      reset({
        ...COUPON_DEFAULT_VALUES,
        ...(initialValues ?? {}),
      });
    }
  }, [initialValues, reset]);

  const type = methods.watch("type");
  const validFromValue = methods.watch("validFrom");

  // YYYY-MM-DD for date input min/max
  const todayMin = React.useMemo(() => {
    const d = new Date();
    return d.toISOString().slice(0, 10);
  }, []);
  const validFromMin = React.useMemo(() => {
    if (!validFromValue || typeof validFromValue !== "string") return todayMin;
    return validFromValue.slice(0, 10);
  }, [validFromValue, todayMin]);

  const discountTypeOptions = [
    { label: "Fixed", value: "Fixed" },
    { label: "Percentage", value: "Percentage" },
  ];

  const RECURRING_MONTHS = [1, 2, 3, 4] as const;

  const toNumber = (v: unknown): number => {
    if (v === undefined || v === null || v === "") return 0;
    const n = Number(v);
    return Number.isNaN(n) ? 0 : n;
  };

  const handleFormSubmit = async (values: CreateCouponPayload) => {
    const description =
      values.description != null && String(values.description).trim() !== ""
        ? String(values.description).trim()
        : null;

    const payload: CreateCouponPayload = {
      ...values,
      description,
      value: toNumber(values.value),
      minOrderAmount:
        values.minOrderAmount === undefined
          ? undefined
          : toNumber(values.minOrderAmount),
      maxDiscountAmount:
        values.maxDiscountAmount === undefined
          ? undefined
          : toNumber(values.maxDiscountAmount),
      usageLimit:
        values.usageLimit === undefined
          ? undefined
          : toNumber(values.usageLimit),
      userUsageLimit:
        values.userUsageLimit === undefined
          ? undefined
          : toNumber(values.userUsageLimit),
      recurringMonths: values.recurringMonths?.length
        ? values.recurringMonths
        : undefined,
    };

    // On edit: don't send validFrom/validUntil to backend if user didn't change them
    if (mode === "edit" && initialValues) {
      const toDateOnly = (v: string | undefined) =>
        v ? String(v).slice(0, 10) : "";
      const initialFrom = toDateOnly(initialValues.validFrom);
      const initialUntil = toDateOnly(initialValues.validUntil);
      const currentFrom = toDateOnly(values.validFrom);
      const currentUntil = toDateOnly(values.validUntil);
      if (initialFrom === currentFrom)
        delete (payload as Record<string, unknown>).validFrom;
      if (initialUntil === currentUntil)
        delete (payload as Record<string, unknown>).validUntil;
    }

    await onSubmit(payload);
  };

  const title = mode === "edit" ? initialValues?.code : "Create Coupon";
  const submitLabel = mode === "edit" ? "Update" : "Save";

  return (
    <FormProvider {...methods}>
      <div className="flex items-center justify-between mb-5">
        <button
          type="button"
          className="flex items-center gap-2 text-gray-600 hover:text-gray-900 transition-colors cursor-pointer"
          onClick={() => router.back()}
          disabled={isSubmitting}
        >
          <ChevronLeft className="w-5 h-5" />
          <h1 className="text-2xl font-bold text-gray-900">{title}</h1>
        </button>

        <Button
          size="lg"
          disabled={isSubmitting}
          variant="teal"
          type="submit"
          form="coupon-form"
        >
          {isSubmitting ? "Saving..." : submitLabel}
        </Button>
      </div>

      <form id="coupon-form" onSubmit={handleSubmit(handleFormSubmit)}>
        <div className="mb-6">
          <ApiError error={apiError} />
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-5">
          {/* Left: Coupon details */}
          <div className="lg:col-span-2 bg-white rounded-lg border border-gray-200 p-5 space-y-5">
            <h2 className="text-base 3xl:text-lg font-medium text-gray-900">
              Coupons details
            </h2>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-5">
              <Controller
                control={control}
                name="code"
                render={({ field }) => (
                  <InputField
                    ref={field.ref}
                    label="Coupon Code"
                    required
                    placeholder="E.g. SAVE20"
                    maxLength={maxCouponCodeLength}
                    value={field.value ?? ""}
                    onChange={(e) => {
                      const v = e.target.value
                        .toUpperCase()
                        .slice(0, maxCouponCodeLength);
                      field.onChange(v);
                      onCodeChange?.();
                    }}
                    onBlur={field.onBlur}
                    error={errors.code?.message}
                    className="pr-20 xl:pr-30"
                    postIcon={
                      <button
                        type="button"
                        onClick={() => {
                          const newCode =
                            generateCouponCode()?.slice(
                              0,
                              maxCouponCodeLength,
                            ) ?? "";
                          setValue("code", newCode, { shouldValidate: true });
                          clearErrors("code");
                          onCodeChange?.();
                        }}
                        className="shrink-0 text-sm font-medium text-teal-600 hover:text-teal-700 transition-colors cursor-pointer"
                      >
                        Generate <span className="hidden xl:inline">code</span>
                      </button>
                    }
                  />
                )}
              />

              <Controller
                control={control}
                name="type"
                render={({ field }) => (
                  <SelectField
                    label="Discount type"
                    required
                    placeholder="Select discount type"
                    options={discountTypeOptions}
                    value={field.value}
                    onValueChange={field.onChange}
                    error={errors.type?.message}
                  />
                )}
              />

              <InputField
                label={
                  type === "Percentage" ? "Discount (%)" : "Discount Amount"
                }
                required
                placeholder={type === "Percentage" ? "e.g. 20" : "e.g. 20"}
                type="number"
                min={0}
                {...register("value")}
                error={errors.value?.message}
              />

              <InputField
                label="Name"
                required
                placeholder="e.g. 20% Off"
                {...register("name")}
                error={errors.name?.message}
              />

              <InputField
                label="Max usage per user"
                placeholder="e.g. 1 (0 = no limit)"
                type="number"
                min={0}
                noDecimals
                {...register("userUsageLimit")}
                error={errors.userUsageLimit?.message}
              />

              <InputField
                label="Max global usage"
                placeholder="e.g. 1000 (0 = no limit)"
                type="number"
                min={0}
                noDecimals
                {...register("usageLimit")}
                error={errors.usageLimit?.message}
              />

              <InputField
                label="Minimum cart amount"
                placeholder="e.g. 50"
                type="number"
                min={0}
                {...register("minOrderAmount")}
                error={errors.minOrderAmount?.message}
              />

              <InputField
                label="Max discount amount"
                placeholder="e.g. 100 (0 = no limit)"
                type="number"
                min={0}
                {...register("maxDiscountAmount")}
                error={errors.maxDiscountAmount?.message}
              />
            </div>

            <InputField
              label="Description"
              placeholder="Get 20% off on your purchase"
              {...register("description")}
              error={errors.description?.message}
            />
          </div>

          {/* Right: Start/Expiration + Rules */}
          <div className="lg:col-span-1 space-y-5">
            <div className="bg-white rounded-lg border border-gray-200 p-5 space-y-4">
              <h3 className="text-base 3xl:text-lg font-medium text-gray-900">
                Validity period
              </h3>

              <Controller
                control={control}
                name="validFrom"
                render={({ field }) => (
                  <InputField
                    label="Start date"
                    required
                    type="date"
                    // min={todayMin}
                    value={field.value ? field.value.slice(0, 10) : ""}
                    onChange={(e) => {
                      const v = e.target.value;
                      field.onChange(v ? new Date(v).toISOString() : "");
                    }}
                    error={errors.validFrom?.message}
                  />
                )}
              />

              <Controller
                control={control}
                name="validUntil"
                render={({ field }) => (
                  <InputField
                    label="Expiry date"
                    required
                    type="date"
                    min={validFromMin}
                    value={field.value ? field.value.slice(0, 10) : ""}
                    onChange={(e) => {
                      const v = e.target.value;
                      field.onChange(v ? new Date(v).toISOString() : "");
                    }}
                    error={errors.validUntil?.message}
                  />
                )}
              />
            </div>

            <div className="bg-white rounded-lg border border-gray-200 p-5 space-y-4">
              <h3 className="text-base 3xl:text-lg font-medium text-gray-900">
                Coupon Usage Rules
              </h3>

              <Controller
                control={control}
                name="isRecurring"
                render={({ field }) => (
                  <div className="flex items-center justify-between">
                    <span className="text-sm 3xl:text-base text-gray-700">
                      Allow on Renewals
                    </span>
                    <ToggleSwitch
                      checked={!!field.value}
                      onChange={field.onChange}
                    />
                  </div>
                )}
              />

              <Controller
                control={control}
                name="oneTimeUse"
                render={({ field }) => (
                  <div className="flex items-center justify-between">
                    <span className="text-sm 3xl:text-base text-gray-700">
                      One-Time Use Only
                    </span>
                    <ToggleSwitch
                      checked={!!field.value}
                      onChange={field.onChange}
                    />
                  </div>
                )}
              />

              <Controller
                control={control}
                name="recurringMonths"
                render={({ field }) => {
                  const value = field.value ?? [];
                  const toggle = (month: number) => {
                    const set = new Set(value);
                    if (set.has(month)) set.delete(month);
                    else set.add(month);
                    field.onChange(Array.from(set).sort((a, b) => a - b));
                  };
                  return (
                    <div className="space-y-2">
                      <span className="text-sm 3xl:text-base font-medium text-gray-700 mb-2 block">
                        Recurring months
                      </span>
                      <div className="flex flex-wrap gap-3 border rounded-md p-4">
                        {RECURRING_MONTHS.map((month) => (
                          <label
                            key={month}
                            className="flex items-center gap-2 cursor-pointer"
                          >
                            <Checkbox
                              checked={value.includes(month)}
                              onChange={() => toggle(month)}
                            />
                            <span className="text-sm text-gray-700">
                              {month} Month{month > 1 ? "s" : ""}
                            </span>
                          </label>
                        ))}
                      </div>
                    </div>
                  );
                }}
              />
            </div>
          </div>
        </div>
      </form>
    </FormProvider>
  );
}
