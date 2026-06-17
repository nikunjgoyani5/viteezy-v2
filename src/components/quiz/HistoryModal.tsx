"use client";

import React, {
  useState,
  useCallback,
  useMemo,
  useRef,
  useEffect,
} from "react";
import { useRouter, usePathname } from "next/navigation";

import PortalDialog from "@/components/ui/portalDialog";
import DeleteConfirmationModal from "@/components/ui/deleteConfirmationModal";
import InputField from "@/components/ui/input";
import { Search, MoreVertical, ClipboardPenLine, Trash2 } from "lucide-react";
import { X } from "../icons";
import { useClickOutside } from "@/hooks";
import { useTranslations } from "next-intl";

import {
  useDeleteSessionMutation,
  useGetSessionsByUserQuery,
  useLazySearchMessagesQuery,
} from "@/store/api/quizApi";

import { HistorySession, SearchMatch } from "@/store/api/types/quiz.types";
import { formatDateWithTranslation } from "@/lib/utils";
import Spinner from "../ui/spinner";
import { routes } from "../constants/route";

/* ---------------------------------- */
/* Helpers                            */
/* ---------------------------------- */

const getUserId = (): string | null => {
  if (typeof window === "undefined") return null;
  try {
    const user = localStorage.getItem("user");
    return user ? JSON.parse(user)?._id : null;
  } catch {
    return null;
  }
};

const normalizeDate = (dateStr: string) => {
  const d = new Date(dateStr);
  return new Date(d.getFullYear(), d.getMonth(), d.getDate());
};

/* ---------------------------------- */
/* Component                          */
/* ---------------------------------- */

interface HistoryModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSessionSelect?: (sessionId: string) => void;
  onNewChat?: () => void;
}

