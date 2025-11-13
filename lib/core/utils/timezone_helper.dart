import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;

class TimezoneHelper {
  String getIsoDateTime(String localDate, String localTime) {
    if (localDate == 'TBA' || localTime == 'TBA') {
      return DateTime.now().toIso8601String();
    }
    try {
      final dateTimeStr = "${localDate}T${localTime}";
      return DateTime.parse(dateTimeStr).toIso8601String();
    } catch (e) {
      return DateTime.now().toIso8601String();
    }
  }

  Map<String, String> getConvertedTimeForZone(
      String isoDateTime, String originalTimezone, String targetTimezoneId) {
    try {
      final tz.Location originalLocation = tz.getLocation(originalTimezone);
      final tz.TZDateTime originalZonedDateTime =
          tz.TZDateTime.parse(originalLocation, isoDateTime);

      final tz.Location targetLocation = tz.getLocation(targetTimezoneId);
      final tz.TZDateTime targetZonedDateTime =
          tz.TZDateTime.from(originalZonedDateTime, targetLocation);

      return {
        'date': DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
            .format(targetZonedDateTime),
        'time': DateFormat("HH:mm").format(targetZonedDateTime),
      };
    } catch (e) {
      print('Timezone conversion error: $e');
      return {'date': 'Error Konversi', 'time': 'Error'};
    }
  }
}