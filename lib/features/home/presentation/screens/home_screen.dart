import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../camps/data/models/camp_model.dart';
import '../widgets/camp_card.dart';
import '../widgets/home_bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<_CityMock> _cities = const [
    _CityMock(title: 'Москва', assetPath: 'assets/images/city_moscow.jpg'),
    _CityMock(title: 'Калуга', assetPath: 'assets/images/city_kaluga.jpg'),
    _CityMock(title: 'Тверь', assetPath: 'assets/images/city_tver.jpg'),
    _CityMock(title: 'Тула', assetPath: 'assets/images/city_tula.jpg'),
  ];

  bool _isLoading = true;
  String? _error;
  List<CampModel> _camps = [];
  int _selectedBottomIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  Future<void> _loadCamps() async {
    try {
      final camps = await ServiceLocator.campsApiService.getCamps();

      if (!mounted) return;
      setState(() {
        _camps = camps;
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

  Future<void> _toggleFavorite(CampModel camp) async {
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

  void _onBottomBarTap(int index) {
    setState(() {
      _selectedBottomIndex = index;
    });

    if (index == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Фото из лагеря позже реализуем')),
      );
    }

    if (index == 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Профиль позже реализуем')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommended = _camps.take(2).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _loadCamps,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HomeHeader(
                    onSearchTap: () {
                      Navigator.pushNamed(context, AppRoutes.search);
                    },
                  ),
                  const SizedBox(height: 20),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: _NearestCampCard(),
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _CitiesSection(cities: _cities),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _SectionHeader(
                      title: 'Рекомендуем',
                      actionText: 'Смотреть все',
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.allCamps);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(top: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                  else
                    ...recommended.map(
                          (camp) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                        child: CampCard(
                          title: camp.title,
                          location: camp.location,
                          bookedCount: camp.bookedCount,
                          isFavorite: camp.isFavorite,
                          imageUrl: camp.imageUrl,
                          onFavoriteTap: () => _toggleFavorite(camp),
                        ),
                      ),
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
}

class _HomeHeader extends StatelessWidget {
  final VoidCallback onSearchTap;

  const _HomeHeader({required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFD8EEF3),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                const Center(
                  child: Icon(
                    Icons.flight,
                    size: 26,
                    color: Color(0xFF3E1A16),
                  ),
                ),
                const Spacer(),
                const Text(
                  'Привет!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: onSearchTap,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search,
                          color: Colors.black87,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Поиск лагеря',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF8B8B8B),
                          ),
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

class _NearestCampCard extends StatelessWidget {
  const _NearestCampCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 88,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/nearest_camp_bg.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEFF3E7),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ближайший лагерь',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Укажи местоположение',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF3D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Указать',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

class _CitiesSection extends StatelessWidget {
  final List<_CityMock> cities;

  const _CitiesSection({required this.cities});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: cities
          .map(
            (city) => _CityItem(
          title: city.title,
          assetPath: city.assetPath,
        ),
      )
          .toList(),
    );
  }
}

class _CityItem extends StatelessWidget {
  final String title;
  final String assetPath;

  const _CityItem({
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(36),
          child: SizedBox(
            width: 72,
            height: 72,
            child: Image.asset(
              assetPath,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFFD9D9D9),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.location_city,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CityMock {
  final String title;
  final String assetPath;

  const _CityMock({
    required this.title,
    required this.assetPath,
  });
}