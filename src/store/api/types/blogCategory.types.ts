export type BlogCategory = {
  _id: string;
  slug: string;
  title: string;
  isActive: boolean;
  isDeleted: boolean;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  updatedBy?: string;
};

export type GetBlogCategoriesParams = {
  page?: number;
  limit?: number;
};

export type BlogCategoriesPagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetBlogCategoriesResponse = {
  success: boolean;
  message: string;
  data: BlogCategory[];
  pagination: BlogCategoriesPagination;
};

export type CreateBlogCategoryPayload = {
  title: string;
  isActive: boolean; 
};

export type CreateBlogCategoryResponse = {
  success: boolean;
  message: string;
  data: BlogCategory;
};
