"use client";

import React, { useEffect, useState } from "react";
import { cn } from "@/lib/utils";

interface RichTextDisplayProps {
  content: string;
  className?: string;
  maxLines?: number;
  showFullContent?: boolean;
}

export default function RichTextDisplay({ 
  content, 
  className, 
  maxLines = 2,
  showFullContent = false 
}: RichTextDisplayProps) {
  const [textContent, setTextContent] = useState("");
  const [isClient, setIsClient] = useState(false);

  useEffect(() => {
    setIsClient(true);
    if (content) {
      // Strip HTML tags for plain text display with truncation
      const div = document.createElement('div');
      div.innerHTML = content;
      const text = div.textContent || div.innerText || '';
      setTextContent(text);
    }
  }, [content]);

  if (!content) {
    return <span className={cn("text-gray-500", className)}>No description</span>;
  }

  // If showFullContent is true, render the full HTML content
  if (showFullContent && isClient) {
    return (
      <div 
        className={cn("prose prose-sm max-w-none text-gray-700", className)}
        dangerouslySetInnerHTML={{ __html: content }}
      />
    );
  }

  // For table view, show truncated text
  const truncatedText = textContent.length > 100 
    ? textContent.substring(0, 100) + "..." 
    : textContent;

  return (
    <span className={cn("text-gray-700 block max-w-xs", className)}>
      {isClient ? truncatedText : content.substring(0, 100) + (content.length > 100 ? "..." : "")}
    </span>
  );
}
