import type { LandingFormValues } from "./landing.schema";
import type { LandingPageApiResponse } from "@/store/api/types/landingPage.types";

/**
 * Maps API response to form values
 */
export function mapApiResponseToFormValues(
  apiData: LandingPageApiResponse
): LandingFormValues {
  const hero = apiData.heroSection;
  const membership = apiData.membershipSection;
  const howItWorks = apiData.howItWorksSection;
  const productCategory = apiData.productCategorySection;
  const community = apiData.communitySection;
  const features = apiData.featuresSection;
  const designedByScience = apiData.designedByScienceSection;
  const testimonials = apiData.testimonialsSection;
  const blog = apiData.blogSection;
  const faq = apiData.faqSection;

  // Helper to ensure arrays have the right length
  const padArray = <T>(arr: T[], length: number, defaultValue: T): T[] => {
    const result = [...arr];
    while (result.length < length) {
      result.push(defaultValue);
    }
    return result.slice(0, length);
  };

  return {
    // Hero Section
    heroSection_title: hero.title || "",
    heroSection_description: hero.description || "",
    heroSection_video_url: hero.videoUrl || "",
    heroBackgroundImage: hero.backgroundImage || null,
    heroSection_isEnabled: hero.isEnabled ?? true,
    heroSection_order: hero.order ?? 1,
    heroSection_highlightedText: hero.highlightedText?.map((text) => ({ value: text })) || [],
    heroSection_primaryCTA: padArray(
      hero.primaryCTA?.map((cta) => ({
        label: cta.label || "",
        link: cta.link || "",
        order: cta.order || 0,
        image: cta.image || null,
      })) || [],
      3,
      { label: "", link: "", order: 0, image: null }
    ),

    // Membership Section
    membershipSection_title: membership.title || "",
    membershipSection_subTitle: "",
    membershipSection_description: membership.description || "",
    membershipBackgroundImage: membership.backgroundImage || null,
    membershipSection_isEnabled: membership.isEnabled ?? true,
    membershipSection_order: membership.order ?? 2,
    membershipSection_benefits: padArray(
      membership.benefits?.map((benefit) => ({
        title: benefit.title || "",
        description: benefit.description || "",
        order: benefit.order || 0,
        icon: benefit.icon || null,
      })) || [],
      3,
      { title: "", description: "", order: 0, icon: null }
    ),

    // How It Works Section
    howItWorksSection_title: howItWorks.title || "",
    howItWorksSection_subTitle: howItWorks.subTitle || "",
    howItWorksSection_stepsCount: howItWorks.stepsCount || 3,
    howItWorksSection_isEnabled: howItWorks.isEnabled ?? true,
    howItWorksSection_order: howItWorks.order ?? 3,
    howItWorksSection_steps: padArray(
      howItWorks.steps?.map((step) => ({
        title: step.title || "",
        description: step.description || "",
        order: step.order || 0,
        image: step.image || null,
      })) || [],
      3,
      { title: "", description: "", order: 0, image: null }
    ),

    // Product Category Section
    productCategorySection_title: productCategory.title || "",
    productCategorySection_subTitle: "",
    productCategorySection_description: productCategory.description || "",
    productCategorySection_categories:
      productCategory.productCategories?.map((cat) => ({
        _id: cat._id,
        name: cat.name,
        slug: cat.slug,
        description: cat.description,
        icon: cat.icon,
        image: cat.image,
      })) || [],
    productCategorySection_isEnabled: productCategory.isEnabled ?? true,
    productCategorySection_order: productCategory.order ?? 4,

    // Community Section
    communitySection_title: community.title || "",
    communitySection_subTitle: community.subTitle || "",
    communitySection_isEnabled: community.isEnabled ?? true,
    communitySection_order: community.order ?? 5,
    communityBackgroundImage: community.backgroundImage || null,
    communitySection_metrics: padArray(
      community.metrics?.map((metric) => ({
        label: metric.label || "",
        value: metric.value ?? null,
        order: metric.order || 0,
      })) || [],
      4,
      { label: "", value: null, order: 0 }
    ),

    // Features Section
    featuresSection_title: features.title || "",
    featuresSection_subTitle: "",
    featuresSection_description: features.description || "",
    featuresSection_isEnabled: features.isEnabled ?? true,
    featuresSection_order: features.order ?? 6,
    featuresSection_features: padArray(
      features.features?.map((feature) => ({
        title: feature.title || "",
        description: feature.description || "",
        order: feature.order || 0,
        icon: feature.icon || null,
      })) || [],
      4,
      { title: "", description: "", order: 0, icon: null }
    ),

    // Designed by Science Section
    designedByScienceSection_title: designedByScience.title || "",
    designedByScienceSection_description: designedByScience.description || "",
    designedByScienceSection_isEnabled: designedByScience.isEnabled ?? true,
    designedByScienceSection_order: designedByScience.order ?? 7,
    designedByScienceSection_steps: padArray(
      designedByScience.steps?.map((step) => ({
        title: step.title || "",
        description: step.description || "",
        order: step.order || 0,
        image: step.image || null,
      })) || [],
      3,
      { title: "", description: "", order: 0, image: null }
    ),

    // Testimonials Section
    testimonialsSection_title: testimonials.title || "",
    testimonialsSection_subTitle: testimonials.subTitle || "",
    testimonialsSection_isEnabled: testimonials.isEnabled ?? true,
    testimonialsSection_order: testimonials.order ?? 8,

    // Blog Section
    blogSection_title: blog.title || "",
    blogSection_description: blog.description || "",
    blogSection_isEnabled: blog.isEnabled ?? true,
    blogSection_order: blog.order ?? 9,

    // FAQ Section
    faqSection_title: faq.title || "",
    faqSection_description: faq.description || "",
    faqSection_isEnabled: faq.isEnabled ?? true,
    faqSection_order: faq.order ?? 10,

    // Overall
    isActive: apiData.isActive ?? true,
  };
}
