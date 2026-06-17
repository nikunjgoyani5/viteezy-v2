export interface ServiceHealth {
  status: "healthy" | "unhealthy";
  response_time_ms: number;
  error: string | null;
}

export interface HealthData {
  status: "healthy" | "unhealthy";
  timestamp: string;
  services: {
    mongodb: ServiceHealth;
    openai: ServiceHealth;
    [key: string]: ServiceHealth;
  };
}

export interface sessionPayload {
  user_id: string;
}

export interface Product {
  id: string;
  title: string;
  shortDescription: string;
  productImage: string;
}

export interface SessionMessage {
  role: "user" | "assistant";
  content: string;
  created_at: string;
  options?: LastQuestionOption[];
  question_type?: string;
  redirect_url?: string | null;
  isRegistered?: boolean;
  products?: Product[];
}

export interface SessionData {
  session_id: string;
  session_name: string | null;
  created_at: string;
  updated_at: string;
  user_id: string;
  message_count: number;
  messages: SessionMessage[];
  reply?: {
    role: "assistant";
    content: string;
    created_at: string;
  };
  options?: {
    value: string;
    label: string;
  }[];
  question_type?: string;
  redirect_url?: string | null;
  isRegistered?: boolean;
  timestamp?: string;
}

export interface LastQuestionReply {
  role: "assistant";
  content: string;
  created_at: string;
}

export interface LastQuestionOption {
  value: string;
  label: string;
}

export interface LastQuestionData {
  session_id: string;
  reply: LastQuestionReply | null;
  options: LastQuestionOption[] | null;
  question_type: "yes_no" | "multiple_choice" | "open_ended" | string | null;
  redirect_url: string | null;
  isRegistered: boolean;
  timestamp: string;
}

// History API Types
export interface HistorySession {
  session_id: string;
  session_name: string | null;
  created_at: string;
  updated_at: string;
}

export interface HistoryPagination {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface HistoryResponse {
  success: boolean;
  message: string;
  data: HistorySession[];
  pagination: HistoryPagination;
}

// Search API Types
export interface SearchMessage {
  message_index: number;
  role: "user" | "assistant";
  content: string;
}

export interface SearchMatch {
  session_id: string;
  session_name: string | null;
  date: string;
  messages: SearchMessage[];
}

export interface SearchData {
  user_id: string;
  search_word: string;
  total_matches: number;
  matches: SearchMatch[];
}

export interface SearchPagination {
  page: number;
  limit: number;
  total: number;
  pages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export interface SearchResponse {
  success: boolean;
  message: string;
  data: SearchData;
  pagination: SearchPagination;
}

export interface ProductRecommendation {
  id: string;
  title: string;
  shortDescription: string;
  productImage: string;
}

export interface RecommendationResponse {
  isLogin: boolean;
  showRecommendation: boolean;
  message?: string;
  products?: ProductRecommendation[];
  timestamp?: string;
}
