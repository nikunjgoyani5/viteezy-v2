"use client";

import React, { useEffect, useState } from "react";

interface TypingTextProps {
  text: string;
  speed?: number; // Now represents ms per word
  onComplete?: () => void;
}

const TypingText = ({ text, speed = 60, onComplete }: TypingTextProps) => {
  const [displayedText, setDisplayedText] = useState("");

  useEffect(() => {
    setDisplayedText("");

    if (!text) return;

    const words = text.split(" ");
    let wordIndex = 0;
    const displayedWords: string[] = [];

    const interval = setInterval(() => {
      displayedWords.push(words[wordIndex]);
      setDisplayedText(displayedWords.join(" "));
      wordIndex++;

      if (wordIndex >= words.length) {
        clearInterval(interval);
        onComplete?.();
      }
    }, speed);

    return () => clearInterval(interval);
  }, [text, speed, onComplete]);

  return <span>{displayedText}</span>;
};

export default TypingText;
