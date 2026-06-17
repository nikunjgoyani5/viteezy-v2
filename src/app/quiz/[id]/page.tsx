"use client";

import MainLayout from "@/components/layouts/MainLayout";
import QuizChatBoard from "@/components/quiz/QuizChatBoard";
import { useParams } from "next/navigation";
import React from "react";

const QuizChatBoardPage = () => {
  const params = useParams();
  const id = params.id as string;

  return (
    <MainLayout
      isFooter={false}
      headerClassName="border-b border-slate-border-color"
    >
      <div className="h-[calc(100vh-117px)] bg-off-white-color">
        <QuizChatBoard sessionId={id} />
      </div>
    </MainLayout>
  );
};

export default QuizChatBoardPage;
