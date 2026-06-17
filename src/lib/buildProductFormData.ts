export type UploadMaybe = File | string | null | undefined;

export type ProductUpsertPayload = {
  title: string;
  description: string;
  shortDescription: string;

  productImage?: UploadMaybe;
  galleryImages?: UploadMaybe[];
  standupPouchImages?: UploadMaybe[];

  hasStandupPouch: boolean;

  sachetPrices: unknown;
  standupPouchPrice: unknown;

  categories: string[];
  ingredientCompositions: {
    ingredient: string;
    quantity: number | string;
    driPercentage: number | string;
  }[];
  ingredientMeta?: {
    sectionTitle?: string;
    sectionSubtitle?: string;
    excipients?: string;
    backgroundImage?: UploadMaybe;
  };
  healthGoals: string[];
  benefits: string[];

  faqs?: { question?: string; answer?: string }[];

  nutritionInfo: string;
  howToUse: string;

  status?: boolean;
  isFeatured?: boolean;

  comparisonSection?: unknown;
  similarProducts?: { _id: string; title?: string; productImage?: string }[];

  specificationMainTitle?: string;
  specificationBgImage?: UploadMaybe;

  specificationTitle1?: string;
  specificationDescr1?: string;
  specificationItemImage1?: UploadMaybe;
  specificationItemImagemobile1?: UploadMaybe;

  specificationTitle2?: string;
  specificationDescr2?: string;
  specificationItemImage2?: UploadMaybe;
  specificationItemImagemobile2?: UploadMaybe;

  specificationTitle3?: string;
  specificationDescr3?: string;
  specificationItemImage3?: UploadMaybe;
  specificationItemImagemobile3?: UploadMaybe;

  specificationTitle4?: string;
  specificationDescr4?: string;
  specificationItemImage4?: UploadMaybe;
  specificationItemImagemobile4?: UploadMaybe;
};

const isFile = (v: unknown): v is File =>
  typeof File !== "undefined" && v instanceof File;

const isUrlString = (v: unknown): v is string =>
  typeof v === "string" && v.trim().length > 0;

const appendString = (fd: FormData, key: string, val: unknown) => {
  if (val === undefined || val === null) return;
  fd.append(key, String(val));
};

const appendBool = (fd: FormData, key: string, val: boolean | undefined) => {
  if (val === undefined || val === null) return;
  fd.append(key, val ? "true" : "false");
};

const appendJson = (fd: FormData, key: string, val: unknown) => {
  if (val === undefined || val === null) return;
  fd.append(key, JSON.stringify(val));
};

const parseNumberish = (value: unknown) => {
  if (typeof value === "number") return Number.isNaN(value) ? undefined : value;
  if (typeof value !== "string") return undefined;
  const trimmed = value.trim();
  if (!trimmed) return undefined;
  const normalized = trimmed.replace(/,/g, "").replace(/%$/, "").trim();
  if (!normalized) return undefined;
  const parsed = Number(normalized);
  return Number.isNaN(parsed) ? undefined : parsed;
};

// ✅ append same key for both string urls and files
const appendMixed = (fd: FormData, key: string, val?: UploadMaybe) => {
  if (!val) return;
  if (isFile(val)) fd.append(key, val);
  else if (isUrlString(val)) fd.append(key, val);
};

const appendFileOnly = (fd: FormData, key: string, val?: UploadMaybe) => {
  if (isFile(val)) fd.append(key, val);
};

const appendMixedMany = (fd: FormData, key: string, vals?: UploadMaybe[]) => {
  if (!vals?.length) return;
  vals.forEach((v) => appendMixed(fd, key, v)); // repeat same key multiple times
};

