"use client";

import Image from "next/image";
import Link from "next/link";
import { useEffect, useMemo, useRef, useState } from "react";
import { useRouter, useSearchParams, usePathname } from "next/navigation";
import {
  BlackStarIcon,
  DropdownDownArrow,
  HeartIcon,
  HeartIconFilled,
} from "../icons";
import { Button } from "../ui/button";
import { sortOptions } from "../constants";
import Banner from "../ui/banner";
import Pagination from "../pagination";
import FavoritePopup from "./productDetail/FavoritePopup";
import { useCartSidebar } from "@/lib/cartSidebar";
import { useWishlist } from "@/hooks";
import { hasAuthToken, getCurrencySymbol } from "@/lib/utils";
import {
  useGetCategoriesQuery,
  useGetProductsQuery,
  useAddCartItemMutation,
} from "@/store";
import { useTranslations } from "next-intl";
import { toast } from "react-hot-toast";
import AOS from "aos";
import { ScrollTrigger } from "gsap/ScrollTrigger";

const heroImageSrc = "/products/productHeroBanner.png";

// Local component: Wishlist heart toggle for product cards
function WishlistToggle({
  productId,
  initialIsLiked = false,
  className = "",
  onToggle,
}: {
  productId: string;
  initialIsLiked?: boolean;
  className?: string;
  onToggle?: (wasLiked: boolean, nowLiked: boolean) => void;
}) {
  const tProducts = useTranslations("Products");
  const { isLoading, toggleWithId } = useWishlist(undefined, false, initialIsLiked);
  const [liked, setLiked] = useState(initialIsLiked);

  useEffect(() => {
    setLiked(initialIsLiked);
  }, [initialIsLiked]);

  const handleClick: React.MouseEventHandler<HTMLButtonElement> = async (e) => {
    e.preventDefault();
    e.stopPropagation();
    const wasLiked = liked;

    try {
      setLiked((prev) => !prev);
      await toggleWithId(productId);
      onToggle?.(wasLiked, !wasLiked);
    } catch (err) {
      setLiked((prev) => !prev);
      console.error("Failed to toggle wishlist:", err);
    }
  };

  return (
    <button
      aria-label={
        liked ? tProducts("removeFromWishlist") : tProducts("addToWishlist")
      }
      onClick={handleClick}
      disabled={isLoading}
      className={`w-9 3xl:w-11 h-9 3xl:h-11 rounded-full flex items-center justify-center transition-all cursor-pointer ${className}`}
    >
      {liked ? <HeartIconFilled /> : <HeartIcon />}
    </button>
  );
}

