import 'package:my_app/src/features/auth/views/auth_screen.dart';
import 'package:my_app/src/features/home/home_screen.dart';
import 'package:my_app/src/features/splash/loading_profile_data.dart';
import 'package:my_app/src/features/splash/splash_screen.dart';

class AppRoutes {
  static const String initProfileData = '/init-profile-data';
  static const String splashScreen = '/splash-screen';
  static const String auth = '/auth';
  static const String home = '/home';
}

final routes = {
  AppRoutes.splashScreen: (context) => const SplashScreen(),
  AppRoutes.auth: (context) => const AuthScreen(),
  AppRoutes.initProfileData: (context) => const LoadingProfileData(),
  AppRoutes.home: (context) => const HomeScreen(),
};
