import { SearchIcon } from "@/components/icons";
import React from "react";
import { MdSearch } from "react-icons/md";

interface TableSearchProps {
    placeholder: string;
    value: string;
    onChange: (value: string) => void;
}

export function TableSearch({ placeholder, value, onChange }: TableSearchProps) {
    return (
        <div className="relative flex-1">
            <div className="absolute left-3 top-1/2 -translate-y-1/2 ">
                <SearchIcon />
            </div>
            <input
                type="text"
                placeholder={placeholder}
                value={value}
                onChange={(e) => onChange(e.target.value)}
                className="h-8.5 w-full rounded-md border border-extra-light-gray bg-white pl-9 pr-4 text-base placeholder:text-text-gray focus:outline-none focus:ring focus:ring-emerald-500"
            />
        </div>
    );
}
