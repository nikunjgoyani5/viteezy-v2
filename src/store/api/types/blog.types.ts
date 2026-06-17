export type BlogCategoryRef = {
  _id: string;
  slug: string;
  title: string;
};

export type BlogSeo = {
  metaTitle: string;
  metaSlug: string;
  metaDescription: string;
};

export type Blog = {
  _id: string;
  title: string;
  description: string;
  seo: BlogSeo;
  coverImage: string | null;
  isActive: boolean;
  authorId: string | null;
  categoryId: BlogCategoryRef;
  viewCount: number;
  isDeleted: boolean;
  createdAt: string;
  updatedAt: string;
};

export type BlogBannerImage = null | {
  type: string;
  url: string;
  sortOrder: number;
};

export type BlogBanner = {
  _id: string;
  banner_image: BlogBannerImage;
  heading: string;
  description: string;
  isDeleted: boolean;
  createdBy: string;
  updatedBy: string;
  createdAt: string;
  updatedAt: string;
};

export type BlogsPagination = {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
};

export type GetBlogsParams = {
  limit?: number;
  page?: number;
  search?: string;
};

export type GetBlogsResponse = {
  success: boolean;
  message: string;
  data: {
    blogs: Blog[];
    blogBanners: BlogBanner[];
  };
  pagination: BlogsPagination;
};

export type CreateBlogResponse = {
  success: boolean;
  message: string;
  data: {
    blog: {
      _id: string;
      id?: string;
      title: string;
      description: string;
      seo: {
        metaTitle: string;
        metaSlug: string;
        metaDescription: string;
      };
      coverImage: string | null;
      isActive: boolean;
      authorId: string | null;
      categoryId: string;
      viewCount: number;
      isDeleted: boolean;
      createdAt: string;
      updatedAt: string;
      __v?: number;
    };
  };
};

export type DeleteBlogResponse = {
  success: boolean;
  message: string;
};

export type GetBlogByIdResponse = {
  success: boolean;
  message: string;
  data: {
    blog: Blog;
  };
};

export type UpdateBlogResponse = {
  success: boolean;
  message: string;
  data: {
    blog: Blog;
  };
};

export type UpdateBlogStatusResponse = {
  success: boolean;
  message: string;
};

export type UpdateBlogStatusArgs = {
  id: string;
  isActive: boolean;
  listArgs: GetBlogsParams;
};

// Blog Banners Types
export type GetBlogBannersResponse = {
  success: boolean;
  message: string;
  data: BlogBanner[];
};

export type CreateBlogBannerResponse = {
  success: boolean;
  message: string;
  data: {
    blogBanner: BlogBanner;
  };
};

export type UpdateBlogBannerResponse = {
  success: boolean;
  message: string;
  data: {
    blogBanner: BlogBanner;
  };
};
