import ManageCouponPage from "@/components/coupon-management/manage";

export default async function CouponEditPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = await params;
  return <ManageCouponPage mode="edit" id={id} />;
}
