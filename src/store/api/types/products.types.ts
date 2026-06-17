export type ProductListIngredient = {
  _id: string;
  name: string;
  description: string;
};

export type ProductListCategory = {
  _id: string;
  slug: string;
  name: string;
  description: string;
  sortOrder: number;
  icon: string | null;
  productCount: number;
};

export type ProductListItem = {
  _id: string;
  title: string;
  slug: string;
  description: string;
  shortDescription: string;
  productImage: string;
  benefits: string[];
  ingredients: ProductListIngredient[];
  categories: ProductListCategory[];
  healthGoals: string[];
  status: boolean;
  isActive?: boolean;
  createdAt: string;
  updatedAt: string;
  variants?: string[];
};

export type ProductsPagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetProductsParams = {
  page?: number;
  limit?: number;

  categories?: string;
  healthGoals?: string;
  ingredients?: string;

  // Additional filters supported by the API (see GetProductFiltersResponse)
  variants?: string;
  hasStandupPouch?: string;
  status?: string;

  search?: string;
  sortBy?: "priceHighToLow" | "priceLowToHigh" | "rating" | "relevance";
};

export type GetProductsResponse = {
  success: boolean;
  message: string;
  data: ProductListItem[];
  pagination: ProductsPagination;
};

export type ProductFilterCategory = {
  _id: string;
  slug: string;
  name: string;
  icon: string | null;
};

export type ProductFilterIngredient = {
  _id: string;
  name: string;
};

export type ProductFilterSortBy = {
  label: string;
  value: string;
};

export type GetProductFiltersResponse = {
  success: boolean;
  message: string;
  data: {
    categories: ProductFilterCategory[];
    healthGoals: string[];
    ingredients: ProductFilterIngredient[];
    variants: string[];
    hasStandupPouch: boolean[];
    status: boolean[];
    sortBy: ProductFilterSortBy[];
  };
};

// Public API types for products
export type PublicProductIngredient = {
  _id: string;
  name: string;
  description: string;
  image: {
    type: string;
    url: string;
    sortOrder: number;
  } | null;
};

export type PublicProductCategory = {
  _id: string;
  slug: string;
  name: string;
  description: string;
  sortOrder: number;
  icon: string | null;
  image: {
    type: string;
    url: string;
    sortOrder: number;
  } | null;
  productCount: number;
};

export type PublicProduct = {
  _id: string;
  title: string;
  slug: string;
  description: string;
  shortDescription: string;
  productImage: string;
  benefits: string[];
  ingredients: PublicProductIngredient[];
  categories: PublicProductCategory[];
  healthGoals: string[];
  galleryImages: string[];
  status: boolean;
  variants?: string[];
  createdAt: string;
  updatedAt: string;
};

export type GetPublicProductsParams = {
  page?: number;
  limit?: number;
  search?: string;
  categories?: string;
};

export type GetPublicProductsResponse = {
  success: boolean;
  message: string;
  data: PublicProduct[];
};

// Create and Edit product types

export type Money = {
  currency: string;
  amount: number;
  discountedPrice?: number;
  taxRate?: number;
  durationDays?: number;
  capsuleCount?: number;
  features?: string[];
};

export type SachetPrices = {
  thirtyDays: Money;
  sixtyDays: Money;
  ninetyDays: Money;
  oneEightyDays: Money;
  oneTime: {
    count30: Money;
    count60: Money;
  };
};

export type StandupPouchPrice = {
  count_0: Money;
  count_1: Money;
};

export type ComparisonSection = {
  title: string;
  columns: string[];
  rows: Array<{
    label: string;
    values: boolean[];
  }>;
};

export type IngredientComposition = {
  ingredient: string;
  quantity: string;
  driPercentage: number | "*" | "**";
};

export type IngredientMeta = {
  sectionTitle?: string;
  sectionSubtitle?: string;
  excipients?: string;
  backgroundImage?: {
    type: string;
    url: string;
    sortOrder?: number;
  } | null;
};

export type ProductUpsertPayload = {
  title: string;

  description: string;
  shortDescription: string;

  hasStandupPouch: boolean;

  productImage?: File | null;
  galleryImages?: File[];
  standupPouchImages?: File[];
  specificationBgImage?: File | null;

  sachetPrices: SachetPrices;
  standupPouchPrice: StandupPouchPrice;

  categories: string[];
  ingredientCompositions: IngredientComposition[];
  ingredientMeta?: IngredientMeta;
  healthGoals: string[];
  benefits: string[];

  nutritionInfo: string;
  howToUse: string;

  status?: boolean;
  isFeatured?: boolean;

  comparisonSection?: ComparisonSection;

  specificationMainTitle?: string;

  specificationTitle1?: string;
  specificationDescr1?: string;
  specificationItemImage1?: File | null;
  specificationItemImagemobile1?: File | null;

  specificationTitle2?: string;
  specificationDescr2?: string;
  specificationItemImage2?: File | null;
  specificationItemImagemobile2?: File | null;

  specificationTitle3?: string;
  specificationDescr3?: string;
  specificationItemImage3?: File | null;
  specificationItemImagemobile3?: File | null;

  specificationTitle4?: string;
  specificationDescr4?: string;
  specificationItemImage4?: File | null;
  specificationItemImagemobile4?: File | null;
};

export type ProductAdmin = {
  _id: string;
  title: string;
  slug: string;
  description: string;
  shortDescription: string;
  productImage: string | null;
  galleryImages: string[];
  hasStandupPouch: boolean;
  categories: string[];
  ingredients: string[];
  ingredientCompositions?: Array<{
    ingredient: string | { _id: string };
    quantity: string | number;
    driPercentage: number | "*" | "**";
  }>;
  ingredientMeta?: IngredientMeta;
  healthGoals: string[];
  benefits: string[];
  nutritionInfo: string;
  howToUse: string;
  status: boolean;
  isFeatured: boolean;
  createdAt: string;
  updatedAt: string;
};

export type CreateProductResponse = {
  success: boolean;
  message: string;
  data: { product: ProductAdmin };
};

export type UpdateProductResponse = {
  success: boolean;
  message: string;
  data: { product: ProductAdmin };
};

export type GetProductByIdResponse = {
  success: boolean;
  message: string;
  data: { product: ProductAdmin };
};

export type DeleteProductResponse = {
  success: boolean;
  message: string;
};

export type UpdateProductStatusResponse = {
  success: boolean;
  message: string;
};
