import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? mapController;
  final Map<String, Marker> _markers = {};
  EventModel? _selectedEvent;

  // Center of USA coordinates
  static const LatLng _usaCenter = LatLng(39.8283, -98.5795);

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    if (address.isEmpty) return null;

    try {
      // Using Nominatim (OpenStreetMap) geocoding service (free, no API key required)
      final encodedAddress = Uri.encodeComponent(address);
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$encodedAddress&format=json&limit=1',
      );

      final response = await http.get(
        url,
        headers: {'User-Agent': "Who's Got What App"},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (data.isNotEmpty) {
          final result = data[0] as Map<String, dynamic>;
          final lat = double.parse(result['lat'] as String);
          final lon = double.parse(result['lon'] as String);
          return LatLng(lat, lon);
        }
      }
    } catch (e) {
      debugPrint('Geocoding error for "$address": $e');
    }

    return null;
  }

  Future<void> _loadEventMarkers(List<EventModel> events) async {
    final Map<String, Marker> markers = {};

    for (final event in events) {
      if (event.location.isEmpty) continue;

      final coordinates = await _geocodeAddress(event.location);
      if (coordinates == null) continue;

      final marker = Marker(
        markerId: MarkerId(event.id),
        position: coordinates,
        infoWindow: InfoWindow(
          title: event.title,
          snippet: event.location,
        ),
        onTap: () {
          setState(() {
            _selectedEvent = event;
          });
        },
      );

      markers[event.id] = marker;
    }

    setState(() {
      _markers.clear();
      _markers.addAll(markers);
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Map',
          style: AppTextStyles.titleLarge(context),
        ),
      ),
      body: Stack(
        children: [
          eventsAsync.when(
            data: (events) {
              // Load markers when events are available
              if (_markers.isEmpty && events.isNotEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _loadEventMarkers(events);
                });
              }

              return GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _usaCenter,
                  zoom: 4.0,
                ),
                markers: _markers.values.toSet(),
                mapType: MapType.normal,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading events',
                      style: AppTextStyles.titleMedium(context),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      err.toString(),
                      style: AppTextStyles.bodySmall(context),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Selected event info card
          if (_selectedEvent != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  context.go('/home/events/${_selectedEvent!.id}');
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedEvent!.title,
                            style: AppTextStyles.eventTitle(context),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              _selectedEvent = null;
                            });
                          },
                          iconSize: 20,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _selectedEvent!.location,
                            style: AppTextStyles.eventLocation(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.event,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatEventDate(_selectedEvent!),
                          style: AppTextStyles.eventDateTime(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          context.go('/home/events/${_selectedEvent!.id}');
                        },
                        child: Text(
                          'View Details',
                          style: AppTextStyles.labelPrimary(context),
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

  String _formatEventDate(EventModel event) {
    final start = event.startDate;
    final dateFormatter = DateFormat('MMM d, y');
    final timeFormatter = DateFormat('h:mm a');
    
    if (event.isAllDay) {
      return '${dateFormatter.format(start)} • All Day';
    }

    return '${dateFormatter.format(start)} • ${timeFormatter.format(start)}';
  }
}
