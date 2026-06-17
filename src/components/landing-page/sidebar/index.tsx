"use client";

import React, { useState, useEffect, useMemo, useRef, useCallback } from "react";
import { useFormContext } from "react-hook-form";
import { Accordion } from "@/components/ui/accordion";
import HeroSectionForm from "./HeroSectionForm";
import MembershipSectionForm from "./MembershipSectionForm";
import HowItWorksSectionForm from "./HowItWorksSectionForm";
import ProductCategorySectionForm from "./ProductCategorySectionForm";
import CommunitySectionForm from "./CommunitySectionForm";
import FeaturesSectionForm from "./FeaturesSectionForm";
import DesignedByScienceSectionForm from "./DesignedByScienceSectionForm";
import TestimonialsSectionForm from "./TestimonialsSectionForm";
import BlogSectionForm from "./BlogSectionForm";
import FAQSectionForm from "./FAQSectionForm";
import type { LandingFormValues } from "../landing.schema";

// Memoized helper function outside component to prevent recreation
const hasNestedError = (errors: any, fieldPath: string): boolean => {
  if (!errors || !fieldPath) return false;
  
  const parts = fieldPath.split(".");
  let current = errors;
  
  for (const part of parts) {
    if (current && typeof current === "object" && part in current) {
      current = current[part];
    } else {
      return false;
    }
  }
  
  if (!current) return false;
  
  if (Array.isArray(current)) {
    return current.some((item) => {
      if (typeof item === "object" && item !== null) {
        return Object.values(item).some((val: any) => {
          if (val && typeof val === "object") {
            return val.message || Object.values(val).some((v: any) => v?.message);
          }
          return false;
        });
      }
      return false;
    });
  }
  
  if (current && typeof current === "object") {
    if (current.message) return true;
    return Object.values(current).some((val: any) => {
      if (val && typeof val === "object") {
        return val.message || (Array.isArray(val) && val.some((v: any) => v?.message));
      }
      return false;
    });
  }
  
  return false;
};

// Section configurations with their field paths
const SECTION_FIELDS: Record<string, string[]> = {
  hero: [
    "heroSection_title",
    "heroSection_description",
    "heroSection_video_url",
    "heroBackgroundImage",
    "heroSection_highlightedText",
    "heroSection_primaryCTA",
  ],
  membership: [
    "membershipSection_title",
    "membershipSection_description",
    "membershipBackgroundImage",
    "membershipSection_benefits",
  ],
  "how-it-works": [
    "howItWorksSection_title",
    "howItWorksSection_subTitle",
    "howItWorksSection_steps",
  ],
  "product-category": [
    "productCategorySection_title",
    "productCategorySection_description",
  ],
  community: [
    "communitySection_title",
    "communitySection_subTitle",
    "communityBackgroundImage",
    "communitySection_metrics",
  ],
  features: [
    "featuresSection_title",
    "featuresSection_description",
    "featuresSection_features",
  ],
  "designed-by-science": [
    "designedByScienceSection_title",
    "designedByScienceSection_description",
    "designedByScienceSection_steps",
  ],
  testimonials: ["testimonialsSection_title"],
  blog: ["blogSection_title", "blogSection_description"],
  faq: ["faqSection_title", "faqSection_description"],
};

