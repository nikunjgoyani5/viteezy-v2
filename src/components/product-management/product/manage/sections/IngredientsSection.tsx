"use client";

import React, { useState, useEffect, useCallback, useRef, useMemo } from "react";
import { useFormContext, Controller } from "react-hook-form";
import { ChevronDown, Loader2 } from "lucide-react";
import {
  useLazyGetProductIngredientsQuery,
  useLazyGetProductIngredientByIdQuery,
} from "@/store/api/productIngredientsApi";
import type { ProductIngredient } from "@/store/api/types/productIngredient.types";
import { Checkbox } from "@/components/ui/table/Checkbox";
import InputField from "@/components/ui/inputs/input";
import { TextareaField } from "@/components/ui/inputs";
import UploadFile from "@/components/ui/uploadFile";
import AppImage from "@/components/ui/appImage";
import { cn } from "@/lib/utils";
import { useDebounce } from "@/hooks/useDebounce";
import { IoSearchOutline } from "react-icons/io5";
import type { ProductFormValues } from "../product.schema";

const PAGE_SIZE = 20;

const TABS = [
  { id: "content", label: "Content" },
  { id: "selection", label: "Selection" },
] as const;

type TabId = (typeof TABS)[number]["id"];

type IngredientComposition = NonNullable<
  ProductFormValues["ingredientCompositions"]
>[number];

function IngredientRow({
  ingredient,
  selected,
  composition,
  quantityError,
  driError,
  onToggle,
  onQuantityChange,
  onDriChange,
}: {
  ingredient: ProductIngredient;
  selected: boolean;
  composition?: IngredientComposition;
  quantityError?: string;
  driError?: string;
  onToggle: () => void;
  onQuantityChange: (value: string) => void;
  onDriChange: (value: string) => void;
}) {
  const [open, setOpen] = useState(selected);

  useEffect(() => {
    if (selected) setOpen(true);
  }, [selected]);

  const imageUrl =
    ingredient.image &&
    typeof ingredient.image === "object" &&
    "url" in ingredient.image
      ? (ingredient.image as { url: string }).url
      : null;

  return (
    <div
      className={cn(
        "py-3 px-4 rounded-lg border border-transparent transition-all duration-200",
        selected
          ? "border-teal-500 bg-teal-50/10"
          : "bg-slate-gray hover:bg-gray-100 hover:border-gray-200"
      )}
    >
      <div className="flex items-start gap-3">
        <div className="mt-4 shrink-0">
          <Checkbox checked={selected} onChange={onToggle} />
        </div>

        <div
          className="flex items-start gap-3 w-full cursor-pointer select-none"
          onClick={() => setOpen((v) => !v)}
        >
          <div className="h-12 w-12 shrink-0 rounded-full overflow-hidden bg-white border border-gray-100">
            {imageUrl ? (
              <AppImage
                src={imageUrl}
                alt={ingredient.name}
                width={48}
                height={48}
                className="object-cover w-full h-full"
              />
            ) : (
              <div className="w-full h-full flex items-center justify-center text-xs text-gray-400">
                No img
              </div>
            )}
          </div>

          <div className="flex-1 min-w-0 pt-0.5">
            <p className="font-medium text-gray-900 line-clamp-1">
              {ingredient.name}
            </p>
            <p
              className={cn(
                "text-sm text-gray-500 mt-1 whitespace-pre-wrap transition-all",
                !open && "line-clamp-1"
              )}
            >
              {ingredient.description || "—"}
            </p>
          </div>

          <button
            type="button"
            className="shrink-0 p-1 text-gray-400 hover:text-teal-600 transition-colors mt-1"
          >
            <ChevronDown
              className={cn(
                "w-5 h-5 transition-transform duration-200",
                open && "-rotate-180"
              )}
            />
          </button>
        </div>
      </div>

      {selected && open && (
        <div
          className="mt-4 grid grid-cols-1 sm:grid-cols-2 gap-3 w-full"
          onClick={(e) => e.stopPropagation()}
        >
          <InputField
            label="Quantity"
            type="text"
            inputMode="decimal"
            placeholder="e.g., 500 mg/mcg"
            value={composition?.quantity ?? ""}
            onChange={(e) => onQuantityChange(e.target.value)}
            className="bg-white"
            error={quantityError}
          />
          <InputField
            label="% DRI"
            type="text"
            inputMode="decimal"
            placeholder="e.g., 25%"
            value={
              composition?.driPercentage === undefined
                ? ""
                : String(composition.driPercentage)
            }
            onChange={(e) => onDriChange(e.target.value)}
            className="bg-white"
            error={driError}
          />
        </div>
      )}
    </div>
  );
}

