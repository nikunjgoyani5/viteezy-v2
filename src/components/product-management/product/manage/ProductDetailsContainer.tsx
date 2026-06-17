"use client";

import React, { useState } from "react";
import { cn } from "@/lib/utils";
import { PRODUCT_DETAILS_SECTIONS } from "./productSectionConfig";
import { ProductDetailsSidebar } from "./ProductDetailsSidebar";

import PriceSection from "./sections/price";
import ProductDetailsSection from "./sections/ProductDetailsSection";
import BenefitsSection from "./sections/BenefitsSection";
import IngredientsSection from "./sections/IngredientsSection";
import NutritionInfoSection from "./sections/NutritionInfoSection";
import HowToUseSection from "./sections/HowToUseSection";
import SimilarProductsSection from "./sections/SimilarProductsSection";
import ComparisonSection from "./sections/ComparisonSection";
import SpecificationSection from "./sections/SpecificationSection";
import FAQSection from "./sections/FAQSection";

const MemoizedSpecificationSection = React.memo(SpecificationSection);

export default function ProductDetailsContainer() {
  const [activeTab, setActiveTab] = useState("price");
  const activeSection = PRODUCT_DETAILS_SECTIONS.find(
    (s) => s.id === activeTab,
  );

  return (
    <div className="bg-white rounded-lg border border-gray-200 overflow-hidden">
      <div className="px-6 py-4 border-b border-gray-200 bg-white">
        <h2 className="text-lg font-semibold text-gray-900">
          {activeSection?.label || "Product Configuration"}
        </h2>
      </div>

      <div className="flex min-h-[600px]">
        <ProductDetailsSidebar
          activeTab={activeTab}
          onTabChange={setActiveTab}
        />

        <div className="flex-1 bg-white overflow-y-auto">
          {activeTab === "price" && <PriceSection />}
          {activeTab === "details" && <ProductDetailsSection />}
          {activeTab === "membership" && <div>Membership Content</div>}
          {activeTab === "benefits" && <BenefitsSection />}
          {activeTab === "ingredients" && <IngredientsSection />}
          {activeTab === "nutrition" && <NutritionInfoSection />}
          {activeTab === "howToUse" && <HowToUseSection />}
          {activeTab === "similarProducts" && <SimilarProductsSection />}
          {activeTab === "featureComparison" && <ComparisonSection />}
          <div className={cn(activeTab !== "specification" && "hidden")}>
            <MemoizedSpecificationSection />
          </div>
          {activeTab === "faqs" && <FAQSection />}
        </div>
      </div>
    </div>
  );
}
