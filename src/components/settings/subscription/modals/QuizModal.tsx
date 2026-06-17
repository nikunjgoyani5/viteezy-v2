"use client";

import PortalDialog from "@/components/ui/portalDialog";
import { X } from "lucide-react";
import QuizBase from "@/components/quiz";
import { useTranslations } from "next-intl";

interface QuizModalProps {
  isOpen: boolean;
  onClose: () => void;
  subscriptionId?: string;
  onQuizComplete?: (cartId?: string) => void;
}

const QuizModal = ({ isOpen, onClose, subscriptionId, onQuizComplete }: QuizModalProps) => {
  const t = useTranslations("Common");
  return (
    <PortalDialog
      isShow={isOpen}
      onClose={onClose}
      // width={1000}
      showCloseButton={false}
      bodyClass="p-0 max-h-[190vh]"
      className="max-w-[1200px]! 3xl:max-w-[1540px]!"
      animationType="center"
    >
      <div className="relative">
        <button
          onClick={onClose}
          aria-label={t("close")}
          className="absolute top-4 right-4 border rounded-full p-2 cursor-pointer bg-white hover:bg-gray-100 z-50"
        >
          <X className="h-5 w-5" />
        </button>
        <div className="h-[calc(100vh-100px)] 3xl:h-[calc(100vh-150px)]">
          <QuizBase 
            shouldNavigate={false} 
            subscriptionId={subscriptionId}
            onQuizComplete={onQuizComplete}
            isModal={true}
          />
        </div>
      </div>
    </PortalDialog>
  );
};

export default QuizModal;
