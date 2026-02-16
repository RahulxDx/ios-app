/*
 * ========================================================================
 * File: main.dart
 * Description: Application entry point for the Stellantis Hygiene Audit
 *              System. Initializes and launches the Flutter application.
 *
 * Author: Rahul Raja
 * Website: https://www.stellantis.com/
 * ========================================================================
 */

import 'package:flutter/material.dart';
import 'app.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';

/// Application entry point
/// Initializes services and runs the Stellantis Audit app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize API client with automatic backend detection
  await ApiClient().initialize();

  // Initialize authentication service (restore session if exists)
  await AuthService().initialize();

  runApp(const StellantisApp());
}

/*
 * ========================================================================
 * End of main.dart
 * Author: Rahul Raja
 * Website: https://www.stellantis.com/
 * ========================================================================
 */

