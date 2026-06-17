"use client";

import { SandClockIcon } from "../icons";

const ComingSoon = () => {
    return (
        <div className="flex flex-col items-center justify-center min-h-[40vh] w-full ">
            <div className="flex flex-col items-center text-center space-y-4 bg-white p-16 rounded-2xl shadow-[0px_4px_30px_rgba(0,0,0,0.03)] border border-gray-100 w-full">
                <div className="mb-2">
                        <SandClockIcon />
                </div>

                <h1 className="text-xl md:text-2xl font-bold text-gray-900 tracking-tight">
                    Coming Soon 🚀
                </h1>

                <p className="text-gray-400 text-sm md:text-base leading-relaxed">
                    We&apos;re working on this feature. It will be available very soon.
                </p>
            </div>
        </div>
    );
};

export default ComingSoon;
