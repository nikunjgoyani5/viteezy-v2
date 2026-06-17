"use client";

import { CircleCheck, Circle } from "lucide-react";
import { PASSWORD_REQUIREMENTS } from "@/lib/passwordUtils";
import { cn } from "@/lib/utils";

interface PasswordRequirementsProps {
  password: string;
  className?: string;
}

export function PasswordRequirements({
  password,
  className,
}: PasswordRequirementsProps) {
  return (
    <ul className={cn("space-y-1.5", className)}>
      {PASSWORD_REQUIREMENTS.map((rule) => {
        const met = rule.test(password);
        return (
          <li
            key={rule.id}
            className={cn(
              "flex items-center gap-2 text-xs transition-colors",
              met ? "text-teal-600" : "text-gray-500"
            )}
          >
            {met ? (
              <CircleCheck className="shrink-0" size={14} />
            ) : (
              <Circle className="shrink-0" size={14} />
            )}
            <span>{rule.label}</span>
          </li>
        );
      })}
    </ul>
  );
}
