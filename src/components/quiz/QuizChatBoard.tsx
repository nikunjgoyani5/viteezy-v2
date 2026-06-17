"use client";

import React, { useCallback, useEffect, useRef } from "react";
import { useRouter } from "next/navigation";
import Messages from "@/components/quiz/Messages";
import SearchBar from "@/components/quiz/SearchBar";
import { FixedPortal, getUserFromStorage } from "@/lib/utils";
import { useAppSelector } from "@/store";
import {
  quizApi,
  useGetLastQuestionQuery,
  useGetSessionDetailsQuery,
  usePostChatMsgMutation,
} from "@/store/api/quizApi";
import { routes } from "@/components/constants/route";

interface QuizChatBoardProps {
  sessionId: string;
  isModal?: boolean;
  onSessionSelect?: (sessionId: string) => void;
  onNewChat?: () => void;
  subscriptionId?: string;
  onQuizComplete?: (cartId?: string) => void;
}

const QuizChatBoard = ({
  sessionId,
  isModal = false,
  onSessionSelect,
  onNewChat,
  subscriptionId,
  onQuizComplete,
}: QuizChatBoardProps) => {
  const [postChatMsg, { isLoading: msgLoading }] = usePostChatMsgMutation();

  const scrollContainerRef = useRef<HTMLDivElement>(null);
  const latestUserMsgRef = useRef<HTMLDivElement>(null);
  const previousMessageCountRef = useRef<number>(0);
  const scrollTimeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isScrollingRef = useRef<boolean>(false);
  const hasInitialScrolled = useRef(false);
  const router = useRouter();

  const { data: chatDetails, isLoading } = useGetSessionDetailsQuery(
    { sessionId: sessionId! },
    { skip: !sessionId },
  );

  const { isLoading: isLastQLoading } = useGetLastQuestionQuery(
    { sessionId: sessionId! },
    {
      skip:
        !sessionId ||
        !chatDetails?.success ||
        !chatDetails?.data?.messages?.length,
    },
  );

  const userId = getUserFromStorage()?._id;

  const recState = useAppSelector((state) =>
    quizApi.endpoints.getProductRecommendations.select({
      userId,
      sessionId: sessionId,
    })(state),
  );

  const isRecommendationLoading = recState?.isLoading;

  // Single controlled scroll function with debouncing
  const scrollToLatestUserMsg = useCallback(
    (behavior: ScrollBehavior = "smooth", immediate = false) => {
      // Clear any pending scroll
      if (scrollTimeoutRef.current) {
        clearTimeout(scrollTimeoutRef.current);
        scrollTimeoutRef.current = null;
      }

      // Prevent multiple simultaneous scrolls
      if (isScrollingRef.current && !immediate) return;

      const performScroll = () => {
        if (!latestUserMsgRef.current) return;

        isScrollingRef.current = true;

        // Use double RAF for better DOM readiness
        requestAnimationFrame(() => {
          requestAnimationFrame(() => {
            if (latestUserMsgRef.current) {
              latestUserMsgRef.current.scrollIntoView({
                behavior,
                block: "start",
              });

              // Reset scrolling flag after animation completes
              setTimeout(
                () => {
                  isScrollingRef.current = false;
                },
                behavior === "smooth" ? 500 : 100,
              );
            } else {
              isScrollingRef.current = false;
            }
          });
        });
      };

      if (immediate) {
        performScroll();
      } else {
        // Debounce scroll to prevent rapid-fire calls
        scrollTimeoutRef.current = setTimeout(performScroll, 100);
      }
    },
    [],
  );

  // Single effect to handle all scroll scenarios
  useEffect(() => {
    if (isLoading) return;

    const currentMessageCount = chatDetails?.data?.messages?.length || 0;
    const hasNewMessage = currentMessageCount > previousMessageCountRef.current;

    if (
      hasNewMessage ||
      (!hasInitialScrolled.current && currentMessageCount > 0)
    ) {
      // Use immediate scroll for initial load, smooth for updates
      // Add slight delay for new messages to ensure DOM is ready (especially for typing animation)
      const behavior = hasInitialScrolled.current ? "smooth" : "auto";
      const delay = hasInitialScrolled.current ? 250 : 0; // Wait a bit longer for new messages

      if (delay > 0) {
        scrollTimeoutRef.current = setTimeout(() => {
          scrollToLatestUserMsg(behavior, true);
        }, delay);
      } else {
        scrollToLatestUserMsg(behavior, true);
      }

      if (!hasInitialScrolled.current) {
        hasInitialScrolled.current = true;
      }

      previousMessageCountRef.current = currentMessageCount;
    }

    return () => {
      if (scrollTimeoutRef.current) {
        clearTimeout(scrollTimeoutRef.current);
        scrollTimeoutRef.current = null;
      }
    };
  }, [chatDetails?.data?.messages?.length, isLoading, scrollToLatestUserMsg]);

  const lastMessage =
    chatDetails?.data?.messages?.[chatDetails.data.messages.length - 1];
  // Only check the actual last message from session - don't use cached lastQuestion as it may be stale
  const hasOptions = Boolean(lastMessage?.options?.length);
  const isChatEnd = Array.isArray(lastMessage?.products);

  const handleSendMessage = useCallback(
    async (content: string) => {
      if (!content.trim()) return;

      if (!getUserFromStorage()?._id) {
        router.push(routes.login);
        return;
      }

      try {
        await postChatMsg({ session_id: sessionId, message: content }).unwrap();
        // Scroll will be handled by the useEffect watching message count changes
      } catch (error) {
        console.error(error);
      }
    },
    [postChatMsg, sessionId, router],
  );

  const containerHeight = isModal
    ? "h-full"
    : "min-h-[calc(100vh-120px)] max-h-[calc(100vh-120px)]";

  return (
    <div
      className="bg-off-white-color h-full flex flex-col relative"
      ref={scrollContainerRef}
    >
      <div className={`${containerHeight} overflow-y-auto flex-1`}>
        <div className="max-w-4xl mx-auto px-4 pt-5 pb-[58vh]">
          <Messages
            ref={latestUserMsgRef}
            data={chatDetails}
            handleSendMessage={handleSendMessage}
            isAssistantLoading={
              msgLoading || isLastQLoading || isRecommendationLoading
            }
            subscriptionId={subscriptionId}
            onSubscriptionProductsAdded={onQuizComplete}
          />
        </div>
      </div>

      {!hasOptions &&
        (isModal ? (
          <div className="sticky bottom-0 z-1 w-full pt-4 bg-off-white-color border-t border-gray-100">
            <div className="relative pb-4">
              <div className="max-w-4xl mx-auto">
                <SearchBar
                  onSendMessage={handleSendMessage}
                  disabled={
                    isLoading ||
                    msgLoading ||
                    isLastQLoading ||
                    isRecommendationLoading ||
                    isChatEnd
                  }
                  isLoading={
                    isLoading ||
                    msgLoading ||
                    isLastQLoading ||
                    isRecommendationLoading
                  }
                  centered={false}
                  isChatEnd={isChatEnd}
                  onSessionSelect={onSessionSelect}
                  onNewChat={onNewChat}
                  isModal={isModal}
                />
              </div>
            </div>
          </div>
        ) : (
          <FixedPortal>
            <div className="fixed z-1 bottom-0 start-[50%] -translate-x-[50%] w-full pt-4">
              <div className="relative pb-4">
                <div className="max-w-4xl mx-auto">
                  <SearchBar
                    onSendMessage={handleSendMessage}
                    disabled={
                      isLoading ||
                      msgLoading ||
                      isLastQLoading ||
                      isRecommendationLoading ||
                      isChatEnd
                    }
                    isLoading={
                      isLoading ||
                      msgLoading ||
                      isLastQLoading ||
                      isRecommendationLoading
                    }
                    centered={false}
                    isChatEnd={isChatEnd}
                    onSessionSelect={onSessionSelect}
                    onNewChat={onNewChat}
                  />
                  <div className="bg-off-white-color h-[80%] w-full bottom-0 start-0 absolute -z-1"></div>
                </div>
              </div>
            </div>
          </FixedPortal>
        ))}
    </div>
  );
};

export default QuizChatBoard;
