"use client";

import { Button } from "@/components/ui/button";
import PortalDialog from "@/components/ui/portalDialog";
import { ChevronRight, X } from "lucide-react";
import Image from "next/image";
import { useEffect, useRef, useState } from "react";
import ProductDetailModal from "./ProductDetailModal";
import {
  useGetSubscriptionProductsStatusQuery,
  useUpdateSubscriptionProductsMutation,
} from "@/store/api/subscriptionApi";
import CheckboxField from "@/components/ui/inputs/checkbox";
import Spinner from "@/components/ui/spinner";
import { toast } from "react-hot-toast";
import { useSubscriptionSidebar } from "@/lib/subscriptionSidebar";
import { useTranslations } from "next-intl";

interface SelectProductModalProps {
  isOpen: boolean;
  onClose: () => void;
  subscriptionId: string;
}

const SelectProductModal = ({
  isOpen,
  onClose,
  subscriptionId,
}: SelectProductModalProps) => {
  const t = useTranslations("Account");
  const tCommon = useTranslations("Common");
  const { openSidebar } = useSubscriptionSidebar();
  const scrollRef = useRef<HTMLDivElement>(null);
  const [isDetailModalOpen, setIsDetailModalOpen] = useState(false);
  const [selectedProductId, setSelectedProductId] = useState<string | null>(
    null,
  );
  const [page, setPage] = useState(1);
  const [selectedProductIds, setSelectedProductIds] = useState<string[]>([]);

  const { data, isLoading, isFetching } = useGetSubscriptionProductsStatusQuery(
    {
      subscriptionId,
      page,
      limit: 10,
    },
    { skip: !isOpen },
  );

  const [updateSubscriptionProducts, { isLoading: isUpdating }] =
    useUpdateSubscriptionProductsMutation();

  // Initialize selected IDs from the first page of data
  const [hasInitialized, setHasInitialized] = useState(false);
  useEffect(() => {
    if (isOpen && data?.data && !hasInitialized) {
      const initialSelected = data.data
        .filter((p) => p.isInSubscription)
        .map((p) => p._id);
      if (initialSelected.length > 0) {
        setSelectedProductIds(initialSelected);
        setHasInitialized(true);
      }
    }
  }, [isOpen, data, hasInitialized]);

  // Reset state when modal closes
  useEffect(() => {
    if (!isOpen) {
      setPage(1);
      setSelectedProductIds([]);
      setHasInitialized(false);
    }
  }, [isOpen]);

  const handleScroll = () => {
    if (!scrollRef.current || isFetching || !data?.pagination?.hasNext) return;

    const { scrollTop, scrollHeight, clientHeight } = scrollRef.current;
    if (scrollTop + clientHeight >= scrollHeight - 20) {
      setPage((prev) => prev + 1);
    }
  };

  const handleToggleProduct = (productId: string) => {
    setSelectedProductIds((prev) =>
      prev.includes(productId)
        ? prev.filter((id) => id !== productId)
        : [...prev, productId],
    );
  };

  const handleUpdateProducts = async () => {
    try {
      const result = await updateSubscriptionProducts({
        subscriptionId,
        productIds: selectedProductIds,
      }).unwrap();
      toast.success(t("subscriptionProductsUpdatedSuccess"));
      onClose();
      openSidebar(result.data.cartId);
    } catch (error) {
      toast.error(t("failedUpdateSubscriptionProducts"));
    }
  };

  const handleOpenDetailModal = (productId: string) => {
    setSelectedProductId(productId);
    setIsDetailModalOpen(true);
  };

  const handleCloseDetailModal = () => {
    setIsDetailModalOpen(false);
    setSelectedProductId(null);
  };

  const products = data?.data || [];

  return (
    <PortalDialog
      animationType="center"
      isShow={isOpen}
      onClose={onClose}
      showCloseButton={false}
      width={680}
      bodyClass="p-0 max-h-[85vh] sm:max-h-auto "
    >
      <div className="">
        <div className="flex justify-between items-center px-5 py-4 border-b sticky top-0 bg-white z-10">
          <h2 className="text-xl 3xl:text-2xl font-medium">{t("selectProduct")}</h2>
          <button
            onClick={onClose}
            aria-label={tCommon("close")}
            className="border rounded-full p-2"
          >
            <X className="h-6 w-6" />
          </button>
        </div>
        <div
          ref={scrollRef}
          onScroll={handleScroll}
          className="sm:h-[calc(55vh-30px)] 3xl:h-[55vh] max-h-[400px] sm:max-h-[500px] overflow-y-auto py-5"
        >
          {isLoading && page === 1 ? (
            <div className="flex justify-center items-center h-full min-h-[200px]">
              <Spinner size="lg" text={t("loadingProducts")} />
            </div>
          ) : (
            <>
              {products.map((product) => (
                <div
                  key={product._id}
                  className="flex items-center justify-between px-5 cursor-pointer bg-white hover:bg-neutral-50 py-2.5 transition-colors duration-300"
                >
                  <div className="flex items-center gap-4 flex-1">
                    <div onClick={(e) => e.stopPropagation()}>
                      <CheckboxField
                        name={`product-${product._id}`}
                        checked={selectedProductIds.includes(product._id)}
                        onChange={() => handleToggleProduct(product._id)}
                      />
                    </div>
                    <div
                      className="flex items-center gap-4 flex-1"
                      onClick={() => handleOpenDetailModal(product._id)}
                    >
                      <Image
                        src={product.productImage}
                        alt={product.title}
                        width={60}
                        height={60}
                        className="rounded-lg w-15 h-15 object-cover"
                      />
                      <div>
                        <h4 className="font-medium">{product.title}</h4>
                        <p className="font-medium text-sm block md:hidden">
                          ${product.price.amount.toFixed(2)}
                        </p>
                      </div>
                    </div>
                  </div>
                  <div
                    className="flex items-center gap-3"
                    onClick={() => handleOpenDetailModal(product._id)}
                  >
                    <p className="font-medium 3xl:text-lg hidden md:block">
                      ${product.price.amount.toFixed(2)}
                    </p>
                    <ChevronRight />
                  </div>
                </div>
              ))}
              {isFetching && (
                <div className="py-6 flex flex-col items-center justify-center gap-2">
                  <Spinner size="sm" />
                  <p className="text-sm text-gray-500 font-medium">
                    {t("loadingMoreProducts")}
                  </p>
                </div>
              )}
            </>
          )}
        </div>
        <div className="flex justify-end gap-2.5 px-5 py-4 border-t sticky bottom-0 bg-white">
          <Button
            variant="elevate"
            size="elevate-md"
            className="px-6 h-11 xl:h-auto"
            onClick={onClose}
            disabled={isUpdating}
          >
            {tCommon("cancel")}
          </Button>
          <Button
            variant="tealElevate"
            size="elevate-md"
            className="px-6 h-11 sm:h-auto min-w-[140px]"
            onClick={handleUpdateProducts}
            disabled={isUpdating}
          >
            {isUpdating ? (
              <Spinner size="xs" color="white" />
            ) : (
              t("updateProducts")
            )}
          </Button>
        </div>
      </div>
      {selectedProductId && (
        <ProductDetailModal
          isOpen={isDetailModalOpen}
          onClose={handleCloseDetailModal}
          productId={selectedProductId}
        />
      )}
    </PortalDialog>
  );
};

export default SelectProductModal;
