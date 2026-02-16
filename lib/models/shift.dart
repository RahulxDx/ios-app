// ============================================================================
// FILE: shift.dart
// DESCRIPTION: Data model representing work shifts, including types and availability logic.
// ============================================================================
// PROJECT: Stellantis Dealer Hygiene App
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// VERSION: 1.0.0
// ============================================================================
// COPYRIGHT: © 2026 STELLANTIS N.V. - INTERNAL USE ONLY
// ============================================================================

/// Enum defining the types of shifts available.
enum ShiftType {
  morning,
  evening,
}

/// Represents a work shift with a specific time range and date.
class Shift {
  final ShiftType type;
  final String startTime;
  final String endTime;
  final bool isActive;
  final DateTime date;

  Shift({
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.date,
  });

  // TODO: Add method to check if a specific time falls within the shift.

  /// Returns a user-friendly name for the shift type.
  String get displayName {
    switch (type) {
      case ShiftType.morning:
        return 'Morning Shift';
      case ShiftType.evening:
        return 'Evening Shift';
    }
  }

  /// Returns the formatted time range of the shift (e.g., "06:00 - 14:00").
  String get timeRange => '$startTime - $endTime';

  /// checks if the shift is currently available based on the current time.
  /// 
  /// TODO: Handle timezone differences properly. Currently uses local time.
  /// TODO: Make shift timings configurable instead of hardcoded.
  bool get isAvailable {
    final now = DateTime.now();

    // Morning shift is available from 6:00 AM
    if (type == ShiftType.morning) {
      return now.hour >= 6 && now.hour < 14;
    }
    // Evening shift is available from 2:00 PM
    else {
      return now.hour >= 14 && now.hour < 22;
    }
  }


  /// Generates the standard shifts for the current day.
  /// 
  /// TODO: Fetch shift configurations from a backend or config file.
  static List<Shift> getTodayShifts() {
    final today = DateTime.now();
    final isMorningActive = today.hour >= 6 && today.hour < 14;
    final isEveningActive = today.hour >= 14 && today.hour < 22;

    return [
      Shift(
        type: ShiftType.morning,
        startTime: '06:00',
        endTime: '14:00',
        isActive: isMorningActive,
        date: today,
      ),
      Shift(
        type: ShiftType.evening,
        startTime: '14:00',
        endTime: '22:00',
        isActive: isEveningActive,
        date: today,
      ),
    ];
  }
}

// ============================================================================
// END OF FILE: shift.dart
// ============================================================================
// AUTHOR: Rohith U
// WEBSITE: https://www.stellantis.com/
// ============================================================================

