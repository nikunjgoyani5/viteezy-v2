import { configureStore } from "@reduxjs/toolkit";
import { baseApi } from "./api/baseApi";
import { quizApi } from "./api/quizApi";

export const makeStore = () => {
  return configureStore({
    reducer: {
      // Add the API reducer
      [baseApi.reducerPath]: baseApi.reducer,
      [quizApi.reducerPath]: quizApi.reducer,

      // Add other reducers here as your app grows
    },

    // Adding the api middleware enables caching, invalidation, polling, and other features of RTK Query
    middleware: (getDefaultMiddleware) =>
      getDefaultMiddleware().concat(baseApi.middleware, quizApi.middleware),

    // Enable Redux DevTools in development (helpful for debugging)
    devTools: process.env.NODE_ENV !== "production",
  });
};

// Infer the type of makeStore
export type AppStore = ReturnType<typeof makeStore>;

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<AppStore["getState"]>;
export type AppDispatch = AppStore["dispatch"];
