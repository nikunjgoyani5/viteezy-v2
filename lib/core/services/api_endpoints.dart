class ApiEndpoints {

  ///Auth API
  static const String login = 'auth/login';
  static const String googleLogin = 'auth/google/login';
  static const String appleLogin = 'auth/apple-login';
  static const String register = 'auth/register';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resendOtp = 'auth/resend-otp';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';
  static const String changePass = 'auth/change-password';
  static const String logout = 'auth/logout';

  ///user profile
  static const String getUserProfile = 'users/me';
  static const String deviceToken = 'users/device-token';
  static const String userTransactions = 'users/me/transactions';
  static const String familyInfo = 'users/family/info';
  static const String subMembers = 'users/family/sub-members';

  static const String faqCategory = 'faqs/categories/list';
  static String faqs = 'faqs';
  static String address = 'addresses';

  // Home/Landing Page
  static const String landingPage = 'landing-page';

  // Product Endpoints
  static const String productCategories = 'products/categories';
  static const String products = 'products';
  static const String toggleLike = 'wishlist/toggle';
  static const String productTestimonials = 'product-testimonials';
  static const String productFilters = 'products/filters';
  static const String featuredProducts = 'checkout/featured-products';
  static String wishlist(String page, String limit) => 'wishlist?page=$page&limit=$limit';

  // AI Chat
  static const String health = 'health';
  static const String sessions = 'sessions';
  static const String firstQuestion = 'sessions/first-question';
  static const String chat = 'chat';
  static const String useridLogin = 'useridLogin';
  static const String sessionLink = 'sessions/link-user';
  static const String sessionByUser = 'sessions/by-user';
  static const String searchMessages = 'search-messages';
  static const String sessionsHistory = 'sessions/history';
  static String deleteSession(String sessionId) => 'sessions/$sessionId';
  // Cart Endpoints
  static const String cart = 'carts';
  static const String addToCart = 'carts/items';

  // Memberships
  static const String memberships = 'memberships';
  static  String membershipsTransactionsHistoryGetById(String membershipId) => 'memberships/$membershipId/transactions';
  static String canselMembership(String membershipId) => 'memberships/$membershipId/cancel';
  static const String membershipsPlans = 'memberships/plans';
  static const String membershipsBuy = 'memberships/buy';
  static String trackPayment(String membershipId) => 'payments/track?membershipId=$membershipId';

  // Orders
  static const String orders = 'orders';
  static String orderDetail(String orderId) => 'orders/$orderId';

  // Subscriptions
  static const String subscriptions = 'subscriptions';
  static String cancelSubscription(String subscriptionId) => 'subscriptions/$subscriptionId/cancel';
  static String pauseSubscription(String subscriptionId) => 'subscriptions/$subscriptionId/pause';
  static String changeShippingAddress(String subscriptionId) => 'subscriptions/$subscriptionId/change-shipping-address';
  static String subscriptionActivity(String subscriptionId) => 'subscriptions/$subscriptionId';
  // static String subscriptionActivity(String subscriptionId) => 'subscriptions/$subscriptionId/activity';
  static String subscriptionProducts(String subscriptionId) => 'subscriptions/$subscriptionId/products';
  static String subscriptionProductsStatus(String subscriptionId) => 'subscriptions/$subscriptionId/products/status';
  static String subscriptionUpdateProducts(String subscriptionId) => 'subscriptions/actions/$subscriptionId/update/products';
  static String subscriptionUpdateProductsRemove(String subscriptionId) => 'subscriptions/actions/$subscriptionId/update/products/remove';
  static String subscriptionUpdateConfirm(String subscriptionId) => 'subscriptions/actions/$subscriptionId/update/confirm';
  static const String subscriptionActionsSummary = 'subscriptions/actions/summary';

  // Postponements
  static const String postponements = 'postponements';

  // General Settings
  static const String generalSettings = 'general-settings';

  // Checkout
  static const String checkoutPageSummary = 'checkout/page-summary';

  // Payments
  static const String createPayment = 'payments/create';

  // Coupons
  static const String validateCoupon = 'coupons/validate';

  // Notifications
  static String notifications(int page, int limit) =>
      'notifications?page=$page&limit=$limit';
  static String notificationMarkRead(String id) => 'notifications/$id/read';

  // Reminders
  static const String reminders = 'reminders';
  static String reminderToggle(String id) => 'reminders/$id/toggle';
  static const String createReminder = 'reminders';
  static String remindersHistory(int page, int limit) => 'reminders/history?page=$page&limit=$limit';
}
