"use client";

import React, { useState, useEffect } from "react";
import InputField from "@/components/ui/inputs/input";
import { generateSlugFromTitle } from "@/lib/slugUtils";
import { RefreshCw } from "lucide-react";

interface SlugInputProps {
  label?: string;
  placeholder?: string;
  value: string;
  onChange: (value: string) => void;
  error?: string;
  required?: boolean;
  disabled?: boolean;
  titleForGeneration?: string;
  maxLength?: number;
  className?: string;
  inputClassName?: string;
}

export default function SlugInput({
  label = "Slug",
  placeholder = "e.g. my-first-post",
  value,
  onChange,
  error,
  required = false,
  disabled = false,
  titleForGeneration,
  maxLength = 80,
  className,
  inputClassName,
}: SlugInputProps) {
  const [lastGeneratedSlug, setLastGeneratedSlug] = useState<string>("");
  const [userEdited, setUserEdited] = useState<boolean>(false);

  // Auto-fill slug when title changes and user hasn't edited manually
  useEffect(() => {
    if (!userEdited) {
      if (!titleForGeneration?.trim()) {
        // Clear slug if title is empty
        if (value !== "") {
          onChange("");
        }
        setLastGeneratedSlug("");
      } else {
        // Generate slug from title
        const generatedSlug = generateSlugFromTitle(titleForGeneration);
        if (generatedSlug !== value) {
          onChange(generatedSlug);
          setLastGeneratedSlug(generatedSlug);
        }
      }
    }
  }, [titleForGeneration, userEdited, value, onChange]);

  const handleGenerateSlug = () => {
    if (!titleForGeneration?.trim()) return;

    const generatedSlug = generateSlugFromTitle(titleForGeneration);
    onChange(generatedSlug);
    setLastGeneratedSlug(generatedSlug);
    setUserEdited(false); // Reset user edit flag after generation
  };

  const handleManualChange = (newValue: string) => {
    onChange(newValue);
    setUserEdited(true); // Mark as user edited
  };

  const isGenerateDisabled =
    disabled ||
    !titleForGeneration?.trim() ||
    generateSlugFromTitle(titleForGeneration) === value;

  return (
    <div className={`${className || ""}`}>
      <div className="flex-1">
        {label && (
          <label className="text-sm 3xl:text-base font-medium text-gray-700 mb-1 block">
            {label}
            {required && <span className="text-red-500">*</span>}
          </label>
        )}
        <div className="flex items-center w-full gap-2">
          <InputField
            // label={label}
            placeholder={placeholder}
            value={value}
            onChange={(e) => handleManualChange(e.target.value)}
            error={error}
            required={required}
            disabled={disabled}
            maxLengthCount={maxLength}
            className={inputClassName}
          />
          {titleForGeneration && (
            <button
              type="button"
              onClick={handleGenerateSlug}
              disabled={isGenerateDisabled}
              className={`shrink-0 p-1.75 rounded-md transition-colors ${
                isGenerateDisabled
                  ? "text-gray-400 cursor-not-allowed"
                  : "hover:text-teal-700 hover:bg-gray-100 cursor-pointer"
              }`}
              title={
                isGenerateDisabled
                  ? "No title available or slug already generated"
                  : "Generate slug from title"
              }
            >
              <RefreshCw className="w-4 h-4" />
            </button>
          )}
        </div>
      </div>
    </div>
  );
}
