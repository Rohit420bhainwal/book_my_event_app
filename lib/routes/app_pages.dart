import 'package:bookmyevent/app/views/email_phone_signup_screen.dart';
import 'package:bookmyevent/app/views/provider_onboarding_screen.dart';
import 'package:bookmyevent/app/views/registration_screen.dart';
import 'package:bookmyevent/app/views/reset_password_screen.dart';
import 'package:bookmyevent/app/views/select_customer_city_screen.dart';
import 'package:bookmyevent/views/customer/customer_dashboard.dart';
import 'package:bookmyevent/views/menulist/menu_list_screen.dart';
import 'package:bookmyevent/views/provider/provider_home_screen.dart';
import 'package:get/get.dart';
import '../app/views/chat_screen.dart';
import '../app/views/edit_service_screen.dart';
import '../app/views/pending_approval_screen.dart';
import '../app/views/provider_earnings_screen.dart';
import '../app/views/transaction_receipt_screen.dart';
import '../controllers/dashboard/bookings/my_bookings_controller.dart';
import '../controllers/venues/booking_controller.dart';
import '../app/views/login_screen.dart';
import '../app/views/role_selection_screen.dart';
import '../views/customer/my_booking_detail_screen.dart';
import '../views/customer/my_bookings_screen.dart';
import '../views/customer/venues/booking_form_screen.dart';
import '../views/customer/venues/booking_success_screen.dart';
import '../views/customer/venues/dummy_payment_screen.dart';
import '../views/customer/venues/venue_details_screen.dart';
import '../views/provider/provider_dashboard.dart';
import '../views/splash/splash_screen.dart';

import '../controllers/splash_controller.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = <GetPage>[
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
      binding: BindingsBuilder(() {
        Get.put(SplashController());
      }),
    ),
    GetPage(name: Routes.login, page: () => LoginScreen()),
    GetPage(
        name: Routes.customerDashboard, page: () => const CustomerDashboard()),
    GetPage(
        name: Routes.selectCustomerCity,
        page: () => const SelectCustomerCityScreen()),
    GetPage(
      name: Routes.bookingForm,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        print("args: $args");
        return BookingFormScreen(
          venue: args["venue"],
        );
      },
      binding: BindingsBuilder(() {
        Get.put(BookingController());
      }),
    ),
    GetPage(
        name: Routes.bookingSuccess, page: () => const BookingSuccessScreen()),
    GetPage(
      name: Routes.myBookings,
      page: () => const MyBookingsScreen(),
      binding: BindingsBuilder(() {
        Get.put(MyBookingsController());
      }),
    ),
    GetPage(name: Routes.dummyPayment, page: () => const DummyPaymentScreen()),
    GetPage(
        name: Routes.roleSelection, page: () => const RoleSelectionScreen()),
    GetPage(
        name: Routes.registrationScreen,
        page: () => const RegistrationScreen()),
    GetPage(
        name: Routes.providerDashboard, page: () => const ProviderDashboard()),
    GetPage(
        name: Routes.emailPhoneSignup,
        page: () => const EmailPhoneSignupScreen()),
    GetPage(
        name: Routes.providerOnboarding,
        page: () => const ProviderOnboardingScreen()),
    GetPage(
      name: Routes.pendingApprovalScreen,
      page: () => const PendingApprovalScreen(),
    ),
    GetPage(
      name: Routes.providerHomeScreen,
      page: () {
        final args = Get.arguments ?? {};
        return ProviderHomeScreen(
          token: args["token"] ?? "",
          roleName: args["roleName"] ?? "User",
        );
      },
    ),
    GetPage(
      name: Routes.menuList,
      page: () {
        final args = Get.arguments ?? {};
        return MenuListScreen(
          token: args["token"] ?? "",
          userId: args["userId"] ?? "",
          roleName: args["roleName"] ?? "User",
        );
      },
    ),
    GetPage(
      name: Routes.bookingDetails,
      page: () => MyBookingDetailsScreen(),
    ),
    GetPage(
      name: Routes.transactionReceiptScreen,
      page: () => TransactionReceiptScreen(),
    ),
    GetPage(
      name: Routes.editService,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return EditServiceScreen(
          userId: args["userId"],
          serviceId: args["serviceId"],
          initialType: args["initialType"],
          initialDescription: args["initialDescription"],
          initialPrice: args["initialPrice"],
          initialImages: args["initialImages"],
          initialFilledFields: args["initialFilledFields"],
          initialSelectedServiceId: args["initialSelectedServiceId"],
        );
      },
    ),
    GetPage(
      name: Routes.chatInbox,
      page: () => ChatScreen(),
    ),

    GetPage(
      name: Routes.chatScreen,
      page: () => ChatScreen(),
    ),

    GetPage(
      name: Routes.venueDetails,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return VenueDetailsScreen(
          venue: args["venue"],
        );
      },
    ),
    GetPage(
      name: Routes.providerEarnings,
      page: () => ProviderEarningsScreen(),
    ),

    GetPage(
      name: Routes.resetPasswordScreen,
      page: () => ResetPasswordScreen(),
    ),
  ];
}