export default function ProductsPage() {
  const t = useTranslations("Products");
  const tCommon = useTranslations("Common");
  const tCheckout = useTranslations("Checkout");

  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const [isCategoryDropdownOpen, setIsCategoryDropdownOpen] = useState(false);
  const [isSortDropdownOpen, setIsSortDropdownOpen] = useState(false);
  const [isFavoritePopupOpen, setIsFavoritePopupOpen] = useState(false);
  const [selectedFavoriteProduct, setSelectedFavoriteProduct] =
    useState<any>(null);

  const dropdownRef = useRef<HTMLDivElement>(null);
  const sortDropdownRef = useRef<HTMLDivElement>(null);
  const productsTopRef = useRef<HTMLDivElement>(null);

  const { openCart } = useCartSidebar();
  const { data } = useGetCategoriesQuery();
  // @ts-ignore
  const categories = data?.data?.categories || [];

  const productsPerPage = 16;

  // -------- URL as source of truth --------
  const urlState = useMemo(() => {
    const page = parseInt(searchParams.get("page") || "1", 10);
    const search = searchParams.get("search") || "";
    const sortBy = searchParams.get("sortBy") || "relevance";
    const categoriesParam = searchParams.get("categories") || "";

    const selectedCategories = categoriesParam
      ? categoriesParam.split(", ").filter(Boolean)
      : [];

    return {
      page: Number.isNaN(page) ? 1 : page,
      search,
      sortBy,
      selectedCategories,
    };
  }, [searchParams]);

  // local search input (for typing debounce)
  const [searchInput, setSearchInput] = useState(urlState.search);

  // if URL search changes (like from header SearchMenu), sync input
  useEffect(() => {
    setSearchInput(urlState.search);
  }, [urlState.search]);

  // debounce
  const [debouncedSearch, setDebouncedSearch] = useState(urlState.search);
  useEffect(() => {
    const h = setTimeout(() => setDebouncedSearch(searchInput.trim()), 400);
    return () => clearTimeout(h);
  }, [searchInput]);

  // helper to update URL params using Next router
  const updateUrl = (patch: {
    page?: number;
    search?: string;
    sortBy?: string;
    categories?: string[];
  }) => {
    const params = new URLSearchParams(searchParams.toString());

    const nextCategories =
      patch.categories !== undefined
        ? patch.categories
        : urlState.selectedCategories;

    if (nextCategories.length)
      params.set("categories", nextCategories.join(", "));
    else params.delete("categories");

    const nextSort =
      patch.sortBy !== undefined ? patch.sortBy : urlState.sortBy;
    if (nextSort && nextSort !== "relevance") params.set("sortBy", nextSort);
    else params.delete("sortBy");

    const nextSearch =
      patch.search !== undefined ? patch.search : urlState.search;
    if (nextSearch) params.set("search", nextSearch);
    else params.delete("search");

    const nextPage = patch.page !== undefined ? patch.page : urlState.page;
    if (nextPage > 1) params.set("page", String(nextPage));
    else params.delete("page");

    const qs = params.toString();
    router.replace(qs ? `${pathname}?${qs}` : pathname, { scroll: false });
  };

  // when debouncedSearch changes -> update URL and reset page to 1
  useEffect(() => {
    if (debouncedSearch === (urlState.search || "")) return;
    updateUrl({ search: debouncedSearch, page: 1 });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedSearch]);

  // Fetch products (NO manual refetch needed)
  const {
    data: productsData,
    isLoading,
    error,
  } = useGetProductsQuery({
    categories:
      urlState.selectedCategories.length > 0
        ? urlState.selectedCategories.join(", ")
        : undefined,
    sortBy: urlState.sortBy !== "relevance" ? urlState.sortBy : undefined,
    search: urlState.search || undefined,
    page: urlState.page,
    limit: productsPerPage,
  });

  const products = productsData?.data || productsData || [];
  const pagination = productsData?.pagination;

  const [addCartItem] = useAddCartItemMutation();

  const handleAddToCart = async (
    productId: string,
    hasStandupPouch: boolean
  ) => {
    if (!hasAuthToken()) {
      toast.error(tCommon("loginRequired"));
      return;
    }
    try {
      const res = await addCartItem({
        productId,
        variantType: hasStandupPouch ? "STAND_UP_POUCH" : "SACHETS",
      }).unwrap();
      toast.success(res?.message || tCheckout("addedToCartSuccessfully"));
      openCart();
    } catch (error: any) {
      const message =
        error?.data?.message || error?.message || t("failedToAddToCart");
      toast.error(message);
    }
  };

  const toggleCategoryDropdown = () => {
    setIsCategoryDropdownOpen((v) => !v);
    setIsSortDropdownOpen(false);
  };

  const toggleSortDropdown = () => {
    setIsSortDropdownOpen((v) => !v);
    setIsCategoryDropdownOpen(false);
  };

  const handleCategoryChange = (categoryId: string) => {
    const next = urlState.selectedCategories.includes(categoryId)
      ? urlState.selectedCategories.filter((id) => id !== categoryId)
      : [...urlState.selectedCategories, categoryId];

    updateUrl({ categories: next, page: 1 });
  };

  const handleSortChange = (sortId: string) => {
    setIsSortDropdownOpen(false);
    updateUrl({ sortBy: sortId, page: 1 });
  };

  const handlePageChange = (nextPage: number) => {
    updateUrl({ page: nextPage });
  };

  // Scroll to top when page changes
  useEffect(() => {
    if (!isLoading && productsTopRef.current) {
      // Small delay to ensure content is rendered
      setTimeout(() => {
        // @ts-ignore
        const smoother = (window as any).ScrollSmoother?.get?.();
        if (smoother) {
          smoother.scrollTo(0, true);
        } else {
          window.scrollTo({ top: 0, behavior: "smooth" });
        }

        // After DOM + scroll position settles, recalculate animation trigger points.
        // This is critical for AOS-driven footer elements when switching to an empty state.
        requestAnimationFrame(() => {
          smoother?.refresh?.();
          ScrollTrigger.refresh();
          AOS.refreshHard();
        });
      }, 100);
    }
  }, [urlState.page, isLoading]);

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setIsCategoryDropdownOpen(false);
      }
      if (
        sortDropdownRef.current &&
        !sortDropdownRef.current.contains(event.target as Node)
      ) {
        setIsSortDropdownOpen(false);
      }
    };

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const breadcrumbs = [
    { label: tCommon("home"), href: "/" },
    { label: t("products"), isActive: true },
  ];

  const handleWishlistToggle =
    (product: any) => (wasLiked: boolean, nowLiked: boolean) => {
      if (!wasLiked && nowLiked) {
        setSelectedFavoriteProduct(product);
        setIsFavoritePopupOpen(true);
      }
    };

  return (
    <section className="min-h-screen">
      {selectedFavoriteProduct && (
        <FavoritePopup
          product={{
            id: selectedFavoriteProduct._id,
            name: selectedFavoriteProduct.title,
            description:
              selectedFavoriteProduct.shortDescription ||
              selectedFavoriteProduct.description?.replace(/<[^>]*>/g, ""),
            price:
              selectedFavoriteProduct.sachetPrices?.thirtyDays
                ?.discountedPrice ||
              selectedFavoriteProduct.price?.amount ||
              0,
            originalPrice:
              selectedFavoriteProduct.sachetPrices?.thirtyDays?.amount ||
              selectedFavoriteProduct.price?.amount ||
              0,
            rating: selectedFavoriteProduct.averageRating || 5.0,
            reviewCount: selectedFavoriteProduct.ratingCount || 0,
            images: {
              front:
                selectedFavoriteProduct.productImage ||
                "/products/pro_detail0.png",
              gallery: selectedFavoriteProduct.galleryImages || [],
            },
            category:
              selectedFavoriteProduct.categories?.[0]?.name || "Supplements",
            inStock: selectedFavoriteProduct.status !== false,
          }}
          isOpen={isFavoritePopupOpen}
          onClose={() => setIsFavoritePopupOpen(false)}
        />
      )}

      <Banner
        backgroundImage={heroImageSrc}
        breadcrumbs={breadcrumbs}
        title={t("wellnessEssentialsTitle")}
        description={t("wellnessEssentialsDescription")}
      />

      {/* FILTERS BAR */}
      <div
        ref={productsTopRef}
        className="w-section mx-auto flex flex-col md:flex-row md:items-center md:justify-between gap-4"
      >
        <div className="flex items-center mt-7 gap-3 flex-wrap">
          <button className="px-4 py-2 rounded-full bg-teal-green-color text-white text-sm shadow-sm 3xl:text-lg min-w-15">
            {t("all")}
          </button>

          <div className="relative" ref={dropdownRef}>
            <button
              onClick={toggleCategoryDropdown}
              className="px-4 py-2 bg-slate-50-color rounded-full text-base 3xl:text-lg flex items-center justify-center gap-2 font-medium hover:bg-neutral-100 cursor-pointer transition-colors"
            >
              {t("category")}
              <span
                className={`transition-transform duration-200 mt-1 ${
                  isCategoryDropdownOpen ? "rotate-180" : ""
                }`}
              >
                <DropdownDownArrow />
              </span>
            </button>

            {isCategoryDropdownOpen && (
              <div className="absolute top-full left-0 mt-3.5 w-56 bg-white rounded-2xl 3xl:rounded-3xl shadow-lg z-50">
                <div className="p-3 xl:p-4 3xl:p-5 space-y-2 h-full max-h-60 overflow-auto">
                  {Array.isArray(categories) &&
                    categories.map((category: any) => (
                      <label
                        key={category?.slug}
                        className="flex items-center space-x-2 cursor-pointer hover:bg-gray-50 p-0.5 rounded transition-colors"
                      >
                        <div className="relative">
                          <input
                            type="checkbox"
                            checked={urlState.selectedCategories.includes(
                              category?.slug
                            )}
                            onChange={() =>
                              handleCategoryChange(category?.slug)
                            }
                            className="sr-only"
                          />
                          <div
                            className={`w-4 h-4 rounded border-2 transition-all duration-200 flex items-center justify-center ${
                              urlState.selectedCategories.includes(
                                category?.slug
                              )
                                ? "bg-teal-green-color border-teal-green-color"
                                : "bg-white border-gray-300 hover:border-gray-400"
                            }`}
                          >
                            {urlState.selectedCategories.includes(
                              category?.slug
                            ) && (
                              <svg
                                className="w-5 h-5 text-white"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24"
                              >
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth={2}
                                  d="M5 13l4 4L19 7"
                                />
                              </svg>
                            )}
                          </div>
                        </div>
                        <span className="text-sm text-gray-700">
                          {category?.name}
                        </span>
                      </label>
                    ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* SEARCH BAR */}
        <div>
          <div className="relative w-full mt-7">
            <input
              type="text"
              value={searchInput}
              onChange={(e) => setSearchInput(e.target.value)}
              placeholder={t("searchAllProducts")}
              className="w-full 3xl:min-w-100 pl-10 pr-6 py-1.5 3xl:py-2 rounded-lg border border-gains-light-boro bg-white text-base outline-none! focus:border-gray-300 transition-all placeholder:text-gray-400"
            />
            <span className="absolute left-2 top-1/2 -translate-y-1/2 text-black-color">
              <svg
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                strokeWidth={1.5}
                stroke="currentColor"
                className="w-6 h-6"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  d="m21 21-5.197-5.197m0 0A7.5 7.5 0 1 0 5.196 5.196a7.5 7.5 0 0 0 10.607 10.607Z"
                />
              </svg>
            </span>
          </div>
        </div>
      </div>

      <div className="w-section">
        <div className="mx-2 mt-3 h-px md:mx-auto bg-slate-border-color" />
      </div>

      {/* RESULTS INFO BAR */}
      <div className="section-padding">
        <div className="w-section mx-auto py-6 flex items-center justify-between">
          <p className="text-base md:text-sm text-gray-warm 3xl:text-lg">
            {t("showingResultsFor")}{" "}
            <span className="text-black-color font-medium">{t("all")}</span>
          </p>

          <div className="flex items-center gap-2">
            <span className="text-base md:text-sm text-gray-warm 3xl:text-lg">
              {t("sortBy")}
            </span>

            <div className="relative" ref={sortDropdownRef}>
              <button
                onClick={toggleSortDropdown}
                className="text-base md:text-sm cursor-pointer text-black-color font-medium transition-colors duration-200 flex items-center gap-1 3xl:text-lg"
              >
                {t(sortOptions.find((o) => o.id === urlState.sortBy)?.label || "relevance")}
                <span
                  className={`transition-transform duration-200 ${
                    isSortDropdownOpen ? "rotate-180" : ""
                  }`}
                >
                  <DropdownDownArrow />
                </span>
              </button>

              {isSortDropdownOpen && (
                <div className="absolute top-full right-0 mt-2 w-48 bg-white rounded-lg shadow-lg border border-gray-100 z-50">
                  <div className="py-1">
                    {sortOptions.map((option) => (
                      <button
                        key={option.id}
                        onClick={() => handleSortChange(option.id)}
                        className={`w-full px-4 py-2 text-left text-sm hover:bg-gray-50 transition-colors duration-150 ${
                          urlState.sortBy === option.id
                            ? "text-teal-green-color font-medium bg-teal-50"
                            : "text-gray-700"
                        }`}
                      >
                        {t(option.label)}
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* PRODUCT GRID */}
      <div className="section-padding">
        <div className="w-section mx-auto mb-12 3xl:mb-15 grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5">
          {isLoading ? (
            Array.from({ length: 8 }).map((_, i) => (
              <div
                key={i}
                className="bg-offwhite-color rounded-2xl overflow-hidden shadow-sm animate-pulse"
              >
                <div className="aspect-square m-2 rounded-2xl bg-gray-200" />
                <div className="p-4 space-y-3">
                  <div className="h-6 bg-gray-200 rounded w-3/4" />
                  <div className="h-4 bg-gray-200 rounded w-full" />
                  <div className="h-4 bg-gray-200 rounded w-2/3" />
                </div>
              </div>
            ))
          ) : error ? (
            <div className="col-span-full text-center py-12">
              <p className="text-red-500 text-lg">
                {tCommon("error")}: {t("errorLoadingProduct")}
              </p>
            </div>
          ) : Array.isArray(products) && products.length === 0 ? (
            <div className="col-span-full text-center py-12">
              <p className="text-gray-500 text-lg">{t("productNotFound")}</p>
            </div>
          ) : (
            Array.isArray(products) &&
            products.map((product: any) => (
              <article
                key={product._id}
                className="bg-offwhite-color rounded-2xl overflow-hidden duration-300 product-card-group flex flex-col"
              >
                <Link href={`/products/${product._id}`}>
                  <div className="aspect-square m-1.25 rounded-2xl bg-gray-100 relative overflow-hidden cursor-pointer">
                    <WishlistToggle
                      productId={product._id}
                      initialIsLiked={product?.is_liked ?? false}
                      className="absolute top-2 right-2 z-10"
                      onToggle={handleWishlistToggle(product)}
                    />

                    <Image
                      src={product.productImage || "/products/productFront.png"}
                      alt={`${product.title} front view`}
                      fill
                      className="object-cover transition-opacity duration-300 fav-img"
                      // unoptimized
                    />

                    <Image
                      src={
                        product.galleryImages?.[0] ||
                        product.productImage ||
                        "/products/productBack.png"
                      }
                      alt={`${product.title} back view`}
                      fill
                      className="object-cover transition-opacity duration-300 opacity-0 fav-alter-img absolute inset-0"
                      // unoptimized
                    />

                    <div className="absolute inset-x-4 -bottom-1 pb-2.5 transition-all duration-500! transform translate-y-2 fav-btn">
                      <Button
                        animateText
                        size="elevate"
                        variant="elevate"
                        onClick={(e) => {
                          e.preventDefault();
                          handleAddToCart(product._id, product.hasStandupPouch);
                        }}
                        className="w-full bg-black text-white px-4 font-medium transition-all duration-200 shadow-lg"
                      >
                        <span className="truncate wrap-break-word block">{t("addToCart")}</span>
                      </Button>
                    </div>
                  </div>
                </Link>

                <Link
                  className="flex-1 flex flex-col w-full"
                  href={`/products/${product._id}`}
                >
                  <div className="p-4 flex-1 flex flex-col w-full">
                    <h3 className="font-semibold text-xl 3xl:text-[21px] text-black-color mb-1 font-saans hover:text-teal-green-color transition-colors duration-200 cursor-pointer">
                      {product.title}
                    </h3>

                    <p className="sub-heading-style mb-4 line-clamp-2">
                      {product.shortDescription ||
                        product.description?.replace(/<[^>]*>/g, "")}
                    </p>

                    <div className="flex items-center justify-between mt-auto">
                      <div className="flex items-center justify-center gap-2">
                        <span className="text-base font-semibold text-black-color 3xl:text-lg">
                          {getCurrencySymbol(product.price.currency)}
                          {product.sachetPrices?.thirtyDays?.discountedPrice?.toFixed(
                            2
                          ) || product.price.amount?.toFixed(2)}
                        </span>

                        {product.sachetPrices?.thirtyDays?.amount &&
                          product.sachetPrices.thirtyDays.amount !==
                            product.sachetPrices.thirtyDays.discountedPrice && (
                            <span className="text-sm text-gray-warm line-through 3xl:text-lg">
                              {getCurrencySymbol(product.price.currency)}
                              {product.sachetPrices.thirtyDays.amount.toFixed(
                                2
                              )}
                            </span>
                          )}
                      </div>

                      {/* <div className="flex items-center text-sm gap-1 text-black-color">
                        <div className="flex items-center gap-1">
                          <BlackStarIcon />
                          <span className="font-medium text-sm text-black-color 3xl:text-base">
                            {(product.averageRating || 0).toFixed(1)}
                          </span>
                        </div>
                        <span className="text-black-color font-extralight text-lg">
                          |
                        </span>
                        <span className="text-sm text-black-color font-medium 3xl:text-base">
                          {product.ratingCount || 0}{" "}
                          {product.ratingCount === 1
                            ? t("review")
                            : t("reviews")}
                        </span>
                      </div> */}
                    </div>
                  </div>
                </Link>
              </article>
            ))
          )}
        </div>

        {pagination && pagination.pages > 1 && (
          <div className="mb-12 3xl:mb-15">
            <Pagination
              currentPage={urlState.page}
              totalPages={pagination.pages}
              onPageChange={handlePageChange}
            />
          </div>
        )}
      </div>
    </section>
  );
}
