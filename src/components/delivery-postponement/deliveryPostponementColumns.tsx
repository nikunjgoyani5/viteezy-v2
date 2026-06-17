"use client";

import React, { useState } from "react";
import { ColumnDef } from "@tanstack/react-table";
import { Button } from "@/components/ui/button";
import { format, parseISO, isValid } from "date-fns";
import type { DeliveryPostponementRow, DeliveryPostponementStatus } from "./types";
import { getPostponementUserName } from "./types";
import { ApprovePostponementModal } from "./ApprovePostponementModal";
import { RejectPostponementModal } from "./RejectPostponementModal";
import { ModifyDeliveryDateModal } from "./ModifyDeliveryDateModal";

const statusStyles: Record<
  DeliveryPostponementStatus,
  string
> = {
  Pending: "bg-yellow text-dark-yellow",
  Approved: "bg-parrot-green text-dark-green",
  Rejected: "bg-soft-red text-hard-red",
};

function formatDate(iso: string | null | undefined): string {
  if (!iso) return "—";
  try {
    const d = parseISO(iso);
    return isValid(d) ? format(d, "MMM dd, yyyy") : "—";
  } catch {
    return "—";
  }
}

function StatusBadge({ status }: { status: DeliveryPostponementStatus }) {
  return (
    <span
      className={`inline-flex items-center px-2 h-7 rounded-sm text-xs 3xl:text-sm font-medium ${statusStyles[status] ?? "bg-gray-100 text-gray-800"}`}
    >
      {status}
    </span>
  );
}

function ActionsCell({ row }: { row: DeliveryPostponementRow }) {
  const [approveOpen, setApproveOpen] = useState(false);
  const [rejectOpen, setRejectOpen] = useState(false);
  const [modifyOpen, setModifyOpen] = useState(false);

  const { status } = row;

  return (
    <>
      <div className="flex items-center gap-2 flex-wrap">
        {status === "Pending" && (
          <>
            <Button
              size="sm"
              variant="teal"
              className="h-7 px-2 text-xs 3xl:text-sm"
              onClick={() => setApproveOpen(true)}
            >
              Approve
            </Button>
            <Button
              size="sm"
              variant="coral-red"
              className="h-7 px-2 text-xs 3xl:text-sm"
              onClick={() => setRejectOpen(true)}
            >
              Reject
            </Button>
          </>
        )}
        {status === "Approved" && (
          <Button
            size="sm"
            variant="outline"
            className="h-7 px-2 bg-cyan-blue text-dark-cyan hover:bg-cyan-blue/90 text-xs 3xl:text-sm"
            onClick={() => setModifyOpen(true)}
          >
            Edit
          </Button>
        )}
        {status === "Rejected" && (
          <Button
            size="sm"
            variant="outline"
            className="h-7 px-2 bg-gray-100 text-gray-700 border-0 cursor-auto text-xs 3xl:text-sm"
            onClick={() => {}}
          >
            Processed
          </Button>
        )}
      </div>

      <ApprovePostponementModal
        open={approveOpen}
        onOpenChange={setApproveOpen}
        row={row}
      />
      <RejectPostponementModal
        open={rejectOpen}
        onOpenChange={setRejectOpen}
        row={row}
      />
      <ModifyDeliveryDateModal
        open={modifyOpen}
        onOpenChange={setModifyOpen}
        row={row}
      />
    </>
  );
}

export const deliveryPostponementColumns: ColumnDef<DeliveryPostponementRow>[] = [
  {
    id: "userName",
    header: "User name",
    accessorFn: (row) => getPostponementUserName(row),
    cell: ({ row }) => (
      <span className="font-medium text-gray-900">
        {getPostponementUserName(row.original)}
      </span>
    ),
  },
  {
    accessorKey: "plan",
    header: "Plan",
    cell: ({ row }) => (
      <span className="font-medium text-gray-900">{row.original.plan}</span>
    ),
  },
  {
    id: "originalDeliveryDate",
    header: "Original Delivery Date",
    accessorFn: (row) => row.originalDeliveryDate,
    cell: ({ row }) => (
      <span className="font-medium text-gray-900">
        {formatDate(row.original.originalDeliveryDate)}
      </span>
    ),
  },
  {
    id: "requestedDeliveryDate",
    header: "Requested Delivery Date",
    accessorFn: (row) => row.requestedDeliveryDate,
    cell: ({ row }) => (
      <span className="font-medium text-gray-900">
        {formatDate(row.original.requestedDeliveryDate)}
      </span>
    ),
  },
  {
    accessorKey: "status",
    header: "Status",
    cell: ({ row }) => {
      const r = row.original;
      const dateModified =
        r.status === "Approved" &&
        r.requestedDeliveryDate &&
        r.approvedDeliveryDate &&
        r.requestedDeliveryDate !== r.approvedDeliveryDate;

      return (
        <div className="flex items-center gap-2">
          <StatusBadge status={r.status} />
          {dateModified && (
            <span className="text-xs 3xl:text-sm font-medium text-gray-600">
              Date modified
            </span>
          )}
        </div>
      );
    },
  },
  {
    id: "actions",
    header: "Actions",
    cell: ({ row }) => <ActionsCell row={row.original} />,
  },
];
