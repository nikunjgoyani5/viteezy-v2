"use client";

import React from "react";

type ApiFieldError = {
  field: string;
  message: string;
  value?: any;
};

export type ApiErrorResponse = {
  success?: boolean;
  message?: string;
  errorType?: string;
  error?: string;
  data?: any;
  errors?: ApiFieldError[];
};

export default function ApiError({
  error,
  className = "",
}: {
  error?: ApiErrorResponse | string | null;
  className?: string;
}) {
  if (!error) return null;

  const payload: ApiErrorResponse =
    typeof error === "string" ? { message: error } : error;

  const topMessage =
    payload.message ||
    payload.error ||
    "Something went wrong. Please try again.";

  const fieldErrors = payload.errors ?? [];

  return (
    <div
      className={`bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg text-sm ${className}`}
    >
      <div className="font-medium">{topMessage}</div>

      {fieldErrors.length > 0 && (
        <ul className="mt-2 list-disc pl-5 space-y-1">
          {fieldErrors.map((e, idx) => (
            <li key={`${e.field}-${idx}`}>
              <span className="font-medium">{e.field}:</span> {e.message}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
