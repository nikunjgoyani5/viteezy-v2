import * as yup from "yup";
import type { CreateCouponPayload } from "@/store/api/types/coupon.types";

export const createCouponSchema = yup
  .object<CreateCouponPayload>({
    code: yup.string().trim().required("Coupon code is required").max(50),
    name: yup.string().trim().required("Name is required").max(120),
    description: yup.string().trim().optional(),

    type: yup
      .mixed<"Fixed" | "Percentage">()
      .oneOf(["Fixed", "Percentage"])
      .required("Discount type is required"),

    value: yup
      .number()
      .typeError("Value must be a number")
      .required("Value is required")
      .moreThan(0, "Value must be greater than 0")
      .when("type", {
        is: "Percentage",
        then: (s) => s.max(100, "Percentage cannot be more than 100"),
      }),

    minOrderAmount: yup
      .number()
      .typeError("Minimum cart amount must be a number")
      .min(0)
      .nullable()
      .transform((v, o) => (o === "" || o === undefined ? null : v))
      .optional(),

    maxDiscountAmount: yup
      .number()
      .typeError("Max discount amount must be a number")
      .min(0)
      .nullable()
      .transform((v, o) => (o === "" || o === undefined ? null : v))
      .optional(),

    usageLimit: yup
      .number()
      .typeError("Max global usage must be a number")
      .integer("Must be an integer")
      .min(0)
      .nullable()
      .transform((v, o) => (o === "" || o === undefined ? null : v))
      .optional(),

    userUsageLimit: yup
      .number()
      .typeError("Max usage per user must be a number")
      .integer("Must be an integer")
      .min(0)
      .nullable()
      .transform((v, o) => (o === "" || o === undefined ? null : v))
      .optional(),

    validFrom: yup.string().required("Valid from is required"),
    validUntil: yup
      .string()
      .required("Expiry date is required")
      .test("after", "Expiry date must be after valid from", function (v) {
        const { validFrom } = this.parent;
        if (!validFrom || !v) return true;
        return new Date(v).getTime() >= new Date(validFrom).getTime();
      }),

    isActive: yup.boolean().default(true),
    isRecurring: yup.boolean().default(false),
    oneTimeUse: yup.boolean().default(false),

    recurringMonths: yup
      .array()
      .of(
        yup
          .number()
          .integer()
          .min(1, "Month must be 1–4")
          .max(4, "Month must be 1–4")
      )
      .optional()
      .nullable()
      .default(undefined),
  })
  .required();
