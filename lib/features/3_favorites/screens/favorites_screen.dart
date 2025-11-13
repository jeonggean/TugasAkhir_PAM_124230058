import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../controllers/favorites_controller.dart';
import '../../1_event/screens/popular_events_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoritesController>(context, listen: false).loadFavorites();
    });
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
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
      (Match m) => '${m[1]},',
    );
    return '$symbol$priceStr';
  }

  Future<bool> _confirmDelete(String name) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus dari Favorit'),
            content: Text('Hapus "$name" dari daftar favorit?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesController>(
      builder: (context, controller, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Acara Favorit',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.kPrimaryColor,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.kPrimaryColor,
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PopularEventsScreen(
                    popularEvents: controller.favorites, // Gunakan controller
                    isLoading: false,
                  ),
                ),
              );
            },
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              Expanded(child: _buildBody(controller)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    // ... (Tidak ada perubahan di method ini)
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
                    icon: Icon(
                      Icons.clear,
                      color: AppColors.kSecondaryTextColor,
                    ),
                    onPressed: () => _searchController.clear(),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 16.0),
          ),
        ),
      ),
    );
  }

  // UBAH: Terima 'FavoritesController controller' sbg parameter
  Widget _buildBody(FavoritesController controller) {
    if (controller.isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
      );
    }

    final List<EventModel> filteredFavorites;
    if (_searchQuery.isEmpty) {
      filteredFavorites = controller.favorites;
    } else {
      filteredFavorites = controller.favorites.where((event) {
        return event.name.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    if (filteredFavorites.isEmpty) {
      return Center(
        child: Text(
          _searchQuery.isNotEmpty
              ? 'Tidak ada favorit untuk "$_searchQuery".'
              : 'Kamu belum punya acara favorit.',
          textAlign: TextAlign.center,
          style: GoogleFonts.nunito(
            fontSize: 16,
            color: AppColors.kSecondaryTextColor,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 80.0),
      itemCount: filteredFavorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = filteredFavorites[index];
        // Oper controller ke card
        return _buildSlidableCard(event, controller);
      },
    );
  }

  Widget _buildSlidableCard(EventModel event, FavoritesController controller) {
    return Slidable(
      key: ValueKey(event.id ?? event.name),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (context) async {
              final ok = await _confirmDelete(event.name);
              if (ok) {
                await controller.removeFromFavorites(event.id ?? event.name);
              }
            },
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
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
                          const Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.grey,
                          ),
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
                          const Icon(
                            Icons.calendar_today,
                            size: 14,
                            color: Colors.grey,
                          ),
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
                              horizontal: 10,
                              vertical: 6,
                            ),
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
      ),
    );
  }
}
