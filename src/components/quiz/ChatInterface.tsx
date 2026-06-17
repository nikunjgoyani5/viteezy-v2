"use client";

import { useState, useEffect, useRef, useCallback, useMemo } from "react";
import Message from "./Message";
import SearchBar from "./SearchBar";
import { ChatMessage } from "../types/quiz";
import { suggestedQuestionDefs } from "../constants/quiz";
import { FixedPortal, getUserFromStorage } from "@/lib/utils";
import { Button } from "../ui/button";
import BotAvatar from "./BotAvatar";
import {
  useCreateSessionMutation,
  useGetHealthQuery,
  usePostChatMsgMutation,
} from "@/store/api/quizApi";
import { useTranslations } from "next-intl";
import FullscreenLoader from "../ui/fullscreenLoader";
import { useRouter } from "next/navigation";
import { routes } from "../constants/route";

export default function ChatInterface({
  onSessionCreated,
  onSessionSelect,
  onNewChat,
  isModal = false,
}: {
  onSessionCreated?: (sessionId: string) => void;
  onSessionSelect?: (sessionId: string) => void;
  onNewChat?: () => void;
  isModal?: boolean;
}) {
  const t = useTranslations("Header");
  const tQuiz = useTranslations("Quiz");
  const tCommon = useTranslations("Common");

  const suggestedQuestions = useMemo(
    () =>
      suggestedQuestionDefs.map(({ messageKey, Icon }) => ({
        title: tQuiz(messageKey),
        icon: <Icon className="w-5 h-5 shrink-0" aria-hidden />,
      })),
    [tQuiz],
  );
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [isLoading, setIsLoading] = useState<boolean>(false);
  const chatContainerRef = useRef<HTMLDivElement>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const [createSession, { isLoading: sessionLoading }] =
    useCreateSessionMutation();
  const [postChatMsg, { isLoading: msgLoading }] = usePostChatMsgMutation();
  const router = useRouter();

  const scrollToBottom = useCallback(() => {
    if (chatContainerRef.current) {
      chatContainerRef.current.scrollTop =
        chatContainerRef.current.scrollHeight;
    }
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, []);

  useEffect(() => {
    scrollToBottom();
  }, [messages, isLoading, scrollToBottom]);

  const user = JSON.parse(localStorage.getItem("user") || "{}");

  const userId = user?._id;
  const isLoggedIn = Boolean(userId);

  const handleSendMessage = useCallback(
    async (content: string) => {
      if (!content.trim()) return;

      if (!isLoggedIn) {
        router.push(routes.login);
        return;
      }

      try {
        let activeSessionId = "";

        const res = await createSession({ user_id: user._id }).unwrap();
        activeSessionId = res.data.session_id;
        await postChatMsg({
          session_id: res.data.session_id,
          message: content,
        });

        if (onSessionCreated) {
          onSessionCreated(activeSessionId);
        } else {
          router.push(`/quiz/${activeSessionId}`);
        }
      } catch (error) {
        console.log(error);
      }
    },
    [createSession, router, user, postChatMsg, onSessionCreated],
  );

  const handleSuggestedQuestion = useCallback(
    (question: string) => {
      handleSendMessage(question);
    },
    [handleSendMessage],
  );

  const hasMessages = messages.length > 0;
  console.log(user);
  return (
    <div className="flex flex-col h-full">
      <div ref={chatContainerRef} className="flex-1 overflow-y-auto">
        {!hasMessages ? (
          <div className="h-full flex flex-col items-center justify-center p-4 relative">
            <div
              className="absolute w-[1240px] max-w-full h-[400px] blur-[380px] rounded-[100%] opacity-90"
              style={{
                background:
                  "linear-gradient(90deg, #1baf993f 0%, #f7a17347 100%)",
              }}
            />
            <div className="text-center mb-5 w-full">
              <h1 className="text-3xl md:text-4xl max-w-xl mx-auto break-all truncate font-bold md:mb-2 bg-gradient-to-r from-[#45ac92] from-40% via-[#cda47b] via-55% to-[#247D7A] to-100% bg-clip-text text-transparent">
                {t("hello")},{" "}
                {user?.firstName
                  ? `${user.firstName} ${user.lastName ?? ""}`.trim()
                  : tCommon("guestUser")}
              </h1>
              <p className="text-3xl md:text-4xl font-bold mb-4">
                {t("howCanIHelpYouToday")}
              </p>

              <div className="w-full mx-auto mt-9 md:mt-14">
                <SearchBar
                  onSendMessage={handleSendMessage}
                  disabled={isLoading || sessionLoading || msgLoading}
                  centered={true}
                  isLoading={sessionLoading || msgLoading}
                  suggestedQuestions={suggestedQuestions}
                  handleSuggestedQuestion={handleSuggestedQuestion}
                  isOptionsDisabled={false}
                  onSessionSelect={onSessionSelect}
                  onNewChat={onNewChat}
                  isModal={isModal}
                />
              </div>
            </div>
          </div>
        ) : (
          <div className="p-4">
            <div className="max-w-4xl mx-auto">
              {messages.map((message) => (
                <Message
                  key={message.id}
                  message={message}
                  onProductSelect={(productId) => {
                    console.log("Product selected:", productId);
                  }}
                />
              ))}

              {isLoading && (
                <div className="flex justify-start mb-6">
                  <div className="max-w-[80%] mr-auto">
                    <div className="flex items-start gap-3">
                      <BotAvatar />
                      <div className="px-4 py-3 rounded-2xl bg-gray-100 dark:bg-gray-800 rounded-tl-none shadow-sm">
                        <div className="flex space-x-2">
                          <div className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
                          <div
                            className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"
                            style={{ animationDelay: "0.2s" }}
                          ></div>
                          <div
                            className="w-2 h-2 bg-gray-400 rounded-full animate-bounce"
                            style={{ animationDelay: "0.4s" }}
                          ></div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              <div ref={messagesEndRef} className="h-35" />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
