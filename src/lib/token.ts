export const getAuthToken = (): string | null => {
  if (typeof window === "undefined") return null;
  
  // Try to get from cookie first, then fallback to localStorage for backward compatibility
  const getCookie = (name: string): string | null => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(';').shift() || null;
    return null;
  };
  
  return getCookie("accessToken") || localStorage.getItem("accessToken");
};

export const getRefreshToken = (): string | null => {
  if (typeof window === "undefined") return null;
  
  const getCookie = (name: string): string | null => {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);
    if (parts.length === 2) return parts.pop()?.split(';').shift() || null;
    return null;
  };
  
  return getCookie("refreshToken") || localStorage.getItem("refreshToken");
};

export const saveAuthToken = (token: string): void => {
  if (typeof window !== "undefined") {
    // Save to both localStorage and cookie for backward compatibility
    localStorage.setItem("accessToken", token);
    
    // Set cookie with secure attributes
    const isSecure = window.location.protocol === 'https:';
    document.cookie = `accessToken=${token}; path=/; max-age=${7 * 24 * 60 * 60}; SameSite=Strict; ${isSecure ? 'Secure;' : ''}`;
  }
};

export const saveRefreshToken = (token: string): void => {
  if (typeof window !== "undefined") {
    // Save to both localStorage and cookie for backward compatibility
    localStorage.setItem("refreshToken", token);
    
    // Set cookie with secure attributes
    const isSecure = window.location.protocol === 'https:';
    document.cookie = `refreshToken=${token}; path=/; max-age=${7 * 24 * 60 * 60}; SameSite=Strict; ${isSecure ? 'Secure;' : ''}`;
  }
};

export type StoredUser = {
  name?: string;
  email?: string;
};

export const saveUser = (user: StoredUser): void => {
  if (typeof window !== "undefined") {
    localStorage.setItem("user", JSON.stringify(user));
  }
};

export const getUser = (): StoredUser | null => {
  if (typeof window === "undefined") return null;
  try {
    const raw = localStorage.getItem("user");
    if (!raw) return null;
    return JSON.parse(raw) as StoredUser;
  } catch {
    return null;
  }
};

export const handleLogout = (): void => {
  if (typeof window !== "undefined") {
    // Remove from localStorage
    localStorage.removeItem("accessToken");
    localStorage.removeItem("refreshToken");
    localStorage.removeItem("user");

    // Remove from cookies
    document.cookie = "accessToken=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Strict;";
    document.cookie = "refreshToken=; path=/; expires=Thu, 01 Jan 1970 00:00:00 GMT; SameSite=Strict;";

    // Only redirect if not already on login page to prevent hard refresh
    const isLoginPage = window.location.pathname.includes("/login");
    if (!isLoginPage) {
      window.location.href = "/login";
    }
  }
};
