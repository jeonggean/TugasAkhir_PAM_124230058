import 'dart:math';

class EventModel {
  final String id;
  final String name;
  final String imageUrl;
  final String localDate;
  final String localTime;
  final String timezone;
  final String currency;
  final double minPrice;
  final double maxPrice;
  final String venueName;
  final String venueCity;
  final String venueCountry;
  final String json;

  EventModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.localDate,
    required this.localTime,
    required this.timezone,
    required this.currency,
    required this.minPrice,
    required this.maxPrice,
    required this.venueName,
    required this.venueCity,
    required this.venueCountry,
    required this.json,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    String getImageUrl(Map<String, dynamic> json) {
      if (json.containsKey('imageUrl')) {
        return json['imageUrl'] ?? 'https://i.imgur.com/gA1q3nJ.png';
      }
      if (json['images'] != null && json['images'].isNotEmpty) {
        final fallbackImage = json['images'][0]['url'];
        final preferredImage = (json['images'] as List).firstWhere(
          (img) => img['ratio'] == '16_9',
          orElse: () => null,
        );
        return preferredImage?['url'] ?? fallbackImage;
      }
      return 'https://i.imgur.com/gA1q3nJ.png';
      
    }

    int _hashString(String str) {
      int hash = 5381;
      for (int i = 0; i < str.length; i++) {
        hash = ((hash << 5) + hash) + str.codeUnitAt(i);
      }
      return hash.abs();
    }

    final String eventId = json['id'] ?? '';
    String currency;
    double minPrice;
    double maxPrice;

    String getVenueName(Map<String, dynamic>? embedded) {
      if (embedded == null ||
          !embedded.containsKey('venues') ||
          (embedded['venues'] as List).isEmpty) {
        return "Lokasi tidak tersedia";
      }
      return embedded['venues'][0]['name'] ?? "Lokasi tidak tersedia";
    }

    String getVenueCity(Map<String, dynamic>? embedded) {
      if (embedded == null ||
          !embedded.containsKey('venues') ||
          (embedded['venues'] as List).isEmpty) {
        return "N/A";
      }
      final venue = embedded['venues'][0];
      if (venue.containsKey('city') && venue['city'] != null) {
        return venue['city']['name'] ?? "N/A";
      }
      return "N/A";
    }

    String getVenueCountry(Map<String, dynamic>? embedded) {
      if (embedded == null ||
          !embedded.containsKey('venues') ||
          (embedded['venues'] as List).isEmpty) {
        return "N/A";
      }
      final venue = embedded['venues'][0];
      if (venue.containsKey('country') && venue['country'] != null) {
        return venue['country']['name'] ?? "N/A";
      }
      return "N/A";
    }

    if (json['priceRanges'] != null && json['priceRanges'].isNotEmpty) {
      final priceRange = json['priceRanges'][0];
      currency = priceRange['currency'] ?? 'USD';
      minPrice = (priceRange['min'] as num?)?.toDouble() ?? 0.0;
      maxPrice = (priceRange['max'] as num?)?.toDouble() ?? 0.0;
    } else if (json.containsKey('currency') &&
        json.containsKey('minPrice') &&
        json.containsKey('maxPrice')) {
      currency = json['currency'] ?? 'USD';
      minPrice = (json['minPrice'] as num?)?.toDouble() ?? 0.0;
      maxPrice = (json['maxPrice'] as num?)?.toDouble() ?? 0.0;
    } else {
      currency = 'USD';
      final seed = _hashString(eventId);
      final random = Random(seed);
      minPrice = 15.0 + (random.nextDouble() * 35.0);
      maxPrice = minPrice + 20.0 + (random.nextDouble() * 60.0);
      minPrice = double.parse(minPrice.toStringAsFixed(2));
      maxPrice = double.parse(maxPrice.toStringAsFixed(2));
    }

    final embeddedData = json['_embedded'] as Map<String, dynamic>?;

    return EventModel(
      id: eventId,
      name: json['name'] ?? 'No Name',
      imageUrl: json['imageUrl'] ?? getImageUrl(json),
      localDate:
          json['localDate'] ?? json['dates']?['start']?['localDate'] ?? 'No Date',
      localTime:
          json['localTime'] ?? json['dates']?['start']?['localTime'] ?? 'No Time',
      timezone: json['timezone'] ?? json['dates']?['timezone'] ?? 'N/A',
      currency: currency,
      minPrice: minPrice,
      maxPrice: maxPrice,
      venueName: getVenueName(embeddedData),
      venueCity: getVenueCity(embeddedData),
      venueCountry: getVenueCountry(embeddedData),
      json: json.toString(),
    );
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['eventId'] ?? map['id'],
      name: map['name'] ?? 'No Name',
      imageUrl: map['imageUrl'] ?? 'https://i.imgur.com/gA1q3nJ.png',
      localDate: map['localDate'] ?? 'No Date',
      localTime: map['localTime'] ?? 'No Time',
      timezone: map['timezone'] ?? 'N/A',
      currency: map['currency'] ?? 'USD',
      minPrice: (map['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (map['maxPrice'] as num?)?.toDouble() ?? 0.0,
      venueName: map['venueName'] ?? 'Lokasi tidak tersedia',
      venueCity: map['venueCity'] ?? 'N/A',
      venueCountry: map['venueCountry'] ?? 'N/A',
      json: map['json'] ?? '{}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'localDate': localDate,
      'localTime': localTime,
      'timezone': timezone,
      'currency': currency,
      'minPrice': minPrice,
      'maxPrice': maxPrice,
      'venueName': venueName,
      'venueCity': venueCity,
      'venueCountry': venueCountry,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'eventId': id,
      'name': name,
      'imageUrl': imageUrl,
      'localDate': localDate,
      'localTime': localTime,
      'venueCity': venueCity,
      'venueCountry': venueCountry,
      'minPrice': minPrice,
      'currency': currency,
      'json': json,
    };
  }
}