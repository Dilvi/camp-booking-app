import 'package:flutter/material.dart';

class CampCard extends StatelessWidget {
  final String title;
  final String location;
  final int bookedCount;
  final bool isFavorite;
  final String? imageUrl;
  final VoidCallback onFavoriteTap;
  final VoidCallback? onTap;

  const CampCard({
    super.key,
    required this.title,
    required this.location,
    required this.bookedCount,
    required this.isFavorite,
    required this.onFavoriteTap,
    this.imageUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFFE8E8E8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    height: 205,
                    width: double.infinity,
                    child: _CampImage(imageUrl: imageUrl),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
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
                _BookedUsers(bookedCount: bookedCount),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CampImage extends StatelessWidget {
  final String? imageUrl;

  const _CampImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: const Color(0xFFD9D9D9),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          color: Colors.white,
          size: 44,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFEAEAEA),
          alignment: Alignment.center,
          child: const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFD9D9D9),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          color: Colors.white,
          size: 44,
        ),
      ),
    );
  }
}

class _BookedUsers extends StatelessWidget {
  final int bookedCount;

  const _BookedUsers({required this.bookedCount});

  @override
  Widget build(BuildContext context) {
    final extra = bookedCount > 3 ? bookedCount - 3 : 0;

    return SizedBox(
      width: 92,
      height: 30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            left: 0,
            child: _AvatarCircle(backgroundColor: Color(0xFF174EA6)),
          ),
          const Positioned(
            left: 16,
            child: _AvatarCircle(backgroundColor: Color(0xFFF4A62A)),
          ),
          const Positioned(
            left: 32,
            child: _AvatarCircle(backgroundColor: Color(0xFFD8C7B8)),
          ),
          Positioned(
            left: 48,
            child: _PlusCircle(extraCount: extra),
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
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}

class _PlusCircle extends StatelessWidget {
  final int extraCount;

  const _PlusCircle({required this.extraCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF58B947),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '+$extraCount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}