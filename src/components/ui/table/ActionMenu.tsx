"use client";

import { ActionMenuIcon } from "@/components/icons";
import React, { useState, useRef, useEffect } from "react";
import { IconType } from "react-icons/lib";
interface ActionMenuItem {
    label: string;
    onClick: () => void;
    icon?: React.ReactNode;
    danger?: boolean;
    disabled?: boolean;
}

interface ActionMenuProps {
    items: ActionMenuItem[];
    icon?: any;
    dropdownWidth?: string;
}

export function ActionMenu({ items, dropdownWidth }: ActionMenuProps) {
    const [isOpen, setIsOpen] = useState(false);
    const menuRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        function handleClickOutside(event: MouseEvent) {
            if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
                setIsOpen(false);
            }
        }

        if (isOpen) {
            document.addEventListener("mousedown", handleClickOutside);
        }

        return () => {
            document.removeEventListener("mousedown", handleClickOutside);
        };
    }, [isOpen]);

    return (
        <div className="relative" ref={menuRef}>
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="p-1 rounded-md hover:bg-gray-100 transition-colors cursor-pointer"
            >
                <ActionMenuIcon />
            </button>

            {isOpen && (
                <div
                    className={`absolute right-0 mt-1 rounded-lg border border-gray-200 bg-white shadow-lg z-50 ${dropdownWidth ? dropdownWidth : "w-max min-w-[8rem]"}`}
                >
                    <div className="py-1">
                        {items.map((item, index) => (
                            <button
                                key={index}
                                disabled={item.disabled}
                                onClick={() => {
                                    if (!item.disabled) {
                                        item.onClick();
                                        setIsOpen(false);
                                    }
                                }}
                                className={`w-full flex items-center gap-2 px-4 py-2 text-sm text-left transition-colors ${item.disabled
                                        ? "opacity-50 cursor-not-allowed text-gray-400"
                                        : `cursor-pointer hover:bg-gray-50 ${item.danger ? "text-red-600 hover:bg-red-50" : "text-gray-700"}`
                                    }`}
                            >
                                {item.icon && <span>{item.icon}</span>}
                                <span className="text-nowrap">{item.label}</span>
                            </button>
                        ))}
                    </div>
                </div>
            )}
        </div>
    );
}
