// -------- Stats Types (keep existing) --------
export type StatChange = {
  vsLastMonth: {
    percentage: number;
    isPositive: boolean;
  };
};

export type CountStat = {
  value: number;
  change: StatChange;
};

export type AmountStat = {
  amount: number;
  currency: string;
  change: StatChange;
};

export type ExpiringSoonStat = {
  count: number;
};

export type CouponStats = {
  activeCoupons: CountStat;
  totalRedemptions: CountStat;
  totalDiscountedAmount: AmountStat;
  expiringSoon: ExpiringSoonStat;
};

export type GetCouponStatsResponse = {
  success: boolean;
  message: string;
  data: {
    stats: CouponStats;
  };
};

// -------- List Coupons Types --------
export type CouponStatus = "all" | "active" | "inactive" | "expired";

export type GetCouponsParams = {
  page?: number;
  limit?: number;
  search?: string;
  status?: string;
  type?: string;
};

export type Coupon = {
  _id: string;
  code: string;
  name: string;
  description?: string;
  type: string;
  value: number;
  minOrderAmount?: number;
  maxDiscountAmount?: number;
  usageLimit?: number;
  usageCount: number;
  userUsageLimit?: number;
  applicableProducts: string[];
  applicableCategories: string[];
  excludedProducts: string[];
  validFrom?: string;
  validUntil?: string;
  isActive: boolean;
  isRecurring: boolean;
  oneTimeUse: boolean;
  /** Optional. Months 1–4 for recurring. */
  recurringMonths?: number[];
  isDeleted: boolean;
  createdBy: string;
  createdAt: string;
  updatedAt: string;
};

export type GetCouponsResponse = {
  success: boolean;
  message: string;
  data: Coupon[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
};

// -------- Single Coupon / Update Types --------

export type GetCouponByIdResponse = {
  success: boolean;
  message: string;
  data: {
    coupon: Coupon;
  };
};

export type Money = {
  currency: string;
  amount: number;
  taxRate: number;
};

export type CouponUsageLog = {
  _id: string;

  usageCount: number;
  discountAmount: Money;

  couponCode: string;
  orderNumber: string;

  createdAt: string;
  updatedAt: string;

  coupon: {
    _id: string;
    code: string;
    name: string;
    type: string;
    value: number;
    isActive: boolean;
    validUntil?: string;
  };

  user: {
    _id: string;
    firstName: string;
    lastName: string;
    email: string;
  };

  order: {
    _id: string | null;
    orderNumber?: string;
    status?: string;
  };

  couponId: string;
  userId: string;
  orderId: string;
};

export type GetCouponUsageLogsParams = {
  page?: number;
  limit?: number;
};

export type GetCouponUsageLogsResponse = {
  success: boolean;
  message: string;
  data: CouponUsageLog[];
  pagination: {
    page: number;
    limit: number;
    total: number;
    pages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
};

export type CouponType = "Fixed" | "Percentage";

export type CreateCouponPayload = {
  code: string;
  name: string;
  description?: string | null;

  type: CouponType;
  value?: number;

  minOrderAmount?: number | null;
  maxDiscountAmount?: number | null;

  usageLimit?: number | null;
  userUsageLimit?: number | null;

  validFrom: string;
  validUntil: string;

  isActive: boolean;
  isRecurring: boolean;
  oneTimeUse: boolean;

  /** Optional. Months 1–4 for recurring. */
  recurringMonths?: number[];
};

export type CreateCouponResponse = {
  success: boolean;
  message: string;
};

export type UpdateCouponResponse = {
  success: boolean;
  message: string;
};

export type UpdateCouponStatusPayload = {
  isActive: boolean;
};

export type UpdateCouponStatusResponse = {
  success: boolean;
  message: string;
};

export type DeleteCouponResponse = {
  success: boolean;
  message: string;
};
