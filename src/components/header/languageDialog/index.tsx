"use client";

import React, { memo, useEffect, useMemo, useState } from "react";
import Image from "next/image";
import PortalDialog from "@/components/ui/portalDialog";
import { Button } from "@/components/ui/button";
import SelectField from "@/components/ui/select";
import { useLocale } from "next-intl";
import { useTranslations } from "next-intl";

import {
  countries,
  languages as fallbackLanguages,
} from "@/components/constants/countries";
import { useGeneralSettings } from "@/hooks/useGeneralSettings";
import { getUserCountry, setUserCountry } from "@/lib/services/country";
import { useLanguageSwitcher } from "@/hooks/useLanguageSwitcher";
import { useUpdateUserLanguageMutation } from "@/store/api/userApi";
import LanguageFlagIcon from "@/components/ui/LanguageFlagIcon";

const LanguageDialog = () => {
  const locale = useLocale();
  const t = useTranslations("Common");
  const tCountries = useTranslations("Countries");
  const { enabledLanguages } = useGeneralSettings(locale);
  const languages = useMemo(
    () => (enabledLanguages.length > 0 ? enabledLanguages : fallbackLanguages),
    [enabledLanguages]
  );

  /** Modal state */
  const [isOpen, setIsOpen] = useState(false);

  /** Draft selections (applied only on Confirm) */
  const [selectedLang, setSelectedLang] = useState(locale);
  const [selectedCountry, setSelectedCountry] = useState("in");

  const { changeLanguage } = useLanguageSwitcher();
  const [updateUserLanguage] = useUpdateUserLanguageMutation();

  /** Update selected language when localStorage changes (for cross-tab sync) */
  useEffect(() => {
    const handleStorageChange = (e: StorageEvent) => {
      if (e.key === "lang" && e.newValue) {
        const newLang = e.newValue;
        if (languages.find(lang => lang.code === newLang)) {
          setSelectedLang(newLang);
        }
      }
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, [languages]);

  /** Load saved country */
  useEffect(() => {
    const fetchCountry = async () => {
      const country = await getUserCountry();
      setSelectedCountry(country || "in");
    };
    fetchCountry();
  }, []);

  /** Handlers */
  const handleOpen = () => {
    setSelectedLang(locale);
    setIsOpen(true);
  };
  const handleClose = () => setIsOpen(false);

  const handleLangChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedLang(e.target.value);
  };

  const handleCountryChange = (e: React.ChangeEvent<HTMLSelectElement>) => {
    setSelectedCountry(e.target.value);
  };

  const onConfirm = async () => {
    try {
      // Get selected language details
      const selectedLanguage = languages.find(
        (lang) => lang.code === selectedLang
      );

      if (selectedLanguage) {
        // Store in localStorage
        localStorage.setItem("language", selectedLanguage.name);
        localStorage.setItem("lang", selectedLanguage.code);

        // Update user language in API (only send language name)
        try {
          await updateUserLanguage({
            language: selectedLanguage.name,
          }).unwrap();
          console.log("Language updated successfully");
        } catch (error) {
          // Continue even if API call fails (user might not be logged in)
          console.log("Language API update:", error);
        }

        // Update language if changed
        if (selectedLang !== locale) {
          await changeLanguage(selectedLang);
        }
      }

      // Update country
      await setUserCountry(selectedCountry);

      // Close dialog
      handleClose();
    } catch (error) {
      console.error("Error updating language:", error);
    }
  };

  /** Current language display */
  const currentLangCode = useMemo(() => {
    return locale;
  }, [locale]);

  const currentLang = useMemo(() => {
    return languages.find((lang) => lang.code === currentLangCode) ?? languages[0];
  }, [currentLangCode, languages]);

  /** Force re-render when localStorage changes */
  const [, forceUpdate] = useState({});
  useEffect(() => {
    const handleStorageChange = () => {
      forceUpdate({});
    };

    window.addEventListener("storage", handleStorageChange);
    return () => window.removeEventListener("storage", handleStorageChange);
  }, []);

  return (
    <div>
      {/* Trigger */}
      <div
        onClick={handleOpen}
        className="flex items-center gap-1.5 p-2 px-2.5 rounded-full
                   hover:bg-white transition-colors duration-300 cursor-pointer"
      >
        <LanguageFlagIcon langCode={currentLang.code} size={24} />
        <span className="text-base font-semibold text-gray-700 hidden sm:inline">
          {currentLang.label}
        </span>
      </div>

      {/* Dialog */}
      <PortalDialog
        width={800}
        isShow={isOpen}
        onClose={handleClose}
        bodyClass="p-0 overflow- bg-off-white-color p-3.5 lg:p-1.5"
        contentClass="m-0"
        closeButtonClass="m-6 md:m-2"
        transitionDuration={800}
      >
        <div className="grid grid-cols-1 md:grid-cols-2">
          {/* Image */}
          <div>
            <Image
              width={400}
              height={400}
              src="/bannerImg1.png"
              alt={t("selectLanguageAndCountry")}
              // className="w-full h-75 md:h-full object-cover rounded-lg"
              className="w-full h-75 md:h-90 object-cover rounded-lg"
            />
          </div>

          {/* Content */}
          <div className="py-2 md:py-12 px-0 md:px-7.5">
            <h3 className="text-xl md:text-2xl font-medium mb-4 md:mb-8">
              {t("selectLanguageAndCountry")}
            </h3>

            {/* Language */}
            <div>
              <label className="block mb-2 font-medium text-sm md:text-base">
                {t("language")}
              </label>
              <SelectField
                className="font-medium"
                value={selectedLang}
                onChange={handleLangChange}
              >
                {languages.map((lang) => (
                  <option key={lang.code} value={lang.code}>
                    {lang.label}
                  </option>
                ))}
              </SelectField>
            </div>

            {/* Country - Commented out */}
            {/* <div>
              <label className="block mb-2 mt-4 sm:mt-5 font-medium text-sm md:text-base">
                {t("shippingCountry")}
              </label>
              <SelectField
                className="font-medium"
                value={selectedCountry}
                onChange={handleCountryChange}
              >
                {countries.map((country) => (
                  <option key={country.code} value={country.code}>
                    {country.flag} &nbsp;&nbsp; {tCountries(country.code)}
                  </option>
                ))}
              </SelectField>
            </div> */}

            {/* Confirm */}
            <Button
              className="w-full mt-4 sm:mt-6 md:mt-8 h-12"
              animateText
              size="elevate"
              variant="elevate"
              type="button"
              onClick={onConfirm}
            >
              {t("confirm")}
            </Button>
          </div>
        </div>
      </PortalDialog>
    </div>
  );
};

export default memo(LanguageDialog);
