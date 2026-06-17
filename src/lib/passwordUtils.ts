import * as yup from "yup";

const LOWERCASE = "abcdefghijklmnopqrstuvwxyz";
const UPPERCASE = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const NUMBERS = "0123456789";
const SPECIAL = "!@#$%^&*()_+-=[]{}|;:,.<>?";
const ALL_CHARS = LOWERCASE + UPPERCASE + NUMBERS + SPECIAL;

export const PASSWORD_REQUIREMENTS = [
  { id: "length", label: "At least 8 characters", test: (v: string) => v.length >= 8 },
  { id: "lower", label: "One lowercase letter", test: (v: string) => /[a-z]/.test(v) },
  { id: "upper", label: "One uppercase letter", test: (v: string) => /[A-Z]/.test(v) },
  { id: "number", label: "One number", test: (v: string) => /[0-9]/.test(v) },
  {
    id: "special",
    label: "One special character",
    test: (v: string) => /[^a-zA-Z0-9]/.test(v),
  },
] as const;

export function generateStrongPassword(length = 16): string {
  const safeLength = Math.max(length, 8);
  const required = [
    LOWERCASE[Math.floor(Math.random() * LOWERCASE.length)],
    UPPERCASE[Math.floor(Math.random() * UPPERCASE.length)],
    NUMBERS[Math.floor(Math.random() * NUMBERS.length)],
    SPECIAL[Math.floor(Math.random() * SPECIAL.length)],
  ];

  const remaining = Array.from({ length: safeLength - required.length }, () =>
    ALL_CHARS[Math.floor(Math.random() * ALL_CHARS.length)]
  );

  const chars = [...required, ...remaining];

  for (let i = chars.length - 1; i > 0; i--) {
    const j = Math.floor(Math.random() * (i + 1));
    [chars[i], chars[j]] = [chars[j], chars[i]];
  }

  return chars.join("");
}

export const strongPasswordFieldSchema = yup
  .string()
  .required("Password is required")
  .min(8, "Password must be at least 8 characters")
  .matches(/[a-z]/, "Password must contain a lowercase letter")
  .matches(/[A-Z]/, "Password must contain an uppercase letter")
  .matches(/[0-9]/, "Password must contain a number")
  .matches(/[^a-zA-Z0-9]/, "Password must contain a special character");

export function getPasswordStrength(password: string): number {
  if (!password) return 0;
  return PASSWORD_REQUIREMENTS.filter((rule) => rule.test(password)).length;
}
