"use client";

import type { ComponentType } from "react";
import { AiFillDollarCircle, AiOutlineDollar } from "react-icons/ai";
import { HiTag, HiOutlineTag, HiPresentationChartBar, HiOutlinePresentationChartBar } from "react-icons/hi";
import { IoDocumentText, IoDocumentTextOutline } from "react-icons/io5";
import { PiBowlFoodFill, PiBowlFood, PiBookBookmarkFill, PiBookBookmarkLight } from "react-icons/pi";
import { BiSolidLeaf, BiSolidAddToQueue } from "react-icons/bi";
import { TbLeaf } from "react-icons/tb";
import { MdOutlineAddToPhotos } from "react-icons/md";
import { RiFileSettingsFill, RiFileSettingsLine, RiQuestionnaireFill, RiQuestionnaireLine } from "react-icons/ri";
import { LuScale } from "react-icons/lu";
import { FaScaleBalanced } from "react-icons/fa6";

export type ProductDetailsSectionId =
  | "price"
  | "details"
  | "membership"
  | "benefits"
  | "ingredients"
  | "nutrition"
  | "howToUse"
  | "similarProducts"
  | "specification"
  | "featureComparison"
  | "faqs";

export type ProductSectionItem = {
  id: ProductDetailsSectionId;
  label: string;
  iconFill: ComponentType<{ className?: string }>;
  iconOutline: ComponentType<{ className?: string }>;
  fields: string[];
};

export const PRODUCT_DETAILS_SECTIONS: ProductSectionItem[] = [
  {
    id: "price",
    label: "Price",
    iconFill: AiFillDollarCircle,
    iconOutline: AiOutlineDollar,
    fields: ["sachetPrices", "standupPouchPrice"],
  },
  {
    id: "details",
    label: "Product Details",
    iconFill: IoDocumentText,
    iconOutline: IoDocumentTextOutline,
    fields: ["description"],
  },
  // {
  //   id: "membership",
  //   label: "Membership Discounts",
  //   iconFill: HiTag,
  //   iconOutline: HiOutlineTag,
  //   fields: [],
  // },
  {
    id: "benefits",
    label: "Benefits",
    iconFill: HiPresentationChartBar,
    iconOutline: HiOutlinePresentationChartBar,
    fields: ["benefits"],
  },
  {
    id: "ingredients",
    label: "Ingredients",
    iconFill: PiBowlFoodFill,
    iconOutline: PiBowlFood,
    fields: ["ingredientMeta", "ingredientCompositions"],
  },
  {
    id: "nutrition",
    label: "Nutrition Info",
    iconFill: BiSolidLeaf,
    iconOutline: TbLeaf,
    fields: ["nutritionInfo"],
  },
  {
    id: "howToUse",
    label: "How to Use",
    iconFill: PiBookBookmarkFill,
    iconOutline: PiBookBookmarkLight,
    fields: ["howToUse"],
  },
  // {
  //   id: "similarProducts",
  //   label: "Similar Products",
  //   iconFill: BiSolidAddToQueue,
  //   iconOutline: MdOutlineAddToPhotos,
  //   fields: ["similarProducts"],
  // },
  {
    id: "specification",
    label: "Specification",
    iconFill: RiFileSettingsFill,
    iconOutline: RiFileSettingsLine,
    fields: [
      "specificationMainTitle",
      "specificationBgImage",
      ...Array.from({ length: 4 }, (_, i) => [
        `specificationTitle${i + 1}`,
        `specificationDescr${i + 1}`,
        `specificationItemImage${i + 1}`,
        `specificationItemImagemobile${i + 1}`,
      ]).flat(),
    ],
  },
  {
    id: "featureComparison",
    label: "Feature Comparison",
    iconFill: LuScale,
    iconOutline: FaScaleBalanced,
    fields: ["comparisonSection.title", "comparisonSection.rows"],
  },
  {
    id: "faqs",
    label: "FAQs",
    iconFill: RiQuestionnaireFill,
    iconOutline: RiQuestionnaireLine,
    fields: ["faqs"],
  },
];
