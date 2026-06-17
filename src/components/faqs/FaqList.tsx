"use client";

import React from "react";
import Link from "next/link";
import toast from "react-hot-toast";
import { MoreVertical, Pencil, Trash2 } from "lucide-react";
import type { Faq } from "@/store/api/types/faq.types";
import type { FaqPagination } from "@/store/api/types/faq.types";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import ConfirmModal from "@/components/ui/confirmModal";
import { useDeleteConfirm } from "@/hooks/useDeleteConfirm";
import { ROUTES } from "@/constants/routes";
import { useDeleteFaqMutation } from "@/store/api/faqApi";

const MAX_ANSWER_PREVIEW = 120;

function truncate(str: string, max: number) {
  if (!str || str.length <= max) return str;
  return str.slice(0, max).trim() + "...";
}

export default function FaqList({
  faqs,
  pagination,
  loadingMore,
  onLoadMore,
  onDeleted,
}: {
  faqs: Faq[];
  pagination: FaqPagination | null;
  loadingMore: boolean;
  onLoadMore: () => void;
  onDeleted?: () => void;
}) {
  return (
    <div className="space-y-3">
      {faqs.map((faq) => (
        <FaqCard key={faq._id} faq={faq} onDeleted={onDeleted} />
      ))}
      {pagination?.hasNext && (
        <div className="pt-4 flex justify-center">
          <Button
            type="button"
            variant="outline"
            onClick={onLoadMore}
            disabled={loadingMore}
          >
            {loadingMore ? "Loading..." : "Load more"}
          </Button>
        </div>
      )}
    </div>
  );
}

function FaqCard({ faq, onDeleted }: { faq: Faq; onDeleted?: () => void }) {
  const [deleteFaq, { isLoading: deleting }] = useDeleteFaqMutation();
  const deleteConfirm = useDeleteConfirm<Faq>({
    onDelete: (item) => deleteFaq(item._id).unwrap(),
    isDeleting: deleting,
    onSuccess: () => {
      toast.success("FAQ deleted successfully");
      onDeleted?.();
    },
  });

  return (
    <>
      <div className="flex items-start gap-3 p-4 rounded-lg border border-gray-200 bg-gray-50/50 hover:bg-gray-50 transition-colors">
        <div className="flex-1 min-w-0">
          <p className="font-semibold text-gray-900 text-sm 3xl:text-base truncate">
            {faq.question}
          </p>
          <p className="mt-1 text-gray-600 text-sm truncate pe-10">
            {/* {truncate(faq.answer, MAX_ANSWER_PREVIEW)} */}
            {faq.answer}
          </p>
        </div>
        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <button
              type="button"
              className="shrink-0 p-1.5 rounded-md hover:bg-gray-200 text-gray-500"
              aria-label="More options"
            >
              <MoreVertical className="h-5 w-5" />
            </button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end">
            <DropdownMenuItem asChild>
              <Link
                href={ROUTES.CMS_MANAGEMENT.FAQ_EDIT(faq._id)}
                className="cursor-pointer flex items-center gap-2"
              >
                <Pencil className="h-4 w-4" />
                Edit
              </Link>
            </DropdownMenuItem>
            <DropdownMenuItem
              className="text-red-600 focus:text-red-600 cursor-pointer flex items-center gap-2"
              onClick={(e) => {
                e.preventDefault();
                deleteConfirm.openDelete(faq);
              }}
            >
              <Trash2 className="h-4 w-4" />
              Delete
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>

      <ConfirmModal
        open={deleteConfirm.open}
        onOpenChange={deleteConfirm.onOpenChange}
        title="Delete this FAQ?"
        description={
          deleteConfirm.deleteItem
            ? `Are you sure you want to delete "${deleteConfirm.deleteItem.question}"? This action cannot be undone.`
            : ""
        }
        error={deleteConfirm.deleteError}
        confirmText="Delete"
        cancelText="Cancel"
        loading={deleting}
        variant="danger"
        onConfirm={deleteConfirm.onConfirm}
      />
    </>
  );
}
