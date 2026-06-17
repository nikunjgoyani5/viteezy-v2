import { AppError } from "./AppError";

export const DEFAULT_CURRENCY = "USD";

export const normalizeCurrency = (currency?: string | null): string =>
  (currency || DEFAULT_CURRENCY).toString().trim().toUpperCase();

export const resolveSingleCurrency = (
  currencies: Array<string | null | undefined>,
  context: string = "pricing"
): string => {
  const normalized = Array.from(
    new Set(
      currencies
        .filter((currency): currency is string => Boolean(currency))
        .map((currency) => normalizeCurrency(currency))
    )
  );

  if (normalized.length === 0) {
    return DEFAULT_CURRENCY;
  }

  if (normalized.length > 1) {
    throw new AppError(
      `Mixed currencies are not supported in ${context}: ${normalized.join(", ")}`,
      400
    );
  }

  return normalized[0];
};

export const assertSameCurrency = (
  expected: string,
  actual: string | null | undefined,
  context: string
): void => {
  const expectedCurrency = normalizeCurrency(expected);
  const actualCurrency = normalizeCurrency(actual);

  if (expectedCurrency !== actualCurrency) {
    throw new AppError(
      `${context} currency mismatch: expected ${expectedCurrency}, received ${actualCurrency}`,
      400
    );
  }
};