const HistoryModal: React.FC<HistoryModalProps> = ({
  isOpen,
  onClose,
  onSessionSelect,
  onNewChat,
}) => {
  const t = useTranslations("Header");
  const tCommon = useTranslations("Common");
  const tQuiz = useTranslations("Quiz");
  const tMonths = useTranslations("Months");
  const router = useRouter();
  const [searchQuery, setSearchQuery] = useState("");
  const [openMenuId, setOpenMenuId] = useState<string | null>(null);
  const [deleteItem, setDeleteItem] = useState<any>(null);
  const [currentPage, setCurrentPage] = useState(1);
  const [shouldLoadMoreAfterDelete, setShouldLoadMoreAfterDelete] =
    useState(false);

  const debounceRef = useRef<NodeJS.Timeout | null>(null);
  const scrollContainerRef = useRef<HTMLDivElement>(null);

  const getDateGroup = (dateStr: string) => {
    const date = normalizeDate(dateStr);
    const today = normalizeDate(new Date().toISOString());
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);

    if (+date === +today) return { key: "today", label: tCommon("today") };
    if (+date === +yesterday) return { key: "yesterday", label: tCommon("yesterday") };

    return {
      key: date.toISOString().split("T")[0],
      label: formatDateWithTranslation(dateStr, "DD MMM YYYY", tMonths).toLowerCase(),
    };
  };

  const groupByDate = (items: (HistorySession | SearchMatch)[]) => {
    const map = new Map<string, { key: string; label: string; items: any[] }>();

    items.forEach((item) => {
      const date = "created_at" in item ? item.created_at : item.date;

      const { key, label } = getDateGroup(date);
      const existing = map.get(key);
      if (existing) {
        existing.items.push(item);
      } else {
        map.set(key, { key, label, items: [item] });
      }
    });
    return map;
  };

  const sortDateGroups = (
    map: Map<string, { key: string; label: string; items: any[] }>
  ) => {
    return Array.from(map.values()).sort((a, b) => {
      return b.key.localeCompare(a.key);
    });
  };

  const userId = useMemo(() => getUserId(), []);

  const pathname = usePathname();
  const currentSessionId = pathname?.split("/").pop();

  /* ---------------- API ---------------- */

  const {
    data: historyData,
    isLoading,
    isFetching,
    refetch,
  } = useGetSessionsByUserQuery(
    { userId: userId!, page: currentPage },
    { skip: !isOpen || !userId },
  );

  const pagination = historyData?.pagination;
  const hasNext = pagination?.hasNext ?? false;
  const isLoadingMore = isFetching && currentPage > 1;

  // Handle loading more after deletion
  useEffect(() => {
    if (
      shouldLoadMoreAfterDelete &&
      !isFetching &&
      hasNext &&
      currentPage === 1 &&
      !searchQuery.trim()
    ) {
      // After deletion, if we reset to page 1 and there's more data, load page 2
      setCurrentPage(2);
      setShouldLoadMoreAfterDelete(false);
    }
  }, [
    shouldLoadMoreAfterDelete,
    isFetching,
    hasNext,
    currentPage,
    searchQuery,
  ]);

  const [
    searchMessages,
    { data: searchData, isLoading: searching, isFetching: searchFetching },
  ] = useLazySearchMessagesQuery();

  /* ---------------- Search ---------------- */

  const handleSearch = useCallback(
    (value: string) => {
      setSearchQuery(value);

      if (debounceRef.current) {
        clearTimeout(debounceRef.current);
      }

      debounceRef.current = setTimeout(() => {
        if (value.trim() && userId) {
          searchMessages({ userId, word: value.trim() });
        }
      }, 400);
    },
    [userId, searchMessages],
  );

  useEffect(() => {
    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, []);

  /* ---------------- Pagination ---------------- */

  // Reset page when modal opens or search query changes
  useEffect(() => {
    if (isOpen) {
      setCurrentPage(1);
    }
  }, [isOpen, searchQuery]);

  // Handle scroll to bottom for pagination
  useEffect(() => {
    // Find the scrollable container (PortalDialog body)
    const findScrollableContainer = (): HTMLElement | null => {
      if (!scrollContainerRef.current) return null;
      // Find the closest parent with overflow-y-auto (PortalDialog body)
      let parent = scrollContainerRef.current.parentElement;
      while (parent) {
        const style = window.getComputedStyle(parent);
        if (style.overflowY === "auto" || style.overflowY === "scroll") {
          return parent;
        }
        parent = parent.parentElement;
      }
      return null;
    };

    const container = findScrollableContainer();
    // Don't set up scroll listener if searching, no next page, or already loading
    if (!container || searchQuery.trim() || !hasNext || isFetching) return;

    let timeoutId: NodeJS.Timeout | null = null;

    const handleScroll = () => {
      // Debounce scroll events
      if (timeoutId) clearTimeout(timeoutId);

      timeoutId = setTimeout(() => {
        const { scrollTop, scrollHeight, clientHeight } = container;
        // Trigger when within 100px of bottom
        if (scrollHeight - scrollTop - clientHeight < 100) {
          setCurrentPage((prev) => {
            // Only increment if we have next page and not already loading
            if (hasNext && !isFetching) {
              return prev + 1;
            }
            return prev;
          });
        }
      }, 150);
    };

    container.addEventListener("scroll", handleScroll);
    return () => {
      container.removeEventListener("scroll", handleScroll);
      if (timeoutId) clearTimeout(timeoutId);
    };
  }, [hasNext, isFetching, searchQuery]);

  /* ---------------- Data ---------------- */

  const displayItems = useMemo(() => {
    return searchQuery.trim()
      ? searchData?.data?.matches || []
      : historyData?.data || [];
  }, [searchQuery, searchData, historyData]);

  const groupedItems = useMemo(() => sortDateGroups(groupByDate(displayItems)), [displayItems]);

  /* ---------------- Menu ---------------- */

  const menuRef = useClickOutside<HTMLDivElement>(() => setOpenMenuId(null));

  const getTitle = (item: any) =>
    item.session_name || tQuiz("untitledChat");

  const getId = (item: any) => item.session_id;

  /* ---------------- UI ---------------- */

  const px = "px-7";

  const [deleteSession, { isLoading: deleting }] = useDeleteSessionMutation();

  return (
    <PortalDialog
      isShow={isOpen}
      onClose={onClose}
      width={900}
      contentClass="p-0"
      bodyClass="p-0 pb-6 min-h-[60vh]"
      showCloseButton={false}
      animationType="center"
      transitionDuration={200}
    >
      {/* Header */}
      <div className="sticky top-0 bg-white">
        <div
          className={`${px} flex items-center gap-4 pt-4 mb-4.5 justify-between`}
        >
          <h3 className="text-2xl font-medium">{t("history")}</h3>
          <button
            onClick={onClose}
            className="min-h-10 min-w-10 max-h-10 max-w-10 rounded-full border hover:bg-gray-100 p-2"
          >
            <X />
          </button>
        </div>
        <div className={px}>
          <InputField
            floating={false}
            value={searchQuery}
            onChange={(e) => handleSearch(e.target.value)}
              placeholder={t("searchChatsPlaceholder")}
            preIcon={<Search className="h-5 w-5 text-gray-500" />}
            className="w-full h-11"
          />
        </div>
        {/* New Chat */}
        <div className="px-4">
          <button
            onClick={() => {
              onClose();
              if (onNewChat) {
                onNewChat();
              } else {
                router.push(routes.quiz);
              }
            }}
            className="flex items-center gap-2 py-3 -px-10 hover:bg-gray-50 px-4 w-full my-4 rounded-md cursor-pointer"
          >
            <ClipboardPenLine size={20} />
            <span className="font-medium">{t("newChat")}</span>
          </button>
        </div>
      </div>

      {/* Content */}
      <div ref={scrollContainerRef} className={`${px} space-y-4 min-h-[40vh]`}>
        {isLoading || searching || searchFetching || deleting ? (
          <Spinner
            text={deleting ? tCommon("deleting") : tCommon("fetching")}
            size="md"
            className="my-10"
          />
        ) : groupedItems.length === 0 ? (
          <p className="text-center mb-3 rounded-md py-3 text-gray-500 bg-gray-50">
            {t("noHistoryFound")}
          </p>
        ) : (
          <>
            {groupedItems.map((group) => (
              <div key={group.key} className="">
                <p className="text-sm text-gray-500 font-medium mb-2">
                  {group.label}
                </p>

                {group.items.map((item) => {
                  const id = getId(item);

                  const handleItemClick = () => {
                    onClose();
                    if (onSessionSelect) {
                      onSessionSelect(id);
                    } else {
                      router.push(`${routes.quiz}/${id}`);
                    }
                  };

                  return (
                    <div
                      key={id}
                      onClick={handleItemClick}
                      className="group flex justify-between items-center px-4 py-3 rounded-md hover:bg-gray-50 cursor-pointer"
                    >
                      <div className="min-w-0">
                        <p className="font-medium truncate">{getTitle(item)}</p>
                        {item.messages?.[0]?.content && (
                          <p className="text-xs text-gray-400 truncate">
                            {item.messages[0].content}
                          </p>
                        )}
                      </div>

                      <div className="relative">
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            setOpenMenuId(id);
                          }}
                          className="opacity-0 group-hover:opacity-100 cursor-pointer"
                          disabled={deleting}
                        >
                          <MoreVertical size={18} className="-mb-1" />
                        </button>

                        {openMenuId === id && (
                          <div
                            ref={menuRef}
                            className="absolute right-0 mt-2 bg-white border rounded shadow-md"
                          >
                            <button
                              onClick={(e) => {
                                e.preventDefault();
                                e.stopPropagation();
                                setDeleteItem(item);
                              }}
                              className="flex items-center gap-2 px-4 py-2 text-red-600 hover:bg-red-50"
                              disabled={deleting}
                            >
                              <Trash2 size={16} />
                              {tCommon("delete")}
                            </button>
                          </div>
                        )}
                      </div>
                    </div>
                  );
                })}
              </div>
            ))}

            {/* Bottom loading indicator for pagination */}
            {isLoadingMore && (
              <div className="flex justify-center py-4">
                <Spinner text={tCommon("loadingMore")} size="sm" />
              </div>
            )}
          </>
        )}
      </div>

      {/* Delete Modal */}
      <DeleteConfirmationModal
        isOpen={!!deleteItem}
        onClose={() => setDeleteItem(null)}
        onConfirm={async () => {
          if (!deleteItem || !userId) return;

          const deletingSessionId = deleteItem.session_id;
          const wasOnPageGreaterThanOne = currentPage > 1;

          try {
            await deleteSession({
              sessionId: deletingSessionId,
              userId,
            }).unwrap();

            if (currentSessionId === deletingSessionId) {
              router.push(routes.quiz);
            }

            // Reset to page 1 to recalculate pagination from scratch
            // This will automatically trigger a new query with page 1
            setCurrentPage(1);

            // Refetch to get updated pagination info
            await refetch();

            // If we were on a page > 1, mark that we should load more after refetch completes
            if (wasOnPageGreaterThanOne && !searchQuery.trim()) {
              setShouldLoadMoreAfterDelete(true);
            }
          } catch (error) {
            console.error("Failed to delete session:", error);
          }

          setDeleteItem(null);
          setOpenMenuId(null);
        }}
        title={tQuiz("deleteChatTitle")}
        message={tQuiz("deleteChatMessage")}
        zIndexBackdrop={50}
        zIndexDialog={51}
      />
    </PortalDialog>
  );
};

export default HistoryModal;
