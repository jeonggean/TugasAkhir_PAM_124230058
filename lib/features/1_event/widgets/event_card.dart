import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../models/event_model.dart';
import '../../../core/utils/app_colors.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback? onTap;
  final Widget? trailing;
  final ActionPane? endActionPane;
  final ValueKey? slidableKey;
  final bool isSlidable;

  const EventCard({
    Key? key,
    required this.event,
    this.onTap,
    this.trailing,
    this.endActionPane,
    this.slidableKey,
    this.isSlidable = false,
  }) : super(key: key);

  String _formatCurrency(double? price, String? currencyCode) {
    if (price == null || currencyCode == null || currencyCode == 'N/A') return "N/A";
    if (price == 0.0) return "Gratis";

    String symbol;
    switch (currencyCode.toUpperCase()) {
      case 'USD':
        symbol = '\$';
        break;
      case 'IDR':
        symbol = 'Rp';
        break;
      case 'EUR':
        symbol = '€';
        break;
      case 'GBP':
        symbol = '£';
        break;
      default:
        symbol = currencyCode;
    }

    final priceInt = price.toInt();
    final priceStr = priceInt.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );

    return '$symbol$priceStr';
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isSlidable ? 0 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: AppColors.kCardColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimaryColor.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Image.network(
                  event.imageUrl,
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 80,
                    width: 80,
                    color: AppColors.kBackgroundColor,
                    child: const Icon(
                      Icons.broken_image,
                      size: 40,
                      color: AppColors.kSecondaryTextColor,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.name,
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.kTextColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venueCity != 'N/A' ? event.venueCity : event.venueCountry,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.kSecondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          event.localDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.kSecondaryTextColor,
                          ),
                        ),
                        const Spacer(),
                        if (trailing != null) trailing!,
                        if (trailing == null)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatCurrency(event.minPrice, event.currency),
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.kPrimaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
    if (endActionPane != null && slidableKey != null) {
      return Slidable(
        key: slidableKey,
        endActionPane: endActionPane,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: cardContent,
        ),
      );
    }

    return cardContent;
  }
}
