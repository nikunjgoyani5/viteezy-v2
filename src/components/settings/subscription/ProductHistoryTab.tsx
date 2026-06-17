"use client";

import Image from "next/image";
import { Button } from "@/components/ui/button";
import { useState } from "react";
import ChooseProductProcessModal from "./modals/ChooseProductProcessModal";
import SelectProductModal from "./modals/SelectProductModal";
import QuizModal from "./modals/QuizModal";
import { useSubscriptionSidebar } from "@/lib/subscriptionSidebar";
import { Info } from "lucide-react";
import { useTranslations } from "next-intl";

import { useGetSubscriptionProductsQuery } from "@/store";

const ProductHistoryTab = ({ subscriptionId, subscriptionStatus }: { 
  subscriptionId: string; 
  subscriptionStatus?: string; 
}) => {
  const t = useTranslations("Account");
  const { openSidebar } = useSubscriptionSidebar();
  const { data: subscriptionProductsData, isLoading } =
    useGetSubscriptionProductsQuery(subscriptionId);
  const [isChooseModalOpen, setIsChooseModalOpen] = useState(false);
  const [isSelectProductModalOpen, setIsSelectProductModalOpen] =
    useState(false);
  const [isQuizModalOpen, setIsQuizModalOpen] = useState(false);

  const handleOpenChooseModal = () => setIsChooseModalOpen(true);
  const handleCloseChooseModal = () => setIsChooseModalOpen(false);

  const handleOpenSelectProductModal = () => {
    setIsSelectProductModalOpen(true);
  };
  const handleCloseSelectProductModal = () => {
    setIsSelectProductModalOpen(false);
  };

  const handleOpenQuizModal = () => setIsQuizModalOpen(true);
  const handleCloseQuizModal = () => setIsQuizModalOpen(false);

  const handleBuyNow = () => {
    handleCloseChooseModal();
    handleOpenSelectProductModal();
  };

  const handleTakeQuiz = () => {
    handleCloseChooseModal();
    handleOpenQuizModal();
  };

  const handleQuizComplete = (cartId?: string) => {
    handleCloseQuizModal();
    openSidebar(cartId);
  };

  const products = subscriptionProductsData?.data.items ?? [];

  // Check if subscription is paused or cancelled
  const isPaused = subscriptionStatus?.toLowerCase() === "paused" || subscriptionStatus === "Paused";
  const isCancelled = subscriptionStatus === "Cancelled";
  const shouldHideChangeOrder = isPaused || isCancelled;

  if (isLoading) {
    return <div>{t("loadingProducts")}</div>;
  }

  return (
    <div className="mt-6 border rounded-2xl overflow-hidden">
      <div className="p-5">
        <div className="flex justify-between items-center">
          <div>
            <h3 className="text-xl font-semibold">{t("changeProduct")}</h3>
            <p className="text-slightly-gray font-medium">
              {t("selectDifferentProductForDelivery")}
            </p>
          </div>
          {!shouldHideChangeOrder && (
            <Button
              onClick={handleOpenChooseModal}
              variant="elevate"
              size="elevate-md"
              animateText
            >
              {t("changeOrder")}
            </Button>
          )}
        </div>
        <div className="mt-5 space-y-5">
          {products.map((product, index) => (
            <div key={index} className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <Image
                  src={product.product?.productImage || "/products/placeholder.png"}
                  alt={product.name}
                  width={80}
                  height={80}
                  className="rounded-lg w-20 h-20 object-cover"
                />
                <div>
                  <h4 className="font-medium text-lg 3xl:text-xl">
                    {product.name}
                  </h4>
                  <p className="text-gray-500 text-base 3xl:text-lg">
                    {t("capsulesCount", { count: product.capsuleCount })}
                  </p>
                </div>
              </div>
              <p className="font-semibold text-lg 3xl:text-xl">
                ${product.totalAmount.toFixed(2)}
              </p>
            </div>
          ))}
        </div>
      </div>
      <div className="text-sm text-concord bg-white-smoke px-5 py-3 flex items-center gap-2">
        <Info className="w-5 h-5" />
        <p className="font-medium">
          {t("productChangeNotice")}
        </p>
      </div>
      <ChooseProductProcessModal
        isOpen={isChooseModalOpen}
        onClose={handleCloseChooseModal}
        onBuyNow={handleBuyNow}
        onTakeQuiz={handleTakeQuiz}
      />
      <SelectProductModal
        isOpen={isSelectProductModalOpen}
        onClose={handleCloseSelectProductModal}
        subscriptionId={subscriptionId}
      />
      <QuizModal 
        isOpen={isQuizModalOpen} 
        onClose={handleCloseQuizModal} 
        subscriptionId={subscriptionId}
        onQuizComplete={handleQuizComplete}
      />
    </div>
  );
};

export default ProductHistoryTab;
