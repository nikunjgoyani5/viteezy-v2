/**
 * Product API Types
 */

export interface Product {
  _id: string;
  title: string;
  description?: string;
  price: {
    amount: number;
  };
  productImage: string;
  category?: string;
  stock?: number;
  is_liked?: boolean;
}

export interface GetProductsResponse {
  success: boolean;
  message?: string;
  data: Product[];
  pagination?: {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

export type CategoryProduct = {
  _id: string;
  title: string;
  slug: string;
  productImage?: string;
  galleryImages?: string[];
  shortDescription?: string;
  is_liked?: boolean;
};

export type CategoryWithProducts = {
  _id: string;
  slug: string;
  name: string;
  description?: string;
  icon?: string | null;
  image?: { type: string; url: string; sortOrder?: number } | null;
  products?: CategoryProduct[];
};

export type CategoriesWithProductsResponse = {
  success: boolean;
  message: string;
  data: { categories: CategoryWithProducts[] };
};
