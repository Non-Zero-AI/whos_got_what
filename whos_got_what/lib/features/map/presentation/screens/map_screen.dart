import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/shared/widgets/liquid_glass_container.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:intl/intl.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentIndex = 0;

  // Center of USA coordinates (fallback)
  static const LatLng _defaultCenter = LatLng(39.8283, -98.5795);

  @override
  void dispose() {
    mapController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _createMarkers(List<EventModel> events) {
    if (_markers.isNotEmpty) return;

    final Map<String, Marker> markers = {};
    for (int i = 0; i < events.length; i++) {
      final event = events[i];
      if (event.lat == null || event.lng == null) continue;

      final marker = Marker(
        markerId: MarkerId(event.id),
        position: LatLng(event.lat!, event.lng!),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _getMarkerHue(event.category),
        ),
        onTap: () {
          _pageController.animateToPage(
            i,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        },
      );
      markers[event.id] = marker;
    }

    if (markers.isNotEmpty) {
      setState(() {
        _markers.addAll(markers);
      });
    }
  }

  double _getMarkerHue(String? category) {
    switch (category?.toLowerCase()) {
      case 'event': return BitmapDescriptor.hueCyan;
      case 'promotion': return BitmapDescriptor.hueOrange;
      case 'pop-up': return BitmapDescriptor.hueViolet;
      default: return BitmapDescriptor.hueRed;
    }
  }

  void _onPageChanged(int index, List<EventModel> events) {
    setState(() {
      _currentIndex = index;
    });

    final event = events[index];
    if (event.lat != null && event.lng != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(event.lat!, event.lng!), 14),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      body: Stack(
        children: [
          eventsAsync.when(
            data: (events) {
              _createMarkers(events);
              
              return GoogleMap(
                onMapCreated: (controller) => mapController = controller,
                initialCameraPosition: CameraPosition(
                  target: events.isNotEmpty && events[0].lat != null
                      ? LatLng(events[0].lat!, events[0].lng!)
                      : _defaultCenter,
                  zoom: 12.0,
                ),
                markers: _markers.values.toSet(),
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                padding: const EdgeInsets.only(bottom: 250),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),

          // 1. Top HUD (Category Filter)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 16,
            right: 16,
            child: LiquidGlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              borderRadius: 30,
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text('Find events, pop-ups...', style: TextStyle(color: Colors.grey)),
                  ),
                  _CategoryBadge(label: 'All', color: AppTheme.tealAccent),
                ],
              ),
            ),
          ),

          // 2. Bottom Carousel
          eventsAsync.maybeWhen(
            data: (events) => Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              height: 180,
              child: PageView.builder(
                controller: _pageController,
                itemCount: events.length,
                onPageChanged: (idx) => _onPageChanged(idx, events),
                itemBuilder: (context, index) {
                  final event = events[index];
                  final isSelected = _currentIndex == index;

                  return AnimatedScale(
                    scale: isSelected ? 1.0 : 0.9,
                    duration: const Duration(milliseconds: 300),
                    child: LiquidGlassContainer(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      padding: EdgeInsets.zero,
                      onTap: () => context.go('/home/events/${event.id}'),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.horizontal(left: Radius.circular(24)),
                            child: Image.network(
                              event.imageUrl,
                              width: 120,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    event.title,
                                    style: AppTextStyles.titleMedium(context).copyWith(fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: AppTheme.tealAccent),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          event.location,
                                          style: AppTextStyles.captionMuted(context),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    DateFormat('MMM d, h:mm a').format(event.startDate),
                                    style: AppTextStyles.eventDateTime(context),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _CategoryBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
