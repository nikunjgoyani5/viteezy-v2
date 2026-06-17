import type { NextConfig } from "next";
import createNextIntlPlugin from "next-intl/plugin";

const nextConfig: NextConfig = {
  output: "standalone",
  reactStrictMode: false,
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "**",
      },
      {
        protocol: "http",
        hostname: "**",
      },
    ],
    formats: ["image/webp"],
  },
  // Adjust source map handling to avoid invalid third-party maps crashing dev
  productionBrowserSourceMaps: false,
  webpack: (config, { dev, isServer }) => {
    if (dev) {
      // Use a resilient devtool to minimize source map parsing issues
      config.devtool = isServer ? "eval-source-map" : "cheap-module-source-map";
      // Silence non-conformant source map warnings from dependencies
      config.ignoreWarnings = [
        /Failed to parse source map/,
        /Invalid source map/,
        /sourceMapURL could not be parsed/,
      ];
    }
    return config;
  },
};

const withNextIntl = createNextIntlPlugin();

module.exports = withNextIntl(nextConfig);
