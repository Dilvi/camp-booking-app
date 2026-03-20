import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/storage/token_storage.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  Future<void> _mockDeleteAccount(BuildContext context) async {
    await TokenStorage.clearToken();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/splash_tents.png',
                fit: BoxFit.cover,
                height: 220,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                  child: Row(
                    children: [
                      _CircleButton(
                        icon: Icons.arrow_back_ios_new,
                        onTap: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Больше',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 40),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
                    child: Column(
                      children: [
                        _MoreMenuTile(
                          icon: Icons.help_outline,
                          title: 'FAQ',
                          onTap: () {},
                        ),
                        const SizedBox(height: 18),
                        _MoreMenuTile(
                          icon: Icons.shield_outlined,
                          title: 'Политика Конфиденциальности',
                          onTap: () {},
                        ),
                        const SizedBox(height: 18),
                        _MoreMenuTile(
                          icon: Icons.info_outline,
                          title: 'Связаться с нами',
                          onTap: () {},
                        ),
                        const SizedBox(height: 18),
                        _MoreMenuTile(
                          icon: Icons.delete_outline,
                          title: 'Удалить аккаунт',
                          iconColor: const Color(0xFFE55050),
                          textColor: const Color(0xFFE55050),
                          onTap: () => _mockDeleteAccount(context),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F1F1),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: Icon(
            icon,
            size: 18,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _MoreMenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color iconColor;
  final Color textColor;

  const _MoreMenuTile({
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
                decoration: BoxDecoration(
                  color: textColor == const Color(0xFFE55050)
                      ? const Color(0xFFFFF1F1)
                      : const Color(0xFFF6F6F6),
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