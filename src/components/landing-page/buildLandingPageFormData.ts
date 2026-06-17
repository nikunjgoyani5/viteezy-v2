import type { LandingFormValues } from "./landing.schema";
import type { UploadMaybe } from "./landing.schema";

const isFile = (v: any): v is File =>
  typeof File !== "undefined" && v instanceof File;

const isUrlString = (v: any): v is string =>
  typeof v === "string" && v.trim() !== "" && !isFile(v);

const appendString = (fd: FormData, key: string, val?: string | null) => {
  if (val != null && val !== "") {
    fd.append(key, String(val));
  }
};

const appendBool = (fd: FormData, key: string, val?: boolean | null) => {
  if (val != null) {
    fd.append(key, val ? "true" : "false");
  }
};

const appendNumber = (fd: FormData, key: string, val?: number | null) => {
  if (val != null && !isNaN(val)) {
    fd.append(key, String(val));
  }
};

const appendFile = (fd: FormData, key: string, val?: UploadMaybe) => {
  if (!val) return;
  if (isFile(val)) {
    fd.append(key, val);
  } else if (isUrlString(val)) {
    fd.append(key, val);
  }
};

export function buildLandingPageFormData(values: LandingFormValues): FormData {
  const fd = new FormData();

  // Hero Section
  appendString(fd, "heroSection_title", values.heroSection_title);
  appendString(fd, "heroSection_description", values.heroSection_description);
  
  // Highlighted text array
  values.heroSection_highlightedText?.forEach((item, idx) => {
    if (item.value?.trim()) {
      fd.append(`heroSection_highlightedText_${idx}`, item.value);
    }
  });

  appendString(fd, "heroSection_video_url", values.heroSection_video_url);
  appendFile(fd, "heroBackgroundImage", values.heroBackgroundImage);
  appendBool(fd, "heroSection_isEnabled", values.heroSection_isEnabled);
  appendNumber(fd, "heroSection_order", values.heroSection_order);

  // Primary CTA array
  values.heroSection_primaryCTA?.forEach((cta, idx) => {
    appendString(fd, `heroSection_primaryCTA_${idx}_label`, cta.label);
    appendString(fd, `heroSection_primaryCTA_${idx}_link`, cta.link);
    appendNumber(fd, `heroSection_primaryCTA_${idx}_order`, cta.order);
    appendFile(fd, `heroPrimaryCTAImages_${idx}`, cta.image);
  });

  // Membership Section
  appendString(fd, "membershipSection_title", values.membershipSection_title);
  appendString(fd, "membershipSection_subTitle", values.membershipSection_subTitle);
  appendString(fd, "membershipSection_description", values.membershipSection_description);
  appendFile(fd, "membershipBackgroundImage", values.membershipBackgroundImage);
  appendBool(fd, "membershipSection_isEnabled", values.membershipSection_isEnabled);
  appendNumber(fd, "membershipSection_order", values.membershipSection_order);

  // Membership benefits array
  values.membershipSection_benefits?.forEach((benefit, idx) => {
    appendString(fd, `membershipSection_benefits_${idx}_title`, benefit.title);
    appendString(fd, `membershipSection_benefits_${idx}_description`, benefit.description);
    appendFile(fd, `membershipSection_benefits_${idx}_icon`, benefit.icon);
    appendNumber(fd, `membershipSection_benefits_${idx}_order`, benefit.order);
  });

  // How It Works Section
  appendString(fd, "howItWorksSection_title", values.howItWorksSection_title);
  appendString(fd, "howItWorksSection_subTitle", values.howItWorksSection_subTitle);
  appendNumber(fd, "howItWorksSection_stepsCount", values.howItWorksSection_stepsCount);
  appendBool(fd, "howItWorksSection_isEnabled", values.howItWorksSection_isEnabled);
  appendNumber(fd, "howItWorksSection_order", values.howItWorksSection_order);

  // How It Works steps array - only send steps with data
  values.howItWorksSection_steps?.forEach((step, idx) => {
    if (step.title || step.description) {
      appendString(fd, `howItWorksSection_steps_${idx}_title`, step.title);
      appendString(fd, `howItWorksSection_steps_${idx}_description`, step.description);
      appendNumber(fd, `howItWorksSection_steps_${idx}_order`, step.order);
      appendFile(fd, `howItWorksStepImages_${idx}`, step.image);
    }
  });

  // Product Category Section
  appendString(fd, "productCategorySection_title", values.productCategorySection_title);
  appendString(fd, "productCategorySection_subTitle", values.productCategorySection_subTitle);
  appendString(fd, "productCategorySection_description", values.productCategorySection_description);
  appendBool(fd, "productCategorySection_isEnabled", values.productCategorySection_isEnabled);
  appendNumber(fd, "productCategorySection_order", values.productCategorySection_order);

  // Product Category IDs array
  values.productCategorySection_categories?.forEach((cat, idx) => {
    if (cat._id) {
      fd.append(`productCategorySection_productCategoryIds_${idx}`, cat._id);
    }
  });

  // Community Section
  appendString(fd, "communitySection_title", values.communitySection_title);
  appendString(fd, "communitySection_subTitle", values.communitySection_subTitle);
  appendBool(fd, "communitySection_isEnabled", values.communitySection_isEnabled);
  appendNumber(fd, "communitySection_order", values.communitySection_order);
  appendFile(fd, "communityBackgroundImage", values.communityBackgroundImage);

  // Community metrics array
  values.communitySection_metrics?.forEach((metric, idx) => {
    appendString(fd, `communitySection_metrics_${idx}_label`, metric.label);
    const valueStr = metric.value != null ? String(metric.value) : "";
    appendString(fd, `communitySection_metrics_${idx}_value`, valueStr);
    appendNumber(fd, `communitySection_metrics_${idx}_order`, metric.order);
  });

  // Features Section
  appendString(fd, "featuresSection_title", values.featuresSection_title);
  appendString(fd, "featuresSection_subTitle", values.featuresSection_subTitle);
  appendString(fd, "featuresSection_description", values.featuresSection_description);
  appendBool(fd, "featuresSection_isEnabled", values.featuresSection_isEnabled);
  appendNumber(fd, "featuresSection_order", values.featuresSection_order);

  // Features array - send all features that have data
  values.featuresSection_features?.forEach((feature, idx) => {
    if (feature.title || feature.description) {
      appendString(fd, `featuresSection_features_${idx}_title`, feature.title);
      appendString(fd, `featuresSection_features_${idx}_description`, feature.description);
      appendNumber(fd, `featuresSection_features_${idx}_order`, feature.order);
      appendFile(fd, `featureIcons_${idx}`, feature.icon);
    }
  });

  // Designed by Science Section
  appendString(fd, "designedByScienceSection_title", values.designedByScienceSection_title);
  appendString(fd, "designedByScienceSection_description", values.designedByScienceSection_description);
  appendBool(fd, "designedByScienceSection_isEnabled", values.designedByScienceSection_isEnabled);
  appendNumber(fd, "designedByScienceSection_order", values.designedByScienceSection_order);

  // Designed by Science steps array - send all steps that have data
  values.designedByScienceSection_steps?.forEach((step, idx) => {
    if (step.title || step.description) {
      appendString(fd, `designedByScienceSection_steps_${idx}_title`, step.title);
      appendString(fd, `designedByScienceSection_steps_${idx}_description`, step.description);
      appendNumber(fd, `designedByScienceSection_steps_${idx}_order`, step.order);
      appendFile(fd, `designedByScienceStepImages_${idx}`, step.image);
    }
  });

  // Testimonials Section
  appendString(fd, "testimonialsSection_title", values.testimonialsSection_title);
  appendString(fd, "testimonialsSection_subTitle", values.testimonialsSection_subTitle);
  appendBool(fd, "testimonialsSection_isEnabled", values.testimonialsSection_isEnabled);
  appendNumber(fd, "testimonialsSection_order", values.testimonialsSection_order);

  // Blog Section
  appendString(fd, "blogSection_title", values.blogSection_title);
  appendString(fd, "blogSection_description", values.blogSection_description);
  appendBool(fd, "blogSection_isEnabled", values.blogSection_isEnabled);
  appendNumber(fd, "blogSection_order", values.blogSection_order);

  // FAQ Section
  appendString(fd, "faqSection_title", values.faqSection_title);
  appendString(fd, "faqSection_description", values.faqSection_description);
  appendBool(fd, "faqSection_isEnabled", values.faqSection_isEnabled);
  appendNumber(fd, "faqSection_order", values.faqSection_order);

  // Overall
  appendBool(fd, "isActive", values.isActive);

  return fd;
}
