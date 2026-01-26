import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:whos_got_what/features/events/data/event_repository_impl.dart';
import 'package:whos_got_what/features/events/domain/models/event_model.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';
import 'package:whos_got_what/core/theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController(viewportFraction: 0.85);
  
  Set<Marker> _markers = {};
  List<EventModel> _allEvents = [];
  List<EventModel> _visibleEvents = [];
  EventModel? _selectedEvent;
  String _searchQuery = '';

  // Center of USA coordinates
  static const LatLng _usaCenter = LatLng(39.8283, -98.5795);

  @override
  void dispose() {
    _searchController.dispose();
    _pageController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    // Initial load of events and bounds
    _updateVisibleEvents();
  }

  void _updateVisibleEvents() async {
    if (_mapController == null) return;

    final bounds = await _mapController!.getVisibleRegion();
    final currentZoom = await _mapController!.getZoomLevel();
    
    final filtered = _allEvents.where((e) {
      if (e.latitude == null || e.longitude == null) return false;
      
      // If we are at a wide overview, show all pins that have coords
      if (currentZoom <= 6.0) return true;

      // Otherwise, check bounds
      return bounds.contains(LatLng(e.latitude!, e.longitude!));
    }).where((e) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return e.title.toLowerCase().contains(q) || e.location.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    if (mounted) {
      setState(() {
        _visibleEvents = filtered;
        _updateMarkers();
      });
    }
  }

  void _updateMarkers() {
    final markers = _visibleEvents.map((e) {
      return Marker(
        markerId: MarkerId(e.id),
        position: LatLng(e.latitude!, e.longitude!),
        infoWindow: InfoWindow(title: e.title, snippet: e.location),
        onTap: () => _onMarkerTapped(e),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _selectedEvent?.id == e.id ? BitmapDescriptor.hueAzure : BitmapDescriptor.hueRed,
        ),
      );
    }).toSet();

    if (mounted) {
      setState(() {
        _markers = markers;
      });
    }
  }

  void _onMarkerTapped(EventModel event) {
    setState(() {
      _selectedEvent = event;
    });
    
    // Find index in visible events and scroll to it
    final index = _visibleEvents.indexOf(event);
    if (index != -1) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _onPageChanged(int index) {
    if (index < 0 || index >= _visibleEvents.length) return;
    final event = _visibleEvents[index];
    setState(() {
      _selectedEvent = event;
    });
    
    _mapController?.animateCamera(
      CameraUpdate.newLatLng(LatLng(event.latitude!, event.longitude!)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);
    final theme = Theme.of(context);

    // Update local copy of events when provider changes
    ref.listen(eventsProvider, (prev, next) {
      if (next.hasValue) {
        setState(() {
          _allEvents = next.value!;
          _updateVisibleEvents();
        });
      }
    });

    // Handle initial load
    if (_allEvents.isEmpty && eventsAsync.hasValue && eventsAsync.value!.isNotEmpty) {
      _allEvents = eventsAsync.value!;
      // Delay slightly to ensure map is ready if this happens during init
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_mapController != null) _updateVisibleEvents();
      });
    }

    return AppTheme.buildBackground(
      context: context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Event Map', style: AppTextStyles.titleLarge(context)),
          backgroundColor: Colors.transparent,
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(target: _usaCenter, zoom: 4.0),
              markers: _markers,
              onCameraIdle: _updateVisibleEvents,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false, // Use our custom one
              zoomControlsEnabled: false,
              style: theme.brightness == Brightness.dark ? _darkMapStyle : null,
            ),
            
            // Custom My Location Button
            Positioned(
              right: 16,
              bottom: _visibleEvents.isNotEmpty ? 220 : 24,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: theme.colorScheme.surface,
                foregroundColor: theme.colorScheme.primary,
                onPressed: _zoomToMyLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
            
            // Search Bar
            Positioned(
              top: 16, left: 16, right: 16,
              child: NeumorphicContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: BorderRadius.circular(32),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search in view...',
                    hintStyle: AppTextStyles.captionMuted(context),
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                    suffixIcon: _searchQuery.isNotEmpty ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                        _updateVisibleEvents();
                      },
                    ) : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _updateVisibleEvents();
                  },
                ),
              ),
            ),

            // Horizontal Event Cards
            if (_visibleEvents.isNotEmpty)
              Positioned(
                bottom: 24, left: 0, right: 0,
                child: SizedBox(
                  height: 180,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: _onPageChanged,
                    itemCount: _visibleEvents.length,
                    itemBuilder: (context, index) {
                      final event = _visibleEvents[index];
                      return _MiniEventCard(event: event);
                    },
                  ),
                ),
              ),
            
            if (eventsAsync.isLoading && _allEvents.isEmpty)
              const Center(child: CircularProgressIndicator()),
          ],
        ),
      ),
    );
  }

  Future<void> _zoomToMyLocation() async {
    if (_mapController == null) return;
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are denied')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location permissions are permanently denied.')));
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0, // 1 mile radius roughly
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not get location: $e')));
      }
    }
  }

  // Placeholder for dark map style - real implementation would load from assets
  static const String _darkMapStyle = ''; 
}

class _MiniEventCard extends StatelessWidget {
  final EventModel event;
  const _MiniEventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(12),
        onTap: () => context.go('/home/events/${event.id}'),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                event.imageUrl,
                width: 100, height: 100,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(color: theme.colorScheme.surface, child: const Icon(Icons.image)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(event.title, style: AppTextStyles.eventTitle(context), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Expanded(child: Text(event.location, style: AppTextStyles.bodySmall(context), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d • h:mm a').format(event.startDate),
                    style: AppTextStyles.eventDateTime(context),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'View Details →',
                    style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
