import type { ComponentType } from "react";
import { ROUTES } from "@/constants/routes";
import {
  RiLayoutFill,
  RiLayoutLeft2Fill,
  RiLayoutLeft2Line,
  RiLayoutMasonryFill,
  RiPagesFill,
  RiPagesLine,
  RiCoupon3Line,
  RiCoupon3Fill,
} from "react-icons/ri";
import { LuLayoutDashboard } from "react-icons/lu";
import { BiLayout } from "react-icons/bi";
import { FaRegUser, FaUserAlt } from "react-icons/fa";
import {
  MdGroups,
  MdOutlineGroups,
  MdOutlinePages,
  MdPages,
} from "react-icons/md";
import { PiBowlFoodFill, PiBowlFoodLight } from "react-icons/pi";
import { TbClock, TbClockFilled } from "react-icons/tb";
import { AiOutlineCreditCard, AiFillCreditCard } from "react-icons/ai";
import {
  IoCart,
  IoCartOutline,
  IoSettingsOutline,
  IoSettingsSharp,
} from "react-icons/io5";
import { IoMdPricetag } from "react-icons/io";
import { AiOutlineTag } from "react-icons/ai";
import { RiDiscountPercentFill, RiDiscountPercentLine } from "react-icons/ri";

export type SidebarIcon = ComponentType<{ className?: string }>;

export type SidebarItemBase = {
  key: string;
  label: string;
  path: string;
  parent?: string;
};

type BaseItem = {
  key: string;
  label: string;
  parent?: string;
};

export type SidebarChildItem = BaseItem & {
  path: string;
  icon?: never;
  lightIcon?: never;
};

export type SidebarParentItem =
  | (BaseItem & {
      icon: SidebarIcon;
      lightIcon: SidebarIcon;
      path: string;
      children?: never;
    })
  | (BaseItem & {
      icon: SidebarIcon;
      lightIcon: SidebarIcon;
      children: SidebarChildItem[];
      path?: never;
    });

export const SIDEBAR_ITEMS: SidebarParentItem[] = [
  {
    key: "dashboard",
    label: "Admin Dashboard",
    path: ROUTES.DASHBOARD,
    icon: RiLayoutMasonryFill,
    lightIcon: LuLayoutDashboard,
  },
  {
    key: "user-management",
    label: "User Management",
    path: ROUTES.USER_MANAGEMENT,
    icon: FaUserAlt,
    lightIcon: FaRegUser,
  },
  {
    key: "coupon-management",
    label: "Coupon Management",
    path: ROUTES.COUPON_MANAGEMENT.BASE,
    icon: RiCoupon3Fill,
    lightIcon: RiCoupon3Line,
  },
  {
    key: "blog-management",
    label: "Blog Management",
    icon: RiLayoutFill,
    lightIcon: BiLayout,
    children: [
      {
        key: "blog-management.blog",
        label: "Blog",
        path: ROUTES.BLOG.BLOG,
        parent: "blog-management",
      },
      {
        key: "blog-management.blog-category",
        label: "Category",
        path: ROUTES.BLOG.BLOG_CATEGORY,
        parent: "blog-management",
      },
      {
        key: "blog-management.blog-cms",
        label: "Blog CMS",
        path: ROUTES.BLOG.BLOG_CMS,
        parent: "blog-management",
      },
    ],
  },
  {
    key: "cms-management",
    label: "CMS Management",
    icon: RiLayoutLeft2Fill,
    lightIcon: RiLayoutLeft2Line,
    children: [
      {
        key: "cms-management.faqs",
        label: "FAQs",
        path: ROUTES.CMS_MANAGEMENT.FAQS,
        parent: "cms-management",
      },
      {
        key: "cms-management.testimonials",
        label: "Testimonials",
        path: ROUTES.CMS_MANAGEMENT.TESTIMONIALS,
        parent: "cms-management",
      },
      {
        key: "cms-management.our-team",
        label: "Our Team",
        path: ROUTES.OUR_TEAM,
        parent: "cms-management",
      },
    ],
  },
  {
    key: "all-pages",
    label: "All Pages",
    path: ROUTES.ALL_PAGES,
    icon: RiPagesFill as unknown as SidebarIcon,
    lightIcon: RiPagesLine as unknown as SidebarIcon,
  },
  {
    key: "product-management",
    label: "Product Management",
    icon: IoMdPricetag,
    lightIcon: AiOutlineTag,
    children: [
      {
        key: "product-management.product",
        label: "Product",
        path: ROUTES.PRODUCT_MANAGEMENT.PRODUCT,
        parent: "product-management",
      },
      {
        key: "product-management.testimonials",
        label: "Category",
        path: ROUTES.PRODUCT_MANAGEMENT.CATEGORY,
        parent: "product-management",
      },
      {
        key: "product-management.ingredients-management",
        label: "Ingredients Management",
        path: ROUTES.INGREDIENTS_MANAGMENT.BASE,
        parent: "product-management",
      },
    ],
  },
  // {
  //   key: "landing-page",
  //   label: "Landing Page",
  //   path: ROUTES.LANDING_PAGE,
  //   icon: MdPages as unknown as SidebarIcon,
  //   lightIcon: MdOutlinePages as unknown as SidebarIcon,
  // },
  {
    key: "membership-plans",
    label: "Membership Plans",
    path: ROUTES.MEMBERSHIP_PLANS,
    icon: AiFillCreditCard as unknown as SidebarIcon,
    lightIcon: AiOutlineCreditCard as unknown as SidebarIcon,
  },
  // {
  //   key: "membership",
  //   label: "Membership",
  //   path: ROUTES.MEMBERSHIP,
  //   icon: AiFillCreditCard as unknown as SidebarIcon,
  //   lightIcon: AiOutlineCreditCard as unknown as SidebarIcon,
  // },

  {
    key: "order-management",
    label: "Order Management",
    path: ROUTES.ORDER_MANAGMENT,
    icon: IoCart,
    lightIcon: IoCartOutline,
  },
  {
    key: "subscription-management",
    label: "Subscription Management",
    path: ROUTES.SUBSCRIPTION_MANAGEMENT,
    icon: AiFillCreditCard as unknown as SidebarIcon,
    lightIcon: AiOutlineCreditCard as unknown as SidebarIcon,
  },
  {
    key: "delivery-postponement",
    label: "Delivery Postponement",
    path: ROUTES.DELIVERY_POSTPONEMENT,
    icon: TbClockFilled as unknown as SidebarIcon,
    lightIcon: TbClock as unknown as SidebarIcon,
  },
  {
    key: "offer-banners",
    label: "Offer Banners",
    path: ROUTES.HEADER_BANNERS,
    icon: RiDiscountPercentFill as unknown as SidebarIcon,
    lightIcon: RiDiscountPercentLine as unknown as SidebarIcon,
  },
  {
    key: "general-settings",
    label: "General Settings",
    path: ROUTES.GENERAL_SETTINGS,
    icon: IoSettingsSharp as unknown as SidebarIcon,
    lightIcon: IoSettingsOutline as unknown as SidebarIcon,
  },
];
