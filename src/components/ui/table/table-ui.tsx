import * as React from "react";
import { cn } from "@/lib/utils";

/**
 * Table Wrapper Component
 * Provides a responsive scrollable container for the table
 */
const Table = React.forwardRef<
    HTMLTableElement,
    React.HTMLAttributes<HTMLTableElement>
>(({ className, ...props }, ref) => (
    <table
        ref={ref}
        className={cn("w-full caption-bottom text-sm", className)}
        {...props}
    />
));
Table.displayName = "Table";

/**
 * Table Header Component
 * Customizable header section with dark background
 * TO CUSTOMIZE: Change bg color by replacing 'bg-gray-700' with your color
 */
const TableHeader = React.forwardRef<
    HTMLTableSectionElement,
    React.HTMLAttributes<HTMLTableSectionElement>
>(({ className, ...props }, ref) => {
    const headerStyles = [
        "bg-slate-gray",        // Background color - change this for different header color
        "font-normal",        // Font weight
        "border-b",           // Add border at bottom for sticky header
    ].join(" ");

    return (
        <thead
            ref={ref}
            className={cn(headerStyles, className)}
            {...props}
        />
    );
});
TableHeader.displayName = "TableHeader";

/**
 * Table Body Component
 * Contains all table rows
 */
const TableBody = React.forwardRef<
    HTMLTableSectionElement,
    React.HTMLAttributes<HTMLTableSectionElement>
>(({ className, ...props }, ref) => {
    const bodyStyles = [
        "[&_tr:last-child]:border-0",  // Remove border from last row
    ].join(" ");

    return (
        <tbody
            ref={ref}
            className={cn(bodyStyles, className)}
            {...props}
        />
    );
});
TableBody.displayName = "TableBody";

/**
 * Table Footer Component
 * Optional footer section for table
 */
const TableFooter = React.forwardRef<
    HTMLTableSectionElement,
    React.HTMLAttributes<HTMLTableSectionElement>
>(({ className, ...props }, ref) => {
    const footerStyles = [
        "border-t",                     // Top border
        "bg-gray-50",                   // Background color
        "font-medium",                  // Font weight
        "[&>tr]:last:border-b-0",      // Remove bottom border from last row
    ].join(" ");

    return (
        <tfoot
            ref={ref}
            className={cn(footerStyles, className)}
            {...props}
        />
    );
});
TableFooter.displayName = "TableFooter";

/**
 * Table Row Component
 * Individual table row with hover effects
 * TO CUSTOMIZE: Change hover color by modifying 'hover:bg-gray-50/50'
 */
const TableRow = React.forwardRef<
    HTMLTableRowElement,
    React.HTMLAttributes<HTMLTableRowElement>
>(({ className, ...props }, ref) => {
    const rowStyles = [
        "border-b",                         // Bottom border
        "border-gray-200",                  // Border color
        "transition-colors",                // Smooth color transitions
        "hover:bg-gray-50/50",             // Hover background - change this for different hover effect
        "data-[state=selected]:bg-gray-50", // Selected state background
    ].join(" ");

    return (
        <tr
            ref={ref}
            className={cn(rowStyles, className)}
            {...props}
        />
    );
});
TableRow.displayName = "TableRow";

/**
 * Table Head Cell Component
 * Header cells (th elements)
 * TO CUSTOMIZE: Change text color by modifying 'text-gray-600'
 */
const TableHead = React.forwardRef<
    HTMLTableCellElement,
    React.ThHTMLAttributes<HTMLTableCellElement>
>(({ className, ...props }, ref) => {
    const headStyles = [
        "h-10",                              // Height - increased for more padding
        "px-3",                              // Horizontal padding
        "text-left",                         // Text alignment
        "align-middle",                      // Vertical alignment
        "font-medium",                       // Font weight
        "text-gray-600",                     // Text color - change this for different header text color
        "text-sm",
        "text-nowrap",                      // Text size
        "[&:has([role=checkbox])]:pr-0",    // Remove padding if contains checkbox
    ].join(" ");

    return (
        <th
            ref={ref}
            className={cn(headStyles, className)}
            {...props}
        />
    );
});
TableHead.displayName = "TableHead";

/**
 * Table Cell Component
 * Regular data cells (td elements)
 * TO CUSTOMIZE: Change padding by modifying 'py-1.5 px-3'
 */
const TableCell = React.forwardRef<
    HTMLTableCellElement,
    React.TdHTMLAttributes<HTMLTableCellElement>
>(({ className, ...props }, ref) => {
    const cellStyles = [
        "py-1.5",                           // Vertical padding - change for more/less spacing
        "px-3",                             // Horizontal padding - change for more/less spacing
        "align-middle",                     // Vertical alignment
        "text-gray-700",                    // Text color
        "[&:has([role=checkbox])]:pr-0",   // Remove padding if contains checkbox
    ].join(" ");

    return (
        <td
            ref={ref}
            className={cn(cellStyles, className)}
            {...props}
        />
    );
});
TableCell.displayName = "TableCell";

/**
 * Table Caption Component
 * Optional caption for table description
 */
const TableCaption = React.forwardRef<
    HTMLTableCaptionElement,
    React.HTMLAttributes<HTMLTableCaptionElement>
>(({ className, ...props }, ref) => {
    const captionStyles = [
        "mt-4",           // Top margin
        "text-sm",        // Text size
        "text-gray-500",  // Text color
    ].join(" ");

    return (
        <caption
            ref={ref}
            className={cn(captionStyles, className)}
            {...props}
        />
    );
});
TableCaption.displayName = "TableCaption";

// Export all components
export {
    Table,
    TableHeader,
    TableBody,
    TableFooter,
    TableHead,
    TableRow,
    TableCell,
    TableCaption,
};
