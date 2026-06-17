"use client";

import React from "react";

export interface TimelineEntry {
  date: string;
  title: string;
  description: string;
  isActive?: boolean;
}

interface ViteezyTimelineProps {
  title: string;
  subtitle: string;
  entries: TimelineEntry[];
}

const ViteezyTimeline: React.FC<ViteezyTimelineProps> = ({
  title,
  subtitle,
  entries,
}) => {
  return (
    <section className="section-py px-4 py-20 bg-off-white-color">
      <div className="w-section mx-auto max-w-7xl">
        <div className="text-center mb-12 md:mb-16 max-w-3xl mx-auto">
          <h2 className="text-3xl md:text-4xl lg:text-5xl font-medium text-black-color mb-4 font-saans">
            {title}
          </h2>
          <p className="text-base md:text-lg text-charcol-color leading-relaxed font-saans">
            {subtitle}
          </p>
        </div>

        {/* ---------------- Timeline ---------------- */}
        <div className="relative max-w-5xl mx-auto">
          {/* Vertical Line */}
          <div className="hidden md:block absolute left-1/2 -translate-x-1/2 top-0 bottom-0 w-0.5 bg-black z-0" />

          <div className="md:hidden absolute left-0 top-0 bottom-0 w-0.5 bg-black z-0" />

          {/* Timeline Entries */}
          <div className="space-y-12 md:space-y-16">
            {entries.map((entry, index) => {
              const isActive = entry.isActive !== false;
              const textColor = isActive ? "text-black-color" : "text-gray-400";
              const dotColor = isActive ? "bg-black-color" : "bg-gray-400";

              return (
                <div
                  key={index}
                  className="relative grid grid-cols-1 md:grid-cols-2 gap-6 md:gap-30 lg:gap-50 md:items-center"
                >
                  <div>
                    <div
                      className={`text-2xl md:text-3xl lg:text-4xl font-semibold ${textColor} font-saans block md:text-end ml-12 md:ml-0`}
                    >
                      {entry.date}
                    </div>
                  </div>

                  <div
                    className="absolute left-0 md:left-1/2 -translate-x-1/2 top-1/2 md:top-1/2 -translate-y-1/2 z-10"
                  >
                    <div
                      className={`w-9 h-9 md:w-10 md:h-10 rounded-full ${dotColor} border-4 md:border-[6px] border-black bg-black`}
                    />
                  </div>

                  <div className="md:flex-1 ml-12 md:ml-0">
                    <div className="bg-white rounded-lg p-6 shadow-sm border border-gainsboro">
                      <h3 className="text-xl font-semibold mb-3 font-saans text-black-color">
                        {entry.title}
                      </h3>
                      <p className="text-base leading-5 font-saans text-black-color">
                        {entry.description}
                      </p>
                    </div>
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>
    </section>
  );
};

export default ViteezyTimeline;
