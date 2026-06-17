import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  /* config options here */
  output: "standalone",
  outputFileTracingRoot: path.join(__dirname),
  reactCompiler: true,
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "blr1.digitaloceanspaces.com",
      },
      {
        protocol: "https",
        hostname: "milestone.blr1.digitaloceanspaces.com",
      },
      {
        protocol: "https",
        hostname: "guardianshot.blr1.digitaloceanspaces.com",
      },
      {
        protocol: "https",
        hostname: "blr1.digitaloceanspaces.com",
      },
    ],
  },
};

export default nextConfig;
