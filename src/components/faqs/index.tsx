"use client";

import React, { useMemo, useState, useEffect, useCallback } from "react";
import Link from "next/link";
import { MdOutlineAdd } from "react-icons/md";

import { PageHeader } from "@/components/layout/PageHeader";
import { Button } from "@/components/ui/button";
import NoData from "@/components/ui/noData";
import { ROUTES } from "@/constants/routes";

import { useGetFaqCategoriesQuery } from "@/store/api/faqCategoryApi";
import { useLazyGetFaqsByCategoryQuery } from "@/store/api/faqApi";
import type { Faq, FaqPagination } from "@/store/api/types/faq.types";

import FaqCategoryDropdown from "./FaqCategoryDropdown";
import FaqCategoryFormModal from "./manage/FaqCategoryFormModal";
import FaqList from "./FaqList";
import Spinner from "../ui/spinner";

const DEFAULT_LIMIT = 10;

export default function FaqsPage() {
  const {
    data: catRes,
    isLoading: catLoading,
    isFetching: catFetching,
    isError: catError,
  } = useGetFaqCategoriesQuery();

  const categories = catRes?.data ?? [];
  const defaultCategoryId = categories[0]?._id;

  const [selectedCategoryId, setSelectedCategoryId] = useState<
    string | undefined
  >(undefined);
  const [categoryModalOpen, setCategoryModalOpen] = useState(false);

  const effectiveCategoryId = selectedCategoryId ?? defaultCategoryId;

  const selectedCategory = useMemo(() => {
    return categories.find((c) => c._id === effectiveCategoryId);
  }, [categories, effectiveCategoryId]);

  const [
    fetchFaqs,
    { data: faqsRes, isFetching: faqFetching, isError: faqError },
  ] = useLazyGetFaqsByCategoryQuery();

  const [faqs, setFaqs] = useState<Faq[]>([]);
  const [pagination, setPagination] = useState<FaqPagination | null>(null);
  const [loadingMore, setLoadingMore] = useState(false);

  const normalizeList = useCallback((res: typeof faqsRes): Faq[] => {
    if (!res?.data) return [];
    return Array.isArray(res.data) ? res.data : [];
  }, []);

  useEffect(() => {
    if (!effectiveCategoryId) return;
    setFaqs([]);
    setPagination(null);
    fetchFaqs({
      categoryId: effectiveCategoryId,
      page: 1,
      limit: DEFAULT_LIMIT,
    }).then((result) => {
      if (result.data) {
        setFaqs(normalizeList(result.data));
        setPagination(result.data.pagination ?? null);
      }
    });
  }, [effectiveCategoryId, fetchFaqs, normalizeList]);

  const handleLoadMore = useCallback(() => {
    if (!effectiveCategoryId || !pagination?.hasNext || loadingMore) return;
    setLoadingMore(true);
    fetchFaqs({
      categoryId: effectiveCategoryId,
      page: pagination.page + 1,
      limit: DEFAULT_LIMIT,
    }).then((result) => {
      setLoadingMore(false);
      if (result.data) {
        setFaqs((prev) => [...prev, ...normalizeList(result.data!)]);
        setPagination(result.data.pagination ?? null);
      }
    });
  }, [effectiveCategoryId, pagination, loadingMore, fetchFaqs, normalizeList]);

  const handleFaqDeleted = useCallback(() => {
    if (!effectiveCategoryId) return;
    setFaqs([]);
    setPagination(null);
    fetchFaqs({
      categoryId: effectiveCategoryId,
      page: 1,
      limit: DEFAULT_LIMIT,
    }).then((result) => {
      if (result.data) {
        setFaqs(normalizeList(result.data));
        setPagination(result.data.pagination ?? null);
      }
    });
  }, [effectiveCategoryId, fetchFaqs, normalizeList]);

  const faqLoading = faqFetching && faqs.length === 0;

  const headerActions = effectiveCategoryId ? (
    <Link href={ROUTES.CMS_MANAGEMENT.MANAGE_FAQS}>
      <Button variant="teal" className="text-sm 3xl:text-base gap-1">
        <MdOutlineAdd size={21} />
        Add Question
      </Button>
    </Link>
  ) : null;

  if (catLoading) {
    return (
      <div>
        <PageHeader title="FAQs" />
        <div className="bg-white border rounded-lg p-6">
          Loading categories...
        </div>
      </div>
    );
  }

  if (catError) {
    return (
      <div>
        <PageHeader title="FAQs" />
        <div className="bg-white border rounded-lg p-6 text-red-600">
          Failed to load categories.
        </div>
      </div>
    );
  }

  if (!effectiveCategoryId || !Boolean(categories?.length > 0)) {
    return (
      <div>
        <PageHeader title="FAQs" />
        <NoData
          image="/images/noData/faq.webp"
          title="We haven’t created any FAQ categories yet."
          description="Create a category first to start adding FAQs."
          action={
            <Button
              variant="teal"
              className="text-sm 3xl:text-base gap-1"
              onClick={() => setCategoryModalOpen(true)}
            >
              <MdOutlineAdd size={21} />
              Create Category
            </Button>
          }
        />
        <FaqCategoryFormModal
          open={categoryModalOpen}
          onOpenChange={setCategoryModalOpen}
        />
      </div>
    );
  }

  return (
    <div>
      <PageHeader title="FAQs" actions={headerActions} />

      <div className="bg-white border rounded-lg p-5">
        <div className="">
          <FaqCategoryDropdown
            categories={categories}
            effectiveCategoryId={effectiveCategoryId}
            selectedCategory={selectedCategory}
            setSelectedCategoryId={setSelectedCategoryId}
            isLoading={catFetching}
          />
        </div>

        <div className="pt-4">
          {faqLoading ? (
            <div className="text-sm">
              <div className="text-center min-h-50 flex items-center justify-center flex-col">
                {" "}
                <Spinner /> <span className="block mt-5">Loading FAQs...</span>
              </div>
            </div>
          ) : faqError ? (
            <div className=" text-red-600 text-sm text-center min-h-50 flex items-center justify-center flex-col">
              Failed to load FAQs.
            </div>
          ) : faqs?.length === 0 ? (
            <NoData
              image="/images/noData/faq.webp"
              title="No FAQs added yet."
              description="Add your first FAQ question for this category."
              action={
                <Link href={ROUTES.CMS_MANAGEMENT.MANAGE_FAQS}>
                  <Button
                    variant="teal"
                    className="text-sm 3xl:text-base gap-1"
                  >
                    <MdOutlineAdd size={21} />
                    Add Question
                  </Button>
                </Link>
              }
            />
          ) : (
            <FaqList
              faqs={faqs}
              pagination={pagination}
              loadingMore={loadingMore}
              onLoadMore={handleLoadMore}
              onDeleted={handleFaqDeleted}
            />
          )}
        </div>
      </div>
    </div>
  );
}
