import 'package:flutter/material.dart';
import '../../../../app/router.dart';
import '../../../../core/di/service_locator.dart';
import '../../data/models/camp_model.dart';
import '../../../home/presentation/widgets/camp_card.dart';

class AllCampsScreen extends StatefulWidget {
  const AllCampsScreen({super.key});

  @override
  State<AllCampsScreen> createState() => _AllCampsScreenState();
}

class _AllCampsScreenState extends State<AllCampsScreen> {
  bool _isLoading = true;
  String? _error;
  List<CampModel> _camps = [];

  @override
  void initState() {
    super.initState();
    _loadCamps();
  }

  Future<void> _loadCamps() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F1F1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Рекомендуем',
                        style: TextStyle(
                          fontSize: 22,
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
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCamps,
                child: _buildBody(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _error!,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadCamps,
            child: const Text('Повторить'),
          ),
        ],
      );
    }

    if (_camps.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: const [
          SizedBox(height: 100),
          Center(
            child: Text(
              'Лагеря не найдены',
              style: TextStyle(
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: _camps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 22),
      itemBuilder: (context, index) {
        final camp = _camps[index];

        return CampCard(
          title: camp.title,
          location: camp.location,
          bookedCount: camp.bookedCount,
          isFavorite: camp.isFavorite,
          imageUrl: camp.imageUrl,
          onFavoriteTap: () => _toggleFavorite(camp),
          onTap: () async {
            final updatedCamp = await Navigator.pushNamed(
              context,
              AppRoutes.campDetail,
              arguments: camp,
            );

            if (updatedCamp is CampModel) {
              setState(() {
                final index = _camps.indexWhere((item) => item.id == updatedCamp.id);
                if (index != -1) {
                  _camps[index] = updatedCamp;
                }
              });
            }
          },
        );
      },
    );
  }
}