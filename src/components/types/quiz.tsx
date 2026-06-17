export interface Product {
  id: string;
  title: string;
  description: string;
  image?: string;
}

export interface ChatMessage {
  id: number;
  content: string;
  isUser: boolean;
  timestamp?: Date;
  type?: "text" | "products";
  products?: Product[];
}

export interface SuggestedQuestion {
  id: number;
  text: string;
}

export interface ChatbotResponse {
  query: string;
  response: string;
}

export interface StaticResponses {
  [key: string]: string;
}