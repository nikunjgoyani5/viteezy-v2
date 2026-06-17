const ADMIN_PATH_PREFIX = "/admin";

export const ROUTES = {
  DASHBOARD: ADMIN_PATH_PREFIX + "/dashboard",
  USER_MANAGEMENT: ADMIN_PATH_PREFIX + "/user-management",
  COUPON_MANAGEMENT: {
    BASE: ADMIN_PATH_PREFIX + "/coupon-management",
    CREATE: ADMIN_PATH_PREFIX + "/coupon-management/create",
    EDIT: (id: string) => ADMIN_PATH_PREFIX + "/coupon-management/" + id,
  },
  BLOG: {
    BLOG: ADMIN_PATH_PREFIX + "/blog-management/blog",
    BLOG_CATEGORY: ADMIN_PATH_PREFIX + "/blog-management/category",
    BLOG_CMS: ADMIN_PATH_PREFIX + "/blog-cms",
    NEW_BLOG: ADMIN_PATH_PREFIX + "/blog-management/blog/new",
    EDIT_BLOG: ADMIN_PATH_PREFIX + "/blog-management/blog/",
  },
  LANDING_PAGE: ADMIN_PATH_PREFIX + "/landing-page",
  OUR_TEAM: ADMIN_PATH_PREFIX + "/our-team",
  ALL_PAGES: ADMIN_PATH_PREFIX + "/all-pages",
  MEMBERSHIP_PLANS: ADMIN_PATH_PREFIX + "/membership-plans",
  MEMBERSHIP: ADMIN_PATH_PREFIX + "/membership",
  ORDER_MANAGMENT: ADMIN_PATH_PREFIX + "/order-management",
  SUBSCRIPTION_MANAGEMENT: ADMIN_PATH_PREFIX + "/subscription-management",
  DELIVERY_POSTPONEMENT: ADMIN_PATH_PREFIX + "/delivery-postponement",
  HEADER_BANNERS: ADMIN_PATH_PREFIX + "/header-banners",
  CMS_MANAGEMENT: {
    FAQS: ADMIN_PATH_PREFIX + "/cms-management/faqs",
    MANAGE_FAQS: ADMIN_PATH_PREFIX + "/cms-management/faqs/manage",
    FAQ_EDIT: (id: string) => ADMIN_PATH_PREFIX + "/cms-management/faqs/" + id,
    TESTIMONIALS: ADMIN_PATH_PREFIX + "/cms-management/testimonials",
  },
  INGREDIENTS_MANAGMENT: {
    BASE: ADMIN_PATH_PREFIX + "/ingredients-management",
    CREATE_INGREDIENT: ADMIN_PATH_PREFIX + "/ingredients-management/create",
  },
  PRODUCT_MANAGEMENT: {
    CATEGORY: ADMIN_PATH_PREFIX + "/product-management/category",
    PRODUCT: ADMIN_PATH_PREFIX + "/product-management/product",
    CREATE_PRODUCT: ADMIN_PATH_PREFIX + "/product-management/product/create",
  },
  GENERAL_SETTINGS: ADMIN_PATH_PREFIX + "/settings",
  COMING_SOON: ADMIN_PATH_PREFIX + "/coming-soon",
};
