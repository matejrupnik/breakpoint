import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/road_surface_provider.dart';

class RoadSurfaceSettings extends StatefulWidget {
  const RoadSurfaceSettings({super.key});

  @override
  State<RoadSurfaceSettings> createState() => _RoadSurfaceSettingsState();
}

class _RoadSurfaceSettingsState extends State<RoadSurfaceSettings> {
  late double _smoothThreshold;
  late double _moderateThreshold;
  late double _roughThreshold;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    // Initialize with values from provider
    final provider = Provider.of<RoadSurfaceProvider>(context, listen: false);
    _smoothThreshold = provider.smoothThreshold;
    _moderateThreshold = provider.moderateThreshold;
    _roughThreshold = provider.roughThreshold;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoadSurfaceProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              ListTile(
                title: const Text(
                  'Road Surface Thresholds',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: IconButton(
                  icon: Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                  onPressed: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                ),
              ),
              if (_isExpanded)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildThresholdSlider(
                        context,
                        'Smooth to Moderate',
                        _smoothThreshold,
                        0.3,
                        _moderateThreshold - 0.1,
                        (value) {
                          setState(() {
                            _smoothThreshold = value;
                          });
                        },
                        Colors.green,
                      ),
                      const SizedBox(height: 24),
                      _buildThresholdSlider(
                        context,
                        'Moderate to Rough',
                        _moderateThreshold,
                        _smoothThreshold + 0.1,
                        _roughThreshold - 0.1,
                        (value) {
                          setState(() {
                            _moderateThreshold = value;
                          });
                        },
                        Colors.yellow.shade700,
                      ),
                      const SizedBox(height: 24),
                      _buildThresholdSlider(
                        context,
                        'Rough to Very Rough',
                        _roughThreshold,
                        _moderateThreshold + 0.1,
                        8.0,
                        (value) {
                          setState(() {
                            _roughThreshold = value;
                          });
                        },
                        Colors.red,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              // Reset to default values
                              setState(() {
                                _smoothThreshold = 0.8;
                                _moderateThreshold = 2.0;
                                _roughThreshold = 4.0;
                              });
                              provider.updateThresholds(
                                _smoothThreshold,
                                _moderateThreshold,
                                _roughThreshold,
                              );
                            },
                            child: const Text('Reset to Defaults'),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Apply the new thresholds
                              provider.updateThresholds(
                                _smoothThreshold,
                                _moderateThreshold,
                                _roughThreshold,
                              );
                              // Collapse the settings panel
                              setState(() {
                                _isExpanded = false;
                              });
                            },
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThresholdSlider(
    BuildContext context,
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1),
              ),
              child: Text(
                value.toStringAsFixed(2),
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).round(),
          label: value.toStringAsFixed(2),
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
