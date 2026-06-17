import { Bed, Brain, Shield, Zap, type LucideIcon } from "lucide-react";
import { StaticResponses, Product } from "../types/quiz";

export const staticResponses: StaticResponses = {
  hello: "Hello! How can I assist you today?",
  hi: "Hi there! What can I help you with?",
  "how are you":
    "I'm just a program, but I'm functioning perfectly! How can I help you?",
  "what is your name":
    "I'm a static chatbot created with Next.js and TypeScript!",
  help: "I can help you with general questions. Try asking about weather, time, or just say hello!",
  weather:
    "I'm a static bot, so I can't fetch real-time weather. But it's always a good day to chat!",
  time: "I don't have access to real-time data, but I hope you're having a great day!",
  bye: "Goodbye! Feel free to come back anytime!",
  thanks: "You're welcome! Is there anything else I can help with?",
  "thank you": "You're welcome! Happy to help!",
  joke: "Why don't scientists trust atoms? Because they make up everything!",
  "tell me a joke":
    "Why did the scarecrow win an award? Because he was outstanding in his field!",
  "what can you do":
    "I can answer pre-defined questions! Try asking about my name, the weather, or tell me a joke!",
  "who created you":
    "I was created by a developer using Next.js, TypeScript, and Tailwind CSS!",
  default:
    "I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that. Try asking about something else! I'm not sure how to respond to that.",
};

// Product data
export const productData: Product[] = [
  {
    id: "1",
    title: "Hormone Control",
    description: "Vitex agnus castus supports normal menstruation",
    image: "/carosuleCardImage.png",
  },
  {
    id: "2",
    title: "Skin Support",
    description: "Helps care for the skin from within",
    image: "/carosuleCardImage.png",
  },
  {
    id: "3",
    title: "Gut Support",
    description:
      "Our probiotics contain no fewer than 7 different bacteria strains",
    image: "/bannerImg1.png",
  },
];

export const getResponse = (
  query: string
): { type: "text" | "products"; content?: string; products?: Product[] } => {
  const lowerQuery = query.toLowerCase().trim();

  // Check if query is about products
  if (lowerQuery.includes("product")) {
    return {
      type: "products",
      products: productData,
    };
  }

  // Check for exact matches first
  if (staticResponses[lowerQuery]) {
    return {
      type: "text",
      content: staticResponses[lowerQuery],
    };
  }

  // Check for partial matches
  for (const key in staticResponses) {
    if (lowerQuery.includes(key)) {
      return {
        type: "text",
        content: staticResponses[key],
      };
    }
  }

  // Fallback to default
  return {
    type: "text",
    content: staticResponses.default,
  };
};

/** Message keys under `Quiz` namespace — titles filled via useTranslations in UI */
export const suggestedQuestionDefs: { messageKey: string; Icon: LucideIcon }[] =
  [
    { messageKey: "topicSleep", Icon: Bed },
    { messageKey: "topicEnergy", Icon: Zap },
    { messageKey: "topicStress", Icon: Brain },
    { messageKey: "topicImmunity", Icon: Shield },
  ];

export const quizRoles = {
  user: "user",
  assistant: "assistant",
};
