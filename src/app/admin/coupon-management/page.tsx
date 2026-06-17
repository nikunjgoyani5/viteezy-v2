import CouponManagementPage from "@/components/coupon-management";
import { PageHeader } from "@/components/layout/PageHeader";
import { Button } from "@/components/ui/button";
import { ROUTES } from "@/constants/routes";
import Link from "next/link";
import React, { Suspense } from "react";
import { MdOutlineAdd } from "react-icons/md";

const CouponManagement = () => {
  return (
    <div>
      <PageHeader
        title="Coupon Management"
        actions={
          <Link href={ROUTES.COUPON_MANAGEMENT.CREATE}>
            <Button variant="teal" className="text-sm 3xl:text-base">
              <MdOutlineAdd size={20} />
              Create Coupon
            </Button>
          </Link>
        }
      />
      <Suspense fallback={null}>
        <CouponManagementPage />
      </Suspense>
    </div>
  );
};

export default CouponManagement;
