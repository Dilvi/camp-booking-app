import 'package:flutter/material.dart';

class HomeBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const HomeBottomNavBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF111816),
        borderRadius: BorderRadius.circular(36),
      ),
      child: Row(
        children: [
          _NavItem(
            isActive: selectedIndex == 0,
            icon: Icons.home_outlined,
            label: 'Дом',
            onTap: () => onTap(0),
          ),
          const SizedBox(width: 10),
          _NavItem(
            isActive: selectedIndex == 1,
            icon: Icons.image_outlined,
            label: 'Фото из лагеря',
            onTap: () => onTap(1),
          ),
          const SizedBox(width: 10),
          _NavItem(
            isActive: selectedIndex == 2,
            icon: Icons.person_outline,
            label: 'Профиль',
            onTap: () => onTap(2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavItem({
    required this.isActive,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: isActive ? 2 : 1,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          height: 56,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF4CAF3D) : const Color(0xFF1C2422),
            borderRadius: BorderRadius.circular(isActive ? 28 : 30),
            shape: BoxShape.rectangle,
          ),
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: isActive
                ? Text(
              label,
              key: ValueKey(label),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            )
                : Icon(
              icon,
              key: ValueKey(icon.codePoint),
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }
}