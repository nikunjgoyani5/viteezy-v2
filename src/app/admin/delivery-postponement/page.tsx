"use client";

import React, { Suspense } from "react";
import { PageHeader } from "@/components/layout/PageHeader";
import DeliveryPostponementTable from "@/components/delivery-postponement";

export default function DeliveryPostponementPage() {
  return (
    <>
      <PageHeader title="Delivery Postponement" />
      <div className="mt-4">
        <Suspense fallback={null}>
          <DeliveryPostponementTable />
        </Suspense>
      </div>
    </>
  );
}
