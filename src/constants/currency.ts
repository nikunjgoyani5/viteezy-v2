// Currency constants and types
export const CURRENCIES = {
  USD: {
    symbol: '$',
    code: 'USD',
    name: 'US Dollar',
    decimalPlaces: 2,
  },
  EUR: {
    symbol: '€',
    code: 'EUR',
    name: 'Euro',
    decimalPlaces: 2,
  },
} as const;

export type CurrencyCode = keyof typeof CURRENCIES;
export type CurrencyInfo = typeof CURRENCIES[CurrencyCode];

// Default currency
export const DEFAULT_CURRENCY: CurrencyCode = 'USD';

// Currency formatting options
export interface FormatCurrencyOptions {
  currency?: CurrencyCode;
  amount: number;
  showSymbol?: boolean;
  showCode?: boolean;
  decimalPlaces?: number;
  locale?: string;
}

// Currency display format interface
export interface FormattedCurrency {
  symbol: string;
  amount: string;
  code: string;
  fullDisplay: string;
  currency: CurrencyCode;
}
