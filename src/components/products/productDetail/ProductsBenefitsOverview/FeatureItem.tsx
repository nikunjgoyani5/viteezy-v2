import { memo } from "react";
import Image from "next/image";

// Memoized feature item component to prevent unnecessary re-renders
const FeatureItem = memo(
  ({
    ProductsBenefit,
    className,
  }: {
    ProductsBenefit: {
      title: string;
      description: string;
      image: string;
    };
    className?: string;
  }) => (
    <div className={`flex flex-col items-center gap-2.5 ${className || ""}`}>
      {/* Icon on top */}
      <div className="mb-3 md:mb-4">
        <Image
          width={100}
          height={100}
          className="shrink-0 w-36 h-36 md:w-24 md:h-24 rounded-full object-cover"
          src={ProductsBenefit.image}
          alt={ProductsBenefit.title}
          // unoptimized
        />
      </div>
      {/* Heading */}
      <h3 className="text-2xl md:text-xl font-medium font-saans text-white leading-tight line-clamp-1 3xl:text-[28px]">
        {ProductsBenefit.title}
      </h3>
      {/* Description */}
      <span className="text-xl md:text-base text-center text-white leading-5 font-extralight px-4 md:px-0 line-clamp-2 3xl:text-[21px]">
        {ProductsBenefit.description}
      </span>
    </div>
  )
);

FeatureItem.displayName = "FeatureItem";

export default FeatureItem;
