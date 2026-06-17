"use client";
import React, { useState } from "react";
import { Eye, EyeOff } from "lucide-react";
import { useForm, FormProvider } from "react-hook-form";
import { yupResolver } from "@hookform/resolvers/yup";
import * as yup from "yup";
import InputField from "@/components/ui/inputs/input";
import { Button } from "@/components/ui/button";
import { AppleIcon, GoogleIcon } from "@/components/icons";
import { useLoginMutation, useGoogleLoginMutation, useAppleLoginMutation } from "@/store";
import { useRouter } from "next/navigation";
import AuthErrorMessage from "@/components/ui/authErrorMessage";
import Link from "next/link";
import AuthLayout from "../auth-layout";
import { auth, googleProvider, appleProvider } from "@/lib/firebase";
import { signInWithPopup } from "firebase/auth";
import { useTranslations } from "next-intl";
import { getApiErrorFromUnknown } from "@/lib/apiError";

type LoginFormData = {
  email: string;
  password: string;
};

export default function LoginPage() {
  const tAuth = useTranslations("Auth");
  const tCommon = useTranslations("Common");
  const [showPassword, setShowPassword] = useState(false);
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // RTK Query hook for login mutation
  const [login, { isLoading }] = useLoginMutation();
  const [googleLogin, { isLoading: isGoogleLoading }] = useGoogleLoginMutation();
  const [appleLogin, { isLoading: isAppleLoading }] = useAppleLoginMutation();
  const router = useRouter();

  const loginSchema = yup.object().shape({
    email: yup
      .string()
      .required(tAuth("emailRequired"))
      .email(tAuth("validEmail")),
    password: yup
      .string()
      .required(tAuth("passwordRequired"))
      .min(6, tAuth("passwordMinLength"))
      .max(20, tCommon("passwordMaxLength20")),
  });

  // React Hook Form setup with Yup validation
  const methods = useForm<LoginFormData>({
    resolver: yupResolver(loginSchema),
    mode: "onBlur", // Validate on blur
  });

  // Handle form submission
  const onSubmit = async (data: LoginFormData) => {
    setErrorMessage(null);
    try {
      // Call the login API
      const result = await login(data).unwrap();

      // Success - redirect to account page or home
      if (result.success) {
        // Use replace instead of push to avoid adding to history stack
        // and refresh to update server components without full page reload
        router.push("/");
      }
    } catch (err: unknown) {
      setErrorMessage(
        getApiErrorFromUnknown(err, {
          mode: "single",
          fallback: tAuth("loginFailed"),
        })
      );
      console.error("Login error:", err);
    }
  };

  // Handle Google Login
  const handleGoogleLogin = async () => {
    setErrorMessage(null);
    try {
      // Temporarily clear any existing tokens to avoid auth conflicts
      const existingToken = localStorage.getItem("accessToken");
      if (existingToken) {
        localStorage.removeItem("accessToken");
      }

      const result = await signInWithPopup(auth, googleProvider);
      const idToken = await result.user.getIdToken();

      // Call backend API with the ID token
      const response = await googleLogin({
        idToken,
        deviceInfo: "Web",
      }).unwrap();

      if (response.success) {
        router.push("/");
      }
    } catch (err: unknown) {
      setErrorMessage(
        getApiErrorFromUnknown(err, {
          mode: "single",
          fallback: "Google login failed. Please try again.",
        })
      );
      console.error("Google login error:", err);
    }
  };

  // Handle Apple Login
  const handleAppleLogin = async () => {
    setErrorMessage(null);
    try {
      // Temporarily clear any existing tokens to avoid auth conflicts
      const existingToken = localStorage.getItem("accessToken");
      if (existingToken) {
        localStorage.removeItem("accessToken");
      }

      const result = await signInWithPopup(auth, appleProvider);
      const idToken = await result.user.getIdToken();

      // Call backend API with the ID token
      const response = await appleLogin({
        idToken,
        deviceInfo: "Web",
      }).unwrap();

      if (response.success) {
        router.push("/");
      }
    } catch (err: unknown) {
      setErrorMessage(
        getApiErrorFromUnknown(err, {
          mode: "single",
          fallback: "Apple login failed. Please try again.",
        })
      );
      console.error("Apple login error:", err);
    }
  };

  return (
    <AuthLayout>
      <div className="min-h-screen bg-[#F6F4ED] flex items-center justify-center p-4">
        <div className="w-full max-w-md bg-transparent flex flex-col items-center gap-6">
          <div className="flex items-center gap-3 flex-col">
            <h1 className="text-3xl font-semibold ">{tAuth("login")}</h1>
            <p className="text-base text-gray-600">
              {tAuth("dontHaveAccount")}
              <Link
                href="/createAccount"
                className="ml-1 underline font-medium text-black-color"
              >
                {tAuth("createAccountLink")}
              </Link>
            </p>
          </div>

          <FormProvider {...methods}>
            <form
              onSubmit={methods.handleSubmit(onSubmit)}
              className="w-full flex flex-col gap-4 mt-2"
            >
              {errorMessage && (
                <AuthErrorMessage message={errorMessage} className="mb-2" />
              )}

              <InputField
                name="email"
                placeholder={tAuth("email")}
                type="email"
                disabled={isLoading}
              />

              <InputField
                name="password"
                placeholder={tAuth("password")}
                type={showPassword ? "text" : "password"}
                disabled={isLoading}
                icon={
                  <div
                    onClick={() => setShowPassword(!showPassword)}
                    className="cursor-pointer"
                  >
                    {showPassword ? (
                      <EyeOff size={23} className="text-gray-400" />
                    ) : (
                      <Eye size={23} className="text-gray-400" />
                    )}
                  </div>
                }
              />

              <div className="w-full text-right -mt-2">
                <Link
                  href="/forgotPassword"
                  className="underline text-base text-gray-800 font-medium"
                >
                  {tAuth("forgotPassword")}
                </Link>
              </div>

              <Button
                variant="login"
                size="login"
                type="submit"
                disabled={isLoading}
              >
                {isLoading ? tCommon("loggingIn") : tAuth("login")}
              </Button>

              <div className="flex items-center gap-4">
                <div className="h-px bg-gray-300 flex-1"></div>
                <span className="text-gray-600 text-base">{tAuth("orContinueWith")}</span>
                <div className="h-px bg-gray-300 flex-1"></div>
              </div>

              <Button
                variant="outline"
                size="login"
                type="button"
                onClick={handleGoogleLogin}
                disabled={isGoogleLoading || isLoading}
              >
                <GoogleIcon className="w-5 h-5" />{" "}
                <span className="text-lg">
                  {isGoogleLoading ? tCommon("loggingIn") : tCommon("loginWithGoogle")}
                </span>
              </Button>

              <Button
                variant="outline"
                size="login"
                type="button"
                onClick={handleAppleLogin}
                disabled={isAppleLoading || isLoading}
              >
                <AppleIcon className="w-6 h-6" />{" "}
                <span className="text-lg">
                  {isAppleLoading ? tCommon("loggingIn") : tCommon("loginWithApple")}
                </span>
              </Button>
            </form>
          </FormProvider>
        </div>
      </div>
    </AuthLayout>
  );
}