export default function LandingSidebarFormUI() {
  const { formState, getFieldState } = useFormContext<LandingFormValues>();
  const { errors, submitCount } = formState;
  const [openValue, setOpenValue] = useState<string>("hero");
  
  // Refs to track state without causing re-renders
  const previousSubmitCountRef = useRef<number>(0);
  const previousErrorSectionsRef = useRef<string[]>([]);
  const isManualChangeRef = useRef<boolean>(false);
  const hasErrorsRef = useRef<boolean>(false);

  // Memoized: Find sections with errors - only show after submit attempt
  // Use getFieldState for better reactivity when errors are cleared
  const sectionsWithErrors = useMemo(() => {
    // Don't show errors until submit is attempted
    if (submitCount === 0) return [];
    
    const errorSections: string[] = [];
    
    Object.entries(SECTION_FIELDS).forEach(([sectionId, fields]) => {
      const hasError = fields.some((fieldPath) => {
        // Use getFieldState for simple fields - more reactive
        if (!fieldPath.includes(".") && !fieldPath.includes("[")) {
          try {
            const fieldState = getFieldState(fieldPath as any, formState);
            return !!fieldState.error;
          } catch {
            return !!(errors[fieldPath as keyof typeof errors]?.message);
          }
        }
        // For nested/array fields, check errors object
        return hasNestedError(errors, fieldPath);
      });
      
      if (hasError) {
        errorSections.push(sectionId);
      }
    });
    
    return errorSections;
  }, [errors, submitCount, formState, getFieldState]);

  // Handle validation trigger - open ONLY first accordion with errors
  // Optimized: Combine both effects and reduce dependency array
  useEffect(() => {
    const hasErrorsNow = sectionsWithErrors.length > 0;
    const hadErrorsBefore = hasErrorsRef.current;
    const submitCountIncreased = submitCount > previousSubmitCountRef.current;
    
    // When validation is triggered (submitCount increases)
    if (submitCountIncreased) {
      previousSubmitCountRef.current = submitCount;
      isManualChangeRef.current = false;
      
      if (hasErrorsNow) {
        setOpenValue(sectionsWithErrors[0]);
        previousErrorSectionsRef.current = [...sectionsWithErrors];
        hasErrorsRef.current = true;
      }
      return;
    }

    // Detect when errors first appear
    if (!hadErrorsBefore && hasErrorsNow) {
      setOpenValue(sectionsWithErrors[0]);
      previousErrorSectionsRef.current = [...sectionsWithErrors];
      hasErrorsRef.current = true;
      isManualChangeRef.current = false;
      return;
    }

    // Auto-open next accordion with errors when current one is fixed
    if (hasErrorsNow && openValue) {
      const currentHasError = sectionsWithErrors.includes(openValue);
      const wasInPreviousErrors = previousErrorSectionsRef.current.includes(openValue);

      // If current accordion's errors were fixed, open next one
      if (wasInPreviousErrors && !currentHasError && !isManualChangeRef.current) {
        const currentIndex = previousErrorSectionsRef.current.indexOf(openValue);
        const remainingErrors = sectionsWithErrors.filter((id) => id !== openValue);
        
        if (remainingErrors.length > 0) {
          const nextInOrder = previousErrorSectionsRef.current.find(
            (id, idx) => idx > currentIndex && sectionsWithErrors.includes(id)
          );
          
          setOpenValue(nextInOrder || remainingErrors[0]);
          isManualChangeRef.current = false;
        }
      } else if (!currentHasError && !isManualChangeRef.current) {
        // If current accordion doesn't have errors, switch to first error
        setOpenValue(sectionsWithErrors[0]);
        previousErrorSectionsRef.current = [...sectionsWithErrors];
      }
    }

    // Update refs
    hasErrorsRef.current = hasErrorsNow;
    if (hasErrorsNow) {
      previousErrorSectionsRef.current = [...sectionsWithErrors];
    } else {
      previousErrorSectionsRef.current = [];
    }
  }, [submitCount, sectionsWithErrors, openValue]); // Removed errors dependency - sectionsWithErrors already depends on it

  // Memoized callback for accordion changes - optimized timeout
  const handleValueChange = useCallback((value: string | undefined) => {
    isManualChangeRef.current = true;
    setOpenValue(value || "");
    // Use requestAnimationFrame for better performance than setTimeout
    requestAnimationFrame(() => {
      setTimeout(() => {
        isManualChangeRef.current = false;
      }, 50); // Reduced timeout for faster response
    });
  }, []);

  return (
    <Accordion
      type="single"
      collapsible
      value={openValue}
      onValueChange={handleValueChange}
      className="w-full h-full bg-white border rounded-lg overflow-hidden"
    >
      <HeroSectionForm />
      <MembershipSectionForm />
      <HowItWorksSectionForm />
      <ProductCategorySectionForm />
      <CommunitySectionForm />
      <FeaturesSectionForm />
      <DesignedByScienceSectionForm />
      <TestimonialsSectionForm />
      <BlogSectionForm />
      <FAQSectionForm />
    </Accordion>
  );
}
