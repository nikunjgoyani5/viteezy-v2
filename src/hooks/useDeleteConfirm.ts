"use client";

import { useState, useCallback } from "react";
import type { ApiErrorResponse } from "@/components/common/ApiError";
import { normalizeDeleteError } from "@/lib/common";

export interface UseDeleteConfirmOptions<T> {
  onDelete: (item: T) => Promise<unknown>;
  isDeleting: boolean;
  onSuccess?: (item: T) => void;
}

export interface UseDeleteConfirmReturn<T> {
  open: boolean;
  deleteItem: T | null;
  deleteError: ApiErrorResponse | null;
  openDelete: (item: T) => void;
  onOpenChange: (open: boolean) => void;
  onConfirm: () => Promise<void>;
}

export function useDeleteConfirm<T>({
  onDelete,
  isDeleting,
  onSuccess,
}: UseDeleteConfirmOptions<T>): UseDeleteConfirmReturn<T> {
  const [open, setOpen] = useState(false);
  const [deleteItem, setDeleteItem] = useState<T | null>(null);
  const [deleteError, setDeleteError] = useState<ApiErrorResponse | null>(null);

  const openDelete = useCallback((item: T) => {
    setDeleteItem(item);
    setDeleteError(null);
    setOpen(true);
  }, []);

  const onOpenChange = useCallback(
    (v: boolean) => {
      if (isDeleting) return;
      setOpen(v);
      if (!v) {
        setDeleteItem(null);
        setDeleteError(null);
      }
    },
    [isDeleting]
  );

  const onConfirm = useCallback(async () => {
    if (!deleteItem) return;
    try {
      await onDelete(deleteItem);
      setOpen(false);
      const deleted = deleteItem;
      setDeleteItem(null);
      setDeleteError(null);
      onSuccess?.(deleted);
    } catch (e) {
      setDeleteError(normalizeDeleteError(e));
    }
  }, [deleteItem, onDelete, onSuccess]);

  return {
    open,
    deleteItem,
    deleteError,
    openDelete,
    onOpenChange,
    onConfirm,
  };
}
