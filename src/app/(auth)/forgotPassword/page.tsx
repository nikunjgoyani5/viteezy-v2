"use client";
import React, { useState } from "react";
import { useForm, FormProvider } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import AuthInputField from "@/components/ui/inputs/auth/authInput";
import { CircleCheck } from "lucide-react";
import toast from "react-hot-toast";
import { useForgotPasswordMutation } from "@/store/api/authApi";
import AppImage from "@/components/ui/appImage";

// Validation schema
const resetPasswordSchema = yup.object().shape({
  email: yup
    .string()
    .required("Email is required")
    .email("Please enter a valid email address"),
});
type ResetPasswordFormData = yup.InferType<typeof resetPasswordSchema>;

export default function ForgotPasswordPage() {
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [submittedEmail, setSubmittedEmail] = useState<string | null>(null);
  const [forgotPassword, { isLoading }] = useForgotPasswordMutation();

  // React Hook Form setup with Yup validation
  const methods = useForm<ResetPasswordFormData>({
    resolver: yupResolver(resetPasswordSchema),
    mode: "onBlur",
  });

  // Handle form submission
  const onSubmit = async (data: ResetPasswordFormData) => {
    setErrorMessage(null);
    setSubmittedEmail(null);
    try {
      await forgotPassword({
        email: data.email,
        deviceInfo: "Web",
        type: "admin",
      }).unwrap();

      setSubmittedEmail(data.email);
      toast.success("Reset link sent. Check your inbox.");
    } catch (err: any) {
      const errorMsg =
        err?.data?.message ||
        "Failed to send reset link. Please try again.";
      setErrorMessage(errorMsg);
      toast.error(errorMsg);
      console.error("Forgot password error:", err);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Reset Password Form */}
      <div className="w-full lg:w-1/2 bg-off-white-color flex flex-col items-center p-8">
        {/* Logo */}
        <AppImage
            src="/logos/fullLogo.svg"
            alt="logo"
            width={218}
            height={24}
            className="mx-auto"
          />

        <div className="w-full max-w-sm flex-1 flex flex-col justify-center">
          {/* Heading */}
          <div className="mb-6">
            <h2 className="text-[28px] font-normal text-gray-900 tracking-tight mb-4">
              Forgot Password
            </h2>
            <p className="text-sm text-gray-700 leading-relaxed">
              Enter the email address associated with your account.
            </p>
            <p className="text-sm text-gray-700 leading-relaxed">
              If you have an account, we'll send a reset link to your email.
            </p>
          </div>

          {/* Reset Password Form */}
          <FormProvider {...methods}>
            <form
              onSubmit={methods.handleSubmit(onSubmit)}
              className="space-y-4"
            >
              {errorMessage && (
                <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg text-sm">
                  {errorMessage}
                </div>
              )}

              <AuthInputField
                name="email"
                placeholder="Email / Member ID"
                type="email"
                disabled={isLoading || !!submittedEmail}
              />

              {submittedEmail && (
                <div className="bg-teal-50 border border-teal-200 text-gray-900 px-4 py-4 rounded-lg flex items-start gap-3">
                  <CircleCheck className="text-teal-500 mt-0.5 shrink-0" size={20} />
                  <p className="text-sm leading-relaxed">
                    Reset link sent. Check your inbox at{" "}
                    <span className="font-medium">{submittedEmail}</span> for
                    further instructions.
                  </p>
                </div>
              )}

              <Button
                type="submit"
                animateText
                size="login"
                disabled={isLoading || !!submittedEmail}
                className="w-full bg-teal-500 hover:bg-teal-600 text-white font-medium disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isLoading ? "Sending..." : "Send reset link"}
              </Button>

              <div className="text-center pt-2">
                <Link
                  href="/login"
                  className="text-sm text-black font-semibold underline hover:text-gray-900"
                >
                  Back to sign in
                </Link>
              </div>
            </form>
          </FormProvider>
        </div>
      </div>

      {/* Right Side - Image and Logos */}
      <div className="hidden lg:flex lg:w-1/2 bg-gray-100 flex-col">
        {/* Hero Image */}
        <div className="flex-1 relative">
          <Image
            src="/images/auth/rightSide.png"
            alt="Business professionals"
            fill
            className="object-cover"
            priority
          />
        </div>

        {/* Trusted By Section */}
        <div className="bg-white py-8 px-12">
          <p className="text-sm text-gray-600 text-center mb-6">
            Trusted by teams at
          </p>
          <div className="grid grid-cols-4 gap-8 items-center">
            {/* Row 1 */}
            <div className="flex justify-center">
              <span className="text-xl font-serif">Forbes</span>
            </div>
            <div className="flex justify-center">
              <span className="text-lg font-sans tracking-wider">SHEERLUXE</span>
            </div>
            <div className="flex justify-center">
              <span className="text-xl font-serif italic">GRAZIA</span>
            </div>
            <div className="flex justify-center">
              <span className="text-2xl font-script italic">Boots</span>
            </div>
          </div>
          <div className="grid grid-cols-3 gap-8 items-center mt-6">
            {/* Row 2 */}
            <div className="flex justify-center">
              <span className="text-base font-bold tracking-tight">
                URBAN<br />LIST
              </span>
            </div>
            <div className="flex justify-center">
              <span className="text-xl font-serif">BOD<span className="text-teal-500">i</span></span>
            </div>
            <div className="flex justify-center">
              <span className="text-xl font-serif tracking-wider">VOGUE</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
