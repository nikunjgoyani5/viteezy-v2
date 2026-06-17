import React from "react";

const AuthLayout = ({ children }: { children: React.ReactNode }) => {
  return (
    <main className="bg-off-white-color min-h-screen w-full">{children}</main>
  );
};

export default AuthLayout;
