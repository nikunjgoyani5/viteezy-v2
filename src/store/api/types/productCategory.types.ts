export type CategoryImage = null | {
  type: "Image" | string;
  url: string;
  sortOrder: number;
};

export type ProductCategorySeo = {
  hreflang: string[];
};

export type ProductCategory = {
  _id: string;
  slug: string;
  name: string;
  description?: string;
  sortOrder: number;
  icon: string | null;
  image: CategoryImage;
  seo: ProductCategorySeo;
  isActive: boolean;
  productCount: number;
  isDeleted: boolean;
  createdBy: string;
  updatedBy?: string;
  createdAt: string;
  updatedAt: string;
};

export type ProductCategoriesPagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetProductCategoriesParams = {
  page?: number;
  limit?: number;
  search?: string;
};

export type GetProductCategoriesResponse = {
  success: boolean;
  message: string;
  data: ProductCategory[];
  pagination: ProductCategoriesPagination;
};

export type CreateProductCategoryResponse = {
  success: boolean;
  message: string;
  data: { category: ProductCategory };
};

export type UpdateProductCategoryResponse = {
  success: boolean;
  message: string;
  data: { category: ProductCategory };
};

export type DeleteProductCategoryResponse = {
  success: boolean;
  message: string;
};

// Types for categories list with products
export type CategoryProduct = {
  _id: string;
  title: string;
  slug: string;
  productImage: string;
  galleryImages: string[];
  shortDescription: string | Record<string, string>;
};

export type CategoryWithProducts = {
  _id: string;
  slug: string;
  name: string;
  description: string;
  sortOrder: number;
  icon: string | null;
  image: CategoryImage;
  products: CategoryProduct[];
};

export type GetCategoriesListResponse = {
  success: boolean;
  message: string;
  data: {
    categories: CategoryWithProducts[];
  };
};

// Public products categories API response
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

export type GetPublicCategoriesResponse = {
  success: boolean;
  message: string;
  data: {
    categories: PublicProductCategory[];
  };
};
