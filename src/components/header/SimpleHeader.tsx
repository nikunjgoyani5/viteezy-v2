"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { ShoppingCart } from "lucide-react";
import { useCartSidebar } from "@/lib/cartSidebar";
import { useTranslations, useLocale } from "next-intl";
import LogoAnimation from "@/components/ui/logoAnimation";
import Image from "next/image";
import { useGeneralSettings } from "@/hooks/useGeneralSettings";
import { FixedPortal, cn } from "@/lib/utils";
import { useLazyGetCartQuery } from "@/store/api/cartApi";
import { useGetHeaderBannerQuery } from "@/store/api/headerBannerApi";
import { Marquee } from "@/components/ui/marquee";

const SimpleHeader = ({ className }: { className?: string }) => {
  const translate = useTranslations("Header");
  const locale = useLocale();
  const [cartCount, setCartCount] = useState(0);
  const pathname = usePathname();
  const { openCart } = useCartSidebar();
  const [triggerGetCart] = useLazyGetCartQuery();
  const { data: generalSettings } = useGeneralSettings("en");

  // Header banner logic
  const { data: headerBannerData } = useGetHeaderBannerQuery(
    { deviceType: "WEB", lang: locale },
    { skip: false }
  );
  const headerBanner = headerBannerData?.data?.headerBanner;
  const showHeaderBanner = Boolean(
    headerBanner?.isActive && headerBanner?.text?.trim()
  );
  const topOfferText = showHeaderBanner
    ? headerBanner!.text
    : translate("topBanner");
  const shouldShowBanner =
    showHeaderBanner || topOfferText !== translate("topBanner");

  // Fetch cart data and calculate total items count
  useEffect(() => {
    const fetchCartCount = async () => {
      try {
        const res = await triggerGetCart().unwrap();
        const cart = res?.data?.cart;
        const items = cart?.items.length ?? [];

        setCartCount(items);
      } catch (error) {
        // If error, set count to 0
        setCartCount(0);
      }
    };

    fetchCartCount();
  }, [pathname, triggerGetCart]);

  return (
    <FixedPortal>
      <div className="fixed top-0 z-10 left-0 w-full">
        <div data-aos="fade-down" className="relative z-20">
          {/* Top Banner - conditional rendering */}
          {shouldShowBanner && (
            <div className="">
              <Marquee
                className="bg-[linear-gradient(90deg,_#ECD2BC_0%,_#B8E2D0_30%,_#C6E2F1_70%,_#B5E5AD_100%)] text-sm font-semibold text-gray-800 3xl:text-[15px] [--duration:12s] h-auto min-h-[32px] flex items-center"
                repeat={18}
                pauseOnHover
              >
                <div className="flex items-center gap-8 px-6 py-1">
                  <span
                    className="whitespace-nowrap"
                    dangerouslySetInnerHTML={{ __html: topOfferText }}
                  />
                </div>
              </Marquee>
            </div>
          )}

          <header
            className={cn("bg-off-white-color relative", className)}
          >
            <div className="w-full relative">
              <div className="max-w-3xl lg:max-w-[1220px] mx-auto px-4 py-2">
                <div className="flex items-center justify-between min-h-[64px] 3xl:min-h-[72px]">
                  {/* Center Section - Logo (20% width, min 250px) */}
                  <div className="flex justify-center items-center">
                    <Link
                      href="/"
                      className="flex items-center justify-center w-full"
                    >
                      {generalSettings?.logoLight ? (
                        <Image
                          src={generalSettings.logoLight}
                          alt={translate("viteezyLogo")}
                          width={160}
                          height={40}
                          className="max-w-fit h-auto max-h-[7vw] sm:max-h-12 sm:max-w-auto"
                        />
                      ) : (
                        <LogoAnimation className="max-w-fit h-auto max-h-[7vw] sm:max-h-12 sm:max-w-auto" />
                      )}
                    </Link>
                  </div>

                  {/* Right Section - 40% width */}
                  <div className="flex items-center justify-end sm:space-x-1 xl:space-x-1.5 min-w-0">
                    {/* Cart - Hidden on checkout page */}
                    {!pathname?.includes("/checkout") && (
                      <button
                        onClick={openCart}
                        className="relative p-2 rounded-full cursor-pointer hover:bg-white transition-colors duration-300 flex-shrink-0"
                        aria-label={translate("shoppingCart")}
                      >
                        <ShoppingCart className="h-5 w-5 text-gray-600" />
                        {/* Cart Badge */}
                        {cartCount > 0 && (
                          <span className="absolute -top-1 -right-1 h-4 w-4 bg-teal-500 text-white rounded-full flex items-center justify-center text-xs font-semibold">
                            {cartCount}
                          </span>
                        )}
                      </button>
                    )}
                  </div>
                </div>
              </div>
            </div>
          </header>
        </div>
      </div>
    </FixedPortal>
  );
};

export default SimpleHeader;