export function buildProductFormData(payload: ProductUpsertPayload) {
  const fd = new FormData();

  // strings
  appendString(fd, "title", payload.title);
  appendString(fd, "description", payload.description);
  appendString(fd, "shortDescription", payload.shortDescription);

  // booleans
  appendBool(fd, "hasStandupPouch", payload.hasStandupPouch);
  appendBool(fd, "status", payload.status ?? true);
  appendBool(fd, "isFeatured", payload.isFeatured ?? false);

  // images (same keys)
  appendMixed(fd, "productImage", payload.productImage);
  appendMixedMany(fd, "galleryImages", payload.galleryImages);
  appendMixedMany(fd, "standupPouchImages", payload.standupPouchImages);

  // objects as JSON
  appendJson(fd, "sachetPrices", payload.sachetPrices);
  appendJson(fd, "standupPouchPrice", payload.standupPouchPrice);
  appendJson(fd, "comparisonSection", payload.comparisonSection);
  appendJson(
    fd,
    "similarProducts",
    (payload.similarProducts ?? []).map((p) => p._id)
  );

  const validFaqs = (payload?.faqs ?? []).filter(
    (f) =>
      (typeof f.question === "string" && f.question.trim() !== "") ||
      (typeof f.answer === "string" && f.answer.trim() !== "")
  );
  if (validFaqs.length > 0) {
    appendJson(fd, "faqs", validFaqs);
  }

  // arrays as JSON (backend expects JSON strings); filter out empty benefits
  appendJson(fd, "categories", payload.categories);
  const ingredientMeta = payload.ingredientMeta;
  if (ingredientMeta) {
    appendString(
      fd,
      "ingredientMeta[sectionTitle]",
      ingredientMeta.sectionTitle ?? ""
    );
    appendString(
      fd,
      "ingredientMeta[sectionSubtitle]",
      ingredientMeta.sectionSubtitle ?? ""
    );
    appendString(
      fd,
      "ingredientMeta[excipients]",
      ingredientMeta.excipients ?? ""
    );
    appendFileOnly(
      fd,
      "ingredientMeta.backgroundImage",
      ingredientMeta.backgroundImage
    );
  }

  appendJson(
    fd,
    "ingredientCompositions",
    (payload.ingredientCompositions ?? []).map((item) => {
      const quantity =
        typeof item.quantity === "string"
          ? item.quantity.trim()
          : String(item.quantity ?? "").trim();
      const driPercentageValue =
        item.driPercentage === "*" || item.driPercentage === "**"
          ? item.driPercentage
          : parseNumberish(item.driPercentage);

      return {
        ingredient: item.ingredient,
        quantity,
        driPercentage: driPercentageValue ?? 0,
      };
    })
  );
  appendJson(fd, "healthGoals", payload.healthGoals);
  appendJson(
    fd,
    "benefits",
    (payload.benefits || []).filter(
      (b) => typeof b === "string" && b.trim() !== ""
    )
  );

  // rich text
  appendString(fd, "nutritionInfo", payload.nutritionInfo);
  appendString(fd, "howToUse", payload.howToUse);

  // specification
  appendString(fd, "specificationMainTitle", payload.specificationMainTitle);
  appendMixed(fd, "specificationBgImage", payload.specificationBgImage);

  appendString(fd, "specificationTitle1", payload.specificationTitle1);
  appendString(fd, "specificationDescr1", payload.specificationDescr1);
  appendMixed(fd, "specificationItemImage1", payload.specificationItemImage1);
  appendMixed(
    fd,
    "specificationItemImagemobile1",
    payload.specificationItemImagemobile1
  );

  appendString(fd, "specificationTitle2", payload.specificationTitle2);
  appendString(fd, "specificationDescr2", payload.specificationDescr2);
  appendMixed(fd, "specificationItemImage2", payload.specificationItemImage2);
  appendMixed(
    fd,
    "specificationItemImagemobile2",
    payload.specificationItemImagemobile2
  );

  appendString(fd, "specificationTitle3", payload.specificationTitle3);
  appendString(fd, "specificationDescr3", payload.specificationDescr3);
  appendMixed(fd, "specificationItemImage3", payload.specificationItemImage3);
  appendMixed(
    fd,
    "specificationItemImagemobile3",
    payload.specificationItemImagemobile3
  );

  appendString(fd, "specificationTitle4", payload.specificationTitle4);
  appendString(fd, "specificationDescr4", payload.specificationDescr4);
  appendMixed(fd, "specificationItemImage4", payload.specificationItemImage4);
  appendMixed(
    fd,
    "specificationItemImagemobile4",
    payload.specificationItemImagemobile4
  );

  return fd;
}
