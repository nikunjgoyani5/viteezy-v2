import * as yup from "yup";
import { type UploadFileValue } from "@/components/ui/uploadFile";

// ---------------- Helpers ----------------
const trimOrEmpty = (v: unknown) => (typeof v === "string" ? v.trim() : v);

const hasText = (v: unknown) => typeof v === "string" && v.trim().length > 0;

// File can be File (create) or string URL (edit)
const hasFile = (v: unknown) => v instanceof File || typeof v === "string";

const parseNumberish = (value: unknown) => {
  if (typeof value === "number") return Number.isNaN(value) ? undefined : value;
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  const normalized = trimmed.replace(/,/g, "").replace(/%$/, "").trim();
  if (!normalized) return undefined;
  const parsed = Number(normalized);
  return Number.isNaN(parsed) ? undefined : parsed;
};

// ---------------- Money Schemas ----------------
const moneySchema = yup
  .object({
    currency: yup.string().default("USD"),
    amount: yup
      .number()
      .min(0, "Amount must be positive")
      .required("Amount required"),
    discountedPrice: yup
      .number()
      .min(0)
      .nullable()
      .transform((v) => (isNaN(v) ? null : v)),
    taxRate: yup.number().min(0).default(10),
    features: yup.array().of(yup.string()).default([]),
    capsuleCount: yup.number(),
  })
  .test(
    "price-order",
    "Regular Price ($) should not be below Total Sale Price ($)",
    function (value) {
      if (value == null) return true;
      const amount = Number(value.amount);
      const discountedPrice = Number(value.discountedPrice ?? 0);
      if (discountedPrice <= 0) return true;
      if (amount >= discountedPrice) return true;
      return this.createError({
        path: "amount",
        message:
          "Regular Price ($) should not be below Total Sale Price ($)",
      });
    }
  );

const sachetOptionSchema = moneySchema.shape({
  durationDays: yup.number(),
  capsuleCount: yup.number(),
  features: yup.array().of(yup.string()).default([]),
});

// ---------------- FAQ Schema ----------------
const faqItemSchema = yup.object({
  question: yup
    .string()
    .transform(trimOrEmpty)
    .required("Question is required"),
  answer: yup.string().transform(trimOrEmpty).required("Answer is required"),
});

