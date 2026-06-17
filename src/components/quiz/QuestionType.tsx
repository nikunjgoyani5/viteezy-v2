import { SessionMessage } from "@/store/api/types/quiz.types";
import React from "react";
import { Button } from "../ui/button";

interface QuestionTypeProps {
  data?: SessionMessage | undefined;
  onSelect?: (value: string) => void;
  disabled?: boolean; // Disable options if not from the last message
}

const QuestionType = ({ data, onSelect, disabled = false }: QuestionTypeProps) => {
  if (!data?.options) return null;

  return (
    <div className="ms-15">
      <div className="flex flex-wrap gap-4 justify-start">
        {data?.options?.map((option) => (
          <Button
            onClick={() => !disabled && onSelect && onSelect(option.value)}
            key={option.value}
            variant="outline"
            disabled={disabled}
            className={`rounded-xl border-neutral-sand-100 py-5 sm:py-2.5 text-gray-500 px-4 sm:px-5 ${
              disabled
                ? "opacity-50 cursor-not-allowed"
                : "hover:bg-slate-50-color cursor-pointer"
            }`}
          >
            {option.label}
          </Button>
        ))}
      </div>
    </div>
  );
};

export default QuestionType;
