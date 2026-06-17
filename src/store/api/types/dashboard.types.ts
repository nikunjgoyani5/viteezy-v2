export interface ChangeData {
  percentage: number;
  isPositive: boolean;
}

export interface StatItem {
  value: number;
  change: ChangeData;
}

export type DashboardStats = Record<string, StatItem>;

export interface StatsCardsProps {
  data: {
    stats: DashboardStats;
  };
}

export interface GetDashboardStatsResponse {
  success: boolean;
  message: string;
  data: { stats: DashboardStats };
}

export type RevenuePeriod = "daily" | "weekly" | "monthly";

export type RevenueOverviewPoint = {
  date: string;
  label: string;
  revenue: number;
  count: number;
};

export type GetRevenueOverviewResponse = {
  success: boolean;
  message: string;
  data: {
    period: RevenuePeriod;
    startDate: string;
    endDate: string;
    data: RevenueOverviewPoint[];
  };
};

export type GetRevenueOverviewParams = {
  period?: RevenuePeriod;
  startDate?: string;
  endDate?: string;
};

export type TopSellingPlan = {
  name: string;
  cycleDays?: number;
  count: number;
  revenue: number;
  percentage: number;
};

export type GetTopSellingPlansResponse = {
  success: boolean;
  message: string;
  data: {
    period: {
      startDate: string;
      endDate: string;
      label: string;
    };
    summary: {
      totalCount: number;
      totalRevenue: number;
    };
    plans: TopSellingPlan[];
  };
};

export type GetTopSellingPlansParams = {
  startDate?: string;
  endDate?: string;
};

export type ProductPeriod = {
  startDate: string;
  endDate: string;
  label: string;
};

export type ProductSummary = {
  totalProducts: number;
  totalRevenue: number;
  totalOrders: number;
};

export type Product = {
  productId: string;
  productName: string;
  productImage: string;
  slug: string;
  category: string;
  price: number;
  currency: string;
  totalSales: number;
  orderCount: number;
  averageOrderValue: number;
  revenue: number;
  revenuePercentage: number;
  status: boolean;
  description: string;
};

export type TopSellingProductsResponse = {
  success: boolean;
  message: string;
  data: {
    period: ProductPeriod;
    summary: ProductSummary;
    products: Array<Product>;
  };
};