// ---------------- Main Schema ----------------
export const productSchema = yup
  .object({
    // Basics
    title: yup.string().required("Title is required").max(150),
    description: yup
      .string()
      .transform(trimOrEmpty)
      .required("Description is required"),
    shortDescription: yup
      .string()
      .transform(trimOrEmpty)
      .required("Short description is required"),

    // Settings
    hasStandupPouch: yup.boolean().default(false),
    status: yup.boolean().default(true),
    isFeatured: yup.boolean().default(false),

    // Relations
    categories: yup
      .array()
      .of(yup.string().required())
      .min(1, "Select at least one category"),
    healthGoals: yup.array().of(yup.string().required()),
    ingredientMeta: yup.object({
      sectionTitle: yup.string().transform(trimOrEmpty).optional(),
      sectionSubtitle: yup.string().transform(trimOrEmpty).optional(),
      excipients: yup.string().transform(trimOrEmpty).optional(),
      backgroundImage: yup.mixed<UploadFileValue>().nullable(),
    }),
    ingredientCompositions: yup.array().of(
      yup.object({
        ingredient: yup.string().required("Ingredient is required"),
        quantity: yup
          .string()
          .transform((_, originalValue) => {
            if (typeof originalValue === "number") return String(originalValue);
            if (typeof originalValue === "string") return originalValue.trim();
            return "";
          })
          .required("Quantity is required"),
        driPercentage: yup
          .string()
          .transform((_, originalValue) => {
            if (typeof originalValue === "number") return String(originalValue);
            if (typeof originalValue === "string") {
              return originalValue.trim().replace(/%$/, "");
            }
            return "";
          })
          .required("DRI is required")
          .test(
            "valid-dri",
            "DRI must be a number from 0 to 100, or * or **",
            (value) => {
              if (typeof value !== "string") return false;
              if (value === "*" || value === "**") return true;
              const n = parseNumberish(value);
              if (n === undefined) return false;
              return n >= 0 && n <= 100;
            }
          ),
      })
    ),
    benefits: yup.array().of(yup.string()),

    // Rich Text Info
    nutritionInfo: yup.string().optional(),
    howToUse: yup.string().optional(),

    // Images
    productImage: yup
      .mixed<UploadFileValue>()
      .test("required", "Product image is required", (value, context) => {
        const isEdit = context.options.context?.mode === "edit";
        if (isEdit) return !!value; // String or File ok
        return value instanceof File;
      }),
    galleryImages: yup.array().of(yup.mixed<UploadFileValue>()).nullable(),
    standupPouchImages: yup.array().of(yup.mixed<UploadFileValue>()).nullable(),

    // Pricing
    sachetPrices: yup.object({
      thirtyDays: sachetOptionSchema,
      sixtyDays: sachetOptionSchema,
      ninetyDays: sachetOptionSchema,
      oneEightyDays: sachetOptionSchema,
      oneTime: yup.object({
        count30: moneySchema,
        count60: moneySchema,
      }),
    }),

    standupPouchPrice: yup.object().when("hasStandupPouch", {
      is: true,
      then: (schema) =>
        schema
          .shape({
            count_0: moneySchema,
            count_1: moneySchema,
          })
          .required(),
      otherwise: (schema) => schema.nullable(),
    }),

    // Feature comparison (values is boolean[])
    comparisonSection: yup.object({
      title: yup
        .string()
        .transform(trimOrEmpty)
        .required("Comparison title is required"),

      columns: yup.array().of(yup.string()).default(["other"]),

      rows: yup
        .array()
        .of(
          yup.object({
            label: yup
              .string()
              .transform(trimOrEmpty)
              .required("Row title is required"),

            values: yup
              .array()
              .of(yup.boolean().required())
              .min(1, "Select Yes or No")
              .required("Select Yes or No")
              .default([true]),
          })
        )
        .min(1, "Add at least one comparison row")
        .required("Add at least one comparison row"),
    }),

    // Similar products
    similarProducts: yup
      .array()
      .of(
        yup.object({
          _id: yup.string().required(),
          title: yup.string().required(),
          productImage: yup.string().optional(),
        })
      )
      .optional()
      .default([]),

    // faqs
    faqs: yup
      .array()
      .of(faqItemSchema)
      .max(10, "Maximum 10 FAQs allowed")
      .default([]),

    // -------- Specification (flat FE fields) --------
    specificationMainTitle: yup.string().transform(trimOrEmpty).optional(),
    specificationBgImage: yup.mixed<UploadFileValue>().nullable(),

    specificationTitle1: yup.string().transform(trimOrEmpty).optional(),
    specificationDescr1: yup.string().transform(trimOrEmpty).optional(),
    specificationItemImage1: yup.mixed<UploadFileValue>().nullable(),
    specificationItemImagemobile1: yup.mixed<UploadFileValue>().nullable(),

    specificationTitle2: yup.string().transform(trimOrEmpty).optional(),
    specificationDescr2: yup.string().transform(trimOrEmpty).optional(),
    specificationItemImage2: yup.mixed<UploadFileValue>().nullable(),
    specificationItemImagemobile2: yup.mixed<UploadFileValue>().nullable(),

    specificationTitle3: yup.string().transform(trimOrEmpty).optional(),
    specificationDescr3: yup.string().transform(trimOrEmpty).optional(),
    specificationItemImage3: yup.mixed<UploadFileValue>().nullable(),
    specificationItemImagemobile3: yup.mixed<UploadFileValue>().nullable(),

    specificationTitle4: yup.string().transform(trimOrEmpty).optional(),
    specificationDescr4: yup.string().transform(trimOrEmpty).optional(),
    specificationItemImage4: yup.mixed<UploadFileValue>().nullable(),
    specificationItemImagemobile4: yup.mixed<UploadFileValue>().nullable(),
  })
  // ---------- Object-level tests (no cyclic deps) ----------
  .test(
    "spec-main-title-required-if-used",
    "Specification main title is required",
    function (values) {
      const v: any = values || {};

      const used =
        hasFile(v.specificationBgImage) ||
        // item 1
        hasText(v.specificationTitle1) ||
        hasText(v.specificationDescr1) ||
        hasFile(v.specificationItemImage1) ||
        hasFile(v.specificationItemImagemobile1) ||
        // item 2
        hasText(v.specificationTitle2) ||
        hasText(v.specificationDescr2) ||
        hasFile(v.specificationItemImage2) ||
        hasFile(v.specificationItemImagemobile2) ||
        // item 3
        hasText(v.specificationTitle3) ||
        hasText(v.specificationDescr3) ||
        hasFile(v.specificationItemImage3) ||
        hasFile(v.specificationItemImagemobile3) ||
        // item 4
        hasText(v.specificationTitle4) ||
        hasText(v.specificationDescr4) ||
        hasFile(v.specificationItemImage4) ||
        hasFile(v.specificationItemImagemobile4);

      if (!used) return true;

      if (!hasText(v.specificationMainTitle)) {
        return this.createError({
          path: "specificationMainTitle",
          message: "Specification main title is required",
        });
      }

      return true;
    }
  )
  .test("spec-item-1-pair", "Specification item 1 invalid", function (values) {
    const v: any = values || {};

    const used =
      hasText(v.specificationTitle1) ||
      hasText(v.specificationDescr1) ||
      hasFile(v.specificationItemImage1) ||
      hasFile(v.specificationItemImagemobile1);

    if (!used) return true;

    if (!hasText(v.specificationTitle1)) {
      return this.createError({
        path: "specificationTitle1",
        message: "Specification item 1 title is required",
      });
    }
    if (!hasText(v.specificationDescr1)) {
      return this.createError({
        path: "specificationDescr1",
        message: "Specification item 1 description is required",
      });
    }
    return true;
  })
  .test("spec-item-2-pair", "Specification item 2 invalid", function (values) {
    const v: any = values || {};

    const used =
      hasText(v.specificationTitle2) ||
      hasText(v.specificationDescr2) ||
      hasFile(v.specificationItemImage2) ||
      hasFile(v.specificationItemImagemobile2);

    if (!used) return true;

    if (!hasText(v.specificationTitle2)) {
      return this.createError({
        path: "specificationTitle2",
        message: "Specification item 2 title is required",
      });
    }
    if (!hasText(v.specificationDescr2)) {
      return this.createError({
        path: "specificationDescr2",
        message: "Specification item 2 description is required",
      });
    }
    return true;
  })
  .test("spec-item-3-pair", "Specification item 3 invalid", function (values) {
    const v: any = values || {};

    const used =
      hasText(v.specificationTitle3) ||
      hasText(v.specificationDescr3) ||
      hasFile(v.specificationItemImage3) ||
      hasFile(v.specificationItemImagemobile3);

    if (!used) return true;

    if (!hasText(v.specificationTitle3)) {
      return this.createError({
        path: "specificationTitle3",
        message: "Specification item 3 title is required",
      });
    }
    if (!hasText(v.specificationDescr3)) {
      return this.createError({
        path: "specificationDescr3",
        message: "Specification item 3 description is required",
      });
    }
    return true;
  })
  .test("spec-item-4-pair", "Specification item 4 invalid", function (values) {
    const v: any = values || {};

    const used =
      hasText(v.specificationTitle4) ||
      hasText(v.specificationDescr4) ||
      hasFile(v.specificationItemImage4) ||
      hasFile(v.specificationItemImagemobile4);

    if (!used) return true;

    if (!hasText(v.specificationTitle4)) {
      return this.createError({
        path: "specificationTitle4",
        message: "Specification item 4 title is required",
      });
    }
    if (!hasText(v.specificationDescr4)) {
      return this.createError({
        path: "specificationDescr4",
        message: "Specification item 4 description is required",
      });
    }
    return true;
  });

export type ProductFormValues = yup.InferType<typeof productSchema>;
