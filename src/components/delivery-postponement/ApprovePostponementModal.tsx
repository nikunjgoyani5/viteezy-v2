"use client";

import React, { useState, useEffect } from "react";
import toast from "react-hot-toast";
import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import type { DeliveryPostponementRow } from "./types";
import { getPostponementUserName } from "./types";
import { format, parseISO, isValid } from "date-fns";
import { InputField, TextareaField } from "../ui/inputs";
import { useApprovePostponementMutation } from "@/store/api/postponementsApi";

function formatDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  try {
    const d = parseISO(iso);
    return isValid(d) ? format(d, "MMM dd, yyyy") : "—";
  } catch {
    return "—";
  }
}

function toYYYYMMDD(iso: string | null | undefined): string {
  if (!iso) return "";
  try {
    const d = parseISO(iso);
    return isValid(d) ? format(d, "yyyy-MM-dd") : "";
  } catch {
    return "";
  }
}

interface ApprovePostponementModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  row: DeliveryPostponementRow | null;
}

export function ApprovePostponementModal({
  open,
  onOpenChange,
  row,
}: ApprovePostponementModalProps) {
  const [approvedDate, setApprovedDate] = useState("");
  const [initialDate, setInitialDate] = useState("");
  const [notes, setNotes] = useState("");

  const [approve, { isLoading }] = useApprovePostponementMutation();

  useEffect(() => {
    if (open && row) {
      const def = toYYYYMMDD(row.requestedDeliveryDate || row.approvedDeliveryDate);
      setApprovedDate(def);
      setInitialDate(def);
    }
  }, [open, row]);

  const handleClose = () => {
    setApprovedDate("");
    setInitialDate("");
    setNotes("");
    onOpenChange(false);
  };

  const handleApprove = async () => {
    if (!row) return;
    const trimmed = approvedDate.trim();
    const dateChanged = trimmed !== "" && trimmed !== initialDate;
    const body = dateChanged
      ? {
          approvedDeliveryDate: new Date(
            trimmed + "T00:00:00.000Z"
          ).toISOString(),
        }
      : {};
    try {
      const res = await approve({ id: row.id, body }).unwrap();
      if (res.success) {
        toast.success(res.message || "Postponement approved");
        handleClose();
      } else {
        toast.error(res.message || "Failed to approve");
      }
    } catch (err: unknown) {
      const msg =
        (err as { data?: { message?: string } })?.data?.message ||
        "Failed to approve postponement";
      toast.error(msg);
    }
  };

  if (!row) return null;

  return (
    <AppModal
      open={open}
      onOpenChange={handleClose}
      title="Approve Postponement"
      className="xl:min-w-[480px]"
      footer={
        <>
          <Button size="lg" variant="outline" onClick={handleClose} disabled={isLoading}>
            Cancel
          </Button>
          <Button
            size="lg"
            variant="teal"
            onClick={handleApprove}
            disabled={isLoading}
          >
            {isLoading ? "Approving..." : "Approve request"}
          </Button>
        </>
      }
    >
      <div className="space-y-6">
        <p>
          Review and approve the postponement request for{" "}
          <span className="font-medium">{getPostponementUserName(row)}</span>{" "}
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
            <p className="text-sm 3xl:text-base font-medium text-teal-500">
              {formatDate(row.requestedDeliveryDate)}
            </p>
          </div>
        </div>
        <div>
          <InputField
            label="New Approved Date"
            type="date"
            value={approvedDate}
            onChange={(e) => setApprovedDate(e.target.value)}
          />
          <p className="text-xs 3xl:text-sm text-gray-500 mt-1">
            Optional. Change to approve a different date, or leave as requested.
          </p>
        </div>
        <div>
          <TextareaField
            label="Additional notes"
            value={notes}
            onChange={(e) => setNotes(e.target.value)}
            placeholder="Add any notes for the user..."
            className="w-full px-4 py-3 border-border rounded-md placeholder:text-text-gray"
          />
        </div>
      </div>
    </AppModal>
  );
}
