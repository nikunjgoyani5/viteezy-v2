import * as yup from "yup";
import { yupResolver } from "@hookform/resolvers/yup";

export type UploadMaybe = File | string | null;

export type CTA = {
  label: string;
  link: string;
  order: number;
  image: UploadMaybe;
};

export type Benefit = {
  title: string;
  description: string;
  order: number;
  icon: UploadMaybe;
};

export type Step = {
  title: string;
  description: string;
  order: number;
  image: UploadMaybe;
};

export type Metric = {
  label: string;
  value: string | number | null;
  order: number;
};

export type Feature = {
  title: string;
  description: string;
  order: number;
  icon: UploadMaybe;
};

export type LandingProductCategory = {
  _id: string;
  name: string;
  slug: string;
  description?: string;
  icon: string | null;
  image: {
    type: string;
    url: string;
    sortOrder: number;
  } | null;
};

export type LandingFormValues = {
  // Hero
  heroSection_title: string;
  heroSection_description: string;
  heroSection_video_url: string;
  heroBackgroundImage: UploadMaybe;
  heroSection_isEnabled: boolean;
  heroSection_order: number;

  heroSection_highlightedText: { value: string }[]; // max 10

  heroSection_primaryCTA: CTA[]; // fixed 3

  // Membership
  membershipSection_title: string;
  membershipSection_subTitle: string;
  membershipSection_description: string;
  membershipBackgroundImage: UploadMaybe;
  membershipSection_isEnabled: boolean;
  membershipSection_order: number;
  membershipSection_benefits: Benefit[]; // fixed 3

  // How it works
  howItWorksSection_title: string;
  howItWorksSection_subTitle: string;
  howItWorksSection_stepsCount: number;
  howItWorksSection_isEnabled: boolean;
  howItWorksSection_order: number;
  howItWorksSection_steps: Step[]; // fixed 3

  // Product Category section
  productCategorySection_title: string;
  productCategorySection_subTitle: string;
  productCategorySection_description: string;
  productCategorySection_categories: LandingProductCategory[];
  productCategorySection_isEnabled: boolean;
  productCategorySection_order: number;

  // Community
  communitySection_title: string;
  communitySection_subTitle: string;
  communitySection_isEnabled: boolean;
  communitySection_order: number;
  communityBackgroundImage: UploadMaybe;
  communitySection_metrics: Metric[]; // fixed 4

  // Features
  featuresSection_title: string;
  featuresSection_subTitle: string;
  featuresSection_description: string;
  featuresSection_isEnabled: boolean;
  featuresSection_order: number;
  featuresSection_features: Feature[]; // fixed 4

  // Designed by science
  designedByScienceSection_title: string;
  designedByScienceSection_description: string;
  designedByScienceSection_isEnabled: boolean;
  designedByScienceSection_order: number;
  designedByScienceSection_steps: Step[]; // fixed 3

  // Testimonials
  testimonialsSection_title: string;
  testimonialsSection_subTitle: string;
  testimonialsSection_isEnabled: boolean;
  testimonialsSection_order: number;

  // Blog
  blogSection_title: string;
  blogSection_description: string;
  blogSection_isEnabled: boolean;
  blogSection_order: number;

  // FAQ section header
  faqSection_title: string;
  faqSection_description: string;
  faqSection_isEnabled: boolean;
  faqSection_order: number;

  // overall
  isActive: boolean;
};

// Allowed image types and max size for uploads (must match UploadFile component)
const ALLOWED_IMAGE_TYPES = ["image/jpeg", "image/png", "image/webp"];
const MAX_FILE_BYTES = 2 * 1024 * 1024; // 2MB

/** Returns error message for invalid file type/size, or null if valid. */
function validateFileTypeAndSize(file: File): string | null {
  const mime = (file.type || "").toLowerCase();
  const isAllowed = ALLOWED_IMAGE_TYPES.some((t) => mime === t);
  if (!isAllowed) {
    return "Invalid file type. Please upload an image only (PNG, JPG, WebP).";
  }
  if (file.size > MAX_FILE_BYTES) {
    return "File size must not exceed 2MB.";
  }
  return null;
}

// Helper function to validate file uploads (presence)
const validateFile = (value: UploadMaybe): boolean => {
  if (value === null || value === undefined) return false;
  if (typeof value === "string") return value.trim() !== "";
  if (value instanceof File) return true;
  return false;
};

const uploadSchema = yup.mixed().nullable();

