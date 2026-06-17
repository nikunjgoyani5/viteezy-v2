"use client";

import React, { useMemo } from "react";
import Header from "../header";
import Footer from "../footer";
import PageContentWrapper from "../ui/pageContentWrapper";
import SimpleHeader from "../header/SimpleHeader";
import { useGetHeaderBannerQuery, headerBannerApi } from "@/store/api/headerBannerApi";
import { useTranslations, useLocale } from "next-intl";
import { useAppSelector } from "@/store";

const MainLayout = ({
  children,
  isFooter = true,
  headerClassName = "",
  simpleHeader = false,
}: {
  children: React.ReactNode;
  isFooter?: boolean;
  headerClassName?: string;
  simpleHeader?: boolean;
}) => {
  const translate = useTranslations("Header");
  const locale = useLocale();
  const bannerParams = useMemo(
    () => ({ deviceType: "WEB" as const, lang: locale }),
    [locale]
  );

  const headerBannerFromHeader = useAppSelector((state) =>
    headerBannerApi.endpoints.getHeaderBanner.select(bannerParams)(state)
  );

  const { data: headerBannerFromLayout } = useGetHeaderBannerQuery(
    bannerParams,
    { skip: !simpleHeader }
  );

  const headerBannerData = simpleHeader
    ? headerBannerFromLayout
    : headerBannerFromHeader.data;
  
  const headerBanner = headerBannerData?.data?.headerBanner;
  const showHeaderBanner = Boolean(
    headerBanner?.isActive && headerBanner?.text?.trim()
  );
  
  const topOfferText = showHeaderBanner
    ? headerBanner!.text
    : translate("topBanner");
    
  const shouldShowBanner = showHeaderBanner || topOfferText !== translate("topBanner");
  
  // Dynamic padding based on banner visibility
  const contentPadding = shouldShowBanner 
    ? "pt-[124px] lg:pt-[124px] 3xl:pt-[133px]" 
    : "pt-[80px] lg:pt-[80px] 3xl:pt-[88px]";

  return (
    <>
      {simpleHeader ? <SimpleHeader className={headerClassName} /> : <Header className={headerClassName} />}
      <div className={contentPadding}>
        <PageContentWrapper>
          <main>{children}</main>
        </PageContentWrapper>
        {isFooter && <Footer />}
      </div>
    </>
  );
};

export default MainLayout;
