import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:whos_got_what/shared/widgets/neumorphic_text_field.dart';
import 'package:whos_got_what/shared/widgets/neumorphic_container.dart';
import 'package:whos_got_what/core/constants/app_constants.dart';
import 'package:whos_got_what/core/theme/text_styles.dart';

/// Address autocomplete field using Google Places API
class AddressAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final void Function(String)? onAddressSelected;

  const AddressAutocompleteField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.onAddressSelected,
  });

  @override
  State<AddressAutocompleteField> createState() => _AddressAutocompleteFieldState();
}

class _AddressAutocompleteFieldState extends State<AddressAutocompleteField> {
  List<Map<String, dynamic>> _suggestions = [];
  bool _isLoading = false;
  String _lastQuery = '';

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty || query.length < 3) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    if (query == _lastQuery) return;
    _lastQuery = query;

    setState(() => _isLoading = true);

    try {
      final encodedQuery = Uri.encodeComponent(query);
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=$encodedQuery'
        '&key=${AppConstants.googleMapsApiKey}'
        '&components=country:us', // Restrict to USA
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final predictions = data['predictions'] as List<dynamic>? ?? [];

        setState(() {
          _suggestions = predictions
              .map((p) => {
                    'description': p['description'] as String,
                    'place_id': p['place_id'] as String,
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Places autocomplete error: $e');
      setState(() {
        _suggestions = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _selectAddress(String description, String placeId) async {
    widget.controller.text = description;
    setState(() {
      _suggestions = [];
      _lastQuery = '';
    });
    widget.onAddressSelected?.call(description);

    // Optionally get full address details
    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json'
        '?place_id=$placeId'
        '&key=${AppConstants.googleMapsApiKey}'
        '&fields=formatted_address',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final result = data['result'] as Map<String, dynamic>?;
        final formattedAddress = result?['formatted_address'] as String?;
        if (formattedAddress != null && formattedAddress != description) {
          widget.controller.text = formattedAddress;
        }
      }
    } catch (e) {
      debugPrint('Place details error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NeumorphicTextField(
          controller: widget.controller,
          hintText: widget.hintText ?? 'Enter address',
          labelText: widget.labelText ?? 'Location',
          onChanged: (value) {
            _fetchSuggestions(value);
          },
          prefixIcon: const Icon(Icons.location_on_outlined),
        ),
        if (_suggestions.isNotEmpty || _isLoading)
          NeumorphicContainer(
            margin: const EdgeInsets.only(top: 8),
            padding: EdgeInsets.zero,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200),
              child: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _suggestions.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      ),
                      itemBuilder: (context, index) {
                        final suggestion = _suggestions[index];
                        return ListTile(
                          dense: true,
                          leading: Icon(
                            Icons.place_outlined,
                            size: 20,
                            color: theme.colorScheme.primary,
                          ),
                          title: Text(
                            suggestion['description'] as String,
                            style: AppTextStyles.body(context),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            _selectAddress(
                              suggestion['description'] as String,
                              suggestion['place_id'] as String,
                            );
                          },
                        );
                      },
                    ),
            ),
          ),
      ],
    );
  }
}

