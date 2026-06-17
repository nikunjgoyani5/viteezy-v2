"use client";

import React from "react";
import type { ColumnDef } from "@tanstack/react-table";
import { format, isPast, parseISO } from "date-fns";
import { MdEdit, MdDelete } from "react-icons/md";

import { Checkbox } from "@/components/ui/table/Checkbox";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import { ToggleSwitch } from "@/components/ui/table";
import type { Coupon } from "@/store/api/types/coupon.types";
import { formatCurrencySimple } from "@/lib/currencyUtils";
import { cn } from "@/lib/utils";

type CouponColumnsArgs = {
  onEdit: (row: Coupon) => void;
  onDelete: (row: Coupon) => void;
  onToggleStatus?: (row: Coupon, checked: boolean) => void;
  updatingId?: string | null;
};

// Helper to check if coupon is expired
const isExpired = (validUntil?: string): boolean => {
  if (!validUntil) return false;
  return isPast(parseISO(validUntil));
};

// Helper to format date range
const formatDateRange = (from?: string, until?: string): string => {
  if (!from && !until) return "-";
  const fromDate = from ? format(parseISO(from), "MMM dd, yyyy") : "N/A";
  const untilDate = until ? format(parseISO(until), "MMM dd, yyyy") : "N/A";
  // return `${fromDate} - ${untilDate}`;
  return `${untilDate}`;
};

// Helper to format discount value
const formatDiscount = (type: string, value: number): string => {
  if (type.toLowerCase() === "percentage") {
    return `${value}%`;
  }
  return formatCurrencySimple(value);
};

// Helper to get discount badge styles
const getDiscountBadgeStyle = (
  type: string,
  expired: boolean
): { bg: string; text: string } => {
  if (expired) {
    return { bg: "bg-slate-gray", text: "text-gray-500" };
  }

  if (type.toLowerCase() === "percentage") {
    return { bg: "bg-[#FFEB78]", text: "text-gray-900" };
  }

  // Fixed/Flat
  return { bg: "bg-[#AFFEBF]", text: "text-gray-900" };
};

export const couponColumns = ({
  onEdit,
  onDelete,
  onToggleStatus,
  updatingId,
}: CouponColumnsArgs): ColumnDef<Coupon>[] => [
  {
    accessorKey: "code",
    header: "Coupon Code",
    cell: ({ row }) => {
      const coupon = row.original;
      const expired = isExpired(coupon.validUntil);

      return (
        <div className="flex flex-col 3xl:flex-row gap-2 items-center">
          <span
            className={cn(
              "font-medium bg-slate-gray border max-w-fit px-2.5 py-1.5 rounded-sm text-sm 3xl:text-base",
              expired ? "text-gray-500 opacity-50" : "text-gray-900"
            )}
          >
            {coupon.code}
          </span>
          {expired && (
            <span className="text-sm 3xl:text-base text-red font-medium">
              Expired
            </span>
          )}
        </div>
      );
    },
  },
  {
    accessorKey: "type",
    header: "Discount",
    cell: ({ row }) => {
      const coupon = row.original;
      const expired = isExpired(coupon.validUntil);
      const badgeStyle = getDiscountBadgeStyle(coupon.type, expired);

      const getTypeLabel = (type: string): string => {
        const lowerType = type.toLowerCase();
        if (lowerType === "percentage") return "OFF";
        if (lowerType === "fixed") return "FLATE";
        return type;
      };

      return (
        <div className="flex gap-2 items-center">
          <span
            className={cn(
              "border max-w-fit px-2 py-1 rounded-sm text-xs 3xl:text-sm",
              badgeStyle.bg,
              badgeStyle.text,
              expired && "opacity-50"
            )}
          >
            {formatDiscount(coupon.type, coupon.value)}{" "}
            {getTypeLabel(coupon.type)}
          </span>
        </div>
      );
    },
  },
  {
    id: "usage",
    header: "Usage",
    cell: ({ row }) => {
      const coupon = row.original;
      const usageText = coupon.usageLimit
        ? `${coupon.usageCount} / ${coupon.usageLimit}`
        : `${coupon.usageCount} / ∞`;

      const usagePercent = coupon.usageLimit
        ? (coupon.usageCount / coupon.usageLimit) * 100
        : 0;

      return (
        <div className="flex flex-col gap-1">
          <span className="text-sm">{usageText}</span>
          {coupon.usageLimit && (
            <div
              className={`${
                usagePercent >= 100 ? "opacity-50" : ""
              } w-30 h-1.75 bg-gray-200 rounded-full overflow-hidden`}
            >
              <div
                className={cn("h-full rounded-full bg-black")}
                style={{ width: `${Math.min(usagePercent, 100)}%` }}
              />
            </div>
          )}
        </div>
      );
    },
  },
  {
    id: "minOrderAmount",
    header: "Min Amount",
    cell: ({ row }) => {
      return (
        <span className={cn("text-sm whitespace-nowrap")}>
          {row.original.minOrderAmount}
        </span>
      );
    },
  },
  {
    id: "validity",
    header: "Expiry",
    cell: ({ row }) => {
      const coupon = row.original;
      const expired = isExpired(coupon.validUntil);

      return (
        <span
          className={cn(
            "text-sm whitespace-nowrap",
            expired ? "text-red-500" : "text-gray-700"
          )}
        >
          {formatDateRange(coupon.validFrom, coupon.validUntil)}
        </span>
      );
    },
  },
  {
    id: "status",
    header: "Status",
    cell: ({ row }) => {
      const coupon = row.original;
      const isUpdating = updatingId === coupon._id;
      const expired = isExpired(coupon.validUntil);

      return (
        <ToggleSwitch
          checked={coupon.isActive}
          disabled={isUpdating || expired}
          onChange={(checked) => onToggleStatus?.(coupon, checked)}
        />
      );
    },
  },
  {
    id: "actions",
    header: () => <div className="text-center">Actions</div>,
    cell: ({ row }) => (
      <div className="flex justify-center">
        <ActionMenu
          items={[
            {
              label: "Edit",
              icon: <MdEdit className="h-4 w-4" />,
              onClick: () => onEdit(row.original),
            },
            {
              label: "Delete",
              icon: <MdDelete className="h-4 w-4" />,
              onClick: () => onDelete(row.original),
              danger: true,
            },
          ]}
        />
      </div>
    ),
  },
];
