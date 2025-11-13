import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';

class PopularEventsScreen extends StatefulWidget {
  final List<EventModel> popularEvents;
  final bool isLoading;

  const PopularEventsScreen({
    super.key,
    required this.popularEvents,
    required this.isLoading,
  });

  @override
  State<PopularEventsScreen> createState() => _PopularEventsScreenState();
}

class _PopularEventsScreenState extends State<PopularEventsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double? price, String currency) {
    if (price == null) return 'Free';
    
    String symbol = '';
    switch (currency.toUpperCase()) {
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
        symbol = currency;
    }

    if (price == 0) return 'Free';
    final priceStr = price.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},'
    );
    
    return '$symbol$priceStr';
  }

  List<EventModel> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return widget.popularEvents;
    }
    return widget.popularEvents.where((event) {
      return event.name.toLowerCase().contains(_searchQuery) ||
          event.venueCity.toLowerCase().contains(_searchQuery) ||
          event.venueCountry.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Acara Populer',
          style: GoogleFonts.nunito(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppColors.kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: AppColors.kPrimaryColor,
      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(color: AppColors.kTextColor),
          decoration: InputDecoration(
            hintText: 'Cari acara populer...',
            hintStyle: TextStyle(color: AppColors.kSecondaryTextColor),
            prefixIcon: Icon(Icons.search, color: AppColors.kPrimaryColor),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: AppColors.kSecondaryTextColor),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (widget.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
      );
    }

    final filteredEvents = _filteredEvents;

    if (filteredEvents.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 80, color: AppColors.kSecondaryTextColor),
              const SizedBox(height: 16),
              Text(
                'No events found for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 16,
                  color: AppColors.kSecondaryTextColor,
                ),
              ),
            ],
          ),
        );
      }
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 80, color: AppColors.kSecondaryTextColor),
            const SizedBox(height: 16),
            Text(
              'No popular events found',
              style: GoogleFonts.nunito(
                fontSize: 16,
                color: AppColors.kSecondaryTextColor,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24.0),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: _buildEventCard(filteredEvents[index]),
        );
      },
    );
  }

  Widget _buildEventCard(EventModel event) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
              padding: const EdgeInsets.only(left: 4.0),
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
                    child: Icon(
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.venueCity != 'N/A'
                              ? event.venueCity
                              : event.venueCountry,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
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
                      const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.localDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.kPrimaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatCurrency(event.minPrice, event.currency),
                          style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold,
                            color: AppColors.kPrimaryColor,
                            fontSize: 13,
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
  }
}