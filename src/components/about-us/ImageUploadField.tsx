"use client";

import React, { useRef } from "react";
import AppImage from "@/components/ui/appImage";
import { Upload, Pencil } from "lucide-react";
import toast from "react-hot-toast";

interface ImageUploadFieldProps {
    label: string;
    image: string;
    onImageChange: (imageData: string, file: File) => void;
}

export default function ImageUploadField({
    label,
    image,
    onImageChange,
}: ImageUploadFieldProps) {
    const fileInputRef = useRef<HTMLInputElement>(null);

    const handleImageSelect = (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        if (file) {
            if (!file.type.startsWith("image/")) {
                toast.error("Please select an image file");
                return;
            }
            if (file.size > 5 * 1024 * 1024) {
                toast.error("Image size should be less than 5MB");
                return;
            }
            const reader = new FileReader();
            reader.onloadend = () => {
                onImageChange(reader.result as string, file);
            };
            reader.readAsDataURL(file);
        }
    };

    return (
        <div>
            <label className="block text-sm font-medium mb-2">{label}</label>
            <input
                ref={fileInputRef}
                type="file"
                accept="image/*"
                onChange={handleImageSelect}
                className="hidden"
            />
            <div
                onClick={() => fileInputRef.current?.click()}
                className="relative bg-slate-gray rounded-lg overflow-hidden flex items-center justify-center w-38 h-44 border-2 border-dashed cursor-pointer hover:border-teal-500 group"
            >
                {image ? (
                    <>
                        <AppImage
                            src={image}
                            alt={label}
                            width={200}
                            height={208}
                            className="w-38 h-44 object-contain"
                        />
                        {/* Hover Overlay with Pencil Icon */}
                        <div className="absolute inset-0 bg-black/0 group-hover:bg-black/10 transition-all duration-300 z-10">
                            <div className="absolute top-2 right-2">
                                <div className="bg-white rounded-full p-1.5 shadow-md opacity-0 group-hover:opacity-100 transition-opacity duration-300">
                                    <Pencil className="w-4 h-4 text-gray-700" />
                                </div>
                            </div>
                        </div>
                    </>
                ) : (
                    <div className="flex items-center gap-2 px-4 py-2 text-xs font-medium text-gray-700 bg-white border border-extra-light-gray rounded-lg hover:bg-gray-50">
                        <Upload className="w-4 h-4" />
                        Upload
                    </div>
                )}
            </div>
        </div>
    );
}
