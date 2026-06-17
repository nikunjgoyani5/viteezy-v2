"use client";

import {
  ArrowUp,
  History,
  MessageCirclePlus,
} from "lucide-react";
import React, {
  useState,
  useRef,
  useEffect,
  KeyboardEvent,
  FormEvent,
  useCallback,
} from "react";
import { Button } from "../ui/button";
import HistoryModal from "./HistoryModal";
import { useParams, useRouter } from "next/navigation";
import { useGetHealthQuery } from "@/store/api/quizApi";
import FullscreenLoader from "../ui/fullscreenLoader";
import { useTranslations } from "next-intl";
import { routes } from "../constants/route";
import { quizDraftService } from "@/lib/services/quiz";
import { getUserFromStorage } from "@/lib/utils";
import Link from "next/link";

interface SearchBarProps {
  onSendMessage: (message: string) => void;
  isChatEnd?: boolean;
  disabled?: boolean;
  centered?: boolean;
  hasHealthIssue?: string | boolean;
  isLoading?: boolean;
  isOptionsDisabled?: boolean;
  suggestedQuestions?: { title: string; icon: React.ReactNode }[];
  handleSuggestedQuestion?: (question: string) => void;
  fullbarDisable?: boolean;
  onSessionSelect?: (sessionId: string) => void;
  onNewChat?: () => void;
  isModal?: boolean;
}

