const COUPON_PREFIXES = [
  "SAVE",
  "WELCOME",
  "DISCOUNT",
  "OFFER",
  "DEAL",

  // Common marketing terms
  "PROMO",
  "SALE",
  "BONUS",
  "REWARD",
  "GIFT",
  "VALUE",

  // Urgency / campaign style
  "LIMITED",
  "FLASH",
  "HOT",
  "SPECIAL",

  // E-commerce friendly
  "CASH",
  "PRICECUT",
  "MARKDOWN",
  "STEAL",

  // New user / loyalty
  "NEW",
  "FIRST",
  "LOYAL",
  "THANKYOU",
];

export const generateCouponCode = (): string => {
  const chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

  const randomPart = (length: number) =>
    Array.from({ length })
      .map(() => chars[Math.floor(Math.random() * chars.length)])
      .join("");

  const prefix =
    COUPON_PREFIXES[Math.floor(Math.random() * COUPON_PREFIXES.length)];

  return `${prefix}-${randomPart(4)}-${randomPart(4)}`;
};
