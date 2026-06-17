"use client";

import React, { useId, useState } from "react";
import { cn } from "@/lib/utils";
import { X, Plus, FileIcon } from "lucide-react";
import { FiUpload } from "react-icons/fi"; // Keep consistent icon
import Image from "next/image";
import AppImage from "./appImage";

export type MultiUploadValue = (File | string)[];

type MultiUploadFileProps = {
  label?: string;
  required?: boolean;
  error?: string;
  value?: MultiUploadValue;
  onChange?: (value: MultiUploadValue) => void;
  accept?: string;
  maxSizeMB?: number;
  disabled?: boolean;
  className?: string;
  helperText?: string;
  maxFiles?: number;
};

export default function MultiUploadFile({
  label,
  required,
  error,
  value = [],
  onChange,
  accept = "image/*",
  maxSizeMB = 2,
  disabled,
  className,
  helperText = "Accepts images, videos, or 3D models",
  maxFiles,
}: MultiUploadFileProps) {
  const inputId = useId();
  const [internalError, setLocalError] = useState<string | null>(null);
  const [isDragging, setIsDragging] = useState(false); // Add drag state back

  const getPreview = (item: File | string) => {
    if (typeof item === "string") return item;
    return URL.createObjectURL(item);
  };

  // Common validate function
  const validateAndAdd = (files: File[]) => {
    setLocalError(null);
    const validFiles: File[] = [];

    for (const file of files) {
      if (file.size > maxSizeMB * 1024 * 1024) {
        setLocalError(`File "${file.name}" exceeds ${maxSizeMB}MB.`);
        continue;
      }
      validFiles.push(file);
    }

    if (maxFiles && value.length + validFiles.length > maxFiles) {
      setLocalError(`You can only upload up to ${maxFiles} files.`);
      return;
    }

    onChange?.([...value, ...validFiles]);
  };

  const handlePick: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const files = Array.from(e.target.files || []);
    if (files.length === 0) return;
    validateAndAdd(files);
    e.target.value = "";
  };

  const handleRemove = (index: number) => {
    const newValue = [...value];
    newValue.splice(index, 1);
    onChange?.(newValue);
  };

  // Drag handlers
  const onDragOver: React.DragEventHandler<HTMLDivElement> = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (disabled) return;
    setIsDragging(true);
  };

  const onDragLeave: React.DragEventHandler<HTMLDivElement> = (e) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDragging(false);
  };

  const onDrop: React.DragEventHandler<HTMLDivElement> = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (disabled) return;
    setIsDragging(false);
    const files = Array.from(e.dataTransfer.files);
    if (files.length > 0) validateAndAdd(files);
  };

  const finalError = error || internalError;
  const hasFiles = value.length > 0;

  return (
    <div className={cn("flex flex-col gap-2", className)}>
      {label && (
        <label className="text-sm 3xl:text-base font-medium text-gray-700">
          {label} {required && <span className="text-red-500">*</span>}
        </label>
      )}

      {/* Hidden Input (Shared) */}
      <input
        id={inputId}
        type="file"
        accept={accept}
        multiple
        onChange={handlePick}
        disabled={disabled}
        className="hidden"
      />

      {/* STATE 1: Empty - Show Standard Upload Box */}
      {!hasFiles && (
        <div
          onDragOver={onDragOver}
          onDragLeave={onDragLeave}
          onDrop={onDrop}
          className={cn(
            "rounded-xl border border-dashed bg-surface-light transition-colors p-6 flex flex-col items-center justify-center gap-3 text-center",
            finalError ? "border-red-500" : "border-extra-light-gray",
            isDragging && "border-teal-500 bg-teal-50/20",
            disabled && "opacity-60 pointer-events-none"
          )}
        >
          <label
            htmlFor={inputId}
            className={cn(
              "cursor-pointer select-none",
              "rounded-md border border-extra-light-gray bg-white",
              "px-3.5 py-2 text-xs 3xl:text-sm font-medium text-black",
              "hover:bg-slate-gray transition",
              "flex items-center gap-2"
            )}
          >
            <FiUpload className="w-3.5 3xl:w-4 h-3.5 3xl:h-4" />
            Upload
          </label>
          <div className="min-w-0 w-full">
            <p className="text-xs 3xl:text-sm text-text-gray mt-0.5">
              {isDragging ? "Drop file here" : helperText}
            </p>
          </div>
        </div>
      )}

      {/* STATE 2: Has Files - Show Grid + Add Button */}
      {hasFiles && (
        <div className="flex flex-wrap gap-3">
          {value.map((item, index) => {
            const preview = getPreview(item);
            const isImage =
              typeof item === "string" || item.type.startsWith("image/");

            return (
              <div
                key={index}
                className="relative group w-[calc(33.33%-8px)] aspect-square rounded-xl overflow-hidden border border-gray-200 bg-gray-50 shrink-0"
              >
                {isImage ? (
                  <AppImage
                    src={preview}
                    alt="Preview"
                    fill
                    className="object-cover"
                  />
                ) : (
                  <div className="w-full h-full flex items-center justify-center text-gray-400">
                    <FileIcon className="w-8 h-8" />
                  </div>
                )}

                <button
                  type="button"
                  onClick={() => handleRemove(index)}
                  className="absolute top-1.5 right-1.5 p-1 bg-white/90 rounded-full shadow-sm hover:bg-red-50 hover:text-red-600 transition-all opacity-0 group-hover:opacity-100"
                >
                  <X className="w-3.5 h-3.5" />
                </button>
              </div>
            );
          })}

          {/* Add Button (Last Grid Item) */}
          {(!maxFiles || value.length < maxFiles) && (
            <div className="w-[calc(33.33%-8px)] aspect-square shrink-0">
              <label
                htmlFor={inputId}
                className={cn(
                  "w-full h-full flex flex-col items-center justify-center rounded-xl border border-dashed border-gray-300 bg-white hover:bg-gray-50 cursor-pointer transition-colors text-gray-400 hover:text-gray-600",
                  disabled && "opacity-60 cursor-not-allowed",
                  finalError && "border-red-500 bg-red-50"
                )}
              >
                <Plus className="w-6 h-6 text-black" />
              </label>
            </div>
          )}
        </div>
      )}

      {/* Error / Helper Text */}
      {finalError && <p className="text-xs text-red-500 mt-1">{finalError}</p>}
    </div>
  );
}
