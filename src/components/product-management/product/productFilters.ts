import type {
  GetProductFiltersResponse,
  GetProductsParams,
} from "@/store/api/types/products.types";

export type AdvancedFilterOption = { value: string; label: string };

export type AdvancedFilterConfig = {
  key: string;
  label: string;
  type: "select";
  options: AdvancedFilterOption[];
};

export function buildProductAdvancedFilters(
  filtersRes?: GetProductFiltersResponse
): AdvancedFilterConfig[] {
  const d = filtersRes?.data;

  return [
    {
      key: "categories",
      label: "Category",
      type: "select",
      options: (d?.categories ?? []).map((c) => ({
        value: c._id,
        label: c.name,
      })),
    },
    {
      key: "healthGoals",
      label: "Health Goal",
      type: "select",
      options: (d?.healthGoals ?? []).map((x) => ({ value: x, label: x })),
    },
    {
      key: "ingredients",
      label: "Ingredient",
      type: "select",
      options: (d?.ingredients ?? []).map((i) => ({
        value: i._id,
        label: i.name,
      })),
    },
    {
      key: "variants",
      label: "Variant",
      type: "select",
      options: (d?.variants ?? []).map((v) => ({ value: v, label: v })),
    },
    {
      key: "hasStandupPouch",
      label: "Standup Pouch",
      type: "select",
      options: (d?.hasStandupPouch ?? []).map((b) => ({
        value: String(b),
        label: b ? "Yes" : "No",
      })),
    },
    {
      key: "status",
      label: "Status",
      type: "select",
      options: [
        { value: "true", label: "Active" },
        { value: "false", label: "Inactive" },
      ],
    },
    {
      key: "sortBy",
      label: "Sort By",
      type: "select",
      options: (d?.sortBy ?? []).map((s) => ({
        value: s.value,
        label: s.label,
      })),
    },
  ];
}

export function mapProductFiltersToApi(
  filters: Record<string, string>
): Partial<GetProductsParams> {
  return {
    categories: filters.categories || undefined,
    healthGoals: filters.healthGoals || undefined,
    ingredients: filters.ingredients || undefined,
    variants: filters.variants || undefined,
    hasStandupPouch: filters.hasStandupPouch || undefined,
    status: filters.status || undefined,
    // sortBy is a string union in GetProductsParams, so cast the raw string
    sortBy: (filters.sortBy || undefined) as GetProductsParams["sortBy"] | undefined,
  };
}
