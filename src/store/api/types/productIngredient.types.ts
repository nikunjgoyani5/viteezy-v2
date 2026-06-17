export type IngredientImage = null | {
  type: "Image" | string;
  url: string;
  sortOrder: number;
};

/** Product ref as returned in list/other APIs (IDs only) */
export type ProductIngredient = {
  _id: string;
  products: string[];
  name: string;
  scientificName?: string;
  description: string;
  image: IngredientImage;
  isActive: boolean;
  isDeleted: boolean;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  updatedBy?: string;
  linkedProductCount: number;
};

/** Minimal product shape in get-by-id response (products array is full objects) */
export type IngredientProductRef = {
  _id: string;
  title?: string;
  [key: string]: unknown;
};

/** Ingredient as returned by get-by-id API (products are full product objects) */
export type ProductIngredientDetail = Omit<ProductIngredient, "products"> & {
  products: IngredientProductRef[];
};

export type Pagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetProductIngredientsParams = {
  page?: number;
  limit?: number;
  search?: string;
};

export type GetProductIngredientsResponse = {
  success: boolean;
  message: string;
  data: ProductIngredient[];
  pagination: Pagination;
};

export type GetProductIngredientByIdResponse = {
  success: boolean;
  message: string;
  data: { ingredient: ProductIngredientDetail };
};

export type CreateProductIngredientResponse = {
  success: boolean;
  message: string;
  data: { ingredient: ProductIngredient };
};

export type UpdateProductIngredientResponse = {
  success: boolean;
  message: string;
  data: { ingredient: ProductIngredient };
};

export type DeleteProductIngredientResponse = {
  success: boolean;
  message: string;
};
