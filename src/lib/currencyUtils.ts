import { 
  CURRENCIES, 
  DEFAULT_CURRENCY, 
  type CurrencyCode, 
  type CurrencyInfo, 
  type FormatCurrencyOptions, 
  type FormattedCurrency 
} from '@/constants/currency';

/**
 * Get currency information by code
 */
export const getCurrencyInfo = (currency?: CurrencyCode): CurrencyInfo => {
  const code = currency || DEFAULT_CURRENCY;
  return CURRENCIES[code] || CURRENCIES[DEFAULT_CURRENCY];
};

/**
 * Get currency symbol by code
 */
export const getCurrencySymbol = (currency?: CurrencyCode): string => {
  return getCurrencyInfo(currency).symbol;
};

/**
 * Format currency amount with proper decimal places
 */
export const formatCurrencyAmount = (
  amount: number, 
  decimalPlaces?: number
): string => {
  const places = decimalPlaces ?? 2;
  return amount.toFixed(places);
};

/**
 * Main currency formatting function
 * Returns a formatted currency object with all necessary display information
 */
export const formatCurrency = (options: FormatCurrencyOptions): FormattedCurrency => {
  const {
    currency = DEFAULT_CURRENCY,
    amount,
    showSymbol = true,
    showCode = false,
    decimalPlaces,
    locale = 'en-US'
  } = options;

  const currencyInfo = getCurrencyInfo(currency);
  const formattedAmount = formatCurrencyAmount(amount, decimalPlaces ?? currencyInfo.decimalPlaces);
  
  // Create the display string
  let fullDisplay = '';
  if (showSymbol) {
    fullDisplay = `${currencyInfo.symbol}${formattedAmount}`;
  } else {
    fullDisplay = formattedAmount;
  }
  
  if (showCode) {
    fullDisplay += ` ${currencyInfo.code}`;
  }

  return {
    symbol: currencyInfo.symbol,
    amount: formattedAmount,
    code: currencyInfo.code,
    fullDisplay,
    currency,
  };
};

/**
 * Simple currency formatting function for common use cases
 * Returns just the formatted display string
 * Uses USD as default currency if none provided
 */
export const formatCurrencySimple = (
  amount: number, 
  currency?: CurrencyCode
): string => {
  return formatCurrency({ amount, currency: currency || DEFAULT_CURRENCY }).fullDisplay;
};

/**
 * Format currency for display in UI components
 * Similar to the existing formattedPrice pattern but standardized
 */
export const formatPriceForDisplay = (
  amount: number, 
  currency?: CurrencyCode
): { currency: CurrencyCode; amount: string } => {
  const formatted = formatCurrency({ amount, currency });
  return {
    currency: formatted.currency,
    amount: formatted.amount,
  };
};

/**
 * Legacy compatibility function - replaces the old pattern
 * Use this to gradually migrate existing code
 */
export const formatLegacyPrice = (
  amount: number, 
  currency?: string
): { currency: string; amount: string } => {
  // Handle legacy string currency codes
  const currencyCode = (currency?.toUpperCase() as CurrencyCode) || DEFAULT_CURRENCY;
  const formatted = formatCurrency({ amount, currency: currencyCode });
  return {
    currency: formatted.currency,
    amount: formatted.amount,
  };
};
