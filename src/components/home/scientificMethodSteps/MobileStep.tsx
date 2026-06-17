import React from "react";
import { TeamCollaborationIcon } from "@/components/icons";
import { DesignedByScienceStep } from "@/store/api/types/landing.types";
import FallbackImage from "@/components/ui/fallbackImage";
import { usePreviewUrl } from "@/hooks/usePreviewUrl";
import { useTranslations } from "next-intl";

const MobileStep = ({
  step,
  index,
}: {
  step: DesignedByScienceStep;
  index: number;
}) => {
  const t = useTranslations("Landing");
  const imageUrl = usePreviewUrl(step?.image);

  return (
    <div data-aos="fade-up" className="flex flex-col items-center text-center">
      <div className="relative mb-8 w-44 h-44">
        <div className="absolute left-1/2 -top-2 -translate-x-1/2 bg-soft-orange-color text-white px-5 py-1 rounded-full font-saans text-base font-regular z-10">
          {t("step")} {index + 1}
        </div>

        <div className="w-full h-full rounded-full overflow-hidden">
          <FallbackImage
            src={imageUrl || ""}
            height={300}
            width={300}
            alt={step?.title || ""}
            className="w-full h-full object-cover rounded-full"
          />
        </div>

        <div className="absolute -bottom-10 -right-8 transform -rotate-4">
          <TeamCollaborationIcon />
        </div>
      </div>

      <div className="w-full max-w-sm">
        <h3 className="text-xl font-saans font-medium text-black-color my-2 line-clamp-2 wrap-break-word">
          {step.title}
        </h3>
        <p className="text-black-color sub-heading-style font-saans mx-auto wrap-break-word line-clamp-3">
          {step.description}
        </p>
      </div>
    </div>
  );
};

export default MobileStep;