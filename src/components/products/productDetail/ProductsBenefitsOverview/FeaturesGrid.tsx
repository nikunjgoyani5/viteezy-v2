import React, { useMemo } from "react";
import { ProductsBenefits } from "@/components/constants";
import FeatureItem from "./FeatureItem";
import Divider from "./Divider";
import { useLocale } from "next-intl";
import { resolveLocalizedValue } from "@/lib/utils";

interface FeaturesGridProps {
  productData?: any;
}

const FeaturesGrid: React.FC<FeaturesGridProps> = ({ productData }) => {
  const locale = useLocale();

  // Map API specification items to ProductsBenefit format
  const benefits = useMemo(() => {
    if (
      productData?.specification?.items &&
      productData.specification.items.length > 0
    ) {
      return productData.specification.items.map((item: any) => ({
        title: resolveLocalizedValue(item.title, locale),
        description: resolveLocalizedValue(item.descr, locale),
        image: item.image,
        imageMobile: item.imageMobile,
      }));
    }
    return ProductsBenefits;
  }, [productData, locale]);

  return (
    <div className="relative flex-1 lg:flex-[0.6] w-full">
      {/* Continuous Vertical Divider - spans entire height on desktop */}
      <Divider
        orientation="vertical"
        className="hidden lg:block absolute left-1/2 -top-2 -bottom-10 transform -translate-x-1/2 z-10"
      />

      {/* Responsive Grid Layout */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-0 md:gap-12 lg:gap-16 xl:gap-20">
        {/* Left Column - Features 0,2 */}
        <div
          data-aos="fade-up"
          data-aos-delay="300"
          className="space-y-0 md:space-y-8 lg:space-y-10 pt-0 md:pt-6 lg:pt-14"
        >
          {benefits[0] && <FeatureItem ProductsBenefit={benefits[0]} />}
          <Divider className="my-6 md:my-6 lg:my-8" />
          {benefits[2] && <FeatureItem ProductsBenefit={benefits[2]} />}
        </div>
        <Divider className="my-6 md:hidden" />

        {/* Right Column - Features 1,3 */}
        <div
          data-aos="fade-up"
          data-aos-delay="800"
          className="space-y-0 md:space-y-8 lg:space-y-10"
        >
          {benefits[1] && <FeatureItem ProductsBenefit={benefits[1]} />}
          <Divider className="my-6 md:my-6 lg:my-8" />
          {benefits[3] && <FeatureItem ProductsBenefit={benefits[3]} />}
        </div>
      </div>
    </div>
  );
};

export default FeaturesGrid;
