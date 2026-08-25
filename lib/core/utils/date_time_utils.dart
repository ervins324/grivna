import 'package:intl/intl.dart';

class DateTimeUtils {
  DateTimeUtils._();

  static String formatFullDate(DateTime dateTime) {
    return DateFormat('d MMMM yyyy').format(dateTime);
  }

  static String formatShortDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatMonthYear(DateTime dateTime) {
    return DateFormat('MMM yyyy').format(dateTime);
  }

  static String formatDayMonth(DateTime dateTime) {
    return DateFormat('d MMM').format(dateTime);
  }

  static String formatRelativeDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final date = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = today.difference(date).inDays;

    if (difference == 0) {
      return 'Today, ${formatTime(dateTime)}';
    } else if (difference == 1) {
      return 'Yesterday, ${formatTime(dateTime)}';
    } else if (difference == -1) {
      return 'Tomorrow, ${formatTime(dateTime)}';
    } else if (difference > 1 && difference < 7) {
      return '${DateFormat('EEEE').format(dateTime)}, ${formatTime(dateTime)}';
    } else {
      return '${DateFormat('d MMM').format(dateTime)}, ${formatTime(dateTime)}';
    }
  }

  static String formatDaysRemaining(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    final difference = target.difference(today).inDays;

    if (difference < 0) {
      return 'Overdue by ${difference.abs()} days';
    } else if (difference == 0) {
      return 'Due today';
    } else if (difference == 1) {
      return 'Due tomorrow';
    } else {
      return 'in $difference days';
    }
  }
}
