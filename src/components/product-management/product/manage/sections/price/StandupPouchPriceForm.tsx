"use client";

import React, { useState, useEffect } from "react";
import { useFormContext } from "react-hook-form";
import { Accordion } from "@/components/ui/accordion";
import PriceRow from "./PriceRow";

export default function StandupPouchPriceForm() {
  const [openItem, setOpenItem] = useState<string | undefined>(
    "One-time (60 Count)"
  );

  const POUCH_ROWS = [
    { label: "One-time (60 Count)", basePath: "standupPouchPrice.count_0" },
    { label: "One-time (120 Count)", basePath: "standupPouchPrice.count_1" },
  ];

  const {
    watch,
    formState: { errors, submitCount },
  } = useFormContext();
  const hasStandupPouch = watch("hasStandupPouch");

  // Auto-open first accordion with error after submit
  useEffect(() => {
    if (submitCount > 0) {
      const firstError = POUCH_ROWS.find((row) => {
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

  if (!hasStandupPouch) {
    return (
      <div className="p-4">
        <div className="p-8 text-center bg-gray-50 rounded-lg border border-dashed border-gray-300">
          <p className="text-gray-500 text-sm">
            Stand-up Pouch option is disabled.
            <br />
            Enable it in <strong>Basic Details</strong> to configure prices.
          </p>
        </div>
      </div>
    );
  }

  return (
    <div className="">
      <Accordion
        type="single"
        collapsible
        value={openItem}
        onValueChange={setOpenItem}
        className="w-full"
      >
        {POUCH_ROWS.map((row) => (
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
