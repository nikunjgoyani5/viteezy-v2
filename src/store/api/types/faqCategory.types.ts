export type FaqCategory = {
  _id: string;
  title: string;
  slug: string;
  icon: string | null;
  isActive: boolean;
  isDeleted: boolean;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
  updatedBy?: string;
};

export type GetFaqCategoriesParams = {
  limit?: number;
};

export type GetFaqCategoriesResponse = {
  success: boolean;
  message: string;
  data: FaqCategory[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
};

export type CreateFaqCategoryResponse = {
  success: boolean;
  message: string;
  data: FaqCategory;
};

export type DeleteFaqCategoryResponse = {
  success: boolean;
  message: string;
};

export type UpdateFaqCategoryResponse = {
  success: boolean;
  message: string;
  data: FaqCategory;
};
