"use client";

import React, { useState } from "react";
import ChatInterface from "./ChatInterface";
import QuizChatBoard from "./QuizChatBoard";

import { useRouter } from "next/navigation";

const QuizBase = ({ shouldNavigate = true, subscriptionId, onQuizComplete, isModal = false }: { 
  shouldNavigate?: boolean; 
  subscriptionId?: string;
  onQuizComplete?: (cartId?: string) => void;
  isModal?: boolean;
}) => {
  const [activeSessionId, setActiveSessionId] = useState<string | null>(null);
  const router = useRouter();

  const handleSessionCreated = (sessionId: string) => {
    if (shouldNavigate) {
      router.push(`/quiz/${sessionId}`);
    } else {
      setActiveSessionId(sessionId);
    }
  };

  const handleQuizComplete = (cartId?: string) => {
    if (onQuizComplete) {
      onQuizComplete(cartId);
    }
  };

  const handleNewChat = () => {
    if (shouldNavigate) {
      router.push(`/quiz`);
    } else {
      setActiveSessionId(null);
    }
  };

  return (
    <div className="h-full">
      {!activeSessionId ? (
        <ChatInterface 
          onSessionCreated={handleSessionCreated} 
          onSessionSelect={handleSessionCreated}
          onNewChat={handleNewChat}
          isModal={isModal}
        />
      ) : (
        <QuizChatBoard
          sessionId={activeSessionId}
          isModal={isModal}
          onSessionSelect={handleSessionCreated}
          onNewChat={handleNewChat}
          subscriptionId={subscriptionId}
          onQuizComplete={handleQuizComplete}
        />
      )}
    </div>
  );
};

export default QuizBase;
