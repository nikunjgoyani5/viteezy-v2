import type { PostponementItem, PostponementStatus } from "@/store/api/types/postponement.types";

export type DeliveryPostponementStatus = PostponementStatus;

/** Row type for table and modals: use API item directly */
export type DeliveryPostponementRow = PostponementItem;

export function getPostponementUserName(row: DeliveryPostponementRow): string {
  const u = row.user;
  if (!u) return "—";
  const name = [u.firstName, u.lastName].filter(Boolean).join(" ").trim();
  return name || u.email || "—";
}
