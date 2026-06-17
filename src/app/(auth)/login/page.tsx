"use client";
import React, { useState } from "react";
import { Eye, EyeOff } from "lucide-react";
import { useForm, FormProvider } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import Image from "next/image";
import Link from "next/link";
import { useRouter } from "next/navigation";
import toast from "react-hot-toast";
import { Button } from "@/components/ui/button";
import AuthInputField from "@/components/ui/inputs/auth/authInput";
import { useLoginMutation } from "@/store/api/authApi";
import AppImage from "@/components/ui/appImage";

// Validation schema
const loginSchema = yup.object().shape({
  email: yup
    .string()
    .required("Email is required")
    .email("Please enter a valid email address"),
  password: yup
    .string()
    .required("Password is required")
    .min(6, "Password must be at least 6 characters"),
});
type LoginFormData = yup.InferType<typeof loginSchema>;

export default function LoginPage() {
  const router = useRouter();
  const [showPassword, setShowPassword] = useState(false);

  // RTK Query login mutation
  const [login, { isLoading }] = useLoginMutation();

  // React Hook Form setup with Yup validation
  const methods = useForm<LoginFormData>({
    resolver: yupResolver(loginSchema),
    mode: "onBlur",
  });

  // Handle form submission
  const onSubmit = async (data: LoginFormData) => {
    try {
      const result = await login({
        email: data.email,
        password: data.password,
        deviceInfo: "Web",
        type: "admin",
      }).unwrap();

      // Success - redirect to admin dashboard
      if (result.success) {
        toast.success("Login successful!");
        router.replace("/admin/dashboard");
      }
    } catch (err: any) {
      const errorMsg =
        err?.data?.message ||
        err?.message ||
        "Login failed. Please check your credentials.";
      toast.error(errorMsg);
      console.error("Login error:", err);
    }
  };

  return (
    <div className="min-h-screen flex">
      {/* Left Side - Login Form */}
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
          {/* Welcome Text */}
          <div className="mb-8">
            <div className="text-[28px] font-normal text-gray-900 tracking-tighter">
              Welcome back.
            </div>
            <div className="text-[28px] font-normal text-gray-900 tracking-tighter -mt-2">
              Log in to your account below.
            </div>
          </div>

          {/* Login Form */}
          <FormProvider {...methods}>
            <form
              onSubmit={methods.handleSubmit(onSubmit)}
              className="space-y-4"
            >
              <AuthInputField
                name="email"
                placeholder="Email / Member ID"
                type="email"
                disabled={isLoading}
              />

              <AuthInputField
                name="password"
                placeholder="Password"
                type={showPassword ? "text" : "password"}
                disabled={isLoading}
                icon={
                  <div
                    onClick={() => setShowPassword(!showPassword)}
                    className="cursor-pointer"
                  >
                    {showPassword ? (
                      <EyeOff size={20} className="text-gray-400" />
                    ) : (
                      <Eye size={20} className="text-gray-400" />
                    )}
                  </div>
                }
              />

              <div className="text-right">
                <Link
                  href="/forgotPassword"
                  className="text-sm text-black font-semibold underline hover:text-gray-900"
                >
                  Forgot your password?
                </Link>
              </div>

              <Button
                type="submit"
                disabled={isLoading}
                animateText
                size="login"
                className="w-full bg-teal-500 hover:bg-teal-600 text-white font-medium rounded-4xl hover:rounded-xl transition-all duration-300 disabled:opacity-50 disabled:cursor-not-allowed"
              >
                {isLoading ? "Logging in..." : "Log In"}
              </Button>
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