// Helper to create conditional required string validation
const conditionalRequiredString = (message: string, enabledField: string) =>
  yup
    .string()
    .when(enabledField, {
      is: true,
      then: (schema) => schema.required(message).trim(),
      otherwise: (schema) => schema.optional().default(""),
    });

// Helper to create conditional required file validation (with type/size checks)
const conditionalRequiredFile = (message: string, enabledField: string) =>
  yup
    .mixed()
    .nullable()
    .when(enabledField, {
      is: true,
      then: (schema) =>
        schema.test("file", message, function (value) {
          const v = value as UploadMaybe;
          if (v === null || v === undefined) return false;
          if (typeof v === "string") return v.trim() !== "";
          if (v instanceof File) {
            const err = validateFileTypeAndSize(v);
            if (err) throw this.createError({ message: err });
            return true;
          }
          return false;
        }),
      otherwise: (schema) => schema.nullable(),
    });


export const landingSchema = yup.object({
  heroSection_isEnabled: yup.boolean().default(true),
  heroSection_order: yup.number().default(1),
  heroSection_title: conditionalRequiredString(
    "Title is required",
    "heroSection_isEnabled"
  ),
  heroSection_description: conditionalRequiredString(
    "Description is required",
    "heroSection_isEnabled"
  ),
  heroSection_video_url: conditionalRequiredString(
    "Video URL is required",
    "heroSection_isEnabled"
  ),
  heroBackgroundImage: conditionalRequiredFile(
    "Hero background image is required",
    "heroSection_isEnabled"
  ),

  heroSection_highlightedText: yup
    .array()
    .of(
      yup.object({
        value: conditionalRequiredString(
          "Animation title is required",
          "heroSection_isEnabled"
        ),
      })
    )
    .max(10, "Maximum 10 titles allowed")
    .default([{ value: "" }]),

  // All three CTA buttons are required when hero section is enabled
  // Validate at array level to access root-level heroSection_isEnabled field
  heroSection_primaryCTA: yup
    .array()
    .of(
      yup.object({
        label: yup.string().default(""),
        link: yup.string().default(""),
        order: yup.number().required(),
        image: yup.mixed().nullable().default(null),
      })
    )
    .length(3, "All three CTA buttons are required")
    .test("cta-fields-required", "All CTA fields are required when hero section is enabled", function (ctaArray) {
      // Access root document through this.parent (the array is a child of root)
      const root = this.parent;
      const isEnabled = root?.heroSection_isEnabled;
      
      if (isEnabled === true && ctaArray) {
        // Validate all three CTAs have required fields (except label)
        for (let i = 0; i < ctaArray.length; i++) {
          const cta = ctaArray[i];
          
          // Check label
          // if (!cta.label || (typeof cta.label === "string" && cta.label.trim() === "")) {
          //   return this.createError({
          //     path: `heroSection_primaryCTA[${i}].label`,
          //     message: "CTA label is required",
          //   });
          // }
          
          // Check link
          if (!cta.link || (typeof cta.link === "string" && cta.link.trim() === "")) {
            return this.createError({
              path: `heroSection_primaryCTA[${i}].link`,
              message: "CTA link is required",
            });
          }
          
          // Check image
          if (!validateFile(cta.image as UploadMaybe)) {
            return this.createError({
              path: `heroSection_primaryCTA[${i}].image`,
              message: "CTA image is required",
            });
          }
        }
      }
      
      return true;
    })
    .required(),

  membershipSection_isEnabled: yup.boolean().default(true),
  membershipSection_order: yup.number().default(2),
  membershipSection_title: conditionalRequiredString(
    "Heading is required",
    "membershipSection_isEnabled"
  ),
  membershipSection_subTitle: yup.string().optional().default(""),
  membershipSection_description: conditionalRequiredString(
    "Description is required",
    "membershipSection_isEnabled"
  ),
  membershipBackgroundImage: conditionalRequiredFile(
    "Background image is required",
    "membershipSection_isEnabled"
  ),

  membershipSection_benefits: yup
    .array()
    .of(
      yup.object({
        title: conditionalRequiredString(
          "Card title is required",
          "membershipSection_isEnabled"
        ),
        description: conditionalRequiredString(
          "Card subtitle is required",
          "membershipSection_isEnabled"
        ),
        order: yup.number().required(),
        icon: conditionalRequiredFile(
          "Card icon is required",
          "membershipSection_isEnabled"
        ),
      })
    )
    .length(3)
    .required(),

  howItWorksSection_isEnabled: yup.boolean().default(true),
  howItWorksSection_order: yup.number().default(3),
  howItWorksSection_title: conditionalRequiredString(
    "Title is required",
    "howItWorksSection_isEnabled"
  ),
  howItWorksSection_subTitle: conditionalRequiredString(
    "Subtitle is required",
    "howItWorksSection_isEnabled"
  ),
  howItWorksSection_stepsCount: yup.number().min(1).max(3).required(),
  howItWorksSection_steps: yup
    .array()
    .of(
      yup.object({
        title: conditionalRequiredString(
          "Step title is required",
          "howItWorksSection_isEnabled"
        ),
        description: conditionalRequiredString(
          "Step description is required",
          "howItWorksSection_isEnabled"
        ),
        order: yup.number().required(),
        image: conditionalRequiredFile(
          "Step image is required",
          "howItWorksSection_isEnabled"
        ),
      })
    )
    .length(3)
    .required(),

  productCategorySection_isEnabled: yup.boolean().default(true),
  productCategorySection_order: yup.number().default(4),
  productCategorySection_title: conditionalRequiredString(
    "Title is required",
    "productCategorySection_isEnabled"
  ),
  productCategorySection_subTitle: yup.string().optional().default(""),
  productCategorySection_description: conditionalRequiredString(
    "Description is required",
    "productCategorySection_isEnabled"
  ),
  productCategorySection_categories: yup
    .array()
    .of(
      yup.object({
        _id: yup.string().required(),
        name: yup.string().required(),
        slug: yup.string().required(),
        description: yup.string().optional(),
        icon: yup.string().nullable(),
        image: yup
          .object({
            type: yup.string().required(),
            url: yup.string().required(),
            sortOrder: yup.number().required(),
          })
          .nullable(),
      })
    )
    .optional()
    .default([]),

  communitySection_isEnabled: yup.boolean().default(true),
  communitySection_order: yup.number().default(5),
  communitySection_title: conditionalRequiredString(
    "Title is required",
    "communitySection_isEnabled"
  ),
  communitySection_subTitle: conditionalRequiredString(
    "Subtitle is required",
    "communitySection_isEnabled"
  ),
  communityBackgroundImage: conditionalRequiredFile(
    "Background image is required",
    "communitySection_isEnabled"
  ),
  communitySection_metrics: yup
    .array()
    .of(
      yup.object({
        label: conditionalRequiredString(
          "Metric label is required",
          "communitySection_isEnabled"
        ),
        value: yup
          .mixed<string | number>()
          .nullable()
          .test("conditional-required", "Metric value is required", function (value) {
            const enabled = this.parent?.communitySection_isEnabled;
            if (enabled === true) {
              if (value === null || value === undefined || value === "") {
                return this.createError({ message: "Metric value is required" });
              }
            }
            return true;
          }),
        order: yup.number().required(),
      })
    )
    .length(4)
    .required(),

  featuresSection_isEnabled: yup.boolean().default(true),
  featuresSection_order: yup.number().default(6),
  featuresSection_title: conditionalRequiredString(
    "Title is required",
    "featuresSection_isEnabled"
  ),
  featuresSection_subTitle: yup.string().optional().default(""),
  featuresSection_description: conditionalRequiredString(
    "Description is required",
    "featuresSection_isEnabled"
  ),
  featuresSection_features: yup
    .array()
    .of(
      yup.object({
        title: conditionalRequiredString(
          "Feature title is required",
          "featuresSection_isEnabled"
        ),
        description: conditionalRequiredString(
          "Feature description is required",
          "featuresSection_isEnabled"
        ),
        order: yup.number().required(),
        icon: conditionalRequiredFile(
          "Feature icon is required",
          "featuresSection_isEnabled"
        ),
      })
    )
    .length(4)
    .required(),

  designedByScienceSection_isEnabled: yup.boolean().default(true),
  designedByScienceSection_order: yup.number().default(7),
  designedByScienceSection_title: conditionalRequiredString(
    "Title is required",
    "designedByScienceSection_isEnabled"
  ),
  designedByScienceSection_description: conditionalRequiredString(
    "Description is required",
    "designedByScienceSection_isEnabled"
  ),
  designedByScienceSection_steps: yup
    .array()
    .of(
      yup.object({
        title: conditionalRequiredString(
          "Step title is required",
          "designedByScienceSection_isEnabled"
        ),
        description: conditionalRequiredString(
          "Step description is required",
          "designedByScienceSection_isEnabled"
        ),
        order: yup.number().required(),
        image: conditionalRequiredFile(
          "Step image is required",
          "designedByScienceSection_isEnabled"
        ),
      })
    )
    .length(3)
    .required(),

  testimonialsSection_isEnabled: yup.boolean().default(true),
  testimonialsSection_order: yup.number().default(8),
  testimonialsSection_title: conditionalRequiredString(
    "Title is required",
    "testimonialsSection_isEnabled"
  ),
  testimonialsSection_subTitle: yup.string().optional().default(""),

  blogSection_isEnabled: yup.boolean().default(true),
  blogSection_order: yup.number().default(9),
  blogSection_title: conditionalRequiredString(
    "Title is required",
    "blogSection_isEnabled"
  ),
  blogSection_description: conditionalRequiredString(
    "Description is required",
    "blogSection_isEnabled"
  ),

  faqSection_isEnabled: yup.boolean().default(true),
  faqSection_order: yup.number().default(10),
  faqSection_title: conditionalRequiredString(
    "Title is required",
    "faqSection_isEnabled"
  ),
  faqSection_description: conditionalRequiredString(
    "Description is required",
    "faqSection_isEnabled"
  ),

  isActive: yup.boolean().default(true),
});

