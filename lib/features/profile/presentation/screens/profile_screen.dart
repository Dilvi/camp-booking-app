import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/profile_model.dart';
import '../../../home/presentation/widgets/home_bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  String? _error;
  ProfileModel? _profile;
  int _selectedBottomIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await ServiceLocator.profileApiService.getProfile();

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenStorage.clearToken();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  void _onBottomBarTap(int index) {
    if (index == _selectedBottomIndex) return;

    setState(() {
      _selectedBottomIndex = index;
    });

    if (index == 0) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
            (route) => false,
      );
      return;
    }

    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото из лагеря позже реализуем')),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ProfileHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: _buildBody(),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: HomeBottomNavBar(
              selectedIndex: _selectedBottomIndex,
              onTap: _onBottomBarTap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 80),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Column(
        children: [
          const SizedBox(height: 40),
          Text(
            _error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadProfile,
            child: const Text('Повторить'),
          ),
        ],
      );
    }

    final profile = _profile!;
    return Transform.translate(
      offset: const Offset(0, -58),
      child: Column(
        children: [
          _ProfileCard(
            profile: profile,
            onTap: () async {
              debugPrint('PROFILE CARD TAP');

              final result = await Navigator.pushNamed(
                context,
                AppRoutes.editProfile,
                arguments: profile,
              );

              if (!mounted) return;

              if (result is ProfileModel) {
                setState(() {
                  _profile = result;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Данные профиля успешно обновлены'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 5),
          _ProfileMenuTile(
            icon: Icons.lock_outline,
            title: 'Сменить пароль',
            onTap: () async {
              final result = await Navigator.pushNamed(
                context,
                AppRoutes.changePassword,
              );

              if (!mounted) return;

              if (result is String && result.isNotEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Пароль успешно изменён'),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 18),
          _ProfileMenuTile(
            icon: Icons.group_outlined,
            title: 'Дети',
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.children);
            },
          ),
          const SizedBox(height: 18),
          _ProfileMenuTile(
            icon: Icons.article_outlined,
            title: 'Мои бронирования',
            onTap: () {},
          ),
          const SizedBox(height: 18),
          _ProfileMenuTile(
            icon: Icons.favorite_border,
            title: 'Избранное',
            onTap: () {},
          ),
          const SizedBox(height: 18),
          _ProfileMenuTile(
            icon: Icons.more_vert,
            title: 'Больше',
            onTap: () {},
          ),
          const SizedBox(height: 18),
          _ProfileMenuTile(
            icon: Icons.logout,
            title: 'Выйти',
            iconColor: const Color(0xFFE55050),
            textColor: const Color(0xFFE55050),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home_header.png',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD8EEF3),
              ),
            ),
          ),
          const Positioned(
            top: 62,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                'Мой профиль',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final VoidCallback onTap;

  const _ProfileCard({
    required this.profile,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF101815),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            _Avatar(avatarUrl: profile.avatarUrl),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    profile.fullName.isEmpty ? 'Пользователь' : profile.fullName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    profile.email,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 46,
              height: 46,
              decoration: const BoxDecoration(
                color: Color(0xFF4CAF3D),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? avatarUrl;

  const _Avatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(
        width: 72,
        height: 72,
        child: avatarUrl != null && avatarUrl!.isNotEmpty
            ? Image.network(
          avatarUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFD9D9D9),
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 34,
            ),
          ),
        )
            : Container(
          color: const Color(0xFFD9D9D9),
          alignment: Alignment.center,
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 34,
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE9E9E9)),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F6F6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: textColor == const Color(0xFFE55050)
                    ? const Color(0xFF7A7A7A)
                    : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}