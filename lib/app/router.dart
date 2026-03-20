import 'package:flutter/material.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/camps/presentation/screens/all_camps_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/search/presentation/screens/search_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/camps/presentation/screens/camp_detail_screen.dart';
import '../features/camps/data/models/camp_model.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/presentation/screens/change_password_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/data/models/profile_model.dart';
import '../features/children/presentation/screens/children_screen.dart';
import '../features/children/presentation/screens/child_form_screen.dart';
import '../features/children/data/models/child_model.dart';
import '../features/favorites/presentation/screens/favorites_screen.dart';
import '../features/profile/presentation/screens/more_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String allCamps = '/all-camps';
  static const String campDetail = '/camp-detail';
  static const String profile = '/profile-screen';
  static const String changePassword = '/change-password';
  static const String editProfile = '/edit-profile';
  static const String children = '/children-screen';
  static const String addChild = '/add-child';
  static const String editChild = '/edit-child';
  static const String favorites = '/favorites-screen';
  static const String more = '/more-screen';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case AppRoutes.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case AppRoutes.search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case AppRoutes.allCamps:
        return MaterialPageRoute(builder: (_) => const AllCampsScreen());
      case AppRoutes.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case AppRoutes.changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());
      case AppRoutes.children:
        return MaterialPageRoute(builder: (_) => const ChildrenScreen());
      case AppRoutes.favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case AppRoutes.more:
        return MaterialPageRoute(builder: (_) => const MoreScreen());

      case AppRoutes.addChild:
        return MaterialPageRoute(builder: (_) => const ChildFormScreen());

      case AppRoutes.editChild:
        final args = settings.arguments;
        if (args is! ChildModel) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Ребёнок не передан')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => ChildFormScreen(child: args),
        );
      case AppRoutes.editProfile:
        final args = settings.arguments;
        if (args is! ProfileModel) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Профиль не передан')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => EditProfileScreen(profile: args),
        );
      case AppRoutes.campDetail:
        final args = settings.arguments;
        if (args is! CampModel) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Лагерь не передан')),
            ),
          );
        }
        return MaterialPageRoute(
          builder: (_) => CampDetailScreen(camp: args),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Страница не найдена')),
          ),
        );
    }
  }
}