export const LANDING_DEFAULT_VALUES: LandingFormValues = {
  heroSection_title: "",
  heroSection_description: "",
  heroSection_video_url: "",
  heroBackgroundImage: null,
  heroSection_isEnabled: true,
  heroSection_order: 1,
  heroSection_highlightedText: [{ value: "" }],

  heroSection_primaryCTA: [
    { label: "", link: "", order: 1, image: null },
    { label: "", link: "", order: 2, image: null },
    { label: "", link: "", order: 3, image: null },
  ],

  membershipSection_title: "",
  membershipSection_subTitle: "",
  membershipSection_description: "",
  membershipBackgroundImage: null,
  membershipSection_isEnabled: true,
  membershipSection_order: 2,
  membershipSection_benefits: [
    { title: "", description: "", order: 1, icon: null },
    { title: "", description: "", order: 2, icon: null },
    { title: "", description: "", order: 3, icon: null },
  ],

  howItWorksSection_title: "",
  howItWorksSection_subTitle: "",
  howItWorksSection_stepsCount: 3,
  howItWorksSection_isEnabled: true,
  howItWorksSection_order: 3,
  howItWorksSection_steps: [
    { title: "", description: "", order: 1, image: null },
    { title: "", description: "", order: 2, image: null },
    { title: "", description: "", order: 3, image: null },
  ],

  productCategorySection_title: "",
  productCategorySection_subTitle: "",
  productCategorySection_description: "",
  productCategorySection_categories: [],
  productCategorySection_isEnabled: true,
  productCategorySection_order: 4,

  communitySection_title: "",
  communitySection_subTitle: "",
  communitySection_isEnabled: true,
  communitySection_order: 5,
  communityBackgroundImage: null,
  communitySection_metrics: [
    { label: "", value: null, order: 1 },
    { label: "", value: null, order: 2 },
    { label: "", value: null, order: 3 },
    { label: "", value: null, order: 4 },
  ],

  featuresSection_title: "",
  featuresSection_subTitle: "",
  featuresSection_description: "",
  featuresSection_isEnabled: true,
  featuresSection_order: 6,
  featuresSection_features: [
    { title: "", description: "", order: 1, icon: null },
    { title: "", description: "", order: 2, icon: null },
    { title: "", description: "", order: 3, icon: null },
    { title: "", description: "", order: 4, icon: null },
  ],

  designedByScienceSection_title: "",
  designedByScienceSection_description: "",
  designedByScienceSection_isEnabled: true,
  designedByScienceSection_order: 7,
  designedByScienceSection_steps: [
    { title: "", description: "", order: 1, image: null },
    { title: "", description: "", order: 2, image: null },
    { title: "", description: "", order: 3, image: null },
  ],

  testimonialsSection_title: "",
  testimonialsSection_subTitle: "",
  testimonialsSection_isEnabled: true,
  testimonialsSection_order: 8,

  blogSection_title: "",
  blogSection_description: "",
  blogSection_isEnabled: true,
  blogSection_order: 9,

  faqSection_title: "",
  faqSection_description: "",
  faqSection_isEnabled: true,
  faqSection_order: 10,

  isActive: true,
};
