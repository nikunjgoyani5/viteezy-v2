"use client";

import React from "react";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";

import CouponForm from "./CouponForm";
import {
  useCreateCouponMutation,
  useGetCouponByIdQuery,
  useUpdateCouponMutation,
} from "@/store/api/couponApi";
import type { ApiErrorResponse } from "@/components/common/ApiError";
import type {
  CreateCouponPayload,
  Coupon,
} from "@/store/api/types/coupon.types";
import { ROUTES } from "@/constants/routes";

type ManageCouponPageProps = {
  mode: "create" | "edit";
  id?: string;
};

export default function ManageCouponPage({ mode, id }: ManageCouponPageProps) {
  const router = useRouter();
  const isEdit = mode === "edit";

  const [createCoupon, { isLoading: isCreating, error: createError, reset: resetCreate }] =
    useCreateCouponMutation();
  const [updateCoupon, { isLoading: isUpdating, error: updateError, reset: resetUpdate }] =
    useUpdateCouponMutation();

  const clearApiError = React.useCallback(() => {
    resetCreate();
    resetUpdate();
  }, [resetCreate, resetUpdate]);

  const { data, isLoading: isLoadingCoupon } = useGetCouponByIdQuery(id!, {
    skip: !isEdit || !id,
  });

  const isSubmitting = isEdit ? isUpdating : isCreating;

  const initialValues: Partial<CreateCouponPayload> | null =
    React.useMemo(() => {
      if (!isEdit || !data?.data?.coupon) return null;

      const c = data.data.coupon as Coupon;

      return {
        code: c.code,
        name: c.name,
        description: c.description ?? "",
        type: c.type as any,
        value: c.value,
        minOrderAmount: c.minOrderAmount,
        maxDiscountAmount: c.maxDiscountAmount,
        usageLimit: c.usageLimit,
        userUsageLimit: c.userUsageLimit,
        validFrom: c.validFrom ?? "",
        validUntil: c.validUntil ?? "",
        isActive: c.isActive,
        isRecurring: c.isRecurring,
        oneTimeUse: c.oneTimeUse,
        recurringMonths: c.recurringMonths,
      };
    }, [isEdit, data]);

  const apiError =
    (isEdit ? updateError : createError) &&
      "data" in ((isEdit ? updateError : createError) as {
        data?: ApiErrorResponse | string;
      })
      ? (
        (isEdit ? updateError : createError) as {
          data?: ApiErrorResponse | string;
        }
      ).data ?? null
      : ((isEdit ? updateError : createError) as
        | ApiErrorResponse
        | string
        | undefined) ?? null;

  const handleCreate = async (values: CreateCouponPayload) => {
    try {
      const res = await createCoupon(values).unwrap();
      if (res.success) {
        toast.success("Coupon created successfully");
        router.push(ROUTES.COUPON_MANAGEMENT.BASE);
      }
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to create coupon");
      console.error("Failed to create coupon:", error);
    }
  };

  const handleUpdate = async (values: CreateCouponPayload) => {
    if (!id) return;
    try {
      const res = await updateCoupon({ id, body: values }).unwrap();
      if (res.success) {
        toast.success("Coupon updated successfully");
        router.push(ROUTES.COUPON_MANAGEMENT.BASE);
      }
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to update coupon");
      console.error("Failed to update coupon:", error);
    }
  };

  if (isEdit && isLoadingCoupon) {
    return (
      <div className="flex h-screen items-center justify-center bg-gray-50">
        Loading coupon...
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-20">
      <div className="form-container mx-auto">
        <CouponForm
          mode={mode}
          initialValues={initialValues ?? undefined}
          onSubmit={isEdit ? handleUpdate : handleCreate}
          isSubmitting={isSubmitting}
          apiError={apiError}
          onCodeChange={clearApiError}
        />
      </div>
    </div>
  );
}

