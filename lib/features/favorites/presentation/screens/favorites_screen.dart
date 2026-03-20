import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../camps/data/models/camp_model.dart';
import '../../../home/presentation/widgets/camp_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  String? _error;
  List<CampModel> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final favorites = await ServiceLocator.favoritesApiService.getFavorites();
      final allCamps = await ServiceLocator.campsApiService.getCamps();

      final campsById = {
        for (final camp in allCamps) camp.id: camp,
      };

      final mergedFavorites = favorites.map((favorite) {
        final fullCamp = campsById[favorite.id];
        if (fullCamp == null) return favorite;

        return CampModel(
          id: favorite.id,
          title: favorite.title,
          location: favorite.location,
          pricePerDay: favorite.pricePerDay,
          bookedCount: favorite.bookedCount,
          description: favorite.description,
          shiftDurationDays: favorite.shiftDurationDays,
          ageMin: favorite.ageMin,
          ageMax: favorite.ageMax,
          campType: favorite.campType,
          foodType: favorite.foodType,
          imageUrl: fullCamp.imageUrl,
          isFavorite: true,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _favorites = mergedFavorites;
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

  Future<void> _removeFromFavorites(CampModel camp) async {
    try {
      await ServiceLocator.favoritesApiService.removeFromFavorites(camp.id);

      if (!mounted) return;
      setState(() {
        _favorites.removeWhere((item) => item.id == camp.id);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Удалено из избранного')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось удалить из избранного')),
      );
    }
  }

  Future<void> _openCampDetail(CampModel camp) async {
    final result = await Navigator.pushNamed(
      context,
      AppRoutes.campDetail,
      arguments: camp,
    );

    if (!mounted) return;

    if (result is CampModel) {
      if (!result.isFavorite) {
        setState(() {
          _favorites.removeWhere((item) => item.id == result.id);
        });
      } else {
        setState(() {
          final index = _favorites.indexWhere((item) => item.id == result.id);
          if (index != -1) {
            _favorites[index] = result;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty = !_isLoading && _error == null && _favorites.isEmpty;

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
                            'Избранное',
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
                  child: RefreshIndicator(
                    onRefresh: _loadFavorites,
                    child: _buildBody(isEmpty),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(bool isEmpty) {
    if (_isLoading) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.only(top: 120),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _error!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loadFavorites,
              child: const Text('Повторить'),
            ),
          ],
        ),
      );
    }

    if (isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height - 180,
          child: const _EmptyFavoritesState(),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 180),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final camp = _favorites[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: CampCard(
            title: camp.title,
            location: camp.location,
            bookedCount: camp.bookedCount,
            isFavorite: true,
            imageUrl: camp.imageUrl,
            onFavoriteTap: () => _removeFromFavorites(camp),
            onTap: () => _openCampDetail(camp),
          ),
        );
      },
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

class _EmptyFavoritesState extends StatelessWidget {
  const _EmptyFavoritesState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 108,
              height: 108,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF17A34A)),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icons/favorites_empty_icon.png',
                  width: 42,
                  height: 42,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.favorite_border,
                    size: 44,
                    color: Color(0xFF17A34A),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'Избранных еще нет!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Нажмите на значок сердечка, чтобы\nсохранить любимые лагеря и найти их\nздесь в любое время.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF7A7A7A),
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: 188,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF3D),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Добавить',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}