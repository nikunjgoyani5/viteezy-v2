"use client";

import React, { useState } from "react";
import { cn } from "@/lib/utils";
import SachetPriceForm from "./SachetPriceForm";
import StandupPouchPriceForm from "./StandupPouchPriceForm";

const TABS = [
  { id: "sachets", label: "Sachets" },
  { id: "standup", label: "Stand-up Pouch" },
];

export default function PriceSection() {
  const [activeTab, setActiveTab] = useState("sachets");

  return (
    <div className="space-y-4 pt-4">
      {/* 1. Tabs Header */}
      <div className="border-b border-gray-200 m-0">
        <div className="flex">
          {TABS.map((tab) => {
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                type="button"
                onClick={() => setActiveTab(tab.id)}
                className={cn(
                  "pb-4 text-base font-medium transition-all relative px-4.5 cursor-pointer",
                  isActive
                    ? "text-teal-600"
                    : "text-gray-500 hover:text-gray-700"
                )}
              >
                {tab.label}
                {isActive && (
                  <span className="absolute bottom-0 left-0 w-full h-[2px] bg-teal-500 rounded-t-md" />
                )}
              </button>
            );
          })}
        </div>
      </div>

      {/* 2. Tab Content */}
      <div className="min-h-[300px]">
        {activeTab === "sachets" && <SachetPriceForm />}
        {activeTab === "standup" && <StandupPouchPriceForm />}
      </div>
    </div>
  );
}
