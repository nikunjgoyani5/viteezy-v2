import type { PaginationData } from "./user.types";

export type DeviceType = "WEB" | "MOBILE";

export interface HeaderBanner {
  _id: string;
  text: string;
  deviceType: DeviceType;
  isActive: boolean;
  isScheduled: boolean;
  startDate: string | null;
  endDate: string | null;
  isDeleted: boolean;
  createdBy: string;
  updatedBy: string;
  createdAt: string;
  updatedAt: string;
}

export interface GetHeaderBannersParams {
  page?: number;
  limit?: number;
  deviceType?: DeviceType;
  isActive?: boolean;
  search?: string;
}

export interface GetHeaderBannersResponse {
  success: boolean;
  message: string;
  data: HeaderBanner[];
  pagination: PaginationData;
}

