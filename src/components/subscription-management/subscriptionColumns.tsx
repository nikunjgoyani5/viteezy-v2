"use client";

import React, { useState } from "react";
import { ColumnDef } from "@tanstack/react-table";
import { useRouter } from "next/navigation";
import { Checkbox } from "../ui/table";
import {
  DownIcon,
  ActionMenuIcon,
  EditIcon,
  DeleteIcon,
} from "@/components/icons";
import { ActionMenu } from "@/components/ui/table/ActionMenu";
import type { Subscription } from "@/store/api/types/subscription.types";
import { format } from "date-fns";
import {
  usePauseSubscriptionMutation,
  useCancelSubscriptionMutation,
} from "@/store/api/subscriptionApi";
import { toast } from "react-hot-toast";
import ConfirmModal from "@/components/ui/confirmModal";
import AppModal from "@/components/ui/appModal";
import { Button } from "@/components/ui/button";
import ApiError from "@/components/common/ApiError";

export type SubscriptionRow = Subscription;

const CANCELLATION_REASONS = [
  "Too expensive",
  "Not satisfied with product",
  "Found a better alternative",
  "No longer needed",
  "Moving/relocating",
  "Financial difficulties",
  "Product quality issues",
  "Delivery problems",
  "Customer service issues",
  "Other",
];

interface CancelSubscriptionDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: (data: {
    cancellationReason: string;
    customReason?: string;
    cancelImmediately: boolean;
  }) => void;
  loading: boolean;
  error?: any;
}

const CancelSubscriptionDialog = ({
  open,
  onOpenChange,
  onConfirm,
  loading,
  error,
}: CancelSubscriptionDialogProps) => {
  const [cancelImmediately, setCancelImmediately] = useState(false);
  const [cancellationReason, setCancellationReason] = useState("");
  const [customReason, setCustomReason] = useState("");

  const handleSubmit = () => {
    if (!cancellationReason) {
      toast.error("Please select a cancellation reason");
      return;
    }
    onConfirm({
      cancellationReason,
      customReason:
        cancellationReason === "Other" ? customReason : cancellationReason,
      cancelImmediately,
    });
  };

  const handleClose = () => {
    if (loading) return;
    setCancelImmediately(false);
    setCancellationReason("");
    setCustomReason("");
    onOpenChange(false);
  };

  return (
    <AppModal
      className="xl:min-w-[560px]!"
      open={open}
      onOpenChange={handleClose}
      title="Cancel this subscription?"
      footer={
        <>
          <Button
            size="lg"
            variant="outline"
            onClick={handleClose}
            disabled={loading}
          >
            Cancel
          </Button>
          <Button
            size="lg"
            onClick={handleSubmit}
            disabled={loading}
            className="bg-soft-red text-hard-red hover:bg-soft-red/80"
          >
            {loading ? "Please wait..." : "Confirm Cancellation"}
          </Button>
        </>
      }
    >
      <div className="space-y-5">
        {error && (
          <div className="mb-4">
            <ApiError error={error} />
          </div>
        )}

        {/* Cancel Options */}
        <div>
          <div className="flex items-center gap-4 mb-3">
            <label className="text-sm font-medium text-gray-900 whitespace-nowrap">
              Cancel options:
            </label>
            <div className="flex items-center gap-6">
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="cancelOption"
                  checked={!cancelImmediately}
                  onChange={() => setCancelImmediately(false)}
                  className="w-4 h-4 text-teal-600 cursor-pointer accent-teal-600"
                  disabled={loading}
                />
                <span className="text-sm text-gray-700">
                  Cancel at end date
                </span>
              </label>
              <label className="flex items-center gap-2 cursor-pointer">
                <input
                  type="radio"
                  name="cancelOption"
                  checked={cancelImmediately}
                  onChange={() => setCancelImmediately(true)}
                  className="w-4 h-4 text-teal-600 cursor-pointer accent-teal-600"
                  disabled={loading}
                />
                <span className="text-sm text-gray-700">
                  Cancel immediately
                </span>
              </label>
            </div>
          </div>
        </div>

        {/* Cancellation Reason */}
        <div>
          <label className="block text-sm font-medium text-gray-900 mb-2">
            Cancellation Reason
          </label>
          <select
            value={cancellationReason}
            onChange={(e) => setCancellationReason(e.target.value)}
            className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 text-sm appearance-none bg-white"
            style={{
              backgroundImage: `url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' fill='none' viewBox='0 0 24 24' stroke='currentColor'%3E%3Cpath stroke-linecap='round' stroke-linejoin='round' stroke-width='2' d='M19 9l-7 7-7-7'%3E%3C/path%3E%3C/svg%3E")`,
              backgroundRepeat: "no-repeat",
              backgroundPosition: "right 0.75rem center",
              backgroundSize: "1.25rem",
              paddingRight: "2.5rem",
            }}
            disabled={loading}
          >
            <option value="" className="text-gray-400">
              Select cancellation reason
            </option>
            {CANCELLATION_REASONS.map((reason) => (
              <option key={reason} value={reason}>
                {reason}
              </option>
            ))}
          </select>
        </div>

        {/* Custom Reason (only shown when "Other" is selected) */}
        {cancellationReason === "Other" && (
          <div>
            <label className="block text-sm font-medium text-gray-900 mb-2">
              Custom Reason
            </label>
            <textarea
              value={customReason}
              onChange={(e) => setCustomReason(e.target.value)}
              placeholder="Please specify the reason..."
              className="w-full px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-teal-500 text-sm resize-none"
              rows={3}
              disabled={loading}
            />
          </div>
        )}
      </div>
    </AppModal>
  );
};

