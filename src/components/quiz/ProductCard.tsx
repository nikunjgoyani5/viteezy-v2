import React from "react";
import Image from "next/image";
import FallbackImage from "../ui/fallbackImage";
import Link from "next/link";

interface ProductCardProps {
  title: string;
  id: string;
  description: string;
  image?: string;
  isSelected?: boolean;
  onSelect?: () => void;
}

const ProductCard: React.FC<ProductCardProps> = ({
  id,
  title,
  description,
  image = "/carosuleCardImage.png",
  isSelected = false,
  onSelect,
}) => {
  return (
    <Link
      href={`/products/${id}`}
      // onClick={onSelect}
      className={`cursor-pointer rounded-xl overflow-hidden border group hover:shadow-lg transition-all bg-white max-w-[230px]`}
    >
      <div className="w-full">
        {/* Square Image Container using aspect-square */}
        <div className="w-full">
          <div className="p-1 flex items-center justify-center w-full aspect-square">
            <FallbackImage
              src={image}
              alt={title}
              width={200}
              height={200}
              className="w-full h-full object-cover rounded-lg"
            />
          </div>
        </div>

        {/* Product Info */}
        <div className="p-4 bg-white">
          <h3 className="font-semibold text-gray-900 mb-1 text-lg">{title}</h3>
          <p className="text-base text-gray-600 line-clamp-2 leading-tight">
            {description}
          </p>
        </div>
      </div>
    </Link>
  );
};

export default ProductCard;
