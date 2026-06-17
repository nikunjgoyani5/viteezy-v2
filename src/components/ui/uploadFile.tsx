"use client";

import React, { useEffect, useId, useMemo, useState } from "react";
import { cn } from "@/lib/utils";
import { FiUpload } from "react-icons/fi";
import { IoIosArrowDown } from "react-icons/io";

import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import AppImage from "@/components/ui/appImage";

// Non-null file value (File or existing URL)
export type UploadFileValue = File | string;

type UploadFileProps = {
  label?: string;
  required?: boolean;
  error?: string;

  value?: UploadFileValue | null;
  onChange?: (value: UploadFileValue | null) => void;

  accept?: string;
  maxSizeMB?: number;

  disabled?: boolean;
  className?: string;

  helperText?: string;

  showPreview?: boolean;
  previewClassName?: string;
  mainClassName?: string;
};

function isBrowserDirectImageSrc(url: string) {
  return url.startsWith("blob:") || url.startsWith("data:");
}

function isFileAccepted(file: File, accept?: string) {
  if (!accept || accept.trim() === "" || accept === "*/*") return true;

  const rules = accept
    .split(",")
    .map((s) => s.trim().toLowerCase())
    .filter(Boolean);

  const fileName = file.name.toLowerCase();
  const mime = (file.type || "").toLowerCase();

  return rules.some((r) => {
    if (r.startsWith(".")) return fileName.endsWith(r);
    if (r.endsWith("/*")) return mime.startsWith(r.slice(0, -1));
    return mime === r;
  });
}

