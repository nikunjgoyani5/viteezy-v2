import React, { Suspense } from "react";
import Link from "next/link";
import { PageHeader } from "@/components/layout/PageHeader";
import HeaderBannersTable from "@/components/header-banners";
import { Button } from "@/components/ui/button";
import { MdOutlineAdd } from "react-icons/md";
import { ROUTES } from "@/constants/routes";

export default function HeaderBannersPage() {
  return (
    <div>
      <PageHeader
        title="Offer Banners"
        actions={
          <Link href={`${ROUTES.HEADER_BANNERS}/create`}>
            <Button variant="teal" className="text-sm 3xl:text-base">
              <MdOutlineAdd size={20} />
              Add Offer Banner
            </Button>
          </Link>
        }
      />
      <Suspense fallback={null}>
        <HeaderBannersTable />
      </Suspense>
    </div>
  );
}

