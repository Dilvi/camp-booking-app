import 'package:flutter/material.dart';

class CampCard extends StatelessWidget {
  final String title;
  final String location;
  final bool isFavorite;

  const CampCard({
    super.key,
    required this.title,
    required this.location,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE8E8E8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 205,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Center(
                  child: Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite
                        ? const Color(0xFFE54B4B)
                        : const Color(0xFF1E1E1E),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
                color: Color(0xFF57B44B),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF7A7A7A),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const _BookedUsers(),
            ],
          ),
        ],
      ),
    );
  }
}

class _BookedUsers extends StatelessWidget {
  const _BookedUsers();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 78,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: _AvatarCircle(
              backgroundColor: Color(0xFF174EA6),
            ),
          ),
          Positioned(
            left: 16,
            child: _AvatarCircle(
              backgroundColor: Color(0xFFF4A62A),
            ),
          ),
          Positioned(
            left: 32,
            child: _AvatarCircle(
              backgroundColor: Color(0xFFD8C7B8),
            ),
          ),
          Positioned(
            left: 48,
            child: _PlusCircle(),
          ),
        ],
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final Color backgroundColor;

  const _AvatarCircle({required this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
    );
  }
}

class _PlusCircle extends StatelessWidget {
  const _PlusCircle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF58B947),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
      ),
      child: const Text(
        '5+',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}