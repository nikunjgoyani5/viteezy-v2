"use client";
import { ApiResponse } from "@/store/api/types/common.types";
import { SessionData, SessionMessage } from "@/store/api/types/quiz.types";
import React, { forwardRef } from "react";
import BotAvatar from "./BotAvatar";
import QuestionType from "./QuestionType";
import TypingText from "./TypingText"; // Import your typing component
import { quizRoles } from "../constants/quiz";
import ProductCard from "./ProductCard";
import ProductResponse from "./ProductResponse";

interface MessagesProps {
  data: ApiResponse<SessionData> | undefined;
  handleSendMessage?: (content: string) => void;
  isAssistantLoading: boolean;
  subscriptionId?: string;
  onSubscriptionProductsAdded?: (cartId?: string) => void;
}

const Messages = forwardRef<HTMLDivElement, MessagesProps>(
  (
    {
      data,
      handleSendMessage,
      isAssistantLoading,
      subscriptionId,
      onSubscriptionProductsAdded,
    },
    ref,
  ) => {
    const messages = data?.data?.messages || [];

    // Find the index of the last user message for the scroll anchor
    const lastUserIndex = [...messages]
      .reverse()
      .findIndex((msg) => msg.role === quizRoles.user);
    const latestUserMsgActualIndex =
      lastUserIndex !== -1 ? messages.length - 1 - lastUserIndex : -1;
    return (
      <div>
        {messages.map((msg: SessionMessage, index: number) => {
          const isAssistant = msg.role === quizRoles.assistant;
          const isLatestUserMessage = index === latestUserMsgActualIndex;

          // Logic for typing effect: Only if it's the last message in the array AND it's from the assistant
          const isLastMessage = index === messages.length - 1;
          const shouldType = isLastMessage && isAssistant;

          if (msg?.products || msg?.content)
            return (
              <div
                key={index}
                ref={isLatestUserMessage ? ref : null}
                className="mb-10 scroll-mt-10"
              >
                <div
                  className={`flex ${
                    !isAssistant ? "justify-end" : "justify-start"
                  } animate-in fade-in slide-in-from-bottom-4 duration-300`}
                >
                  <div
                    className={`max-w-[90%] ${
                      !isAssistant ? "ml-auto" : "mr-auto"
                    }`}
                  >
                    <div
                      className={`flex items-start gap-3 ${
                        isAssistant ? "" : ""
                      }`}
                    >
                      <div
                        className={` py-3 rounded-4xl ${
                          !isAssistant
                            ? "bg-white rounded-tr-none border border-neutral-sand-100 px-4"
                            : "flex gap-3 px-1"
                        }`}
                      >
                        {isAssistant && (
                          <span className="block -mt-1.5">
                            <BotAvatar />
                          </span>
                        )}
                        <div className="whitespace-pre-wrap text-lg text-gray-800">
                          {shouldType ? (
                            <TypingText text={msg?.content || ""} speed={15} />
                          ) : (
                            msg?.content
                          )}
                        </div>
                      </div>
                    </div>
                    {Array.isArray(msg?.products) && msg.products.length > 0 ? (
                      <div className="ps-13">
                        <ProductResponse 
                          products={msg.products} 
                          subscriptionId={subscriptionId}
                          onProductSelect={handleSendMessage}
                          onSubscriptionProductsAdded={onSubscriptionProductsAdded}
                        />
                      </div>
                    ) : Array.isArray(msg?.products) && msg.products.length === 0 ? (
                      <div className="ps-13 mt-3">
                        <p className="text-base text-gray-600">
                          Currently no products available for your recommendation.
                        </p>
                      </div>
                    ) : null}
                  </div>
                </div>
                {/* Show options only after typing or for previous messages */}
                <div className="max-w-[80%]">
                  <QuestionType
                    data={msg}
                    onSelect={handleSendMessage}
                    disabled={!isLastMessage || isAssistantLoading} // Disable options if not the last message
                  />
                </div>
              </div>
            );
        })}
        {isAssistantLoading && (
          <div className="flex mt-10 items-center gap-3">
            <BotAvatar />
            <div className="flex justify-start  w-full">
              <div className="bg-gray-200 text-white rounded-2xl px-4 py-2 max-w-[60%]">
                <div className="flex gap-1">
                  <span className="w-1.5 h-1.5 bg-teal-500 rounded-full animate-bounce" />
                  <span className="w-1.5 h-1.5 bg-teal-500 rounded-full animate-bounce delay-150" />
                  <span className="w-1.5 h-1.5 bg-teal-500 rounded-full animate-bounce delay-300" />
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
    );
  }
);

Messages.displayName = "Messages";
export default Messages;
