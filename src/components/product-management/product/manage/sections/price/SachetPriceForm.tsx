"use client";

import React, { useState, useEffect } from "react";
import { useFormContext } from "react-hook-form";
import { Accordion } from "@/components/ui/accordion";
import PriceRow from "./PriceRow";

export default function SachetPriceForm() {
  const [openItem, setOpenItem] = useState<string | undefined>("180 Days");

  const SACHET_ROWS = [
    { label: "180 Days", basePath: "sachetPrices.oneEightyDays" },
    { label: "90 Days", basePath: "sachetPrices.ninetyDays" },
    { label: "60 Days", basePath: "sachetPrices.sixtyDays" },
    { label: "30 Days", basePath: "sachetPrices.thirtyDays" },
  ];

  const {
    formState: { errors, submitCount },
  } = useFormContext();

  // Auto-open first accordion with error after submit
  useEffect(() => {
    if (submitCount > 0) {
      const firstError = SACHET_ROWS.find((row) => {
        const path = row.basePath.split(".");
        let err = errors as Record<string, any>;
        for (const key of path) {
          err = err?.[key];
        }
        return !!err;
      });
      if (firstError) {
        setTimeout(() => {
          setOpenItem(firstError.label);
        }, 0);
      }
    }
    // Only re-run when submitCount changes to avoid switching while user is typing
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [submitCount]);

  return (
    <div className="">
      <Accordion
        type="single"
        collapsible
        value={openItem}
        onValueChange={setOpenItem}
        className="w-full"
      >
        {SACHET_ROWS.map((row) => (
          <PriceRow
            key={row.label}
            label={row.label}
            basePath={row.basePath}
            isStandaloneAccordion={false}
          />
        ))}
      </Accordion>
    </div>
  );
}
