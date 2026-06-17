/**
 * Slug generation and validation utilities
 */

import * as yup from "yup";

// Slug validation regex (same as blog form)
export const SLUG_REGEX = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

// Slug validation messages
export const SLUG_VALIDATION_MESSAGES = {
  required: "Slug is required",
  minLength: "Slug must be at least 3 characters",
  maxLength: "Slug must be at most 80 characters",
  format: "Slug must be lowercase and can contain only letters, numbers, and single hyphens (e.g. my-first-post). No spaces.",
};

/**
 * Generate slug from title
 * Converts title to URL-friendly slug format
 */
export const generateSlugFromTitle = (title: string): string => {
  if (!title.trim()) return "";

  return title
    .toLowerCase()
    .trim()
    // Replace spaces and special characters with hyphens
    .replace(/[^\w\s-]/g, '') // Remove special characters except hyphens
    .replace(/[\s_-]+/g, '-') // Replace spaces, underscores with single hyphen
    .replace(/^-+|-+$/g, '') // Remove leading/trailing hyphens
    .substring(0, 80); // Limit to 80 characters
};

/**
 * Validate slug format
 */
export const validateSlug = (slug: string): { isValid: boolean; message?: string } => {
  if (!slug.trim()) {
    return { isValid: false, message: SLUG_VALIDATION_MESSAGES.required };
  }

  if (slug.length < 3) {
    return { isValid: false, message: SLUG_VALIDATION_MESSAGES.minLength };
  }

  if (slug.length > 80) {
    return { isValid: false, message: SLUG_VALIDATION_MESSAGES.maxLength };
  }

  if (!SLUG_REGEX.test(slug)) {
    return { isValid: false, message: SLUG_VALIDATION_MESSAGES.format };
  }

  return { isValid: true };
};

/**
 * Yup schema for slug validation
 */
export const createSlugValidation = () => {
  return yup.string()
    .required(SLUG_VALIDATION_MESSAGES.required)
    .min(3, SLUG_VALIDATION_MESSAGES.minLength)
    .max(80, SLUG_VALIDATION_MESSAGES.maxLength)
    .matches(SLUG_REGEX, SLUG_VALIDATION_MESSAGES.format);
};

/**
 * Generate slug and validate it
 */
export const generateAndValidateSlug = (title: string): { slug: string; isValid: boolean; message?: string } => {
  const slug = generateSlugFromTitle(title);
  const validation = validateSlug(slug);
  
  return {
    slug,
    isValid: validation.isValid,
    message: validation.message,
  };
};
