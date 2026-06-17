"use client";

import React, { useEffect, useState } from "react";
import toast from "react-hot-toast";
import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import type { DeliveryPostponementRow } from "./types";
import { getPostponementUserName } from "./types";
import { format, parseISO, isValid } from "date-fns";
import { InputField, TextareaField } from "../ui/inputs";
import { useUpdateApprovedDateMutation } from "@/store/api/postponementsApi";

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

interface ModifyDeliveryDateModalProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  row: DeliveryPostponementRow | null;
}

export function ModifyDeliveryDateModal({
  open,
  onOpenChange,
  row,
}: ModifyDeliveryDateModalProps) {
  const [newDate, setNewDate] = useState("");
  const [reason, setReason] = useState("");

  const [updateApprovedDate, { isLoading }] = useUpdateApprovedDateMutation();

  useEffect(() => {
    if (open && row) {
      const initial =
        toYYYYMMDD(row.approvedDeliveryDate) ||
        toYYYYMMDD(row.currentDeliveryDate) ||
        toYYYYMMDD(row.requestedDeliveryDate);
      setNewDate(initial);
    }
  }, [open, row]);

  const handleClose = () => {
    setNewDate("");
    setReason("");
    onOpenChange(false);
  };

  const handleApprove = async () => {
    if (!row || !newDate) return;
    try {
      const iso = new Date(newDate + "T00:00:00.000Z").toISOString();
      const res = await updateApprovedDate({
        id: row.id,
        approvedDeliveryDate: iso,
      }).unwrap();
      if (res.success) {
        toast.success(res.message || "Delivery date updated");
        handleClose();
      } else {
        toast.error(res.message || "Failed to update delivery date");
      }
    } catch (err: unknown) {
      const msg =
        (err as { data?: { message?: string } })?.data?.message ||
        "Failed to update delivery date";
      toast.error(msg);
    }
  };

  if (!row) return null;

  return (
    <AppModal
      open={open}
      onOpenChange={handleClose}
      title="Modify Delivery Date"
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
            variant="teal"
            onClick={handleApprove}
            disabled={!newDate || isLoading}
          >
            {isLoading ? "Updating..." : "Approve with New Date"}
          </Button>
        </>
      }
    >
      <div className="space-y-6">
        <p>
          Review and update the delivery date for{" "}
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
          <InputField
            label="New Approved Date"
            required
            type="date"
            value={newDate}
            onChange={(e) => setNewDate(e.target.value)}
          />
          <p className="text-xs 3xl:text-sm text-gray-500 mt-1">
            Select the final approved delivery date.
          </p>
        </div>
        <div>
          <TextareaField
            label="Reason for modification"
            value={reason}
            onChange={(e) => setReason(e.target.value)}
            placeholder="Explain why you're modifying the date (optional)..."
            className="w-full px-4 py-3 border-border rounded-md placeholder:text-text-gray"
          />
        </div>
      </div>
    </AppModal>
  );
}
