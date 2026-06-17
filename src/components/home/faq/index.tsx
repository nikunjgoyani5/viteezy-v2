"use client";

import { faqData } from "@/components/constants";
import { FAQSection as FAQSectionTypes } from "@/store/api/types/landing.types";
import React, { memo, useMemo, useState } from "react";
import { useLocale, useTranslations } from "next-intl";
import { resolveLocalizedValue } from "@/lib/utils";

const Plus = ({
  className,
  isOpen,
}: {
  className?: string | number;
  isOpen?: boolean;
}) => (
  <svg
    className={`${className} transition-transform duration-300 ease-in-out ${
      isOpen ? "rotate-45" : "rotate-0"
    }`}
    fill="none"
    stroke="currentColor"
    viewBox="0 0 24 24"
  >
    <path
      strokeLinecap="round"
      strokeLinejoin="round"
      strokeWidth={2}
      d="M12 6v6m0 0v6m0-6h6m-6 0H6"
    />
  </svg>
);

export interface ProductFaq {
  _id?: string;
  question: string;
  answer: string;
  sortOrder?: number;
}

const FAQSection = ({
  data,
  productFaqs,
  className,
}: {
  data?: FAQSectionTypes;
  /** FAQs from product details API - when provided, uses these instead of landing data */
  productFaqs?: ProductFaq[];
  className?: string;
}) => {
  const locale = useLocale();
  const t = useTranslations("Landing");
  const [openItems, setOpenItems] = useState<Set<string | number>>(new Set());

  const toggleItem = (id: string | number) => {
    const newOpenItems = new Set(openItems);
    if (openItems.has(id)) {
      newOpenItems.delete(id);
    } else {
      newOpenItems.add(id);
    }
    setOpenItems(newOpenItems);
  };

  // Product FAQs take priority, then landing data, then static fallback
  const displayFaqs = useMemo(() => {
    if (productFaqs?.length) {
      return productFaqs.map((faq, index) => ({
        id: faq._id ?? index,
        question: resolveLocalizedValue(faq.question, locale),
        answer: resolveLocalizedValue(faq.answer, locale),
      }));
    }
    
    // Use landing page FAQ data if available
    const landingFaqs = data?.faqs;
    if (landingFaqs?.length) {
      return landingFaqs?.slice(0,4)?.map((faq, index) => ({
        id: index + 1,
        question: faq.question,
        answer: faq.answer,
      }));
    }
    
    // Fallback to static data
    return faqData;
  }, [productFaqs, data?.faqs, locale]);

  // Show section if productFaqs exist or if landing data is enabled and has FAQs
  const shouldShow = productFaqs?.length || (data?.isEnabled && data?.faqs?.length > 0);
  if (!shouldShow) return null;

  return (
    <section className={`section-pb px-4 relative z-0 ${className ?? ""}`}>
      <div className="max-w-4xl mx-auto">
        {/* Header */}
        <div className="text-center mb-12">
          <h2
            data-aos="fade-up"
            className="heading-style mb-4 font-saans text-black-color 3xl:text-[42px]"
          >
            {data?.title || t("frequentlyAskedQuestions")}
          </h2>
          <p
            data-aos="fade-up"
            data-aos-delay="300"
            className="sub-heading-style max-w-2xl mx-auto 3xl:text-[19px]"
          >
            {data?.description ||
              t("faqDescription")}
          </p>
        </div>

        {/* FAQ Items */}
        <div className="space-y-4">
          {displayFaqs.map((item, index) => (
            <div
              data-aos="fade-up"
              data-aos-delay={index * 100}
              key={item.id}
              className="bg-off-white-color cursor-pointer rounded-lg overflow-hidden  duration-200"
            >
              {/* Question Button */}
              <button
                onClick={() => toggleItem(item.id)}
                className="w-full px-6 py-5 cursor-pointer text-left flex items-center justify-between hover:bg-off-white-color/90 transition-all duration-300 ease-in-out focus:outline-none"
                aria-expanded={openItems.has(item.id)}
                aria-controls={`faq-answer-${item.id}`}
              >
                <span className="text-lg cursor-pointer font-medium text-black-color pr-4 3xl:text-[21px]">
                  {item.question}
                </span>
                <div className="shrink-0 transition-transform duration-300 ease-in-out hover:scale-110">
                  <Plus
                    className="w-7.5 p-0.5 h-7.5 text-black-color bg-white rounded-full "
                    isOpen={openItems.has(item.id)}
                  />
                </div>
              </button>

              {/* Answer */}
              <div
                id={`faq-answer-${item.id}`}
                className={`overflow-hidden transition-all duration-500 ease-in-out ${
                  openItems.has(item.id)
                    ? "max-h-96 opacity-100"
                    : "max-h-0 opacity-0"
                }`}
              >
                <div className="px-6 pb-5">
                  <div className="">
                    <p className="text-charcol-color leading-relaxed transition-opacity duration-300 ease-in-out text-sm 3xl:text-lg wrap-break-word">
                      {item.answer}
                    </p>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default memo(FAQSection);
