import 'package:get/get.dart';
import 'package:viteezy/presentation/auth/change_password/bindings/change_password_binding.dart';
import 'package:viteezy/presentation/auth/change_password/views/change_password_screen.dart';
import 'package:viteezy/presentation/auth/forgot_password/bindings/forgot_password_binding.dart';
import 'package:viteezy/presentation/auth/forgot_password/views/forgot_password_screen.dart';
import 'package:viteezy/presentation/auth/login/bindings/login_binding.dart';
import 'package:viteezy/presentation/auth/login/views/login_screen.dart';
import 'package:viteezy/presentation/auth/reset_password/bindings/reset_password_binding.dart';
import 'package:viteezy/presentation/auth/reset_password/views/reset_password_screen.dart';
import 'package:viteezy/presentation/auth/signup/bindings/signup_binding.dart';
import 'package:viteezy/presentation/auth/signup/views/signup_screen.dart';
import 'package:viteezy/presentation/main/add_address/bindings/add_address_binding.dart';
import 'package:viteezy/presentation/main/add_address/views/add_address_screen.dart';
import 'package:viteezy/presentation/main/addresses/bindings/addresses_binding.dart';
import 'package:viteezy/presentation/main/addresses/views/addresses_screen.dart';
import 'package:viteezy/presentation/main/ai_chat/bindings/ai_chat_binding.dart';
import 'package:viteezy/presentation/main/ai_chat/views/ai_chat_view.dart';
import 'package:viteezy/presentation/main/cart/bindings/cart_binding.dart';
import 'package:viteezy/presentation/main/cart/views/cart_view.dart';
import 'package:viteezy/presentation/main/checkout/bindings/checkout_binding.dart';
import 'package:viteezy/presentation/main/checkout/views/checkout_view.dart';
import 'package:viteezy/presentation/main/checkout/views/order_complete_view.dart';
import 'package:viteezy/presentation/main/dashboard/bindings/dashboard_binding.dart';
import 'package:viteezy/presentation/main/dashboard/views/dashboard_view.dart';
import 'package:viteezy/presentation/main/help_center/bindings/help_center_binding.dart';
import 'package:viteezy/presentation/main/help_center/views/help_center_screen.dart';
import 'package:viteezy/presentation/main/help_details/bindings/help_details_binding.dart';
import 'package:viteezy/presentation/main/help_details/views/help_details_screen.dart';
import 'package:viteezy/presentation/main/membership/views/membership_view.dart';
import 'package:viteezy/presentation/main/notification/bindings/notification_binding.dart';
import 'package:viteezy/presentation/main/notification/views/notification_view.dart';
import 'package:viteezy/presentation/main/orders/bindings/orders_binding.dart';
import 'package:viteezy/presentation/main/orders/views/order_details_screen.dart';
import 'package:viteezy/presentation/main/orders/views/orders_screen.dart';
import 'package:viteezy/presentation/main/otp_verification/bindings/otp_verification_binding.dart';
import 'package:viteezy/presentation/main/otp_verification/views/otp_verification_screen.dart';
import 'package:viteezy/presentation/main/products/bindings/products_binding.dart';
import 'package:viteezy/presentation/main/products/views/product_detail_view.dart';
import 'package:viteezy/presentation/main/profile/bindings/profile_binding.dart';
import 'package:viteezy/presentation/main/profile/views/edit_profile_screen.dart';
import 'package:viteezy/presentation/main/profile/views/profile_screen.dart';
import 'package:viteezy/presentation/main/quiz_chat/bindings/quiz_binding.dart';
import 'package:viteezy/presentation/main/quiz_chat/screens/quiz_questions_screen.dart';
import 'package:viteezy/presentation/main/quiz_chat/screens/quiz_screen.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_binding.dart';
import 'package:viteezy/presentation/main/recommendation/recommendation_screen.dart';
import 'package:viteezy/presentation/main/shop_all_view/bindings/shop_all_binding.dart';
import 'package:viteezy/presentation/main/shop_all_view/views/category_product_view.dart';
import 'package:viteezy/presentation/main/shop_all_view/views/shop_all_view.dart';
import 'package:viteezy/presentation/main/subscription/bindings/subscription_binding.dart';
import 'package:viteezy/presentation/main/subscription/views/subscription_details_screen.dart';
import 'package:viteezy/presentation/main/subscription/views/subscription_products.dart';
import 'package:viteezy/presentation/main/subscription/views/subscription_screen.dart';
import 'package:viteezy/presentation/main/support/bindings/support_binding.dart';
import 'package:viteezy/presentation/main/support/views/support_view.dart';
import 'package:viteezy/presentation/main/webview/views/webview_screen.dart';

