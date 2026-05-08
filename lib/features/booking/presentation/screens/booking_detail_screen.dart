import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/storage/token_storage.dart';
import '../../data/models/bike_route_model.dart';
import '../../data/models/booking_model.dart';

class BookingDetailScreen extends StatefulWidget {
  final int bookingId;

  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = true;
  String? _error;
  BookingModel? _booking;
  List<BikeRouteModel> _routes = [];
  final Map<int, bool> _analysisLoading = {};
  final Map<int, String> _analysisByRouteId = {};
  final Map<int, String> _analysisErrorByRouteId = {};

  @override
  void initState() {
    super.initState();
    _loadBooking();
  }

  Future<void> _loadBooking() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _analysisLoading.clear();
      _analysisByRouteId.clear();
      _analysisErrorByRouteId.clear();
    });

    try {
      final booking = await ServiceLocator.bookingApiService.getBooking(
        widget.bookingId,
      );
      final routes = await ServiceLocator.bookingApiService.getBikeRoutes(
        widget.bookingId,
      );

      if (!mounted) return;
      setState(() {
        _booking = booking;
        _routes = routes;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await _goToLogin();
        return;
      }

      setState(() {
        _error = _messageForStatus(e);
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Не удалось загрузить данные бронирования';
        _isLoading = false;
      });
    }
  }

  Future<void> _analyzeRoute(BikeRouteModel route) async {
    setState(() {
      _analysisLoading[route.id] = true;
      _analysisErrorByRouteId.remove(route.id);
    });

    try {
      final analysis = await ServiceLocator.bookingApiService.analyzeBikeRoute(
        bookingId: widget.bookingId,
        routeId: route.id,
      );

      if (!mounted) return;
      setState(() {
        _analysisByRouteId[route.id] = analysis.recommendations;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      if (e.statusCode == 401) {
        await _goToLogin();
        return;
      }

      setState(() {
        _analysisErrorByRouteId[route.id] = _messageForStatus(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _analysisErrorByRouteId[route.id] =
            'Не удалось получить ИИ-рекомендацию. Попробуйте позже';
      });
    } finally {
      if (mounted) {
        setState(() {
          _analysisLoading[route.id] = false;
        });
      }
    }
  }

  Future<void> _goToLogin() async {
    await TokenStorage.clearToken();

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (route) => false,
    );
  }

  String _messageForStatus(ApiException e) {
    switch (e.statusCode) {
      case 403:
        return 'Этот маршрут недоступен для выбранной брони';
      case 404:
        return 'Бронь или маршрут не найдены';
      case 502:
        return 'Не удалось получить ИИ-рекомендацию. Попробуйте позже';
      default:
        return e.message;
    }
  }

  Future<void> _openMap(String mapUrl) async {
    final uri = Uri.tryParse(mapUrl);
    if (uri == null) return;

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!opened && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Не удалось открыть карту')));
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
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Бронь #${widget.bookingId}',
                        style: const TextStyle(
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
            const SizedBox(height: 22),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadBooking,
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _error!,
            style: const TextStyle(color: Color(0xFFE53935), fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadBooking,
            child: const Text('Повторить'),
          ),
        ],
      );
    }

    final booking = _booking!;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      children: [
        _BookingInfoCard(booking: booking),
        const SizedBox(height: 24),
        const Text(
          'Веломаршруты',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 14),
        if (_routes.isEmpty)
          const _EmptyRoutesState()
        else
          ..._routes.map(
            (route) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _BikeRouteCard(
                route: route,
                isAnalyzing: _analysisLoading[route.id] == true,
                recommendations: _analysisByRouteId[route.id],
                error: _analysisErrorByRouteId[route.id],
                onAnalyze: () => _analyzeRoute(route),
                onOpenMap:
                    route.mapUrl != null && route.mapUrl!.isNotEmpty
                        ? () => _openMap(route.mapUrl!)
                        : null,
              ),
            ),
          ),
      ],
    );
  }
}

class _BookingInfoCard extends StatelessWidget {
  final BookingModel booking;

  const _BookingInfoCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        children: [
          _InfoRow(label: 'id', value: booking.id.toString()),
          _InfoRow(label: 'camp_id', value: booking.campId.toString()),
          _InfoRow(label: 'child_id', value: booking.childId.toString()),
          _InfoRow(label: 'status', value: booking.status),
          _InfoRow(label: 'created_at', value: _formatDate(booking.createdAt)),
          _InfoRow(label: 'updated_at', value: _formatDate(booking.updatedAt)),
        ],
      ),
    );
  }
}

class _BikeRouteCard extends StatelessWidget {
  final BikeRouteModel route;
  final bool isAnalyzing;
  final String? recommendations;
  final String? error;
  final VoidCallback onAnalyze;
  final VoidCallback? onOpenMap;

  const _BikeRouteCard({
    required this.route,
    required this.isAnalyzing,
    required this.recommendations,
    required this.error,
    required this.onAnalyze,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            route.title.isEmpty ? 'Маршрут #${route.id}' : route.title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'route_id: ${route.id} · camp_id: ${route.campId}',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF8A8A8A),
              fontWeight: FontWeight.w500,
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
                  route.location,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF6E6E6E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetricChip(
                icon: Icons.route_outlined,
                label: '${_formatDistance(route.distanceKm)} км',
              ),
              _MetricChip(
                icon: Icons.timer_outlined,
                label: '${route.durationMinutes} мин',
              ),
              _MetricChip(
                icon: Icons.trending_up,
                label: '${route.elevationGainM} м',
              ),
              _MetricChip(icon: Icons.speed_outlined, label: route.difficulty),
              _MetricChip(icon: Icons.forest_outlined, label: route.routeType),
            ],
          ),
          if (route.description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              route.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.4,
                color: Color(0xFF5F5F5F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (route.routePoints.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Точки маршрута',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              route.routePoints,
              style: const TextStyle(
                fontSize: 14,
                height: 1.35,
                color: Color(0xFF5F5F5F),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (route.mapUrl != null && route.mapUrl!.isNotEmpty) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: onOpenMap,
              icon: const Icon(Icons.map_outlined),
              label: const Text('Открыть карту'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF4CAF3D),
                side: const BorderSide(color: Color(0xFF4CAF3D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: isAnalyzing ? null : onAnalyze,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF3D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFFA5D6A7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child:
                  isAnalyzing
                      ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.4,
                          color: Colors.white,
                        ),
                      )
                      : const Text(
                        'ИИ-анализ',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: 12),
            Text(
              error!,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          if (recommendations != null && recommendations!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5FAF3),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD7EED1)),
              ),
              child: MarkdownBody(
                data: recommendations!,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Color(0xFF263128),
                  ),
                  strong: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                  listBullet: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF263128),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetricChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF4CAF3D)),
          const SizedBox(width: 5),
          Text(
            label.isEmpty ? 'unknown' : label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 92,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRoutesState extends StatelessWidget {
  const _EmptyRoutesState();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9E9E9)),
      ),
      child: const Text(
        'Для этой брони веломаршруты не найдены',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF6E6E6E),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

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
          child: Icon(icon, size: 18, color: Colors.black),
        ),
      ),
    );
  }
}

String _formatDate(String raw) {
  final date = DateTime.tryParse(raw);
  if (date == null) return raw;

  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(date.day)}.${two(date.month)}.${date.year} ${two(date.hour)}:${two(date.minute)}';
}

String _formatDistance(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }
  return value.toStringAsFixed(1);
}
