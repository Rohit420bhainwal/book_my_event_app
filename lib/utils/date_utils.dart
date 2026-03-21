import 'package:intl/intl.dart';

class AppDateUtils {
  // Convert raw date string to dd-MMM-yyyy format (09-Oct-2025) in local time
  static String formatToDDMMYY(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(rawDate).toLocal(); // Convert to local
      return DateFormat('dd-MMM-yyyy').format(parsedDate);
    } catch (e) {
      return rawDate; // fallback if parsing fails
    }
  }

  // Optional: format to dd/MM/yy (09/10/25) in local time
  static String formatToDDSlashMMSlashYY(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(rawDate).toLocal(); // Convert to local
      return DateFormat('dd/MM/yy').format(parsedDate);
    } catch (e) {
      return rawDate;
    }
  }

  // Optional: format with time (dd MMM yyyy, hh:mm a)
  static String formatToDateTime(String? rawDate) {
    if (rawDate == null || rawDate.isEmpty) return "";
    try {
      final parsedDate = DateTime.parse(rawDate).toLocal(); // Convert to local
      return DateFormat('dd MMM yyyy, hh:mm a').format(parsedDate);
    } catch (e) {
      return rawDate;
    }
  }

  static String formatDate(String dateString) {
    try {
      DateTime dt = DateTime.parse(dateString).toLocal();
      return "${dt.day.toString().padLeft(2, '0')} "
          "${_month(dt.month)} "
          "${dt.year} – "
          "${_two(dt.hour)}:${_two(dt.minute)} "
          "${dt.hour >= 12 ? 'PM' : 'AM'}";
    } catch (e) {
      return "";
    }
  }

  static String _month(int m) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[m - 1];
  }

  static String _two(int n) => n.toString().padLeft(2, '0');


}
