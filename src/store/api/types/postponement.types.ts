import type { PaginationData } from "./user.types";

export type PostponementStatus = "Pending" | "Approved" | "Rejected";

export interface PostponementUser {
  id: string;
  firstName: string;
  lastName: string;
  email: string;
}

export interface PostponementItem {
  id: string;
  user: PostponementUser;
  orderNumber: string;
  plan: string;
  currentDeliveryDate: string;
  originalDeliveryDate: string;
  requestedDeliveryDate: string;
  approvedDeliveryDate: string;
  status: PostponementStatus;
  reason: string | null;
  processedAt: string | null;
  createdAt: string;
}

export interface GetPostponementsParams {
  page?: number;
  limit?: number;
  status?: PostponementStatus;
  search?: string;
}

export interface GetPostponementsResponse {
  success: boolean;
  message: string;
  data: PostponementItem[];
  pagination: PaginationData;
}

export interface ApprovePostponementBody {
  approvedDeliveryDate?: string; // ISO date string, optional
}

export interface RejectPostponementBody {
  reason: string; // required
}

export interface PostponementMutationResponse {
  success: boolean;
  message: string;
}
