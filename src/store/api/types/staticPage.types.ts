export type StaticPageSEO = {
  title?: string;
  description?: string;
  keywords?: string;
  hreflang?: string[];
};

export type StaticPage = {
  _id: string;
  slug: string;
  title: string;
  content: string; // HTML string
  status: string; // "Published" | "Unpublished"
  seo?: StaticPageSEO;
  isSystemPage?: boolean;
  route?: string;
  isDeleted: boolean;
  createdBy: string;
  createdAt: string; // ISO
  updatedAt: string; // ISO
  updatedBy?: string;
};

export type GetStaticPagesParams = {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
};

export type StaticPagesPagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetStaticPagesResponse = {
  success: boolean;
  message: string;
  data: StaticPage[];
  pagination: StaticPagesPagination;
};

export type GetStaticPageResponse = {
  success: boolean;
  message: string;
  data: {
    staticPage: StaticPage;
  };
};
export type CreateStaticPagePayload = {
  title: string;
  slug: string;
  content: string;
  status: string; // "Published" | "Unpublished"
  seo: {
    title: string;
    description: string;
    keywords: string;
  };
};

export type CreateStaticPageResponse = {
  success: boolean;
  message: string;
  data: {
    staticPage: StaticPage;
  };
};

export type UpdateStaticPagePayload = {
  title: string;
  slug?: string;
  content?: string;
  status?: string;
  seo?: {
    title?: string;
    description?: string;
    keywords?: string;
  };
};

export type UpdateStaticPageResponse = {
  success: boolean;
  message: string;
  data: {
    staticPage: StaticPage;
  };
};

export type UpdateStaticPageStatusPayload = {
  status: "Published" | "Unpublished";
};

export type UpdateStaticPageStatusResponse = {
  success: boolean;
  message: string;
  data: {
    staticPage: StaticPage;
  };
};

export type DeleteStaticPageResponse = {
  success: boolean;
  message: string;
};