const GatewayBadge = ({ gateway }: { gateway: string }) => {
  const colors: Record<string, string> = {
    stripe: "bg-ultra-blue text-white",
    mollie: "bg-black text-white",
  };

  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-medium  mb-0.5 ${colors[gateway.toLowerCase()] || "bg-gray-100 text-gray-800"
        }`}
    >
      {gateway}
    </span>
  );
};

const StatusBadge = ({ status }: { status: string }) => {
  const colors: Record<string, string> = {
    active: "bg-green-100 text-green-800",
    cancelled: "bg-red-100 text-red-800",
    paused: "bg-yellow-100 text-yellow-800",
    expired: "bg-gray-100 text-gray-800",
  };

  return (
    <span
      className={`inline-flex items-center px-3 py-1 rounded-full text-xs font-medium ${colors[status.toLowerCase()] || "bg-gray-100 text-gray-800"
        }`}
    >
      {status}
    </span>
  );
};

const ActionsCell = ({ row }: { row: SubscriptionRow }) => {
  const router = useRouter();
  const [pauseSubscription, { isLoading: isPausing }] =
    usePauseSubscriptionMutation();
  const [cancelSubscription, { isLoading: isCancelling }] =
    useCancelSubscriptionMutation();
  const [showPauseConfirm, setShowPauseConfirm] = useState(false);
  const [showCancelDialog, setShowCancelDialog] = useState(false);
  const [cancelError, setCancelError] = useState<any>(null);

  const handleViewDetails = () => {
    router.push(`/admin/subscription-management/${row.id}`);
  };

  const handlePauseConfirm = async () => {
    try {
      const result = await pauseSubscription(row.id).unwrap();
      toast.success(result.message || "Subscription paused successfully");
      setShowPauseConfirm(false);
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to pause subscription");
    }
  };

  const handleCancelConfirm = async (data: {
    cancellationReason: string;
    customReason?: string;
    cancelImmediately: boolean;
  }) => {
    try {
      setCancelError(null);
      const result = await cancelSubscription({
        subscriptionId: row.id,
        data,
      }).unwrap();
      toast.success(result.message || "Subscription cancelled successfully");
      setShowCancelDialog(false);
    } catch (error: any) {
      setCancelError(error?.data?.message || "Failed to cancel subscription");
    }
  };

  const isPaused = row.status === "Paused";
  const isCancelled = row.status === "Cancelled";
  const canPause = !isPaused && !isCancelled;

  const menuItems = [
    {
      label: "Pause Subscription",
      onClick: () => setShowPauseConfirm(true),
      icon: <EditIcon />,
      disabled: !canPause || isPausing,
    },
    {
      label: "Cancel Subscription",
      onClick: () => {
        setCancelError(null);
        setShowCancelDialog(true);
      },
      icon: <DeleteIcon />,
      danger: true,
      disabled: isCancelled,
    },
  ];

  return (
    <>
      <ActionMenu items={menuItems} />

      <ConfirmModal
        open={showPauseConfirm}
        onOpenChange={setShowPauseConfirm}
        title="Pause this subscription?"
        description="Are you sure you want to pause this subscription?"
        confirmText="Pause subscription"
        cancelText="Cancel"
        variant="danger"
        loading={isPausing}
        onConfirm={handlePauseConfirm}
      />

      <CancelSubscriptionDialog
        open={showCancelDialog}
        onOpenChange={setShowCancelDialog}
        onConfirm={handleCancelConfirm}
        loading={isCancelling}
        error={cancelError}
      />
    </>
  );
};

export const subscriptionColumns: ColumnDef<SubscriptionRow>[] = [
  {
    id: "select",
    header: ({ table }) => (
      <Checkbox
        checked={table.getIsAllPageRowsSelected()}
        indeterminate={table.getIsSomePageRowsSelected()}
        onChange={(value) => table.toggleAllPageRowsSelected(!!value)}
        aria-label="Select all"
      />
    ),
    cell: ({ row }) => (
      <Checkbox
        checked={row.getIsSelected()}
        onChange={(value) => row.toggleSelected(!!value)}
        aria-label="Select row"
      />
    ),
    enableSorting: false,
    enableHiding: false,
  },
  {
    accessorKey: "subscriptionNumber",
    header: "Subscription ID",
    cell: ({ row }) => {
      const router = useRouter();
      const subscriptionNumber = row.getValue("subscriptionNumber") as string;
      const id = row.original.id;
      return (
        <button
          onClick={() =>
            router.push(
              `/admin/subscription-management/${encodeURIComponent(id)}`
            )
          }
          className="font-medium text-black hover:text-blue-600 hover:underline transition-colors text-left cursor-pointer"
        >
          {subscriptionNumber}
        </button>
      );
    },
  },
  {
    accessorKey: "user",
    header: "Customer",
    cell: ({ row }) => {
      const user = row.original.user;
      const [open, setOpen] = React.useState(false);
      const customerMenuRef = React.useRef<HTMLDivElement | null>(null);
      const router = useRouter();
      const subscriptionNumber = row.getValue("subscriptionNumber") as string;
      const id = row.original.id;

      React.useEffect(() => {
        if (!open) return;

        const handlePointerDown = (event: MouseEvent) => {
          if (
            customerMenuRef.current &&
            !customerMenuRef.current.contains(event.target as Node)
          ) {
            setOpen(false);
          }
        };

        const handleEscape = (event: KeyboardEvent) => {
          if (event.key === "Escape") {
            setOpen(false);
          }
        };

        document.addEventListener("mousedown", handlePointerDown);
        document.addEventListener("keydown", handleEscape);

        return () => {
          document.removeEventListener("mousedown", handlePointerDown);
          document.removeEventListener("keydown", handleEscape);
        };
      }, [open]);

      if (!user) {
        return <span className="text-gray-400">N/A</span>;
      }

      return (
        <div
          ref={customerMenuRef}
          className="relative cursor-pointer inline-flex items-center group"
          onClick={(e) => {
            e.stopPropagation();
            setOpen((v) => !v);
          }}
        >
          <span className="font-medium text-black">{user.fullName}</span>
          <button
            aria-label="Open customer menu"
            className="ml-1 mt-1 opacity-0 group-hover:opacity-100 transition-opacity"
          >
            <DownIcon />
          </button>

          {open && (
            <div
              className="absolute left-0 top-full mt-3 w-72 bg-white border border-gray-200 rounded-md shadow-lg z-50 p-3"
              onClick={(e) => e.stopPropagation()}
            >
              <div className="text-base font-semibold text-gray-900">
                {user.fullName}
              </div>
              {user.email && (
                <a
                  href={`mailto:${user.email}`}
                  className="text-teal-600 text-sm mt-2 block"
                >
                  {user.email}
                </a>
              )}
              <button
                onClick={() =>
                  router.push(
                    `/admin/subscription-management/${encodeURIComponent(id)}`
                  )
                }
                className="mt-3 w-full border border-extra-light-gray rounded-md py-2 text-sm hover:bg-gray-50"
              >
                View customer
              </button>
            </div>
          )}
        </div>
      );
    },
  },
  {
    accessorKey: "items",
    header: "Products",
    cell: ({ row }) => {
      const items = row.original.items;
      if (!items || items.length === 0) {
        return <span className="text-gray-400">No products</span>;
      }

      const productNames = items
        .map((item) => {
          if (item.product?.title) {
            return item.product.title;
          }
          return item.name;
        })
        .join(", ");

      return (
        <div className="text-sm max-w-xs truncate" title={productNames}>
          {productNames}
        </div>
      );
    },
  },
  {
    accessorKey: "cycleDays",
    header: "Plan duration",
    cell: ({ row }) => {
      const cycleDays = row.getValue("cycleDays") as number;
      return <div className="text-sm">{cycleDays} Days</div>;
    },
  },
  {
    accessorKey: "subscriptionStartDate",
    header: "Start date",
    cell: ({ row }) => {
      const date = row.getValue("subscriptionStartDate") as string;
      const formatted = format(new Date(date), "MMM dd, yyyy");
      return <div className="text-sm">{formatted}</div>;
    },
  },
  {
    accessorKey: "nextBillingDate",
    header: "Next billing date",
    cell: ({ row }) => {
      const date = row.getValue("nextBillingDate") as string;
      const formatted = format(new Date(date), "MMM dd, yyyy");
      return <div className="text-sm">{formatted}</div>;
    },
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => <StatusBadge status={row.getValue("status")} />,
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => <ActionsCell row={row.original} />,
  },
];
