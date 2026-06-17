import { fetchBaseQuery } from "@reduxjs/toolkit/query";
import { baseQueryWithAuth } from "./baseApi";
import { createApi } from "@reduxjs/toolkit/query/react";
import { ApiResponse } from "./types/common.types";
import {
  LastQuestionData,
  SessionData,
  HistoryResponse,
  SearchResponse,
  SessionMessage,
  RecommendationResponse,
} from "./types/quiz.types";
import { quizRoles } from "@/components/constants/quiz";
import { product_suggest_answer } from "@/components/constants/faq";

const quizBaseQuery = fetchBaseQuery({
  baseUrl: process.env.NEXT_PUBLIC_API_QUIZ_URL,
  prepareHeaders: (headers) => {
    const token = localStorage.getItem("accessToken");
    if (token) {
      headers.set("authorization", `Bearer ${token}`);
    }
    headers.set("content-type", "application/json");
    return headers;
  },
});

const mapLastQuestionToMessage = (
  lastQuestion: LastQuestionData
): SessionMessage => {
  if (!lastQuestion.reply) {
    throw new Error("Cannot map question to message: reply is null");
  }
  return {
    role: "assistant",
    content: lastQuestion.reply.content,
    created_at: lastQuestion.timestamp,
    options: lastQuestion.options || undefined,
    question_type: lastQuestion.question_type || undefined,
    redirect_url: lastQuestion.redirect_url,
    isRegistered: lastQuestion.isRegistered,
  };
};

