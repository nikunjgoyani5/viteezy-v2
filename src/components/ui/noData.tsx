import React from "react";
import AppImage from "./appImage";

const NoData = ({
  title = "No data found",
  description = "You can contact support or explore other help articles.",
  image = "/images/noData/faq.webp",
  action,
}: {
  title?: string;
  description?: string;
  image?: string;
  action?: React.ReactNode | null | undefined | false;
}) => {
  return (
    <div className="min-h-104 bg-white rounded-lg border px-5 flex items-center justify-center">
      <div className="text-center">
        <AppImage
          alt="faq-not-found"
          src={image}
          width={266}
          height={266}
          className="mx-auto"
        />
        <h3 className="heading-sm">{title}</h3>
        <p className="text-text-gray">{description}</p>
        {action && <div className="mt-4">{action}</div>}
      </div>
    </div>
  );
};

export default NoData;
