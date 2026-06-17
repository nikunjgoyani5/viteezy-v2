"use client";
import React, { memo, useMemo } from "react";
import { HowItWorksSection } from "@/store/api/types/landing.types";
import FallbackImage from "@/components/ui/fallbackImage";
import { usePreviewUrls } from "@/hooks/usePreviewUrl";
import { useTranslations } from "next-intl";

const HowItWork = ({ data }: { data?: HowItWorksSection }) => {
  const t = useTranslations("Landing");
  
  // Memoize images array for stable hook usage
  const stepImages = usePreviewUrls(
    useMemo(() => (data?.steps ?? []).map((step) => step?.image), [data?.steps])
  );
  
  if (!data?.isEnabled) return null;

  return (
    <section className="section-py px-4">
      <div className="w-section mx-auto">
        {/* Header */}
        <div className="text-center mb-16">
          <h2
            data-aos="fade-up"
            className="heading-style font-saans text-black-color mb-3 truncate wrap-break-word"
          >
            {data?.title || t("howItWorks")}
          </h2>
          <p
            data-aos="fade-up"
            data-aos-delay="300"
            className="text-black-color font-saans sub-heading-style mx-auto"
          >
            {data?.subTitle ||
              t("howItWorksDescription")}
          </p>
        </div>

        {/* Steps */}
        <div className="relative flex justify-evenly flex-wrap gap-17">
          {data?.steps?.length > 0
            ? data?.steps?.map((step, index) => (
                <div
                  data-aos="fade-up"
                  data-aos-delay={index * 200}
                  key={index}
                  className="relative text-center max-w-full md:max-w-[calc(33.33%-68px)]"
                >
                  {/* Step Image */}
                  <div className="relative w-45 lg:w-50 h-45 lg:h-50 mx-auto mb-9">
                    <div className="w-full h-full rounded-full overflow-hidden border-4 border-white">
                      <FallbackImage
                        src={stepImages[index] || step.image}
                        alt={step.title}
                        fill
                        className="object-cover rounded-full"
                      />
                    </div>
                  </div>

                  {/* Step Content */}
                  <div className="space-y-2">
                    <h3 className="text-[22px]  lg:text-3xl text-black-color font-medium font-saans mb-3 lg:mb-4 truncate">
                      {index + 1}. {step.title}
                    </h3>
                    <p className="text-gray-700 sub-heading-style mx-auto font-saans line-clamp-3 wrap-break-word">
                      {step.description}
                    </p>
                  </div>
                </div>
              ))
            : null}
        </div>
      </div>
    </section>
  );
};

export default memo(HowItWork);
