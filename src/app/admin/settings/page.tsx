"use client";

import { useRef, useState, useEffect } from "react";
import { Button } from "@/components/ui/button";
import InputField from "@/components/ui/inputs/input";
import PhoneInput, {
  type Value,
  isValidPhoneNumber,
} from "react-phone-number-input";
import "react-phone-number-input/style.css";
import {
  FaFacebook,
  FaInstagram,
  FaLinkedin,
  FaTiktok,
  FaYoutube,
} from "react-icons/fa";
import { MdUpload } from "react-icons/md";
import Textarea from "@/components/ui/inputs/textarea";
import {
  DropdownMenu,
  DropdownMenuTrigger,
  DropdownMenuContent,
  DropdownMenuItem,
} from "@/components/ui/dropdown-menu";
import { AiOutlinePlus } from "react-icons/ai";
import { HiDotsVertical } from "react-icons/hi";
import {
  useGetGeneralSettingsQuery,
  useUpdateGeneralSettingsMutation,
} from "@/store/api/settingsApi";
import toast from "react-hot-toast";

type SocialMediaUrls = {
  facebook: string;
  instagram: string;
  youtube: string;
  linkedin: string;
  tiktok: string;
};

type SocialMediaConfig = {
  id: keyof SocialMediaUrls;
  name: string;
  icon: React.ReactNode;
};

type Language = {
  id: string;
  name: string;
  isDefault: boolean;
  hasTranslations: boolean;
};

const socialMediaConfig: SocialMediaConfig[] = [
  {
    id: "facebook",
    name: "Facebook",
    icon: <FaFacebook className="text-blue-600" size={20} />,
  },
  {
    id: "instagram",
    name: "Instagram",
    icon: <FaInstagram className="text-pink-600" size={20} />,
  },
  {
    id: "youtube",
    name: "YouTube",
    icon: <FaYoutube className="text-red-600" size={20} />,
  },
  {
    id: "linkedin",
    name: "LinkedIn",
    icon: <FaLinkedin className="text-blue-700" size={20} />,
  },
  {
    id: "tiktok",
    name: "TikTok",
    icon: <FaTiktok className="text-black" size={20} />,
  },
];

