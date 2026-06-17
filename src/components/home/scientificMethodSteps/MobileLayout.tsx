import React from "react";
import { stepsData } from "@/components/constants";
import MobileStep from "./MobileStep";
import MobileArrow from "./MobileArrow";
import { DesignedByScienceSection } from "@/store/api/types/landing.types";

const MobileLayout = ({ data }: { data?: DesignedByScienceSection }) => (
  <div className="md:hidden flex flex-col items-center gap-12">
    {data?.steps?.map((step, index) => (
      <div key={index} className="w-full">
        <MobileStep step={step} index={index} />
        {/* {index < stepsData.length - 1 && <MobileArrow />} */}
      </div>
    ))}
  </div>
);

export default MobileLayout;
