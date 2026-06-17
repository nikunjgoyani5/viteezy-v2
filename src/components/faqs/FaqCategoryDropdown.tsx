"use client";

import React, { useState } from "react";
import { ChevronDown, Pencil, Trash2 } from "lucide-react";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { useDeleteFaqCategoryMutation } from "@/store/api/faqCategoryApi";
import ConfirmModal from "../ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";
import { FaqCategory } from "@/store/api/types/faqCategory.types";
import FaqCategoryFormModal from "./manage/FaqCategoryFormModal";
import Spinner from "../ui/spinner";

type Category = { _id: string; title: string };

export default function FaqCategoryDropdown({
  selectedCategory,
  effectiveCategoryId,
  categories,
  setSelectedCategoryId,
  isLoading,
}: {
  selectedCategory?: FaqCategory;
  effectiveCategoryId: string;
  categories: FaqCategory[];
  setSelectedCategoryId: (id: string) => void;
  isLoading?: boolean;
}) {
  const [open, setOpen] = useState(false);
  const [catModalOpen, setCatModalOpen] = useState(false);
  const [editCategory, setEditCategory] = useState<FaqCategory | null>(null);

  const [deleteCategory, { isLoading: deleting }] =
    useDeleteFaqCategoryMutation();

  const deleteConfirm = useDeleteConfirm<Category>({
    onDelete: (item) => deleteCategory(item._id).unwrap(),
    isDeleting: deleting,
    onSuccess: (item) => {
      if (item._id === effectiveCategoryId) {
        const next = categories.find((x) => x._id !== item._id);
        if (next) setSelectedCategoryId(next._id);
      }
      setOpen(false);
    },
  });

  return (
    <>
      <DropdownMenu open={open} onOpenChange={setOpen}>
        <DropdownMenuTrigger asChild>
          <button
            type="button"
            className="inline-flex items-center gap-2 text-sm 3xl:text-base font-medium text-black hover:text-gray-900 outline-none cursor-pointer"
          >
            {selectedCategory?.title ?? "Select category"}
            <ChevronDown className="h-4 w-4 text-text-gray" />
          </button>
        </DropdownMenuTrigger>

        <DropdownMenuContent align="start" className="w-80 p-1">
          {isLoading ? (
            <div className="min-h-40 flex items-center justify-center">
              <Spinner />
            </div>
          ) : (
            <div>
              {categories.map((c) => {
                const active = c._id === effectiveCategoryId;

                return (
                  <div
                    onClick={() => {
                      setSelectedCategoryId(c._id);
                      setOpen(false);
                    }}
                    key={c._id}
                    className={`group flex items-center justify-between gap-2 rounded-md px-2 py-2 cursor-pointer ${
                      active ? "bg-slate-gray" : "hover:bg-slate-gray"
                    }`}
                  >
                    {/* CATEGORY LABEL → closes dropdown */}
                    <span
                      className="flex-1 text-left text-sm text-black truncate cursor-pointer"
                      title={c.title}
                    >
                      {c.title}
                    </span>

                    {/* ACTIONS */}
                    <div className="flex items-center gap-1 opacity-0 group-hover:opacity-100 transition-opacity">
                      <button
                        type="button"
                        className="h-8 w-8 rounded-md hover:bg-white/70 flex items-center justify-center cursor-pointer"
                        aria-label="Edit category"
                        onClick={(e) => {
                          e.stopPropagation();
                          setEditCategory(c);
                          setCatModalOpen(true);
                        }}
                      >
                        <Pencil className="h-4 w-4 text-text-gray" />
                      </button>

                      <button
                        type="button"
                        className="h-8 w-8 rounded-md hover:bg-white/70 flex items-center justify-center cursor-pointer"
                        aria-label="Delete category"
                        onClick={(e) => {
                          e.stopPropagation();
                          deleteConfirm.openDelete(c);
                        }}
                      >
                        <Trash2 className="h-4 w-4 text-red" />
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </DropdownMenuContent>
      </DropdownMenu>

      {/* DELETE CONFIRM MODAL */}
      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete this category?"
        description={
          deleteConfirm.deleteItem?.title
            ? `Are you sure you want to delete “${deleteConfirm.deleteItem.title}”? This action cannot be undone.`
            : "Are you sure you want to delete this? This action cannot be undone."
        }
        error={deleteConfirm.deleteError}
        confirmText="Delete FAQ"
        cancelText="Cancel"
        loading={deleting}
        variant="danger"
        onConfirm={deleteConfirm.onConfirm}
      />

      {/* CREATE / EDIT MODAL */}
      <FaqCategoryFormModal
        open={catModalOpen}
        onOpenChange={(v) => {
          setCatModalOpen(v);
          if (!v) setEditCategory(null);
        }}
        editCategory={editCategory}
      />
    </>
  );
}
