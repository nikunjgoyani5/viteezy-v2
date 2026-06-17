"use client";

import React, { useState } from "react";
import { useFormContext } from "react-hook-form";
import { Trash2, Plus } from "lucide-react";
import InputField from "@/components/ui/inputs/input";

export default function BenefitsSection() {
  const { register, getValues, setValue } = useFormContext();

  const [fieldCount, setFieldCount] = useState<number>(() => {
    const b = getValues("benefits");
    const n = Array.isArray(b) ? b.length : 0;
    return n > 0 ? n : 1;
  });

  const handleAdd = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    const n = fieldCount;
    const current = Array.from({ length: n }, (_, i) =>
      getValues(`benefits.${i}`) ?? ""
    );
    const next = [...current, ""];
    setValue("benefits", next, { shouldValidate: false });
    setFieldCount(next.length);
  };

  const handleRemove = (index: number) => {
    if (fieldCount <= 1) return;
    const current = Array.from({ length: fieldCount }, (_, i) =>
      getValues(`benefits.${i}`) ?? ""
    );
    const next = current.filter((_, i) => i !== index);
    setValue("benefits", next, { shouldValidate: false });
    setFieldCount(next.length);
  };

  const n = Math.max(1, fieldCount);

  return (
    <div className="space-y-5 p-5">
      <div className="space-y-3">
        {Array.from({ length: n }, (_, index) => (
          <div key={index} className="flex items-start gap-3">
            <div className="flex-1">
              <InputField
                label={index === 0 ? "Benefits" : undefined}
                placeholder="e.g. Supports bone health"
                {...register(`benefits.${index}`)}
              />
            </div>
            {n > 1 && (
              <button
                type="button"
                onClick={() => handleRemove(index)}
                className={`p-2 text-gray-400 hover:text-red-500 hover:bg-red-50 rounded-md transition-colors cursor-pointer ${
                  index === 0 ? "mt-7" : "mt-1"
                }`}
                title="Remove benefit"
              >
                <Trash2 className="w-5 h-5" />
              </button>
            )}
          </div>
        ))}
      </div>

      <div className="flex justify-end">
        <button
          type="button"
          onClick={handleAdd}
          className="flex items-center text-sm gap-2 text-teal-600 hover:text-teal-700 font-medium transition-colors cursor-pointer"
        >
          <Plus className="w-4 h-4" />
          Add New Benefit
        </button>
      </div>
    </div>
  );
}
