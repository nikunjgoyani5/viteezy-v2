export type LandingPageApiResponse = {
  _id: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
  heroSection: {
    videoUrl: string;
    backgroundImage: string;
    title: string;
    highlightedText: string[];
    subTitle: string;
    description: string;
    primaryCTA: Array<{
      label: string;
      image: string;
      link: string;
      order: number;
    }>;
    isEnabled: boolean;
    order: number;
  };
  membershipSection: {
    backgroundImage: string;
    title: string;
    description: string;
    benefits: Array<{
      icon: string;
      title: string;
      description: string;
      order: number;
    }>;
    isEnabled: boolean;
    order: number;
  };
  howItWorksSection: {
    title: string;
    subTitle: string;
    stepsCount: number;
    steps: Array<{
      image: string;
      title: string;
      description: string;
      order: number;
    }>;
    isEnabled: boolean;
    order: number;
  };
  productCategorySection: {
    title: string;
    description: string;
    productCategories: Array<{
      _id: string;
      name: string;
      slug: string;
      description?: string;
      icon: string | null;
      image: {
        type: string;
        url: string;
        sortOrder: number;
      } | null;
    }>;
    isEnabled: boolean;
    order: number;
  };
  communitySection: {
    backgroundImage: string;
    title: string;
    subTitle: string;
    metrics: Array<{
      label: string;
      value: string | number | null;
      order: number;
    }>;
    isEnabled: boolean;
    order: number;
  };
  featuresSection: {
    title: string;
    description: string;
    features: Array<{
      icon: string;
      title: string;
      description: string;
      order: number;
    }>;
    isEnabled: boolean;
    order: number;
  };
  designedByScienceSection: {
    title: string;
    description: string;
    steps: Array<{
      image: string;
      title: string;
      description: string;
      order: number;
    }>;
    isEnabled: boolean;
    order: number;
  };
  testimonialsSection: {
    title: string;
    subTitle: string;
    testimonials: unknown[];
    isEnabled: boolean;
    order: number;
  };
  blogSection: {
    title: string;
    description: string;
    blogs: unknown[];
    isEnabled: boolean;
    order: number;
  };
  faqSection: {
    title: string;
    description: string;
    faqs: unknown[];
    isEnabled: boolean;
    order: number;
  };
};

export type GetLandingPagesResponse = {
  success: boolean;
  message: string;
  data: LandingPageApiResponse[];
};