export default function SettingsPage() {
  const { data: settingsData, isLoading } = useGetGeneralSettingsQuery();
  const [updateSettings, { isLoading: isSaving }] =
    useUpdateGeneralSettingsMutation();

  const [supportEmail, setSupportEmail] = useState("");
  const [supportPhone, setSupportPhone] = useState("");
  const [phoneError, setPhoneError] = useState("");
  const [address, setAddress] = useState("");
  const [tagline, setTagline] = useState("");
  const [lightLogo, setLightLogo] = useState<string | null>(null);
  const [darkLogo, setDarkLogo] = useState<string | null>(null);
  const [lightLogoFile, setLightLogoFile] = useState<File | null>(null);
  const [darkLogoFile, setDarkLogoFile] = useState<File | null>(null);
  const [isDraggingLight, setIsDraggingLight] = useState(false);
  const [isDraggingDark, setIsDraggingDark] = useState(false);
  const lightInputRef = useRef<HTMLInputElement | null>(null);
  const darkInputRef = useRef<HTMLInputElement | null>(null);

  const [socialMedia, setSocialMedia] = useState<SocialMediaUrls>({
    facebook: "",
    instagram: "",
    youtube: "",
    linkedin: "",
    tiktok: "",
  });

  const [socialMediaEnabled, setSocialMediaEnabled] = useState<
    Record<keyof SocialMediaUrls, boolean>
  >({
    facebook: false,
    instagram: false,
    youtube: false,
    linkedin: false,
    tiktok: false,
  });

  // Load data from API when available
  useEffect(() => {
    if (settingsData?.data?.settings) {
      const { settings } = settingsData.data;
      setSupportEmail(settings.supportEmail || "");
      setSupportPhone(settings.supportPhone || "");
      setPhoneError(""); // Clear any previous errors
      // Skip address for now - will be converted from object to string in future
      // setAddress(settings.address || "");
      setTagline(settings.tagline || "");

      const loadedSocialMedia = settings.socialMedia || {
        facebook: "",
        instagram: "",
        youtube: "",
        linkedin: "",
        tiktok: "",
      };
      const socialMediaData: SocialMediaUrls = {
        facebook: loadedSocialMedia.facebook || "",
        instagram: loadedSocialMedia.instagram || "",
        youtube: loadedSocialMedia.youtube || "",
        linkedin: loadedSocialMedia.linkedin || "",
        tiktok: loadedSocialMedia.tiktok || "",
      };
      setSocialMedia(socialMediaData);

      // Enable checkboxes for non-empty social media URLs
      setSocialMediaEnabled({
        facebook: !!loadedSocialMedia.facebook,
        instagram: !!loadedSocialMedia.instagram,
        youtube: !!loadedSocialMedia.youtube,
        linkedin: !!loadedSocialMedia.linkedin,
        tiktok: !!loadedSocialMedia.tiktok,
      });

      if (settings.logoLight) setLightLogo(settings.logoLight);
      if (settings.logoDark) setDarkLogo(settings.logoDark);
    }
  }, [settingsData]);

  const [languages, setLanguages] = useState<Language[]>([
    { id: "en", name: "English", isDefault: true, hasTranslations: true },
    { id: "fr", name: "French", isDefault: false, hasTranslations: false },
    { id: "de", name: "German", isDefault: false, hasTranslations: false },
    { id: "es", name: "Spanish", isDefault: false, hasTranslations: false },
  ]);

  const updateSocialMediaUrl = (id: keyof SocialMediaUrls, url: string) => {
    setSocialMedia((prev) => ({
      ...prev,
      [id]: url,
    }));
  };

  const toggleSocialMedia = (id: keyof SocialMediaUrls) => {
    setSocialMediaEnabled((prev) => ({
      ...prev,
      [id]: !prev[id],
    }));
  };

  const setDefaultLanguage = (id: string) => {
    setLanguages((prev) => prev.map((l) => ({ ...l, isDefault: l.id === id })));
  };

  const removeLanguage = (id: string) => {
    setLanguages((prev) => prev.filter((l) => l.id !== id));
  };

  const setPreviewFromFile = (
    file: File,
    setFn: (url: string) => void,
    setFileFn: (file: File) => void,
  ) => {
    // Validate file type
    if (!file.type.startsWith("image/")) {
      toast.error("Please select a valid image file.");
      return;
    }
    // Validate file size (max 2MB)
    if (file.size > 2 * 1024 * 1024) {
      toast.error("File size must be less than 2MB.");
      return;
    }
    const url = URL.createObjectURL(file);
    setFn(url);
    setFileFn(file);
  };

  const onLightLogoChange: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setPreviewFromFile(
      file,
      (u) => setLightLogo(u),
      (f) => setLightLogoFile(f),
    );
    // Reset input to allow selecting the same file again
    e.target.value = "";
  };

  const onDarkLogoChange: React.ChangeEventHandler<HTMLInputElement> = (e) => {
    const file = e.target.files?.[0];
    if (!file) return;
    setPreviewFromFile(
      file,
      (u) => setDarkLogo(u),
      (f) => setDarkLogoFile(f),
    );
    // Reset input to allow selecting the same file again
    e.target.value = "";
  };

  // Drag & Drop handlers
  const makeDropHandlers = (
    onDropFile: (file: File) => void,
    setDragging: (v: boolean) => void,
  ) => ({
    onDragOver: (e: React.DragEvent) => {
      e.preventDefault();
      setDragging(true);
    },
    onDragLeave: () => setDragging(false),
    onDrop: (e: React.DragEvent) => {
      e.preventDefault();
      setDragging(false);
      const file = e.dataTransfer.files?.[0];
      if (file) onDropFile(file);
    },
  });

  const handlePhoneChange = (value: Value) => {
    const phone = value || "";
    setSupportPhone(phone);
    // Clear error when user starts typing
    if (phoneError) {
      setPhoneError("");
    }
  };

  const handleSave = async () => {
    try {
      // Validate phone before saving
      if (supportPhone && !isValidPhoneNumber(supportPhone)) {
        setPhoneError("Please enter a valid phone number");
        toast.error("Please fix validation errors before saving");
        return;
      }

      const payload: any = {};

      // Only add enabled social media links that are not empty
      const enabledSocialMedia: Partial<SocialMediaUrls> = {};
      (Object.keys(socialMedia) as Array<keyof SocialMediaUrls>).forEach(
        (key) => {
          if (socialMediaEnabled[key] && socialMedia[key].trim()) {
            enabledSocialMedia[key] = socialMedia[key];
          }
        },
      );

      // Only add socialMedia if there's at least one enabled link
      if (Object.keys(enabledSocialMedia).length > 0) {
        payload.socialMedia = enabledSocialMedia;
      }

      // Only add non-empty fields
      if (address.trim()) payload.address = address;
      if (supportPhone.trim()) payload.supportPhone = supportPhone;
      if (supportEmail.trim()) payload.supportEmail = supportEmail;
      if (tagline.trim()) payload.tagline = tagline;

      // Add file data if new files were selected
      if (lightLogoFile) {
        payload.logoLight = lightLogoFile;
      }
      if (darkLogoFile) {
        payload.logoDark = darkLogoFile;
      }

      await updateSettings(payload).unwrap();
      toast.success("Settings saved successfully!");
    } catch (error: any) {
      toast.error(error?.data?.message || "Failed to save settings");
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 max-w-5xl mx-auto px-6">
      {/* Header */}
      <div className=" flex items-center justify-between mb-5">
        <h1 className="text-2xl font-semibold text-gray-900 dark:text-white">
          Settings
        </h1>
        <Button
          onClick={handleSave}
          disabled={isSaving || isLoading}
          className="px-6 py-2.5 bg-teal-500 text-white rounded-lg hover:bg-teal-600 transition-colors disabled:opacity-50 disabled:cursor-not-allowed font-medium"
        >
          {isSaving ? "Saving..." : "Save"}
        </Button>
      </div>

      {/* Main Content - Two Column Layout */}
      <div className="">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-4">
          {/* Left Column */}
          <div className=" col-span-2 w-full">
            <div className="space-y-6">
              {/* Contact Information */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4">
                <h2 className="text-lg font-semibold  dark:text-white mb-6">
                  Contact Information
                </h2>

                <div className="space-y-4">
                  <div>
                    <label className="block text-sm font-medium  dark:text-gray-300 mb-2">
                      Support Email
                    </label>
                    <InputField
                      type="email"
                      value={supportEmail}
                      onChange={(e) => setSupportEmail(e.target.value)}
                      className="w-full bg-slate-gray border-extra-light-gray text-text-gray"
                      placeholder="support@viteezy.com"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-medium  dark:text-gray-300 mb-2">
                      Support Phone
                    </label>
                    <PhoneInput
                      international
                      defaultCountry="US"
                      value={supportPhone}
                      onChange={handlePhoneChange}
                      placeholder="Enter phone number"
                      className={`phone-input-custom ${phoneError ? "phone-input-error" : ""}`}
                    />
                    {phoneError && (
                      <p className="text-red text-sm mt-1">{phoneError}</p>
                    )}
                  </div>

                  <div>
                    <label className="block text-sm font-medium  dark:text-gray-300 mb-2">
                      Address
                    </label>
                    <Textarea
                      value={address}
                      onChange={(e) => setAddress(e.target.value)}
                      className="w-full min-h-[80px] bg-slate-gray border-extra-light-gray text-text-gray"
                      placeholder="123 Innovation Drive, Suite 400&#10;San Francisco, CA 94103"
                    />
                  </div>
                </div>
              </div>

              {/* Social Media Links */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4">
                <h2 className="text-lg font-semibold  dark:text-white mb-6">
                  Social Media Links
                </h2>

                <div className="space-y-4">
                  {socialMediaConfig.map((config) => (
                    <div key={config.id}>
                      <div className="flex items-center gap-2 mb-2">
                        <input
                          type="checkbox"
                          checked={socialMediaEnabled[config.id]}
                          onChange={() => toggleSocialMedia(config.id)}
                          onClick={(e) => e.stopPropagation()}
                          className="appearance-none w-4 h-4 border border-extra-light-gray rounded cursor-pointer relative checked:bg-teal-green checked:border-teal-green focus:ring-2 focus:ring-teal-green after:content-[''] after:absolute after:hidden checked:after:block after:left-[5px] after:top-[2px] after:w-[4px] after:h-[8px] after:border-white after:border-r-2 after:border-b-2 after:rotate-45"
                        />
                        <span className="text-sm font-medium  dark:text-white">
                          {config.name}
                        </span>
                      </div>

                      {/* Input full-width with icon inside on the left */}
                      <div className="ml-6">
                        <InputField
                          type="url"
                          value={socialMedia[config.id]}
                          onChange={(e) =>
                            updateSocialMediaUrl(config.id, e.target.value)
                          }
                          className="w-full bg-white border-extra-light-gray"
                          placeholder={`https://${config.id}.com/viteezy`}
                          disabled={!socialMediaEnabled[config.id]}
                          preIcon={config.icon}
                        />
                      </div>
                    </div>
                  ))}
                </div>
              </div>

              {/* Language Settings */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-extra-light-gray dark:border-gray-800 p-4">
                <h2 className="text-lg font-semibold  dark:text-white mb-6">
                  Language Settings
                </h2>

                <div className="space-y-3">
                  {languages.map((language) => (
                    <div
                      key={language.id}
                      className="flex items-center justify-between p-3 border border-extra-light-gray dark:border-gray-700 rounded-lg hover:border-teal-400 dark:hover:border-teal-600 transition-colors"
                    >
                      <div>
                        <div className="font-medium  dark:text-white">
                          {language.name}
                        </div>
                        {language.isDefault && (
                          <div className="text-sm text-text-gray dark:text-gray-400">
                            Default language
                          </div>
                        )}
                        {!language.hasTranslations && !language.isDefault && (
                          <div className="flex items-center gap-1 text-sm text-text-gray dark:text-gray-400">
                            <svg
                              className="w-4 h-4"
                              fill="currentColor"
                              viewBox="0 0 20 20"
                            >
                              <path
                                fillRule="evenodd"
                                d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"
                                clipRule="evenodd"
                              />
                            </svg>
                            No translations
                          </div>
                        )}
                      </div>
                      <div className="hidden">
                        {language.isDefault ? (
                          <Button variant="outline" size="sm">
                            Preview
                          </Button>
                        ) : (
                          <Button variant="outline" size="sm">
                            Translate
                          </Button>
                        )}

                        <DropdownMenu>
                          <DropdownMenuTrigger asChild>
                            <button className="p-1 cursor-pointer hover:bg-gray-100 dark:hover:bg-gray-800 rounded">
                              <HiDotsVertical className="w-5 h-5 text-gray-500" />
                            </button>
                          </DropdownMenuTrigger>
                          <DropdownMenuContent className="w-44">
                            {!language.isDefault && (
                              <DropdownMenuItem
                                onClick={() => setDefaultLanguage(language.id)}
                                className="cursor-pointer"
                              >
                                Change default
                              </DropdownMenuItem>
                            )}
                            <DropdownMenuItem
                              variant="destructive"
                              onClick={() => removeLanguage(language.id)}
                              className="cursor-pointer"
                            >
                              Remove languages
                            </DropdownMenuItem>
                          </DropdownMenuContent>
                        </DropdownMenu>
                      </div>
                    </div>
                  ))}

                  <Button
                    variant="outline"
                    size="sm"
                    className="gap-2 px-4 py-5 hidden"
                  >
                    <span className="inline-flex items-center justify-center w-5 h-5 rounded-full bg-teal-500 text-white">
                      <AiOutlinePlus className="w-4 h-4" />
                    </span>
                    Add languages
                  </Button>
                </div>
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-6">
            {/* Branding */}
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4">
              <h2 className="text-lg font-semibold  dark:text-white mb-6">
                Branding
              </h2>

              <div className="space-y-6">
                <div>
                  <div className="flex items-center justify-between mb-3">
                    <label className="block text-sm font-medium  dark:text-gray-300">
                      Light Logo
                    </label>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <button className="text-teal-green hover:text-teal-green text-sm font-medium flex items-center gap-1 cursor-pointer">
                          Edit
                          <svg
                            className="w-4 h-4"
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z" />
                          </svg>
                        </button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent className="w-40 ">
                        <DropdownMenuItem
                          onClick={() => lightInputRef.current?.click()}
                          className="cursor-pointer"
                        >
                          Change image
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                    <input
                      ref={lightInputRef}
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={onLightLogoChange}
                    />
                  </div>
                  <div
                    className={`border-2 border-dashed rounded-lg min-h-44 p-0 text-center transition-colors cursor-pointer flex flex-col justify-center items-center ${
                      isDraggingLight
                        ? "border-teal-400"
                        : "border-gray-300 dark:border-gray-700 hover:border-teal-400"
                    }`}
                    onClick={() => lightInputRef.current?.click()}
                    {...makeDropHandlers(
                      (file) =>
                        setPreviewFromFile(
                          file,
                          (u) => setLightLogo(u),
                          (f) => setLightLogoFile(f),
                        ),
                      setIsDraggingLight,
                    )}
                  >
                    <div className=" gap-2 w-full">
                      {lightLogo ? (
                        <div className="relative w-full h-48 overflow-hidden rounded-lg">
                          {/* Blurred background using the same image */}
                          <div
                            className="absolute inset-0 blur-md scale-110"
                            style={{
                              backgroundImage: `url(${lightLogo})`,
                              backgroundSize: "cover",
                              backgroundPosition: "center",
                            }}
                          />
                          {/* Foreground image with object-contain */}
                          <img
                            src={lightLogo}
                            alt="Light logo preview"
                            className="relative  w-full h-full object-contain"
                          />
                        </div>
                      ) : (
                        <div className=" justify-center flex items-center h-full flex-col">
                          <Button
                            variant="outline"
                            size="sm"
                            className="mt-2"
                            onClick={(e) => {
                              e.stopPropagation();
                              lightInputRef.current?.click();
                            }}
                          >
                            <MdUpload className="mr-2" size={16} />
                            Upload
                          </Button>
                          <p className="text-sm text-gray-500 dark:text-gray-400 mt-2">
                            Click to upload or drag & drop
                          </p>
                          <p className="text-xs text-gray-400 dark:text-gray-500">
                            PNG, JPG (max 2MB)
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                <div>
                  <div className="flex items-center justify-between mb-3">
                    <label className="block text-sm font-medium  dark:text-gray-300">
                      Dark Logo
                    </label>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <button className="text-teal-green hover:text-teal-green text-sm font-medium flex items-center gap-1 cursor-pointer">
                          Edit
                          <svg
                            className="w-4 h-4"
                            viewBox="0 0 20 20"
                            fill="currentColor"
                          >
                            <path d="M5.23 7.21a.75.75 0 011.06.02L10 10.94l3.71-3.71a.75.75 0 111.06 1.06l-4.24 4.24a.75.75 0 01-1.06 0L5.21 8.29a.75.75 0 01.02-1.08z" />
                          </svg>
                        </button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent className="w-40 cursor-pointer">
                        <DropdownMenuItem
                          onClick={() => darkInputRef.current?.click()}
                          className="cursor-pointer"
                        >
                          Change image
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                    <input
                      ref={darkInputRef}
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={onDarkLogoChange}
                    />
                  </div>
                  <div
                    className={`border-2 border-dashed rounded-lg p-0 text-center transition-colors cursor-pointer min-h-44 flex flex-col justify-center items-center ${
                      isDraggingDark
                        ? "border-teal-400"
                        : "border-gray-300 dark:border-gray-700 hover:border-teal-400"
                    }`}
                    onClick={() => darkInputRef.current?.click()}
                    {...makeDropHandlers(
                      (file) =>
                        setPreviewFromFile(
                          file,
                          (u) => setDarkLogo(u),
                          (f) => setDarkLogoFile(f),
                        ),
                      setIsDraggingDark,
                    )}
                  >
                    <div className=" w-full">
                      {darkLogo ? (
                        <div className="relative w-full h-48 overflow-hidden rounded-lg">
                          {/* Blurred background using the same image */}
                          <div
                            className="absolute inset-0 blur-md scale-110"
                            style={{
                              backgroundImage: `url(${darkLogo})`,
                              backgroundSize: "cover",
                              backgroundPosition: "center",
                            }}
                          />
                          {/* Foreground image with object-contain */}
                          <img
                            src={darkLogo}
                            alt="Dark logo preview"
                            className="relative w-full h-full object-contain"
                          />
                        </div>
                      ) : (
                        <div className=" justify-center flex items-center h-full flex-col">
                          <Button
                            variant="outline"
                            size="sm"
                            className="mt-2"
                            onClick={(e) => {
                              e.stopPropagation();
                              darkInputRef.current?.click();
                            }}
                          >
                            <MdUpload className="mr-2" size={16} />
                            Upload
                          </Button>
                          <p className="text-sm text-gray-500 dark:text-gray-400 mt-2">
                            Click to upload or drag & drop
                          </p>
                          <p className="text-xs text-gray-400 dark:text-gray-500">
                            PNG, JPG (max 2MB)
                          </p>
                        </div>
                      )}
                    </div>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-2">
                    Tagline or Short Description
                  </label>
                  <Textarea
                    value={tagline}
                    onChange={(e) => setTagline(e.target.value)}
                    className="w-full min-h-[80px]"
                    placeholder="Enter tagline here..."
                    maxLength={40}
                  />
                  <div className="text-right text-xs text-gray-400 mt-1">
                    {tagline.length}/40
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
