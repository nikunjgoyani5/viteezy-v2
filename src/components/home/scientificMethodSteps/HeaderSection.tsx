import { DesignedByScienceSection } from "@/store/api/types/landing.types";
import React from "react";
import { useTranslations } from "next-intl";

const HeaderSection = ({ data }: { data?: DesignedByScienceSection }) => {
  const t = useTranslations("Landing");
  return (
  <div className="text-center mb-16">
    <h2
      data-aos="fade-up"
      className="heading-style mb-3 font-saans text-black-color break-all line-clamp-2"
    >
      {data?.title || t("designedByScience")}
    </h2>
    <p
      data-aos="fade-up"
      data-aos-delay="300"
      className="sub-heading-style mb-6 font-saans text-black-color max-w-3xl mx-auto break-all line-clamp-3"
    >
      {data?.description ||
        t("scientificCommitteeDescription")}
    </p>
  </div>
);
};

export default HeaderSection;
