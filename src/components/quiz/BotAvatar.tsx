import React from "react";

const BotAvatar = () => {
  return (
    <div
      className={`w-10 h-10 rounded-full flex items-center justify-center shrink-0 bg-teal-500 text-white font-semibold`}
    >
      <span>V</span>
      <sub className="text-sm">+</sub>
    </div>
  );
};

export default BotAvatar;