import '../../presentation/main/ member/ binding/member_binding.dart';
import '../../presentation/main/ member/view/member_screen.dart';
import '../../presentation/main/familymodule/bindings/family_bindings.dart';
import '../../presentation/main/familymodule/views/family_screen.dart';
import '../../presentation/main/reminder/ bindings/reminder_binding.dart';
import '../../presentation/main/reminder/views/reminder_view.dart';
import '../../presentation/onboard/splash/bindings/splash_binding.dart';
import '../../presentation/onboard/splash/views/splash_screen.dart';
import 'app_routes.dart';

class AppPages {
  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailView(),
      binding: ProductsBinding(),
    ),

    /// App screens

    GetPage(name: AppRoutes.initial, page: () => const SplashScreen(), binding: SplashBinding()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.shopAll,
      page: () => const ShopAllView(),
      binding: ShopALlBinding(),
    ),
    GetPage(
      name: AppRoutes.categoryProductView,
      page: () => const CategoryProductView(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignupScreen(),
      binding: SignupBinding(),
    ),
    GetPage(
      name: AppRoutes.resetPass,
      page: () => const ResetPasswordScreen(),
      binding: ResetPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPass,
      page: () => const ForgotPasswordScreen(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.changePass,
      page: () => const ChangePasswordScreen(),
      binding: ChangePasswordBinding(),
    ),
    GetPage(
      name: AppRoutes.verifyOtp,
      page: () => const OtpVerificationScreen(),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileScreen(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.myOrder,
      page: () => const OrdersScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
      binding: SupportBinding(),
    ),
    GetPage(
      name: AppRoutes.aiChat,
      page: () => const AiChatView(),
      binding: AiChatBinding(),
    ),
    GetPage(
      name: AppRoutes.orderDetail,
      page: () => const OrderDetailsScreen(),
      binding: OrdersBinding(),
    ),
    GetPage(
      name: AppRoutes.addresses,
      page: () => const AddressesScreen(),
      binding: AddressesBinding(),
    ),
    GetPage(
      name: AppRoutes.addAddress,
      page: () => const AddAddressScreen(),
      binding: AddAddressBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: AppRoutes.checkout,
      page: () => CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: AppRoutes.orderComplete,
      page: () => const OrderCompleteView(),
      binding: CheckoutBinding(), // Reuse checkout bindingL̥
    ),
    GetPage(
      name: AppRoutes.helpCenter,
      page: () => const HelpCenterScreen(),
      binding: HelpCenterBinding(),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(name: AppRoutes.membership, page: () => const MembershipView()),
    GetPage(
      name: AppRoutes.helpDetails,
      page: () => const HelpDetailsScreen(),
      binding: HelpDetailsBinding(),
    ),
    GetPage(
      name: AppRoutes.subscription,
      page: () => const SubscriptionScreen(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: AppRoutes.subscriptionDetails,
      page: () => const SubscriptionDetailsScreen(),
      binding: SubscriptionBinding(),
    ),
    GetPage(name: AppRoutes.webview, page: () => const WebViewScreen()),
    GetPage(
      name: AppRoutes.subscriptionProducts,
      page: () => const SubscriptionProducts(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: AppRoutes.reminderView,
      page: () => ReminderView(),
      binding: ReminderBinding(),
    ),
    GetPage(
      name: AppRoutes.memberScreen,
      page: () => MemberScreen(),
      binding: MemberBinding(),
    ),
    GetPage(
      name: AppRoutes.familyscreen,
      page: () => const FamilyScreen(),
      binding: FamilyBinding(),
    ),
/*    GetPage(
      name: AppRoutes.quiz,
      page: () => const QuizQuestionsScreen(),
      binding: QuizBinding(),
    ),*/
    GetPage(
      name: AppRoutes.quizFlow,
      page: () => const QuizScreen(),
      binding: QuizBinding(),
    ),
    GetPage(
      name: AppRoutes.recommendation,
      page: () => const RecommendationScreen(),
      binding: RecommendationBinding(),
    ),
  ];
}
