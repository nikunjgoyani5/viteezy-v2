import BlogPage from "@/components/blog-management/blog";
import React, { Suspense } from "react";

const Blog = () => {
  return (
    <div>
      <Suspense fallback={null}>
        <BlogPage />
      </Suspense>
    </div>
  );
};

export default Blog;
