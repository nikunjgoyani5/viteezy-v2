"use client";

import React, { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { ChevronDown } from "lucide-react";
import { X } from "../icons";
import Backdrop from "../ui/backdrop";
import { useCartSidebar } from "@/lib/cartSidebar";
import { useGetPopularBlogsQuery } from "@/store/api/blogApi";
import SideMenuBlogSlider from "./SideMenuBlogSlider";
import { getUserFromStorage } from "@/lib/utils";
import { useLogout } from "@/hooks/useLogout";
import { useLocale } from "next-intl";
import { languages as fallbackLanguages } from "../constants/countries";
import { useGeneralSettings } from "@/hooks/useGeneralSettings";
import { useLanguageSwitcher } from "@/hooks/useLanguageSwitcher";
import { useUpdateUserLanguageMutation } from "@/store/api/userApi";
import { useGetCategoriesWithProductsQuery } from "@/store/api/productApi";
import LanguageFlagIcon from "@/components/ui/LanguageFlagIcon";
import { useTranslations } from "next-intl";
import { Spinner } from "../ui";

const ACCORDION_DURATION = 1000;

const SideMenu = ({ isOpen, onClose, navigationItems = [] }: any) => {
  const [openAccordion, setOpenAccordion] = useState<string | null>(null);
  const [closingItem, setClosingItem] = useState<string | null>(null);
  const [isLanguageLoading, setIsLanguageLoading] = useState(false);

  const { openCart } = useCartSidebar();
  const { data: blogData } = useGetPopularBlogsQuery();
  const blogs = blogData?.data?.blogs ?? [];

  const isLoggedIn = useMemo(() => {
    return Boolean(getUserFromStorage()?._id);
  }, []);

  const { logout, isLoggingOut } = useLogout();
  const { language, changeLanguage } = useLanguageSwitcher(onClose);
  const tHeader = useTranslations("Header");
  const t = useTranslations("Common");
  const [updateUserLanguage] = useUpdateUserLanguageMutation();

  const locale = useLocale();
  const { enabledLanguages } = useGeneralSettings(locale);

  const languages = useMemo(
    () => (enabledLanguages.length > 0 ? enabledLanguages : fallbackLanguages),
    [enabledLanguages]
  );

  /** Re-render on in-app language change event */
  const [, forceUpdate] = useState({});
  useEffect(() => {
    const handleStorageChange = () => {
      forceUpdate({});
    };
    const handleLanguageChange = () => {
      forceUpdate({});
    };

    window.addEventListener("storage", handleStorageChange);
    window.addEventListener("app-language-changed", handleLanguageChange);
    return () => {
      window.removeEventListener("storage", handleStorageChange);
      window.removeEventListener("app-language-changed", handleLanguageChange);
    };
  }, []);

  /** Use active locale as source of truth for display */
  const currentLanguage = useMemo(() => {
    return (
      languages.find((lang) => lang.code === locale) ||
      languages.find((lang) => lang.code === language) ||
      languages[0]
    );
  }, [language, locale, languages]);

  const { data: categoriesData, isLoading: categoriesLoading } =
    useGetCategoriesWithProductsQuery({ lang: locale }, { skip: !isOpen });

  const dynamicCategories = useMemo(() => {
    return (
      categoriesData?.data?.categories
        ?.filter((cat: any) => cat.products && cat.products.length > 0)
        ?.sort((a: any, b: any) => b.products.length - a.products.length)
        ?.slice(0, 5)
        ?.map((cat: any) => ({
          title: cat.name,
          slug: cat.slug,
        })) ?? []
    );
  }, [categoriesData]);

  const defaultMenuItems = [
    { label: t("quiz"), href: "/quiz", badge: t("BadgeNew") },
    { label: t("consult"), href: "/consult" },
    { label: t("ShopAll"), href: "/shop" },
    { label: t("membership"), href: "/membership" },
    { label: "Learn", href: "/learn" },
    { label: t("charity"), href: "/coming-soon" },
  ];

  const mainMenuItems =
    navigationItems.length > 0 ? navigationItems : defaultMenuItems;

  const bottomMenuItems = [
    { label: t("cart"), href: "/cart", isCartAction: true },
    ...(isLoggedIn
      ? [
          { label: t("account"), href: "/account" },
          { label: tHeader("Settings"), href: "/settings" },
          { label: t("contactUs"), href: "/contactUs" },
          { label: "logOut", isLogout: true },
        ]
      : [
          { label: tHeader("LogIn"), href: "/login" },
          { label: t("contactUs"), href: "/contactUs" },
        ]),
  ];

  const handleAccordion = (label: string) => {
    if (openAccordion === label) {
      setClosingItem(label);
      setOpenAccordion(null);

      setTimeout(() => {
        setClosingItem(null);
      }, ACCORDION_DURATION);
    } else {
      setOpenAccordion(label);
    }
  };

  const handleLogout = async () => {
    await logout();
    onClose();
  };

  const handleLangChange = async (e: React.ChangeEvent<HTMLSelectElement>) => {
    const newLang = e.target.value || "en";
    
    // Get selected language details
    const selectedLanguage = languages.find(
      (lang) => lang.code === newLang
    );

    if (selectedLanguage) {
      setIsLanguageLoading(true);
      
      try {
        // Store in localStorage (same as header)
        localStorage.setItem("language", selectedLanguage.name);
        localStorage.setItem("lang", selectedLanguage.code);

        // Update user language in API (same as header)
        try {
          await updateUserLanguage({
            language: selectedLanguage.name,
          }).unwrap();
          console.log("Language updated successfully");
        } catch (error) {
          // Continue even if API call fails (user might not be logged in)
          console.log("Language API update:", error);
        }

        // Update language using the hook (same as header)
        if (newLang !== locale) {
          await changeLanguage(newLang);
        }
      } catch (error) {
        console.error("Error changing language:", error);
      } finally {
        setIsLanguageLoading(false);
      }
    }
  };

  useEffect(() => {
    if (!isOpen) setOpenAccordion(null);
  }, [isOpen]);

  useEffect(() => {
    if (isOpen) document.body.style.overflow = "hidden";
    else document.body.style.overflow = "";

    return () => {
      document.body.style.overflow = "";
    };
  }, [isOpen]);

  return (
    <>
      <Backdrop
        isOpen={isOpen}
        onClose={onClose}
        zIndex={40}
        transitionDuration={700}
      />

      <div
        className={`fixed h-screen overscroll-auto top-0 left-0 w-screen sm:w-110 bg-teal-500 shadow-2xl transform transition-transform duration-700 ease-[cubic-bezier(0.4,0,0.2,1)] z-50 flex flex-col ${
          isOpen ? "translate-x-0" : "-translate-x-full"
        }`}
      >
        {/* Header */}
        <div className="flex items-center justify-end p-6 pb-0 flex-shrink-0">
          <button
            onClick={onClose}
            className="p-2 rounded-full hover:bg-white/20 transition-colors duration-200 cursor-pointer"
          >
            <X className="h-6 w-6 text-white" />
          </button>
        </div>

        <div className="flex-1 overflow-y-auto pb-3 min-h-0">
          <nav className="space-y-1 px-6">
            {mainMenuItems.map((item: any) => {
              const isShopAll =
                item.href === "/shop" || item.href === "/products";

              const shopCategories = isShopAll
                ? dynamicCategories
                : item.categories;

              const hasSubmenu = !!(
                shopCategories?.length ||
                item.subMenu?.length ||
                (isShopAll && categoriesLoading)
              );

              const isAccordionOpen = openAccordion === item.label;

              return (
                <div key={item.label} className="border-b border-white/30 pb-1">
                  {hasSubmenu ? (
                    <button
                      onClick={() => handleAccordion(item.label)}
                      className="w-full flex items-center gap-2 text-white text-lg font-medium group py-3 cursor-pointer"
                    >
                      <div className="relative flex items-center gap-3">
                        <span className="text-3xl lg:text-4xl">
                          {item.label}
                        </span>

                        {!isAccordionOpen && closingItem !== item.label && (
                          <span className="absolute left-0 -bottom-4 h-[2px] w-full bg-white scale-x-0 origin-left transition-transform duration-300 group-hover:scale-x-100"></span>
                        )}

                        {item.badge && (
                          <span className="bg-orange-100 text-black text-xs font-medium px-2.5 py-1 rounded-full">
                            {item.badge}
                          </span>
                        )}
                      </div>

                      <ChevronDown
                        className={`w-6.5 h-6.5 text-white transition-transform duration-700 ${
                          isAccordionOpen ? "rotate-180" : ""
                        }`}
                      />
                    </button>
                  ) : (
                    <Link
                      href={item.href}
                      onClick={onClose}
                      className="w-full flex items-center text-white text-lg font-medium group py-3"
                    >
                      <span className="text-3xl lg:text-4xl relative">
                        <span className="flex items-center gap-3">
                          {item.label}
                          {"badge" in item && item.badge && (
                            <span className="bg-orange-200 text-soft-orange-color text-[12px] 3xl:text-[13px] px-2.5 py-0.25 rounded-full font-semibold leading-loose">
                              {item.badge}
                            </span>
                          )}
                        </span>
                        <span className="absolute left-0 -bottom-4 h-[2px] w-full bg-white scale-x-0 origin-left transition-transform duration-300 group-hover:scale-x-100"></span>
                      </span>
                    </Link>
                  )}

                  {/* Accordion */}
                  {hasSubmenu && (
                    <div
                      className={`overflow-hidden transition-[max-height,opacity] duration-[700ms] ease-[cubic-bezier(0.4,0,0.2,1)] ${
                        isAccordionOpen
                          ? "max-h-[600px] opacity-100"
                          : "max-h-0 opacity-0"
                      }`}
                    >
                      <div className="pb-3">
                        {shopCategories?.map((category: any) => (
                          <Link
                            key={category.slug}
                            href={`/products?categories=${encodeURIComponent(
                              category.slug
                            )}`}
                            onClick={onClose}
                            className="block text-white py-1 text-lg lg:text-xl font-medium hover:text-white/80"
                          >
                            {category.title}
                          </Link>
                        ))}

                        {item.subMenu?.map((subItem: any) => (
                          <Link
                            key={subItem.slug}
                            href={`${subItem.slug}`}
                            onClick={onClose}
                            className="block text-white py-1 text-lg lg:text-xl font-medium hover:text-white/80"
                          >
                            {subItem.title}
                          </Link>
                        ))}
                      </div>
                    </div>
                  )}
                </div>
              );
            })}
          </nav>

          <div className="px-6">
            <hr className="border-white/30" />
          </div>

          {/* Bottom */}
          <div className="mt-6 space-y-2 px-6">
            <span className="block py-1 text-lg text-white/80 font-medium">
              {tHeader("meetViteezy")}
            </span>

            {bottomMenuItems.map((item: any) => {
              if (item.isCartAction) {
                return (
                  <button
                    key={item.label}
                    onClick={() => {
                      openCart();
                      onClose();
                    }}
                    className="block w-full text-left text-white text-lg font-medium cursor-pointer hover:text-white/80"
                  >
                    {item.label}
                  </button>
                );
              }

              if (item.isLogout) {
                return (
                  <button
                    key={item.label}
                    onClick={handleLogout}
                    disabled={isLoggingOut}
                    className="block w-full text-left text-white text-lg font-medium cursor-pointer hover:text-white/80"
                  >
                    {isLoggingOut ? t("logoutLoading") : t("logOut")}
                  </button>
                );
              }

              return (
                <Link
                  key={item.label}
                  href={item.href}
                  onClick={onClose}
                  className={`block text-white text-lg font-medium ${
                    item.href === "/account" ? "xl:hidden" : ""
                  }`}
                >
                  {item.label}
                </Link>
              );
            })}
          </div>

          <SideMenuBlogSlider blogs={blogs} onClose={onClose} />
        </div>

        {/* Language */}
        <div className="p-6 border-t border-teal-400/30 flex-shrink-0">
          <label className="block text-lg text-white/80 font-medium mb-3">
            {t("language")}
          </label>

          <div className="relative flex items-center gap-3">
            <span className="pointer-events-none absolute left-3 z-10">
              <LanguageFlagIcon langCode={currentLanguage.code} size={24} />
            </span>

            <select
              value={currentLanguage.code}
              onChange={handleLangChange}
              disabled={isLanguageLoading}
              className={`w-full bg-white pl-12 pr-10 py-3 rounded-lg appearance-none cursor-pointer ${
                isLanguageLoading ? 'opacity-60 cursor-not-allowed' : ''
              }`}
            >
              {languages.map((lang: any) => (
                <option key={lang.code} value={lang.code}>
                  {lang.label}
                </option>
              ))}
            </select>

            <span className="pointer-events-none absolute right-4 top-1/2 -translate-y-1/2 text-gray-600 flex gap-2 items-center">
              {isLanguageLoading && <Spinner size="xs" />}
              <ChevronDown className="w-6.5 h-6.5" />
            </span>
          </div>
        </div>
      </div>
    </>
  );
};

export default React.memo(SideMenu);
