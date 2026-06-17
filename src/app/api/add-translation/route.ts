import { NextRequest, NextResponse } from "next/server";
import fs from "fs";
import path from "path";
import { locales } from "@/i18n/config";

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();

    if (!body.key || !body.value) {
      return NextResponse.json(
        { error: "Key and value are required" },
        { status: 400 }
      );
    }

    const { key, value } = body;

    const langs = locales; // Add more languages if needed
    const baseDir = path.join(process.cwd(), "messages");

    // Ensure the directory exists
    if (!fs.existsSync(baseDir)) {
      fs.mkdirSync(baseDir, { recursive: true });
    }

    langs.forEach((lang) => {
      const filePath = path.join(baseDir, `${lang}.json`);
      let translations: { [key: string]: string } = {};

      // Read or create the file
      if (fs.existsSync(filePath)) {
        try {
          translations = JSON.parse(fs.readFileSync(filePath, "utf-8"));
        } catch (error) {
          console.error(`Error reading ${lang}.json:`, error);
        }
      }

      // Add the translation if not already present
      if (!translations[key]) {
        translations[key] = value;

        try {
          fs.writeFileSync(
            filePath,
            JSON.stringify(translations, null, 2),
            "utf-8"
          );
        } catch (error) {
          console.error(`Error writing to ${lang}.json:`, error);
        }
      }
    });

    return NextResponse.json({ success: true }, { status: 200 });
  } catch (error) {
    return NextResponse.json({ error: "Invalid request" }, { status: 400 });
  }
}