export const quizApi = createApi({
  reducerPath: "quizApi",
  baseQuery: (args, api, extraOptions) =>
    baseQueryWithAuth(args, api, extraOptions, quizBaseQuery),
  tagTypes: ["Chat"],

  endpoints: (builder) => ({
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    getHealth: builder.query<any, void>({
      query: () => "health",
      keepUnusedDataFor: 60 * 60,
    }),

    createSession: builder.mutation({
      query: (body) => ({
        url: "sessions",
        method: "POST",
        body,
      }),
      // Invalidate history and search caches when a new session is created
      invalidatesTags: ["Chat"],
    }),

    getSessionDetails: builder.query<
      ApiResponse<SessionData>,
      { sessionId: string }
    >({
      query: ({ sessionId }) => {
        const userId =
          typeof window !== "undefined"
            ? JSON.parse(localStorage.getItem("user") || "")?._id
            : null;

        if (!sessionId || !userId) {
          return { data: null };
        }

        return {
          url: `sessions/history`,
          params: { session_id: sessionId, user_id: userId },
        };
      },
    }),

    postChatMsg: builder.mutation<
      ApiResponse<LastQuestionData>,
      { session_id: string; message: string }
    >({
      query: (body) => ({
        url: "chat",
        method: "POST",
        body,
      }),

      async onQueryStarted(
        { session_id, message },
        { dispatch, queryFulfilled }
      ) {
        // 1) Optimistic user message
        const optimisticTimestamp = new Date().toISOString();

        const patchResult = dispatch(
          quizApi.util.updateQueryData(
            "getSessionDetails",
            { sessionId: session_id },
            (draft) => {
              if (!draft?.data?.messages) return;

              draft.data.messages.push({
                role: "user",
                content: message,
                created_at: optimisticTimestamp,
              });

              draft.data.updated_at = optimisticTimestamp;
              draft.data.message_count = draft.data.messages.length;
            }
          )
        );

        try {
          // 2) Wait server response
          const { data } = await queryFulfilled;
          const chatResponse = data?.data;

          // ---- DEBUG (keep temporarily) ----
          console.log("postChatMsg response:", chatResponse);
          console.log("reply is null?", chatResponse?.reply === null);
          // ----------------------------------

          // 3) Add assistant reply only if present
          dispatch(
            quizApi.util.updateQueryData(
              "getSessionDetails",
              { sessionId: session_id },
              (draft) => {
                if (!draft?.data?.messages) return;

                if (chatResponse?.reply) {
                  draft.data.messages.push(
                    mapLastQuestionToMessage(chatResponse)
                  );
                }

                draft.data.updated_at =
                  chatResponse?.timestamp ?? new Date().toISOString();
                draft.data.message_count = draft.data.messages.length;
              }
            )
          );

          // 4) Redirect if provided
          if (chatResponse?.redirect_url) {
            window.open(
              chatResponse.redirect_url,
              "_blank",
              "noopener,noreferrer"
            );
          }

          // 5) Trigger product recommendations when reply is null (your case)
          if (chatResponse?.reply === null) {
            const userId =
              typeof window !== "undefined"
                ? JSON.parse(localStorage.getItem("user") || "null")?._id
                : null;

            console.log("trigger recommendation with:", {
              userId,
              sessionId: session_id,
            });

            if (userId) {
              // IMPORTANT: forceRefetch ensures it actually sends request even if cached
              dispatch(
                quizApi.endpoints.getProductRecommendations.initiate(
                  { userId, sessionId: session_id },
                  { forceRefetch: true }
                )
              );
            } else {
              console.warn("Recommendation not triggered: userId missing");
            }
          }

          // 6) Sync lastQuestion cache
          dispatch(
            quizApi.util.updateQueryData(
              "getLastQuestion",
              { sessionId: session_id },
              (draft) => {
                if (!draft) return;
                draft.data = chatResponse;
              }
            )
          );
        } catch (err) {
          patchResult.undo();
          console.error("postChatMsg failed:", err);
        }
      },
    }),

    getLastQuestion: builder.query<
      ApiResponse<LastQuestionData>,
      { sessionId: string }
    >({
      query: ({ sessionId }) => ({
        url: `sessions/first-question`,
        params: { session_id: sessionId },
      }),

      async onQueryStarted(
        { sessionId },
        { dispatch, queryFulfilled, getState }
      ) {
        try {
          const { data } = await queryFulfilled;
          const lastQuestion = data.data;
          const replyContent = lastQuestion?.reply?.content?.trim();

          dispatch(
            quizApi.util.updateQueryData(
              "getSessionDetails",
              { sessionId },
              (draft) => {
                if (!draft) return;

                const messages = draft.data.messages;

                if (replyContent !== product_suggest_answer) {
                  if (messages.length > 0) {
                    const last = messages[messages.length - 1];
                    if (last.role === quizRoles.assistant) {
                      messages.pop();
                    }
                  }
                  messages.push(mapLastQuestionToMessage(lastQuestion));
                  draft.data.updated_at = lastQuestion.timestamp;
                }

                if (!replyContent || replyContent === null) {
                  const userId =
                    typeof window !== "undefined"
                      ? JSON.parse(localStorage.getItem("user") || "")?._id
                      : null;

                  if (userId) {
                    dispatch(
                      quizApi.endpoints.getProductRecommendations.initiate({
                        userId,
                        sessionId: sessionId,
                      })
                    );
                  }
                }
              }
            )
          );

          if (
            replyContent === product_suggest_answer &&
            lastQuestion.isRegistered
          ) {
            const userId =
              typeof window !== "undefined"
                ? JSON.parse(localStorage.getItem("user") || "")?._id
                : null;
            if (userId) {
              dispatch(
                quizApi.endpoints.getProductRecommendations.initiate({
                  userId,
                  sessionId,
                })
              );
            }
          }
        } catch (error) {
          console.error("Failed to handle last question logic:", error);
        }
      },

      providesTags: ["Chat"],
    }),

    getSessionsByUser: builder.query<
      HistoryResponse,
      { userId: string; page?: number }
    >({
      query: ({ userId, page = 1 }) => ({
        url: `/sessions/by-user`,
        params: { user_id: userId, page },
      }),
      serializeQueryArgs: ({ endpointName, queryArgs }) => {
        const { userId } = queryArgs;
        return `${endpointName}(${userId})`;
      },
      merge: (currentCache, newItems, { arg }) => {
        if (arg.page === 1) {
          return newItems;
        }
        if (newItems.data && currentCache?.data) {
          return {
            ...newItems,
            data: [...currentCache.data, ...newItems.data],
            pagination: newItems.pagination,
          };
        }
        return newItems;
      },
      forceRefetch({ currentArg, previousArg }) {
        return currentArg?.page !== previousArg?.page;
      },
      providesTags: ["Chat"],
    }),

    searchMessages: builder.query<
      SearchResponse,
      { userId: string; word: string }
    >({
      query: ({ userId, word }) => ({
        url: `search-messages`,
        params: { user_id: userId, word },
      }),
      // providesTags: ["Chat"],
    }),

    getProductRecommendations: builder.query<
      ApiResponse<RecommendationResponse>,
      { userId: string; sessionId: string }
    >({
      query: ({ userId, sessionId }) => ({
        url: `useridLogin`,
        method: "POST",
        body: {
          user_id: userId,
          session_id: sessionId,
        },
      }),

      async onQueryStarted({ sessionId }, { dispatch, queryFulfilled }) {
        try {
          const { data } = await queryFulfilled;
          const recommendation = data?.data;

          if (!recommendation || (!recommendation.message && !recommendation.timestamp)) return;

          dispatch(
            quizApi.util.updateQueryData(
              "getSessionDetails",
              { sessionId },
              (draft) => {
                if (!draft?.data?.messages) return;

                const messages = draft.data.messages;
                if (messages.length === 0) return;

                const lastMsg = messages[messages.length - 1];
                if (lastMsg.role === "assistant") {
                  messages.pop();
                }

                messages.push({
                  role: "assistant",
                  content: recommendation.message ?? "The conversation has ended.",
                  created_at: recommendation.timestamp ?? new Date().toISOString(),
                  products: Array.isArray(recommendation.products) ? recommendation.products : [],
                });

                draft.data.updated_at = recommendation.timestamp ?? draft.data.updated_at;
                draft.data.message_count = messages.length;
              }
            )
          );
        } catch (error) {
          console.error(
            "Failed to update chat with product recommendation:",
            error
          );
        }
      },
    }),

    deleteSession: builder.mutation<
      ApiResponse<null>,
      { sessionId: string; userId: string }
    >({
      query: ({ sessionId, userId }) => ({
        url: `sessions/${sessionId}`,
        method: "DELETE",
        params: { user_id: userId },
      }),

      async onQueryStarted(
        { sessionId, userId },
        { dispatch, queryFulfilled }
      ) {
        const patchResult = dispatch(
          quizApi.util.updateQueryData(
            "getSessionsByUser",
            { userId, page: 1 },
            (draft) => {
              if (!draft?.data) return;

              draft.data = draft.data.filter(
                (session) => session.session_id !== sessionId
              );

              if (draft.pagination?.total) {
                draft.pagination.total -= 1;
              }
            }
          )
        );

        try {
          await queryFulfilled;
        } catch {
          patchResult.undo();
        }
      },
    }),
  }),
});

export const {
  useGetHealthQuery,
  useCreateSessionMutation,
  useGetSessionDetailsQuery,
  usePostChatMsgMutation,
  useGetLastQuestionQuery,
  useGetSessionsByUserQuery,
  useLazySearchMessagesQuery,
  useGetProductRecommendationsQuery,
  useLazyGetProductRecommendationsQuery,
  useDeleteSessionMutation,
} = quizApi;
