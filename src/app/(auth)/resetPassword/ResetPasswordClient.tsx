"use client";

import React, { useEffect, useState } from "react";
import { Eye, EyeOff, Sparkles } from "lucide-react";
import { useForm, FormProvider } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import Image from "next/image";
import Link from "next/link";
import { Button } from "@/components/ui/button";
import AuthInputField from "@/components/ui/inputs/auth/authInput";
import { useSearchParams, useRouter } from "next/navigation";
import { useResetPasswordMutation } from "@/store/api/authApi";
import AppImage from "@/components/ui/appImage";
import { PasswordRequirements } from "@/components/auth/PasswordRequirements";
import {
  generateStrongPassword,
  strongPasswordFieldSchema,
} from "@/lib/passwordUtils";

const resetPasswordSchema = yup.object().shape({
  newPassword: strongPasswordFieldSchema,
  confirmPassword: yup
    .string()
    .required("Please confirm your password")
    .oneOf([yup.ref("newPassword")], "Passwords must match"),
});

type ResetPasswordFormData = yup.InferType<typeof resetPasswordSchema>;

export function ResetPasswordClient() {
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);
  const [showSuccessToast, setShowSuccessToast] = useState(false);
  const searchParams = useSearchParams();
  const router = useRouter();
  const [resetPassword, { isLoading, isSuccess }] = useResetPasswordMutation();

  const tokenFromUrl = searchParams.get("token") || "";
  const emailFromUrl = searchParams.get("email") || "";
  const isInvalidLink = !tokenFromUrl || !emailFromUrl;

  const methods = useForm<ResetPasswordFormData>({
    resolver: yupResolver(resetPasswordSchema),
    mode: "onBlur",
  });

  const newPasswordValue = methods.watch("newPassword") ?? "";

  useEffect(() => {
    if (isSuccess) {
      const timer = setTimeout(() => router.replace("/login"), 2500);
      return () => clearTimeout(timer);
    }
  }, [isSuccess, router]);

  const handleSuggestPassword = () => {
    const password = generateStrongPassword();
    methods.setValue("newPassword", password, {
      shouldValidate: true,
      shouldDirty: true,
    });
    methods.setValue("confirmPassword", password, {
      shouldValidate: true,
      shouldDirty: true,
    });
    setShowNewPassword(true);
    setShowConfirmPassword(true);
  };

  const onSubmit = async (data: ResetPasswordFormData) => {
    setErrorMessage(null);
    try {
      if (isInvalidLink) {
        throw new Error("Invalid or expired reset link.");
      }

      await resetPassword({
        email: emailFromUrl,
        password: data.newPassword,
        confirmPassword: data.confirmPassword,
        token: tokenFromUrl,
      }).unwrap();

      setShowSuccessToast(true);
    } catch (err: any) {
      const errorMsg =
        err?.data?.message ||
        err?.message ||
        "Failed to reset password. Please try again.";
      setErrorMessage(errorMsg);
      console.error("Reset password error:", err);
    }
  };

  return (
    <div className="min-h-screen flex">
      {showSuccessToast && (
        <div className="fixed top-6 right-6 z-50">
          <div className="bg-white shadow-lg border border-green-200 rounded-md px-4 py-3 flex items-center gap-3">
            <span className="inline-block h-2 w-2 rounded-full bg-green-500" />
            <p className="text-sm text-gray-900">
              Password reset successfully. You can now sign in.
            </p>
          </div>
        </div>
      )}
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
              Reset your password
            </h2>
            {emailFromUrl && (
              <p className="text-sm text-gray-700 leading-relaxed">
                Resetting password for{" "}
                <span className="font-medium">{emailFromUrl}</span>
              </p>
            )}
          </div>

          {isInvalidLink ? (
            <div className="space-y-4">
              <div className="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-lg text-sm">
                This reset link is invalid or has expired. Please request a new
                one.
              </div>
              <div className="text-center">
                <Link
                  href="/forgotPassword"
                  className="text-sm text-black font-semibold underline hover:text-gray-900"
                >
                  Request a new reset link
                </Link>
              </div>
            </div>
          ) : (
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

                <div className="flex items-center justify-end">
                  <button
                    type="button"
                    onClick={handleSuggestPassword}
                    disabled={isLoading || isSuccess}
                    className="inline-flex items-center gap-1.5 text-sm font-medium text-teal-600 hover:text-teal-700 cursor-pointer disabled:opacity-50 disabled:cursor-not-allowed"
                  >
                    <Sparkles size={14} />
                    Suggest strong password
                  </button>
                </div>

                <AuthInputField
                  name="newPassword"
                  placeholder="New Password"
                  type={showNewPassword ? "text" : "password"}
                  disabled={isLoading || isSuccess}
                  icon={
                    <div
                      onClick={() => setShowNewPassword(!showNewPassword)}
                      className="cursor-pointer"
                    >
                      {showNewPassword ? (
                        <EyeOff size={20} className="text-gray-400" />
                      ) : (
                        <Eye size={20} className="text-gray-400" />
                      )}
                    </div>
                  }
                />

                <AuthInputField
                  name="confirmPassword"
                  placeholder="Confirm password"
                  type={showConfirmPassword ? "text" : "password"}
                  disabled={isLoading || isSuccess}
                  icon={
                    <div
                      onClick={() =>
                        setShowConfirmPassword(!showConfirmPassword)
                      }
                      className="cursor-pointer"
                    >
                      {showConfirmPassword ? (
                        <EyeOff size={20} className="text-gray-400" />
                      ) : (
                        <Eye size={20} className="text-gray-400" />
                      )}
                    </div>
                  }
                />

                <PasswordRequirements password={newPasswordValue} />

                <Button
                  type="submit"
                  disabled={isLoading || isSuccess}
                  animateText
                  size="login"
                  className="w-full bg-teal-500 hover:bg-teal-600 text-white font-medium disabled:opacity-50 disabled:cursor-not-allowed"
                >
                  {isLoading ? "Changing..." : "Change Password"}
                </Button>
                {isSuccess && (
                  <div className="text-center pt-2">
                    <p className="text-sm text-gray-600 mb-2">
                      Redirecting to sign in...
                    </p>
                    <Link
                      href="/login"
                      className="text-sm text-black font-semibold underline hover:text-gray-900"
                    >
                      Back to sign in
                    </Link>
                  </div>
                )}
              </form>
            </FormProvider>
          )}
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
              <span className="text-lg font-sans tracking-wider">
                SHEERLUXE
              </span>
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
                URBAN
                <br />
                LIST
              </span>
            </div>
            <div className="flex justify-center">
              <span className="text-xl font-serif">
                BOD<span className="text-teal-500">i</span>
              </span>
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