export default function UploadFile({
  label,
  required,
  error,
  value = null,
  onChange,
  accept = "image/*",
  maxSizeMB = 2,
  disabled,
  className,
  helperText = "Click to upload or drag & drop PNG, JPG (max 2MB)",
  showPreview = true,
  previewClassName,
  mainClassName,
}: UploadFileProps) {
  const inputId = useId();

  const [file, setFile] = useState<File | null>(
    value instanceof File ? value : null
  );

  const [localError, setLocalError] = useState<string | null>(null);
  const [isDragging, setIsDragging] = useState(false);

  const isVideo = useMemo(() => {
    if (file) return file.type.startsWith("video/");
    if (value instanceof File) return value.type.startsWith("video/");
    if (typeof value === "string") {
      return /\.(mp4|webm|ogg|mov|m4v)$/i.test(value);
    }
    return accept.includes("video");
  }, [file, value, accept]);

  useEffect(() => {
    // Mirror controlled `value` when the form resets or reloads (e.g. edit product).
    // eslint-disable-next-line react-hooks/set-state-in-effect -- sync local pick state with RHF
    setFile(value instanceof File ? value : null);
    setLocalError(null);
  }, [value]);

  const remoteUrl = value && typeof value === "string" ? value : null;

  // Prefer RHF value when it's a File (local `file` can lag behind after remount).
  const resolvedPreviewFile =
    (value instanceof File ? value : null) ??
    (file instanceof File ? file : null);

  // Data URLs avoid blob: lifecycle (revoke on unmount / strict mode) breaking previews after accordion remount.
  const [fileDataUrl, setFileDataUrl] = useState<string | null>(null);

  useEffect(() => {
    if (remoteUrl || !resolvedPreviewFile) {
      const id = requestAnimationFrame(() => setFileDataUrl(null));
      return () => cancelAnimationFrame(id);
    }

    let cancelled = false;
    const reader = new FileReader();
    reader.onloadend = () => {
      if (cancelled || typeof reader.result !== "string") return;
      setFileDataUrl(reader.result);
    };
    reader.readAsDataURL(resolvedPreviewFile);

    return () => {
      cancelled = true;
      reader.abort();
    };
  }, [remoteUrl, resolvedPreviewFile]);

  const previewUrl =
    remoteUrl ?? (resolvedPreviewFile ? fileDataUrl : null);

  const validateAndSet = (f: File | null) => {
    setLocalError(null);

    if (!f) {
      setFile(null);
      onChange?.(null);
      return;
    }

    if (!isFileAccepted(f, accept)) {
      setLocalError(
        accept.includes("image") && !accept.includes("video")
          ? "Invalid file type. Please upload an image only (PNG, JPG, WebP)."
          : "Invalid file type. Please upload a supported file type."
      );
      setFile(null);
      onChange?.(null);
      return;
    }

    const maxBytes = maxSizeMB * 1024 * 1024;
    if (f.size > maxBytes) {
      setLocalError(`File size must not exceed ${maxSizeMB}MB.`);
      setFile(null);
      onChange?.(null);
      return;
    }

    setFile(f);
    onChange?.(f);
  };

  const handlePick: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const f = e.target.files?.[0] ?? null;
    validateAndSet(f);
    e.target.value = "";
  };

  const handleDelete = () => {
    setLocalError(null);
    setFile(null);
    onChange?.(null);
  };

  const handleEdit = () => {
    document.getElementById(inputId)?.click();
  };

  const onDragOver: React.DragEventHandler<HTMLDivElement> = (e) => {
    e.preventDefault();
    e.stopPropagation();
    if (disabled || previewUrl) return;
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
    if (disabled || previewUrl) return;

    setIsDragging(false);
    const f = e.dataTransfer.files?.[0] ?? null;
    validateAndSet(f);
  };

  const hasPreview = showPreview && !!previewUrl;
  // Show actual upload error (wrong type/size) over form "required" so user understands
  const finalError = localError ?? error;

  return (
    <div className={cn("flex flex-col gap-1", mainClassName)}>
      {/* ✅ label left side */}
      {label && (
        <div className="flex items-center justify-between">
          <label className="text-sm 3xl:text-base font-medium text-gray-700 mb-2">
            {label}
            {required && <span className="text-red-500">*</span>}
          </label>
          {hasPreview && (
            <DropdownMenu>
              <DropdownMenuTrigger asChild>
                <button
                  type="button"
                  aria-label="Image actions"
                  className="text-teal-500 text-sm flex items-center gap-0.5 cursor-pointer"
                >
                  <span className="border-b border-transparent hover:border-teal-500">
                    Edit
                  </span>
                  <IoIosArrowDown size={16} />
                </button>
              </DropdownMenuTrigger>

              <DropdownMenuContent align="end" className="w-32">
                <DropdownMenuItem onClick={handleEdit}>Edit</DropdownMenuItem>
                <DropdownMenuItem
                  onClick={handleDelete}
                  className="text-red focus:text-red"
                >
                  Delete
                </DropdownMenuItem>
              </DropdownMenuContent>
            </DropdownMenu>
          )}
        </div>
      )}

      <input
        id={inputId}
        type="file"
        accept={accept}
        onChange={handlePick}
        disabled={disabled}
        className="hidden"
      />

      <div
        onDragOver={onDragOver}
        onDragLeave={onDragLeave}
        onDrop={onDrop}
        className={cn(
          "rounded-xl border border-dashed transition-colors overflow-hidden bg-surface-light",
          finalError ? "border-red-500" : "border-extra-light-gray",
          isDragging && !finalError && "border-primary bg-primary/5",
          disabled && "opacity-60 pointer-events-none",
          className
        )}
      // style={{ border: '2px dashed #ebebeb' }}
      >
        {hasPreview ? (
          <div className="relative">
            {/* ✅ shadcn dropdown */}
            <div className="absolute right-3 top-3 z-10"></div>

            <div
              className={cn("relative bg-white h-52 w-full", previewClassName)}
            >
              {isVideo ? (
                <video
                  key={previewUrl}
                  src={previewUrl!}
                  controls
                  className="h-full w-full object-contain"
                />
              ) : isBrowserDirectImageSrc(previewUrl!) ? (
                // blob:/data: previews are not supported by next/image
                // eslint-disable-next-line @next/next/no-img-element
                <img
                  key={previewUrl}
                  src={previewUrl!}
                  alt="preview"
                  className="h-full w-full object-contain"
                />
              ) : (
                <AppImage
                  src={previewUrl!}
                  alt="preview"
                  fill
                  className="object-contain"
                />
              )}
            </div>
          </div>
        ) : (
          <div className="p-7.5 flex items-center text-center justify-between gap-2 flex-wrap">
            <div className="flex items-center justify-center w-full gap-2">
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
            </div>

            <div className="w-full flex justify-center">
              <p className="text-xs 3xl:text-sm text-center text-text-gray mt-0.5 w-44">
                {isDragging ? "Drop file here" : helperText}
              </p>
            </div>
          </div>
        )}
      </div>

      {finalError && <p className="text-xs text-red-500">{finalError}</p>}
    </div>
  );
}

export function appendFile(
  fd: FormData,
  key: string,
  value: UploadFileValue | null | undefined
) {
  if (value instanceof File) fd.append(key, value);
}
