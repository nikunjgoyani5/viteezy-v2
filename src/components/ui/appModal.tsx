"use client";

import * as React from "react";
import { cn } from "@/lib/utils";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
  DialogTrigger,
  DialogClose,
} from "@/components/ui/dialog";
import { X } from "lucide-react";

type AppModalProps = {
  open: boolean;
  onOpenChange: (v: boolean) => void;

  trigger?: React.ReactNode;

  title?: React.ReactNode;
  description?: React.ReactNode;

  children: React.ReactNode;

  footer?: React.ReactNode;

  className?: string; // modal panel
  overlayClassName?: string; // if you customized overlay in dialog.tsx, ignore this
  showClose?: boolean;
  bodyClassName?: string;
};

export default function AppModal({
  open,
  onOpenChange,
  trigger,
  title,
  description,
  children,
  footer,
  className,
  bodyClassName,
  showClose = true,
}: AppModalProps) {
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      {trigger ? <DialogTrigger asChild>{trigger}</DialogTrigger> : null}

      <DialogContent
        showCloseButton={false}
        className={cn(
          // your theme-like container
          "bg-white border border-extra-light-gray rounded-xl p-0 shadow-lg w-[95vw] xl:min-w-155",
          className
        )}
      >
        {(title || description || showClose) && (
          <DialogHeader
            className={cn(
              "px-6 pt-5 pb-4 border-b border-extra-light-gray relative",
              "bg-surface-light rounded-t-xl"
            )}
          >
            {showClose && (
              <DialogClose
                className="absolute right-4 top-1/2 -translate-y-1/2 rounded-md p-2 hover:bg-slate-gray/50 transition cursor-pointer"
                aria-label="Close"
              >
                <X className="h-5 w-5 text-text-gray" />
              </DialogClose>
            )}

            {title ? (
              <DialogTitle className="heading-sm font-medium text-black">
                {title}
              </DialogTitle>
            ) : null}

            {description ? (
              <DialogDescription className="text-sm text-text-gray">
                {description}
              </DialogDescription>
            ) : null}
          </DialogHeader>
        )}

        <div className={cn("px-5 py-1 min-w-0 overflow-hidden", bodyClassName)}>{children}</div>

        {footer ? (
          <DialogFooter className="px-6 py-4 border-t border-extra-light-gray flex gap-2 sm:justify-end">
            {footer}
          </DialogFooter>
        ) : null}
      </DialogContent>
    </Dialog>
  );
}
