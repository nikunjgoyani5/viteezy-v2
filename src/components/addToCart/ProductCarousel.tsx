"use client";
import React, { useRef } from "react";
import Image from "next/image";
import { PlusIcon } from "../icons";
import { ProductSuggestion } from "../types";

interface ProductCarouselProps {
  products: ProductSuggestion[];
  onAddProduct?: (productId: string) => void;
}

export default function ProductCarousel({
  products,
  onAddProduct,
}: ProductCarouselProps) {
  const scrollRef = useRef<HTMLDivElement>(null);
  const isDragging = useRef(false);
  const hasDragged = useRef(false);
  const startX = useRef(0);
  const scrollLeft = useRef(0);

  const handleMouseDown = (e: React.MouseEvent) => {
    if (!scrollRef.current) return;
    isDragging.current = true;
    hasDragged.current = false;
    startX.current = e.pageX - scrollRef.current.offsetLeft;
    scrollLeft.current = scrollRef.current.scrollLeft;
    scrollRef.current.style.cursor = "grabbing";
  };

  const handleMouseMove = (e: React.MouseEvent) => {
    if (!isDragging.current || !scrollRef.current) return;
    e.preventDefault();
    const x = e.pageX - scrollRef.current.offsetLeft;
    const walk = (x - startX.current) * 2;
    if (Math.abs(walk) > 5) {
      hasDragged.current = true;
    }
    scrollRef.current.scrollLeft = scrollLeft.current - walk;
  };

  const handleMouseUp = () => {
    isDragging.current = false;
    if (scrollRef.current) {
      scrollRef.current.style.cursor = "grab";
    }
  };

  const handleMouseLeave = () => {
    isDragging.current = false;
    if (scrollRef.current) {
      scrollRef.current.style.cursor = "grab";
    }
  };

  const handleAddClick = (e: React.MouseEvent, productId: string) => {
    if (hasDragged.current) {
      e.preventDefault();
      return;
    }
    onAddProduct?.(productId);
  };

  return (
    <div className="mt-5">
      <div
        ref={scrollRef}
        onMouseDown={handleMouseDown}
        onMouseMove={handleMouseMove}
        onMouseUp={handleMouseUp}
        onMouseLeave={handleMouseLeave}
        className="flex overflow-auto whitespace-nowrap gap-3 px-5 [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none] cursor-grab select-none"
      >
        {products.map((product) => (
          <div
            key={product.id}
            className="border order-neutral-sand-100 rounded-lg p-1"
          >
            <div className="rounded-lg overflow-hidden h-20 w-20 bg-neutral-sand-100">
              <Image
                src={product.image}
                alt={product.title}
                width={320}
                height={320}
                className="w-full h-full object-cover"
                // unoptimized
              />
            </div>
            <div className="flex items-center -mt-3">
              <button
                onClick={(e) => handleAddClick(e, product.id)}
                className="mx-auto w-5 h-5 rounded-full bg-white border order-neutral-sand-100 flex items-center justify-center hover:bg-neutral-sand-100 transition-colors cursor-pointer"
              >
                <PlusIcon />
              </button>
            </div>
            <div className="mt-1 text-center">
              <div className="text-xs 3xl:text-sm line-clamp-2 w-20 truncate font-medium">
                {product.title}
              </div>
              <div className="text-[9px] 3xl:text-[11px] text-charcol-color font-medium w-20 truncate line-clamp-2 mb-1">
                {product.description}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
