"use client";

import { DownIcon, PlusIcon } from "@/components/icons";
import React, { useState, useRef, useEffect } from "react";
import { MdKeyboardArrowDown } from "react-icons/md";

export interface FilterOption {
  key: string;
  label: string;
  type?: "select" | "date" | "text" | "range";
  options?: { value: string; label: string }[];
  rangeKeys?: { min: string; max: string }; // For range type
}

interface TableFilterRowProps {
  availableFilters: FilterOption[];
  activeFilters: Record<string, any>;
  onFilterChange: (key: string, value: any) => void;
  onRemoveFilter: (key: string) => void;
  onClearAllFilters?: () => void;
}

export function TableFilterRow({
  availableFilters,
  activeFilters,
  onFilterChange,
  onRemoveFilter,
  onClearAllFilters,
}: TableFilterRowProps) {
  const [openDropdown, setOpenDropdown] = useState<string | null>(null);
  const [showAddFilterMenu, setShowAddFilterMenu] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  // Close dropdown when clicking outside
  useEffect(() => {
    function handleClickOutside(event: MouseEvent) {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(event.target as Node)
      ) {
        setOpenDropdown(null);
        setShowAddFilterMenu(false);
      }
    }

    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const activeFilterKeys = Object.keys(activeFilters);
  const availableToAdd = availableFilters.filter(
    (filter) => !activeFilterKeys.includes(filter.key)
  );

  const handleAddFilter = (filterKey: string) => {
    const filter = availableFilters.find((f) => f.key === filterKey);
    if (filter) {
      // Set first option value for select filters, empty for others
      if (filter.type === "select" && filter.options && filter.options.length > 0) {
        onFilterChange(filterKey, filter.options[0].value);
      } else if (filter.type === "range" && filter.rangeKeys) {
        // Initialize range with empty min and max
        onFilterChange(filterKey, { min: "", max: "" });
      } else {
        onFilterChange(filterKey, "");
      }
    }
    setShowAddFilterMenu(false);
  };

  const clearAllFilters = () => {
    if (onClearAllFilters) {
      onClearAllFilters();
    } else {
      // Fallback to removing filters one by one
      activeFilterKeys.forEach((key) => onRemoveFilter(key));
    }
    setOpenDropdown(null);
    setShowAddFilterMenu(false);
  };

  const formatDisplayDate = (isoDate?: string) => {
    if (!isoDate) return "";
    const parts = isoDate.split("-");
    if (parts.length === 3) {
      const [y, m, d] = parts;
      return `${d}-${m}-${y}`;
    }
    // fallback
    try {
      const date = new Date(isoDate);
      const dd = String(date.getDate()).padStart(2, "0");
      const mm = String(date.getMonth() + 1).padStart(2, "0");
      const yy = String(date.getFullYear());
      return `${dd}-${mm}-${yy}`;
    } catch {
      return isoDate;
    }
  };

  return (
    <div className="flex items-center gap-2 flex-wrap" ref={dropdownRef}>
      {/* Active Filters */}
      {activeFilterKeys.map((filterKey) => {
        const filter = availableFilters.find((f) => f.key === filterKey);
        if (!filter) return null;

        const isOpen = openDropdown === filterKey;

        return (
          <div key={filterKey} className="relative">
            <button
              onClick={() => setOpenDropdown(isOpen ? null : filterKey)}
              className="flex items-center gap-2 px-3 py-1.5 bg-white border border-extra-light-gray rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50 cursor-pointer"
            >
              <span>{filter.label}</span>
              {filter.type === "date" && activeFilters[filterKey] && (
                <span className="text-gray-600">
                  : {formatDisplayDate(activeFilters[filterKey])}
                </span>
              )}
              {filter.type === "range" && activeFilters[filterKey] && (
                <span className="text-gray-600">
                  : {activeFilters[filterKey]?.min || "0"} - {activeFilters[filterKey]?.max || "∞"}
                </span>
              )}
              <div className={`${isOpen ? "rotate-180" : " mt-1"} `}>
                <DownIcon />
              </div>
            </button>

            {/* Dropdown Menu */}
            {isOpen && filter.options && (
              <div className="absolute top-full left-0 mt-1 bg-white border border-gray-200 rounded-md shadow-lg z-50 min-w-48 cursor-pointer">
                <div className="py-1">
                  {filter.options.map((option) => {
                    const isSelected =
                      activeFilters[filterKey] === option.value;
                    return (
                      <button
                        key={option.value}
                        onClick={() => {
                          onFilterChange(filterKey, option.value);
                          setOpenDropdown(null);
                        }}
                        className={`w-full text-left px-4 py-2 text-sm cursor-pointer ${isSelected
                          ? "bg-gray-100 text-gray-900 font-medium"
                          : "text-gray-700 hover:bg-gray-100"
                          }`}
                      >
                        {option.label}
                      </button>
                    );
                  })}
                </div>
                <div className="border-t border-gray-200 py-1">
                  <button
                    onClick={() => {
                      onRemoveFilter(filterKey);
                      setOpenDropdown(null);
                    }}
                    className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100 cursor-pointer"
                  >
                    Remove filter
                  </button>
                </div>
              </div>
            )}
            {isOpen && filter.type === "date" && (
              <div className="absolute top-full left-0 mt-1 bg-white border border-gray-200 rounded-md shadow-lg z-50 min-w-56">
                <div className="p-3">
                  <label className="block text-xs font-medium text-gray-600 mb-1">
                    Select date
                  </label>
                  <input
                    type="date"
                    value={activeFilters[filterKey] ?? ""}
                    onChange={(e) => onFilterChange(filterKey, e.target.value)}
                    className="w-full border border-gray-300 rounded-md px-2 py-1 text-sm focus:outline-none focus:ring-2 focus:ring-gray-200"
                  />
                </div>
                <div className="border-t border-gray-200 py-1">
                  <button
                    onClick={() => {
                      onRemoveFilter(filterKey);
                      setOpenDropdown(null);
                    }}
                    className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                  >
                    Remove filter
                  </button>
                </div>
              </div>
            )}
            {isOpen && filter.type === "range" && (
              <div className="absolute top-full left-0 mt-1 bg-white border border-gray-200 rounded-md shadow-lg z-50 min-w-64">
                <div className="p-3 space-y-3">
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">
                      Min Amount
                    </label>
                    <input
                      type="number"
                      placeholder="Enter min amount"
                      value={activeFilters[filterKey]?.min ?? ""}
                      onChange={(e) =>
                        onFilterChange(filterKey, {
                          ...activeFilters[filterKey],
                          min: e.target.value,
                        })
                      }
                      className="w-full border border-gray-300 rounded-md px-2 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-gray-200"
                    />
                  </div>
                  <div>
                    <label className="block text-xs font-medium text-gray-600 mb-1">
                      Max Amount
                    </label>
                    <input
                      type="number"
                      placeholder="Enter max amount"
                      value={activeFilters[filterKey]?.max ?? ""}
                      onChange={(e) =>
                        onFilterChange(filterKey, {
                          ...activeFilters[filterKey],
                          max: e.target.value,
                        })
                      }
                      className="w-full border border-gray-300 rounded-md px-2 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-gray-200"
                    />
                  </div>
                </div>
                <div className="border-t border-gray-200 py-1">
                  <button
                    onClick={() => {
                      onRemoveFilter(filterKey);
                      setOpenDropdown(null);
                    }}
                    className="w-full text-left px-4 py-2 text-sm text-red-600 hover:bg-gray-100"
                  >
                    Remove filter
                  </button>
                </div>
              </div>
            )}
          </div>
        );
      })}

      {/* Add Filter Button */}
      {availableToAdd.length > 0 && (
        <div className="relative">
          <button
            onClick={() => setShowAddFilterMenu(!showAddFilterMenu)}
            className="flex items-center gap-1 px-3 border-dashed text-sm font-medium rounded-md py-1.5 hover:text-gray-900 cursor-pointer border hover:bg-gray-50 border-gray-200 "
          >
            Add Filter
            <span className="text-lg ml-1">
              <PlusIcon />
            </span>
          </button>

          {/* Add Filter Dropdown */}
          {showAddFilterMenu && (
            <div className="absolute top-full left-0 mt-1 bg-white border border-gray-200 rounded-md shadow-lg z-50 min-w-48">
              <div className="py-1">
                {availableToAdd.map((filter) => (
                  <button
                    key={filter.key}
                    onClick={() => handleAddFilter(filter.key)}
                    className="w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-gray-100"
                  >
                    {filter.label}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      )}

      {/* Clear All */}
      {activeFilterKeys.length > 0 && (
        <button
          onClick={clearAllFilters}
          className="text-sm font-medium text-gray-500 cursor-pointer hover:text-gray-700"
        >
          Clear all
        </button>
      )}
    </div>
  );
}
