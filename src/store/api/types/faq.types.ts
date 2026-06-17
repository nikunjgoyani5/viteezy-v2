export type CreateFaqPayload = {
  question: string;
  answer: string;
  categoryId: string;
  tags: string[];
  status: "Active" | "Inactive";
  isActive: boolean;
};

export type CreateFaqResponse = {
  success: boolean;
  message: string;
  data: any;
};

export type UpdateFaqPayload = CreateFaqPayload;

export type UpdateFaqResponse = {
  success: boolean;
  message: string;
  data: { faq: Faq };
};

export type DeleteFaqResponse = {
  success: boolean;
  message: string;
  data?: unknown;
};

export type FaqCategoryRef = {
  _id: string;
  title: string;
  slug: string;
};

export type Faq = {
  _id: string;
  question: string;
  answer: string;
  categoryId: FaqCategoryRef;
  tags: string[];
  sortOrder: number;
  status: "Active" | "Inactive" | string;
  isActive: boolean;
  isDeleted: boolean;
  createdBy: string;
  createdAt: string; // ISO
  updatedAt: string; // ISO
  updatedBy?: string;
  __v?: number;
};

export type GetFaqResponse = {
  success: boolean;
  message: string;
  data: {
    faq: Faq;
  };
};

export type FaqPagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetFaqsByCategoryParams = {
  categoryId: string;
  page?: number;
  limit?: number;
};

export type GetFaqsByCategoryResponse = {
  success: boolean;
  message: string;
  data: Faq[];
  pagination: FaqPagination;
};
