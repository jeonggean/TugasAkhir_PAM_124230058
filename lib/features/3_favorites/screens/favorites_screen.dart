import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../controllers/favorites_controller.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  late final FavoritesController _controller;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _controller = FavoritesController();
    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    _controller.loadFavorites();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _formatCurrency(double price, String currencyCode) {
    if (price == 0.0 && currencyCode == 'N/A') return "N/A";
    if (price == 0.0) return "Gratis";
    final format = NumberFormat.currency(
      locale: 'en_US',
      symbol: "$currencyCode ",
      decimalDigits: 2,
    );
    return format.format(price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
        title: Text(
          'Acara Favorite',
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
    if (_controller.isLoading) {
      return Center(
          child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary));
    }

    final List<EventModel> filteredFavorites;
    if (_searchQuery.isEmpty) {
      filteredFavorites = _controller.favorites;
    } else {
      filteredFavorites = _controller.favorites.where((event) {
        return event.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (filteredFavorites.isEmpty) {
      if (_searchQuery.isNotEmpty) {
        return Center(
          child: Text(
            'Tidak ada favorit ditemukan untuk "$_searchQuery".',
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
                fontSize: 16, color: AppColors.kSecondaryTextColor),
          ),
        );
      }
      return Center(
        child: Text(
          'Kamu belum punya acara favorit.',
          style: GoogleFonts.nunito(
              fontSize: 16, color: AppColors.kSecondaryTextColor),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 24.0),
      itemCount: filteredFavorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final EventModel event = filteredFavorites[index];
        return _buildEventCard(event);
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
        ).then((_) {
          _controller.loadFavorites();
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Row(
          children: [
            ClipRRect(
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: GoogleFonts.nunito(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: AppColors.kTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: AppColors.kSecondaryTextColor),
                      const SizedBox(width: 6),
                      Text(
                        "${event.localDate} @ ${event.localTime}",
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.attach_money,
                          size: 14, color: AppColors.kSecondaryTextColor),
                      const SizedBox(width: 6),
                      Text(
                        _formatCurrency(event.minPrice, event.currency),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.kSecondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}