function IngredientsContentTab() {
  const { control } = useFormContext<ProductFormValues>();

  return (
    <div className="p-5 space-y-4">
      <Controller
        control={control}
        name="ingredientMeta.sectionTitle"
        render={({ field }) => (
          <InputField
            label="Title"
            placeholder="e.g., Other Ingredients"
            value={field.value ?? ""}
            onChange={field.onChange}
            onBlur={field.onBlur}
            name={field.name}
            className="bg-white"
          />
        )}
      />
      <Controller
        control={control}
        name="ingredientMeta.sectionSubtitle"
        render={({ field }) => (
          <TextareaField
            label="Subtitle"
            placeholder="e.g., Additional ingredients used in the formulation"
            rows={4}
            value={field.value ?? ""}
            onChange={field.onChange}
            onBlur={field.onBlur}
            name={field.name}
            className="bg-white"
          />
        )}
      />
      <Controller
        control={control}
        name="ingredientMeta.excipients"
        render={({ field }) => (
          <TextareaField
            label="Excipients"
            placeholder="e.g., Microcrystalline Cellulose"
            rows={4}
            value={field.value ?? ""}
            onChange={field.onChange}
            onBlur={field.onBlur}
            name={field.name}
            className="bg-white"
          />
        )}
      />
      <Controller
        control={control}
        name="ingredientMeta.backgroundImage"
        render={({ field, fieldState }) => (
          <UploadFile
            label="Background Image"
            value={field.value as string | File | null}
            onChange={field.onChange}
            error={fieldState.error?.message}
          />
        )}
      />
    </div>
  );
}

