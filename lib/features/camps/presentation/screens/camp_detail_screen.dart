import 'package:flutter/material.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/camp_model.dart';

class CampDetailScreen extends StatefulWidget {
  final CampModel camp;

  const CampDetailScreen({
    super.key,
    required this.camp,
  });

  @override
  State<CampDetailScreen> createState() => _CampDetailScreenState();
}

class _CampDetailScreenState extends State<CampDetailScreen> {
  late CampModel camp;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    camp = widget.camp;
  }

  Future<void> _toggleFavorite() async {
    final oldValue = camp.isFavorite;

    setState(() {
      camp.isFavorite = !camp.isFavorite;
    });

    try {
      if (camp.isFavorite) {
        await ServiceLocator.favoritesApiService.addToFavorites(camp.id);
      } else {
        await ServiceLocator.favoritesApiService.removeFromFavorites(camp.id);
      }
    } catch (_) {
      setState(() {
        camp.isFavorite = oldValue;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Не удалось обновить избранное'),
        ),
      );
    }
  }

  String _formatPrice(int price) {
    final text = price.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
          (match) => '${match[1]} ',
    );
    return '$text ₽';
  }

  bool get _shouldShowReadMore => camp.description.length > 170;

  String get _displayDescription {
    if (_isDescriptionExpanded || !_shouldShowReadMore) {
      return camp.description;
    }
    return '${camp.description.substring(0, 170)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 340,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: SizedBox(),
                      ),
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(28),
                            bottomRight: Radius.circular(28),
                          ),
                          child: _DetailHeaderImage(imageUrl: camp.imageUrl),
                        ),
                      ),
                      Positioned(
                        top: 52,
                        left: 20,
                        child: _CircleIconButton(
                          icon: Icons.arrow_back_ios_new,
                          onTap: () => Navigator.pop(context, camp),
                        ),
                      ),
                      Positioned(
                        top: 52,
                        right: 20,
                        child: _CircleIconButton(
                          icon: camp.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          iconColor: camp.isFavorite
                              ? const Color(0xFFE54B4B)
                              : Colors.black,
                          onTap: _toggleFavorite,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              camp.title,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3D9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_border,
                                  size: 18,
                                  color: Color(0xFFF2A300),
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '4.5',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFB77900),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 22,
                            color: Color(0xFF57B44B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              camp.location,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2C2C),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _formatPrice(camp.pricePerDay),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const TextSpan(
                              text: '/сутки',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF7A7A7A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _JoinedCard(bookedCount: camp.bookedCount),
                      const SizedBox(height: 24),
                      const Text(
                        'Описание',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: _displayDescription,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.45,
                                color: Color(0xFF6E6E6E),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (_shouldShowReadMore)
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                      !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4),
                                    child: Text(
                                      _isDescriptionExpanded
                                          ? 'Скрыть'
                                          : 'Читать далее',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        height: 1.45,
                                        color: Color(0xFF4CAF3D),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'О лагере',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: 'Смена',
                              value: '${camp.shiftDurationDays} дня',
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _InfoCard(
                              title: 'Возраст',
                              value: '${camp.ageMin}-${camp.ageMax} Лет',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              title: 'Тип лагеря',
                              value: camp.campType,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _InfoCard(
                              title: 'Питание',
                              value: camp.foodType,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Отзывы',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Смотреть все',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const _ReviewCard(
                        name: 'Жанна Орлова',
                        text: 'Приезжаю каждый год! Замечательное место',
                        date: '12 Авг, 2025',
                        imageAssetPath: 'assets/images/review_1.jpg',
                      ),
                      const SizedBox(height: 14),
                      const _ReviewCard(
                        name: 'Сергей Галактионов',
                        text: 'Хочу сказать что это просто идеальный лагерь.',
                        date: '20 Авг, 2025',
                        imageAssetPath: 'assets/images/review_2.jpg',
                      ),
                      const SizedBox(height: 14),
                      const _ReviewCard(
                        name: 'Марина Максимова',
                        text:
                        'Вожатые очень добрые, всегда поддержат, помогут, объяснят.',
                        date: '01 Июл, 2025',
                        imageAssetPath: 'assets/images/review_3.jpg',
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Бронирование позже реализуем'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF3D),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Забронировать',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailHeaderImage extends StatelessWidget {
  final String? imageUrl;

  const _DetailHeaderImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        color: const Color(0xFFD9D9D9),
        alignment: Alignment.center,
        child: const Icon(
          Icons.image_outlined,
          size: 56,
          color: Colors.white,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFD9D9D9),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 56,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
            color: iconColor,
          ),
        ),
      ),
    );
  }
}

class _JoinedCard extends StatelessWidget {
  final int bookedCount;

  const _JoinedCard({required this.bookedCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      decoration: BoxDecoration(
        color: const Color(0xFFDDF0C9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Уже присоединились',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _JoinedUsers(bookedCount: bookedCount),
                ],
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            child: SizedBox(
              width: 104,
              height: double.infinity,
              child: Image.asset(
                'assets/images/camp_detail_map.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFCAD8BD),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.map_outlined,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _JoinedUsers extends StatelessWidget {
  final int bookedCount;

  const _JoinedUsers({required this.bookedCount});

  @override
  Widget build(BuildContext context) {
    final extraCount = bookedCount > 3 ? bookedCount - 3 : 0;

    return SizedBox(
      width: 118,
      height: 38,
      child: Stack(
        children: [
          const Positioned(
            left: 0,
            child: _JoinedAvatar(
              imageAssetPath: 'assets/images/review_1.jpg',
            ),
          ),
          const Positioned(
            left: 28,
            child: _JoinedAvatar(
              imageAssetPath: 'assets/images/review_2.jpg',
            ),
          ),
          const Positioned(
            left: 56,
            child: _JoinedAvatar(
              imageAssetPath: 'assets/images/review_3.jpg',
            ),
          ),
          if (bookedCount > 3)
            Positioned(
              left: 84,
              child: _JoinedPlus(extraCount: extraCount),
            ),
        ],
      ),
    );
  }
}

class _JoinedAvatar extends StatelessWidget {
  final String imageAssetPath;

  const _JoinedAvatar({required this.imageAssetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          imageAssetPath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFFD9D9D9),
          ),
        ),
      ),
    );
  }
}

class _JoinedPlus extends StatelessWidget {
  final int extraCount;

  const _JoinedPlus({required this.extraCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF3D),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        '+$extraCount',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF3D),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.calendar_today_outlined,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF8B8B8B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
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

class _ReviewCard extends StatelessWidget {
  final String name;
  final String text;
  final String date;
  final String imageAssetPath;

  const _ReviewCard({
    required this.name,
    required this.text,
    required this.date,
    required this.imageAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 74,
              height: 74,
              child: Image.asset(
                imageAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFD9D9D9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 74,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.star_border,
                        size: 18,
                        color: Color(0xFFF2A300),
                      ),
                      const SizedBox(width: 2),
                      const Text(
                        '4',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.35,
                        color: Color(0xFF6E6E6E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF8A8A8A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}