"use client";

import { HeroSection } from "@/store/api/types/landing.types";
import { Pause, Play, Volume2, VolumeX } from "lucide-react";
import { useTranslations } from "next-intl";
import { memo, useRef, useState } from "react";

export default function VideoContent({ data }: { data?: HeroSection }) {
  const t = useTranslations("Landing");
  const [isPlaying, setIsPlaying] = useState(true);
  const [isMuted, setIsMuted] = useState(true);
  const videoRef = useRef<HTMLVideoElement>(null);
  const videoUrl = data?.videoUrl || "";

  const togglePlayPause = () => {
    if (videoRef?.current) {
      if (isPlaying) {
        videoRef.current.pause();
      } else {
        void videoRef.current.play();
      }
      setIsPlaying(!isPlaying);
    }
  };

  const toggleMute = (e: React.MouseEvent) => {
    e.stopPropagation();
    const el = videoRef.current;
    if (!el) return;

    const nextMuted = !isMuted;
    setIsMuted(nextMuted);
    el.muted = nextMuted;

    // Unmuting must follow a user gesture; ensure playback continues.
    if (!nextMuted && el.paused) {
      void el.play();
      setIsPlaying(true);
    }
  };

  return (
    <div className="h-full w-full relative">
      <video
        onClick={togglePlayPause}
        ref={videoRef}
        src={videoUrl}
        autoPlay
        muted={isMuted}
        loop
        playsInline
        preload="metadata"
        className="w-full h-full object-cover"
        poster="/videoThumb.webp" // thumbnail image while video loads
      />
      <div className="absolute bottom-4 left-4 sm:bottom-6 sm:left-6 flex items-center gap-2 z-10">
        <button
          id="video-controls-button"
          type="button"
          onClick={togglePlayPause}
          className="
              flex items-center justify-center 
              w-10 h-10 sm:w-12 sm:h-12
              bg-white/90 backdrop-blur-sm 
              rounded-full 
              shadow-lg 
              hover:bg-white hover:scale-105 
              transition-all duration-200 
              cursor-pointer
            "
          aria-label={isPlaying ? t("pauseVideo") : t("playVideo")}
        >
          {isPlaying ? (
            <Pause
              className="w-5 h-5 sm:w-6 sm:h-6 text-gray-900"
              strokeWidth={0}
              fill="currentColor"
            />
          ) : (
            <Play
              className="w-5 h-5 sm:w-6 sm:h-6 text-gray-900 ml-1"
              strokeWidth={0}
              fill="currentColor"
            />
          )}
        </button>
        {/* <button
          type="button"
          onClick={toggleMute}
          className="
              flex items-center justify-center 
              w-10 h-10 sm:w-12 sm:h-12
              bg-white/90 backdrop-blur-sm 
              rounded-full 
              shadow-lg 
              hover:bg-white hover:scale-105 
              transition-all duration-200 
              cursor-pointer
            "
          aria-label={isMuted ? t("unmuteVideo") : t("muteVideo")}
        >
          {isMuted ? (
            <VolumeX
              className="w-5 h-5 sm:w-6 sm:h-6 text-gray-900"
              strokeWidth={2}
            />
          ) : (
            <Volume2
              className="w-5 h-5 sm:w-6 sm:h-6 text-gray-900"
              strokeWidth={2}
            />
          )}
        </button> */}
      </div>
    </div>
  );
};