function IngredientsSelectionTab() {
  const {
    watch,
    setValue,
    formState: { errors, isSubmitted },
  } = useFormContext<ProductFormValues>();
  const selectedCompositions = watch("ingredientCompositions") ?? [];
  const selectedIds = selectedCompositions.map((item) => item.ingredient);

  const [search, setSearch] = useState("");
  const debouncedSearch = useDebounce(search, 500);

  const [accumulated, setAccumulated] = useState<ProductIngredient[]>([]);
  const [pinnedIngredients, setPinnedIngredients] = useState<ProductIngredient[]>(
    []
  );
  const fetchedPinnedIdsRef = useRef<Set<string>>(new Set());
  const [currentPage, setCurrentPage] = useState(1);
  const [hasNext, setHasNext] = useState(false);

  const [fetchIngredients, { isError, isLoading, isFetching }] =
    useLazyGetProductIngredientsQuery();
  const [fetchIngredientById] = useLazyGetProductIngredientByIdQuery();

  const loadPage = useCallback(
    (pageNum: number, searchTerm: string, append: boolean) => {
      fetchIngredients({
        page: pageNum,
        limit: PAGE_SIZE,
        search: searchTerm.trim() || undefined,
      })
        .unwrap()
        .then((res) => {
          const list = res.data ?? [];
          if (append) {
            setAccumulated((prev) => [...prev, ...list]);
          } else {
            setAccumulated(list);
          }
          setHasNext(res.pagination?.hasNext ?? false);
          setCurrentPage(pageNum);
        })
        .catch(() => {});
    },
    [fetchIngredients]
  );

  useEffect(() => {
    setAccumulated([]);
    setCurrentPage(1);
    setHasNext(false);
    loadPage(1, debouncedSearch, false);
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [debouncedSearch]);

  useEffect(() => {
    const accumulatedIds = new Set(accumulated.map((item) => item._id));
    const missingIds = selectedIds.filter(
      (id) => !accumulatedIds.has(id) && !fetchedPinnedIdsRef.current.has(id)
    );
    if (missingIds.length === 0) return;

    missingIds.forEach((id) => fetchedPinnedIdsRef.current.add(id));

    let cancelled = false;

    Promise.all(
      missingIds.map((id) =>
        fetchIngredientById(id)
          .unwrap()
          .then(
            (res) =>
              (res.data?.ingredient as unknown as ProductIngredient | undefined) ??
              null
          )
          .catch(() => null)
      )
    ).then((results) => {
      if (cancelled) return;
      const fetched = results.filter(Boolean) as ProductIngredient[];
      if (fetched.length === 0) return;

      setPinnedIngredients((current) => {
        const existing = new Set(current.map((item) => item._id));
        const next = [...current];
        fetched.forEach((item) => {
          if (!existing.has(item._id)) next.push(item);
        });
        return next;
      });
    });

    return () => {
      cancelled = true;
    };
  }, [selectedIds, accumulated, fetchIngredientById]);

  const displayIngredients = useMemo(() => {
    const seen = new Set<string>();
    const result: ProductIngredient[] = [];

    const addItem = (item: ProductIngredient) => {
      if (seen.has(item._id)) return;
      seen.add(item._id);
      result.push(item);
    };

    pinnedIngredients.forEach(addItem);
    accumulated.forEach(addItem);

    return result;
  }, [accumulated, pinnedIngredients]);

  const loadMore = () => {
    if (isFetching || !hasNext) return;
    const nextPage = currentPage + 1;
    loadPage(nextPage, debouncedSearch, true);
  };

  const listRef = useRef<HTMLDivElement>(null);
  const handleScroll = () => {
    const el = listRef.current;
    if (!el) return;
    if (el.scrollTop + el.clientHeight >= el.scrollHeight - 50) {
      loadMore();
    }
  };

  const isInitialLoad = displayIngredients.length === 0 && (isLoading || isFetching);
  const isLoadingMore = displayIngredients.length > 0 && (isLoading || isFetching);

  const toggleIngredient = (id: string) => {
    const current = Array.isArray(selectedCompositions)
      ? [...selectedCompositions]
      : [];
    const exists = current.some((item) => item.ingredient === id);
    const next = exists
      ? current.filter((item) => item.ingredient !== id)
      : [
          ...current,
          {
            ingredient: id,
            quantity: "",
            driPercentage: "",
          },
        ];
    setValue("ingredientCompositions", next, {
      shouldValidate: false,
      shouldDirty: true,
    });
  };

  const updateCompositionField = (
    id: string,
    key: "quantity" | "driPercentage",
    value: string
  ) => {
    const current = Array.isArray(selectedCompositions)
      ? [...selectedCompositions]
      : [];
    const next = current.map((item) => {
      if (item.ingredient !== id) return item;

      if (key === "quantity") {
        return {
          ...item,
          quantity: value,
        };
      }

      return {
        ...item,
        driPercentage: value.trim(),
      };
    });

    setValue("ingredientCompositions", next, {
      shouldValidate: isSubmitted,
      shouldDirty: true,
    });
  };

  const getCompositionByIngredient = (id: string) =>
    selectedCompositions.find((item) => item.ingredient === id);

  const getCompositionErrorsByIngredient = (id: string) => {
    const index = selectedCompositions.findIndex((item) => item.ingredient === id);
    if (index < 0) return { quantityError: undefined, driError: undefined };

    const errorItem = errors.ingredientCompositions?.[index];
    return {
      quantityError: errorItem?.quantity?.message as string | undefined,
      driError: errorItem?.driPercentage?.message as string | undefined,
    };
  };

  return (
    <div className="p-5 flex flex-col min-h-0 space-y-5">
      <div className="max-w-md relative shrink-0">
        <InputField
          placeholder="Search ingredients..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          preIcon={<IoSearchOutline className="w-5 h-5 text-black" />}
          className="bg-transparent! w-full"
        />
      </div>

      <div
        ref={listRef}
        onScroll={handleScroll}
        className="space-y-3 flex-1 overflow-y-auto max-h-[500px] pr-2"
      >
        {isInitialLoad && (
          <div className="flex flex-col items-center justify-center py-12 text-gray-400">
            <Loader2 className="w-8 h-8 animate-spin mb-2 text-teal-500" />
            <p>Loading ingredients...</p>
          </div>
        )}

        {isError && !isFetching && (
          <div className="py-8 text-center text-red-600 text-sm bg-red-50 rounded-lg border border-red-100">
            Failed to load ingredients. Try again later.
          </div>
        )}

        {!isInitialLoad && !isError && displayIngredients.length === 0 && (
          <div className="py-12 text-center text-gray-500 bg-gray-50 rounded-lg border border-dashed border-gray-200">
            <p>
              {debouncedSearch.trim()
                ? `No ingredients match "${debouncedSearch}"`
                : "No ingredients found."}
            </p>
          </div>
        )}

        {displayIngredients.length > 0 && (
          <>
            <div className="space-y-3">
              {displayIngredients.map((ingredient) => {
                const rowErrors = getCompositionErrorsByIngredient(ingredient._id);
                return (
                  <IngredientRow
                    key={ingredient._id}
                    ingredient={ingredient}
                    selected={selectedIds.includes(ingredient._id)}
                    composition={getCompositionByIngredient(ingredient._id)}
                    quantityError={rowErrors.quantityError}
                    driError={rowErrors.driError}
                    onToggle={() => toggleIngredient(ingredient._id)}
                    onQuantityChange={(value) =>
                      updateCompositionField(ingredient._id, "quantity", value)
                    }
                    onDriChange={(value) =>
                      updateCompositionField(
                        ingredient._id,
                        "driPercentage",
                        value
                      )
                    }
                  />
                );
              })}
            </div>

            {isLoadingMore && (
              <div className="py-4 flex justify-center text-gray-400">
                <div className="flex items-center gap-2 text-sm">
                  <Loader2 className="w-4 h-4 animate-spin text-teal-600" />
                  <span>Loading more...</span>
                </div>
              </div>
            )}
          </>
        )}
      </div>
    </div>
  );
}

export default function IngredientsSection() {
  const [activeTab, setActiveTab] = useState<TabId>("content");

  return (
    <div className="space-y-4 pt-4">
      <div className="border-b border-gray-200 m-0">
        <div className="flex">
          {TABS.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "pb-4 text-base font-medium transition-all relative px-4.5 cursor-pointer",
                  isActive
                    ? "text-teal-600"
                    : "text-gray-500 hover:text-gray-700"
                )}
              >
                {tab.label}
                {isActive && (
                  <span className="absolute bottom-0 left-0 w-full h-[2px] bg-teal-500 rounded-t-md" />
                )}
              </button>
            );
          })}
        </div>
      </div>

      <div className="min-h-[300px]">
        {activeTab === "content" && <IngredientsContentTab />}
        {activeTab === "selection" && <IngredientsSelectionTab />}
      </div>
    </div>
  );
}
