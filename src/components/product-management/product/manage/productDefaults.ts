import { ProductFormValues } from "./product.schema";

export const PRODUCT_DEFAULT_VALUES: ProductFormValues = {
  title: "",
  description: "",
  shortDescription: "",
  hasStandupPouch: false,
  status: true,
  isFeatured: false,

  // Arrays
  categories: [],
  healthGoals: [],
  ingredientMeta: {
    sectionTitle: "",
    sectionSubtitle: "",
    excipients: "",
    backgroundImage: null,
  },
  ingredientCompositions: [],
  benefits: [""],
  similarProducts: [],
  galleryImages: [],
  standupPouchImages: [],

  // Rich Text
  nutritionInfo: "",
  howToUse: "",

  faqs: [],

  // Comparison
  comparisonSection: {
    title: "",
    columns: ["other"],
    rows: [{ label: "", values: [true] }],
  },

  // Specification (flat fields)
  specificationMainTitle: "",
  specificationBgImage: null,
  specificationTitle1: "",
  specificationDescr1: "",
  specificationItemImage1: null,
  specificationItemImagemobile1: null,
  specificationTitle2: "",
  specificationDescr2: "",
  specificationItemImage2: null,
  specificationItemImagemobile2: null,
  specificationTitle3: "",
  specificationDescr3: "",
  specificationItemImage3: null,
  specificationItemImagemobile3: null,
  specificationTitle4: "",
  specificationDescr4: "",
  specificationItemImage4: null,
  specificationItemImagemobile4: null,

  // Prices
  sachetPrices: {
    thirtyDays: {
      currency: "USD",
      taxRate: 0,
      durationDays: 30,
      capsuleCount: 30,
      amount: 0,
      discountedPrice: 0,
      features: [],
    },
    sixtyDays: {
      currency: "USD",
      taxRate: 0,
      durationDays: 60,
      capsuleCount: 60,
      amount: 0,
      discountedPrice: 0,
      features: [],
    },
    ninetyDays: {
      currency: "USD",
      taxRate: 0,
      durationDays: 90,
      capsuleCount: 90,
      amount: 0,
      discountedPrice: 0,
      features: [],
    },
    oneEightyDays: {
      currency: "USD",
      taxRate: 0,
      durationDays: 180,
      capsuleCount: 180,
      amount: 0,
      discountedPrice: 0,
      features: [],
    },
    oneTime: {
      count30: {
        currency: "USD",
        taxRate: 0,
        capsuleCount: 0,
        amount: 0,
        discountedPrice: 0,
        features: [],
      },
      count60: {
        currency: "USD",
        taxRate: 0,
        capsuleCount: 0,
        amount: 0,
        discountedPrice: 0,
        features: [],
      },
    },
  },
  standupPouchPrice: {
    count_0: {
      currency: "USD",
      taxRate: 0,
      capsuleCount: 60,
      amount: 0,
      discountedPrice: 0,
      features: [],
    },
    count_1: {
      currency: "USD",
      taxRate: 0,
      capsuleCount: 120,
      amount: 0,
      discountedPrice: 0,
      features: [],
    },
  },
};