export default function SearchBar({
  onSendMessage,
  isChatEnd = false,
  disabled = false,
  centered = false,
  isLoading = false,
  isOptionsDisabled = false,
  fullbarDisable = false,
  suggestedQuestions = [],
  handleSuggestedQuestion,
  onSessionSelect,
  onNewChat,
  isModal = false,
}: SearchBarProps) {
  const t = useTranslations("Header");
  const tContact = useTranslations("ContactUs");
  const tQuiz = useTranslations("Quiz");
  const params = useParams();
  const sessionId = (params?.session_id as string) || null;

  const [input, setInput] = useState<string>(
    quizDraftService.getValue(sessionId || null) || "",
  );
  const [isHistoryModalOpen, setIsHistoryModalOpen] = useState(false);
  const textareaRef = useRef<HTMLTextAreaElement>(null);

  const {
    data: healthData,
    isLoading: healthLoading,
    error: healthError,
  } = useGetHealthQuery();

  const isServiceHealthy =
    healthData?.success && healthData?.data?.status === "healthy";

  const isDisable = disabled || !isServiceHealthy || !input.trim();

  const userId = getUserFromStorage()?._id;
  const isLoggedIn = Boolean(userId);

  const router = useRouter();

  const hasHealthIssue =
    healthError ||
    !healthData?.success ||
    healthData?.data?.status !== "healthy";

  // Adjust textarea height dynamically
  const adjustTextareaHeight = useCallback(() => {
    if (textareaRef.current) {
      textareaRef.current.style.height = "auto";
      textareaRef.current.style.height = `${Math.min(
        textareaRef.current.scrollHeight,
        120,
      )}px`;
    }
  }, []);

  // Focus and place cursor at the end of text
  const focusAtEnd = useCallback(() => {
    if (textareaRef.current) {
      textareaRef.current.focus();
      const length = textareaRef.current.value.length;
      textareaRef.current.setSelectionRange(length, length);
      textareaRef.current.scrollTop = textareaRef.current.scrollHeight;
    }
  }, []);

  // Adjust height whenever input changes
  useEffect(() => {
    adjustTextareaHeight();
  }, [input, adjustTextareaHeight]);

  // Focus on mount and when disabled → enabled (after bot replies)
  useEffect(() => {
    if (!disabled && textareaRef.current) {
      // Small delay to ensure DOM is fully ready
      const timer = setTimeout(() => {
        focusAtEnd();
      }, 100);

      return () => clearTimeout(timer);
    }
  }, [disabled, focusAtEnd]);

  // Focus at end when input has draft value on first render
  useEffect(() => {
    if (input && textareaRef.current) {
      focusAtEnd();
    }
  }, [healthLoading]); // Only on mount

  const sendMessage = useCallback(
    (content?: string) => {
      if (hasHealthIssue) return;
      const message = content?.trim() || input.trim();
      if (message && !disabled) {
        onSendMessage(message);
        setInput("");
        quizDraftService.clearDraft(sessionId);

        // Reset height and refocus
        if (textareaRef.current) {
          textareaRef.current.style.height = "auto";
          setTimeout(() => focusAtEnd(), 50);
        }
      }
    },
    [input, onSendMessage, disabled, sessionId, focusAtEnd, hasHealthIssue],
  );

  const handleSubmit = (e: FormEvent) => {
    e.preventDefault();
    if (disabled) return;
    sendMessage();
  };

  const handleKeyDown = (e: KeyboardEvent<HTMLTextAreaElement>) => {
    if (e.key === "Enter" && !e.shiftKey) {
      e.preventDefault();
      sendMessage();
    }
  };

  const handleButtonClick = (e: React.MouseEvent) => {
    e.preventDefault();
    sendMessage();
  };

  // Handle suggested question click
  const handleSuggested = (question: string) => {
    if (isServiceHealthy && handleSuggestedQuestion) {
      handleSuggestedQuestion(question);
    }
  };

  if (healthLoading) {
    return <FullscreenLoader />;
  }

  return (
    <div
      className={centered ? "max-w-[840px] mx-auto" : "max-w-4xl mx-auto px-4"}
    >
      <form onSubmit={handleSubmit} className="w-full">
        <div className="relative bg-white rounded-xl md:rounded-3xl p-4 border border-neutral-sand-100">
          <textarea
            ref={textareaRef}
            value={input}
            onChange={(e) => {
              const value = e.target.value;
              setInput(value);
              quizDraftService.saveDraft({ id: sessionId, value });
            }}
            onKeyDown={handleKeyDown}
            // disabled={disabled || fullbarDisable}
            placeholder={tContact("askQuestion")}
            className={`
              cursor-text
              w-full min-h-14 px-1 placeholder:text-[15px] md:placeholder:text-[18px]
              text-sm md:text-[18px] border-none outline-none rounded-xl text-gray-900
              placeholder-gray-500 resize-none transition-all duration-200
              bg-transparent
            `}
            rows={1}
            autoFocus
          />

          <div className="flex items-center justify-between mt-3">
            <div className="space-x-1.5 sm:space-x-2.5 flex flex-wrap gap-y-2">
              {!centered && (
                <Button
                  type="button"
                  onClick={() => {
                    if (onNewChat) {
                      onNewChat();
                    } else {
                      router.push(routes.quiz);
                    }
                  }}
                  disabled={isOptionsDisabled || !!hasHealthIssue}
                  variant="slateElevate"
                  className="p-0 min-h-10  hover:rounded-4xl"
                >
                  <MessageCirclePlus size={20} /> {t("newChat")}
                </Button>
              )}

              <Button
                type="button"
                disabled={isOptionsDisabled || !!hasHealthIssue}
                variant="slateElevate"
                className="min-h-10 px-3 sm:px-4 hover:rounded-4xl"
                onClick={() => setIsHistoryModalOpen(true)}
              >
                <History size={20} />
                {t("history")}
              </Button>

              <HistoryModal
                isOpen={isHistoryModalOpen}
                onClose={() => setIsHistoryModalOpen(false)}
                onSessionSelect={onSessionSelect}
                onNewChat={onNewChat}
              />
            </div>

            {!hasHealthIssue &&
              (isLoggedIn ? (
                <button
                  type="submit"
                  onClick={handleButtonClick}
                  disabled={isDisable}
                  className={`
                    p-1.5 sm:p-2 rounded-full transition-all duration-200 transform text-white
                    ${
                      isDisable
                        ? "bg-gray-300 cursor-not-allowed"
                        : "bg-teal-500 hover:bg-teal-600 active:scale-95 cursor-pointer"
                    }
                  `}
                >
                  {isLoading ? (
                    <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-white"></div>
                  ) : (
                    <ArrowUp size={20} />
                  )}
                </button>
              ) : (
                <Button
                  type="button"
                  onClick={() => router.push(routes.login)}
                  className="min-h-10 px-4 rounded-full bg-teal-500 hover:bg-teal-600 text-white"
                >
                  {t("LogIn")}
                </Button>
              ))}
          </div>
        </div>

        {hasHealthIssue && (
          <p className="text-red-500 text-sm text-center mt-4">
            {tQuiz("serviceUnavailable")}
          </p>
        )}
      </form>

      {isChatEnd && (
        <p className="text-gray-600 text-sm text-center mt-4 bg-gray-200 p-2 rounded-md">
          {tQuiz("chatSessionEndLead")}{" "}
          <Link href={routes.quiz} className="underline">
            {t("newChat")}
          </Link>{" "}
          {tQuiz("chatSessionEndTrail")}
        </p>
      )}

      {suggestedQuestions?.length > 0 && (
        <div className="w-full max-w-2xl mx-auto mt-6">
          <div className="flex justify-center gap-4 flex-wrap">
            {suggestedQuestions.map((q, i) => (
              <Button
                key={i}
                variant="outline"
                size="elevate-md"
                className="rounded-full border-transparent py-5 sm:py-3 text-gray-500 px-4 sm:px-5 hover:bg-[#f5f5f5] hover:border-slate-50 hover:rounded-full"
                onClick={() => handleSuggested(q.title)}
                disabled={!isServiceHealthy || disabled}
              >
                <div className="flex items-center gap-2 font-normal">
                  {q.icon}
                  <span className="text-base block">{q.title}</span>
                </div>
              </Button>
            ))}
          </div>
        </div>
      )}
    </div>
  );
}
