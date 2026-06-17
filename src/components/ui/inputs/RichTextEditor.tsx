"use client";

import React, { useRef, useEffect, useState } from "react";
import { Bold, Italic, Underline, List, ListOrdered } from "lucide-react";
import { LuImage } from "react-icons/lu";
import { cn } from "@/lib/utils";

// Define the available features as a union type for type safety
type RichTextEditorFeature = 
    | 'headings'
    | 'bold' 
    | 'italic'
    | 'underline'
    | 'strikethrough'
    | 'textColor'
    | 'lists'
    | 'image';

interface RichTextEditorProps {
    value?: string;
    onChange?: (value: string) => void;
    placeholder?: string;
    className?: string;
    error?: string;
    label?: string;
    required?: boolean;
    onImageUpload?: (file: File) => Promise<string> | string; // returns image URL
    options?: RichTextEditorFeature[]; // Array of feature names to show
}

export default function RichTextEditor({
    value = "",
    onChange,
    placeholder = "Enter Description",
    className,
    error,
    label,
    required = false,
    onImageUpload,
    options,
}: RichTextEditorProps) {
    const editorRef = useRef<HTMLDivElement>(null);
    const fileInputRef = useRef<HTMLInputElement>(null);
    const [headingValue, setHeadingValue] = useState<"p" | "h1" | "h2" | "h3">("p");
    const [activeStates, setActiveStates] = useState({
        bold: false,
        italic: false,
        underline: false,
        strike: false,
        ul: false,
        ol: false,
    });

    // Helper function to check if a feature is enabled
    const isFeatureEnabled = (feature: RichTextEditorFeature) => {
        return !options || options.includes(feature);
    };

    // Set initial content when value changes from parent
    useEffect(() => {
        if (editorRef.current && editorRef.current.innerHTML !== value) {
            editorRef.current.innerHTML = value;
        }
    }, [value]);

    const handleInput = (e: React.FormEvent<HTMLDivElement>) => {
        const content = e.currentTarget.innerHTML;
        if (onChange) {
            onChange(content);
        }
    };

    const applyFormat = (command: string, value?: string) => {
        if (!editorRef.current) return;
        editorRef.current.focus();
        document.execCommand(command, false, value);
    };

    const applyHeading = (e: React.ChangeEvent<HTMLSelectElement>) => {
        const value = e.target.value as "p" | "h1" | "h2" | "h3";
        if (!editorRef.current) return;

        const sel = window.getSelection();
        if (!sel) return;

        // Only apply heading if there is a non-collapsed selection
        if (sel.isCollapsed || !sel.toString().trim()) {
            // No selection: do not change entire line/block
            setHeadingValue(value);
            return;
        }

        editorRef.current.focus();
        document.execCommand("formatBlock", false, value);
        setHeadingValue(value);
    };

    const insertImageAtSelection = (url: string) => {
        if (!editorRef.current) return;
        editorRef.current.focus();
        try {
            // Try native command first
            const success = document.execCommand("insertImage", false, url);
            if (!success) {
                document.execCommand(
                    "insertHTML",
                    false,
                    `<img src="${url}" alt="" style="max-width:100%;height:auto;" />`
                );
            }
        } catch {
            document.execCommand(
                "insertHTML",
                false,
                `<img src="${url}" alt="" style="max-width:100%;height:auto;" />`
            );
        }
    };

    const handleImageButton = (e: React.MouseEvent) => {
        e.preventDefault();
        fileInputRef.current?.click();
    };

    const handleFileSelected = async (e: React.ChangeEvent<HTMLInputElement>) => {
        const file = e.target.files?.[0];
        // Reset input so same file can be reselected later
        e.target.value = "";
        if (!file) return;

        // Use custom upload handler if provided
        if (onImageUpload) {
            try {
                const result = await onImageUpload(file);
                const url = typeof result === "string" ? result : String(result);
                insertImageAtSelection(url);
                return;
            } catch (err) {
                console.error("Image upload failed", err);
                return;
            }
        }

        // Default: insert as data URL
        const reader = new FileReader();
        reader.onload = () => {
            const url = reader.result as string;
            insertImageAtSelection(url);
        };
        reader.readAsDataURL(file);
    };

    // Detect if selection is inside the editor and update toolbar active states
    useEffect(() => {
        const updateToolbar = () => {
            const sel = window.getSelection();
            const container = editorRef.current;
            if (!sel || !container) return;
            const anchorNode = sel.anchorNode;
            if (!anchorNode) return;
            // Ensure selection is inside editor
            const isInside = container.contains(anchorNode);
            if (!isInside) return;

            // Active inline styles
            const bold = document.queryCommandState("bold");
            const italic = document.queryCommandState("italic");
            const underline = document.queryCommandState("underline");
            const strike = document.queryCommandState("strikeThrough");
            const ul = document.queryCommandState("insertUnorderedList");
            const ol = document.queryCommandState("insertOrderedList");

            setActiveStates({ bold, italic, underline, strike, ul, ol });

            // Determine current block tag for heading dropdown
            let node: Node | null = anchorNode;
            let currentTag: "p" | "h1" | "h2" | "h3" = "p";
            while (node && node !== container) {
                let el: Element | null = node.nodeType === 3 ? (node.parentElement as Element | null) : (node as Element | null);
                if (!el) break;
                const tag = el.tagName ? el.tagName.toLowerCase() : "";
                if (tag === "h1" || tag === "h2" || tag === "h3" || tag === "p") {
                    currentTag = tag as any;
                    break;
                }
                node = el.parentElement;
            }
            setHeadingValue(currentTag);
        };

        // Listen broadly so active states reflect immediately on cursor moves
        document.addEventListener("selectionchange", updateToolbar);
        document.addEventListener("keyup", updateToolbar, true);
        document.addEventListener("mouseup", updateToolbar, true);
        document.addEventListener("click", updateToolbar, true);
        editorRef.current?.addEventListener("input", updateToolbar, true);

        // Initialize once on mount
        updateToolbar();

        return () => {
            document.removeEventListener("selectionchange", updateToolbar);
            document.removeEventListener("keyup", updateToolbar, true);
            document.removeEventListener("mouseup", updateToolbar, true);
            document.removeEventListener("click", updateToolbar, true);
            editorRef.current?.removeEventListener("input", updateToolbar, true);
        };
    }, []);

    return (
        <div className={cn("flex flex-col gap-2", className)}>
            {label && (
                <label className="text-sm 3xl:text-base font-medium text-gray-700">
                    {label}
                    {required && <span className="text-red-500 ml-1">*</span>}
                </label>
            )}

            <div
                className={cn(
                    "border rounded-lg overflow-hidden bg-white",
                    error ? "border-red-500" : "border-gray-300"
                )}
            >
                {/* Toolbar */}
                <div className="flex items-center gap-4 px-3 py-2 border-b border-extra-light-gray bg-white flex-wrap">
                    {/* Headings */}
                    {isFeatureEnabled('headings') && (
                        <select
                            onChange={applyHeading}
                            className="text-sm border border-gray-300 rounded px-2 py-1.5 bg-white focus:outline-none focus:ring-1 focus:ring-teal-500 text-gray-900"
                            value={headingValue}
                        >
                            <option value="p">Normal text</option>
                            <option value="h1">Heading 1</option>
                            <option value="h2">Heading 2</option>
                            <option value="h3">Heading 3</option>
                        </select>
                    )}

                    {/* Text Formatting */}
                    <div className="flex items-center gap-2">
                        {isFeatureEnabled('bold') && (
                            <button
                                type="button"
                                onMouseDown={(e) => { e.preventDefault(); applyFormat("bold"); }}
                                className={cn("p-1.5 rounded transition font-bold", activeStates.bold ? "bg-slate-gray text-gray-900" : "text-gray-900 hover:text-teal-600 hover:bg-gray-100")}
                                title="Bold"
                            >
                                <Bold className="w-4 h-4" />
                            </button>
                        )}
                        {isFeatureEnabled('italic') && (
                            <button
                                type="button"
                                onMouseDown={(e) => { e.preventDefault(); applyFormat("italic"); }}
                                className={cn("p-1.5 rounded transition", activeStates.italic ? "bg-slate-gray text-gray-900" : "text-gray-900 hover:text-teal-600 hover:bg-gray-100")}
                                title="Italic"
                            >
                                <Italic className="w-4 h-4" />
                            </button>
                        )}
                        {isFeatureEnabled('underline') && (
                            <button
                                type="button"
                                onMouseDown={(e) => { e.preventDefault(); applyFormat("underline"); }}
                                className={cn("p-1.5 rounded transition", activeStates.underline ? "bg-slate-gray text-gray-900" : "text-gray-900 hover:text-teal-600 hover:bg-gray-100")}
                                title="Underline"
                            >
                                <Underline className="w-4 h-4" />
                            </button>
                        )}
                        {isFeatureEnabled('strikethrough') && (
                            <button
                                type="button"
                                onMouseDown={(e) => { e.preventDefault(); applyFormat("strikeThrough"); }}
                                className={cn("p-1.5 rounded transition", activeStates.strike ? "bg-slate-gray text-gray-900" : "text-gray-900 hover:text-teal-600 hover:bg-gray-100")}
                                title="Strikethrough"
                            >
                                <span className="text-sm line-through font-bold">S</span>
                            </button>
                        )}
                    </div>

                    {/* Text Color */}
                    {isFeatureEnabled('textColor') && (
                        <div className="relative">
                            <input
                                type="color"
                                onChange={(e) => applyFormat("foreColor", e.target.value)}
                                className="w-7 h-7 cursor-pointer p-0 border-0 rounded-md"
                                title="Text Color"
                                defaultValue="#000000"
                            />
                        </div>
                    )}

                    {/* Lists */}
                    {isFeatureEnabled('lists') && (
                        <div className="flex items-center gap-2">
                            <button
                                type="button"
                                onMouseDown={(e) => { e.preventDefault(); applyFormat("insertUnorderedList"); }}
                                className={cn("p-1.5 rounded transition", activeStates.ul ? "bg-slate-gray text-gray-900" : "text-gray-900 hover:text-teal-600 hover:bg-gray-100")}
                                title="Bullet List"
                            >
                                <List className="w-4 h-4" />
                            </button>
                            <button
                                type="button"
                                onMouseDown={(e) => { e.preventDefault(); applyFormat("insertOrderedList"); }}
                                className={cn("p-1.5 rounded transition", activeStates.ol ? "bg-slate-gray text-gray-900" : "text-gray-900 hover:text-teal-600 hover:bg-gray-100")}
                                title="Numbered List"
                            >
                                <ListOrdered className="w-4 h-4" />
                            </button>
                        </div>
                    )}

                    {/* Image Upload */}
                    {isFeatureEnabled('image') && (
                        <>
                            <input
                                ref={fileInputRef}
                                type="file"
                                accept="image/*"
                                className="hidden"
                                onChange={handleFileSelected}
                            />
                            <button
                                type="button"
                                onMouseDown={handleImageButton}
                                className="p-1.5 rounded text-gray-900 hover:text-teal-600 transition"
                                title="Insert Image"
                            >
                                <LuImage className="w-4 h-4" />
                            </button>
                        </>
                    )}
                </div>

                {/* Rich Text Area */}
                <div
                    ref={editorRef}
                    contentEditable
                    className="w-full px-4 py-3 text-sm 3xl:text-base border-0 focus:outline-none min-h-50 max-h-100 overflow-y-auto rich-text-editor text-gray-900"
                    suppressContentEditableWarning
                    onInput={handleInput}
                    data-placeholder={placeholder}
                />
            </div>

            {error && <p className="text-xs text-red-500">{error}</p>}

            <style jsx>{`
        .rich-text-editor:empty:before {
          content: attr(data-placeholder);
          color: #9ca3af;
          pointer-events: none;
        }
        .rich-text-editor:focus {
          outline: none;
        }
      `}</style>
        </div>
    );
}
