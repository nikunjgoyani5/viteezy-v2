"use client";

import * as React from "react";
import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import ApiError, { type ApiErrorResponse } from "@/components/common/ApiError";

type ConfirmModalProps = {
  open: boolean;
  onOpenChange: (v: boolean) => void;

  title: React.ReactNode;
  description?: React.ReactNode;

  /** When set, shown at the top of the modal body (e.g. API error after confirm). */
  error?: ApiErrorResponse | string | null;

  confirmText?: string;
  cancelText?: string;

  onConfirm: () => void | Promise<void>;
  loading?: boolean;

  variant?: "danger" | "default";
};

export default function ConfirmModal({
  open,
  onOpenChange,
  title,
  description,
  error,
  confirmText = "Delete",
  cancelText = "Cancel",
  onConfirm,
  loading,
  variant = "danger",
}: ConfirmModalProps) {
  const isDanger = variant === "danger";

  return (
    <AppModal
      className="xl:min-w-[560px]!"
      open={open}
      onOpenChange={(v) => {
        if (loading) return;
        onOpenChange(v);
      }}
      title={title}
      footer={
        <>
          <Button
            size="lg"
            variant="outline"
            onClick={() => onOpenChange(false)}
            disabled={loading}
          >
            {cancelText}
          </Button>

          <Button
            size="lg"
            onClick={onConfirm}
            disabled={loading}
            className={
              isDanger ? "bg-red text-white hover:bg-red/90" : undefined
            }
            variant={isDanger ? undefined : "teal"}
          >
            {loading ? "Please wait..." : confirmText}
          </Button>
        </>
      }
    >
      <>
        {error ? (
          <div className="mb-4">
            <ApiError error={error} />
          </div>
        ) : null}
        {description ? (
          <div className="text-sm 3xl:text-base text-text-gray leading-relaxed wrap-break-word">
            {description}
          </div>
        ) : null}
      </>
    </AppModal>
  );
}
