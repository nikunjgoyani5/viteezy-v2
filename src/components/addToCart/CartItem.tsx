"use client";
import Image from "next/image";
import { useEffect, useState } from "react";
import { TrashIcon, Plus, Minus } from "../icons";
import { ImageOff } from "lucide-react";
import { getCurrencySymbol } from "@/lib/utils";
import { useTranslations } from "next-intl";

interface CartItemProps {
  id: string;
  title: string;
  description: string;
  price: number;
  originalPrice?: number;
  quantity: number;
  image: string;
  variant?: string;
  variantType?: "STAND_UP_POUCH" | "SACHETS";
  membershipDiscount?: number;
  onIncrement: (id: string) => void;
  onDecrement: (id: string) => void;
  onDelete?: (id: string) => void;
  currency?: string;
  isLoading?: boolean;
}

export default function CartItem({
  id,
  title,
  description,
  price,
  originalPrice,
  quantity,
  image,
  variant,
  variantType,
  membershipDiscount,
  onIncrement,
  onDecrement,
  onDelete,
  currency = "USD",
  isLoading = false,
}: CartItemProps) {
  const tCommon = useTranslations("Common");
  const symbol = getCurrencySymbol(currency);
  const hasValidImage = (src?: string) => !!(src && src.trim().length);
  const [src, setSrc] = useState<string | null>(
    hasValidImage(image) ? image : null
  );
  const [hasError, setHasError] = useState(false);

  useEffect(() => {
    if (hasValidImage(image)) {
      setSrc(image);
      setHasError(false);
    } else {
      setSrc(null);
    }
  }, [image]);

  const showPlaceholder = !src || hasError;

  const hasDiscount = originalPrice && originalPrice > price;

  const isStandUpPouch = variantType === "STAND_UP_POUCH";
  const isSachets = variantType === "SACHETS";

  return (
    <div className="mt-3">
      {/* Card container with overflow-hidden so bottom banner clips to rounded corners */}
      <div className="bg-white border border-neutral-sand-100 rounded-xl overflow-hidden relative">
        {/* Loading overlay */}
        {isLoading && (
          <div className="absolute inset-0 bg-white/70 z-50 flex items-center justify-center rounded-xl">
            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-gray-900"></div>
          </div>
        )}
        {/* Content row */}
        <div className="p-3 flex gap-3">
          {/* Product Image */}
          <div className="w-20 h-20 rounded-lg overflow-hidden bg-neutral-sand-100 flex items-center justify-center shrink-0">
            {showPlaceholder ? (
              <ImageOff className="w-8 h-8 text-neutral-400" />
            ) : (
              <Image
                src={src}
                alt={title}
                width={128}
                height={128}
                className="w-full h-full object-cover"
                onError={() => setHasError(true)}
                // unoptimized
              />
            )}
          </div>

          {/* Product Info */}
          <div className="flex-1 flex flex-col justify-between min-w-0">
            <div className="flex items-start justify-between gap-2">
              <div className="flex-1 min-w-0">
                <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-1">
                  <div>
                    <h4 className="text-base font-semibold text-gray-900 truncate">
                      {title}
                    </h4>
                    {variant && (
                      <p className="text-sm text-gray-600 mt-0.5">{variant}</p>
                    )}
                  </div>
                  <div className="flex flex-col items-end justify-between gap-1 sm:ml-2">
                    {/* {hasDiscount && (
                      <span className="text-xs text-gray-400 line-through">
                      {symbol}{originalPrice!.toFixed(2)}
                      </span>
                    )} */}
                    <span className="text-base font-semibold text-gray-900">
                      {symbol}
                      {price.toFixed(2)}
                    </span>
                  </div>
                </div>

                {/* Quantity & actions for specific variants */}
                {isStandUpPouch && (
                  <div className="flex items-center gap-3 mt-2">
                    {onDelete && (
                      <button
                        onClick={() => onDelete(id)}
                        className="w-7 h-7 flex items-center justify-center rounded-md border border-linen-color bg-white hover:bg-neutral-50 cursor-pointer"
                        aria-label={tCommon("removeItemAria")}
                      >
                        <TrashIcon />
                      </button>
                    )}
                    <div className="flex items-center border border-linen-color rounded-md h-7 w-fit shrink-0">
                      {quantity > 1 && (
                        <button
                          onClick={() => onDecrement(id)}
                          className="w-7 h-full flex items-center justify-center hover:bg-gray-50 rounded-l-md transition-colors text-charcol-color border-r border-linen-color cursor-pointer"
                          type="button"
                        >
                          <Minus />
                        </button>
                      )}
                      <span className="w-7     text-center text-sm font-medium">
                        {quantity}
                      </span>
                      <button
                        onClick={() => onIncrement(id)}
                        className={`w-7 h-full flex items-center justify-center hover:bg-gray-50 transition-colors text-charcol-color border-l border-linen-color cursor-pointer ${
                          quantity === 1 ? "rounded-md" : "rounded-r-md"
                        }`}
                        type="button"
                      >
                        <Plus />
                      </button>
                    </div>
                  </div>
                )}

                {/* Sachets: only remove icon */}
                {isSachets && !isStandUpPouch && onDelete && (
                  <div className="flex items-center gap-3 mt-2">
                    <button
                      onClick={() => onDelete(id)}
                      className="w-7 h-7 flex items-center justify-center rounded-md border border-linen-color bg-white hover:bg-neutral-50 cursor-pointer"
                      aria-label={tCommon("removeItemAria")}
                    >
                      <TrashIcon />
                    </button>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>

        {/* Membership Discount banner attached to bottom */}
        {/* {membershipDiscount && membershipDiscount > 0 && (
                    <div
                        style={{
                            background:
                                "linear-gradient(90deg, rgba(27, 175, 154, 0.35) 0%, rgba(247, 161, 115, 0.35) 100%), linear-gradient(0deg, #FFFFFF, #FFFFFF)",
                        }}
                    >
                        <div className="px-3 py-2 flex items-center justify-between">
                            <span className="text-sm font-medium text-black">Membership Discount</span>
                            <span className="text-sm font-semibold text-black">-{symbol}{membershipDiscount.toFixed(2)}</span>
                        </div>
                    </div>
                )} */}
      </div>
    </div>
  );
}
