"use client";

import FaqForm from "@/components/faqs/manage/FaqForm";
import { useParams } from "next/navigation";

export default function EditFaqPage() {
  const params = useParams();
  const id = typeof params?.id === "string" ? params.id : undefined;

  if (!id) {
    return (
      <div className="min-h-[calc(100vh-96px)] bg-gray-50 flex justify-center items-center">
        <div className="text-red-600">Invalid FAQ ID.</div>
      </div>
    );
  }

  return <FaqForm faqId={id} />;
}
