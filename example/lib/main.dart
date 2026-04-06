import 'package:flutter/material.dart';

import 'location_picker_example_page.dart';
import 'map_example_page.dart';

void main() {
  runApp(const NeshanMapsExampleApp());
}

class NeshanMapsExampleApp extends StatelessWidget {
  const NeshanMapsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'neshan_maps_flutter example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('neshan_maps_flutter')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Set your API keys in lib/api_keys.dart, then open an example.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const MapExamplePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('NeshanMap'),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => const LocationPickerExamplePage(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.pin_drop),
                  label: const Text('NeshanLocationPicker'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
