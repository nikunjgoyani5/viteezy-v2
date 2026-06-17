"use client";

import React, { useState } from "react";
import toast from "react-hot-toast";
import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import type { DeliveryPostponementRow } from "./types";
import { getPostponementUserName } from "./types";
import { TextareaField } from "../ui/inputs";
import { useRejectPostponementMutation } from "@/store/api/postponementsApi";
import { format, parseISO, isValid } from "date-fns";

const MIN_REASON_LENGTH = 10;

function formatDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  try {
    const d = parseISO(iso);
    return isValid(d) ? format(d, "MMM dd, yyyy") : "—";
  } catch {
    return "—";
  }
}

interface RejectPostponementModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  row: DeliveryPostponementRow | null;
}

export function RejectPostponementModal({
  open,
  onOpenChange,
  row,
}: RejectPostponementModalProps) {
  const [reason, setReason] = useState("");

  const [reject, { isLoading }] = useRejectPostponementMutation();

  const handleClose = () => {
    setReason("");
    onOpenChange(false);
  };

  const handleReject = async () => {
    if (!row) return;
    const trimmed = reason.trim();
    if (trimmed.length < MIN_REASON_LENGTH) return;
    try {
      const res = await reject({
        id: row.id,
        body: { reason: trimmed },
      }).unwrap();
      if (res.success) {
        toast.success(res.message || "Postponement rejected");
        handleClose();
      } else {
        toast.error(res.message || "Failed to reject");
      }
    } catch (err: unknown) {
      const msg =
        (err as { data?: { message?: string } })?.data?.message ||
        "Failed to reject postponement";
      toast.error(msg);
    }
  };

  const isValid = reason.trim().length >= MIN_REASON_LENGTH;

  if (!row) return null;

  return (
    <AppModal
      open={open}
      onOpenChange={handleClose}
      title="Reject Postponement"
      className="xl:min-w-[480px]"
      footer={
        <>
          <Button
            size="lg"
            variant="outline"
            onClick={handleClose}
            disabled={isLoading}
          >
            Cancel
          </Button>
          <Button
            size="lg"
            onClick={handleReject}
            disabled={!isValid || isLoading}
            variant="coral-red"
          >
            {isLoading ? "Rejecting..." : "Reject request"}
          </Button>
        </>
      }
    >
      <div className="space-y-6">
        <p>
          Provide a reason for rejecting the postponement request from{" "}
          <span className="font-medium">{getPostponementUserName(row)}</span>
        </p>
        <div className="bg-surface-light border rounded-md p-3.5 space-y-3">
          <div className="flex gap-3 justify-between">
            <label className="block text-sm 3xl:text-base">
              Original Delivery Date
            </label>
            <p className="text-sm 3xl:text-base font-medium">
              {formatDate(row.originalDeliveryDate)}
            </p>
          </div>
          <div className="flex gap-3 justify-between">
            <label className="block text-sm 3xl:text-base">
              Requested New Date
            </label>
            <p className="text-sm 3xl:text-base font-medium">
              {formatDate(row.requestedDeliveryDate)}
            </p>
          </div>
        </div>
        <div>
          <TextareaField
            required
            label="Reason for rejection"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="e.g. Delivery slot not available for the requested date."
            className="w-full px-4 py-3 border-border rounded-md placeholder:text-text-gray"
          />
          {reason.length > 0 && reason.trim().length < MIN_REASON_LENGTH && (
            <p className="text-xs text-red-500 mt-1">
              Reason is required (minimum {MIN_REASON_LENGTH} characters)
            </p>
          )}
        </div>
      </div>
    </AppModal>
  );
}
