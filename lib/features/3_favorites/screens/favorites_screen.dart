import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../1_event/controllers/event_controller.dart';
import '../../1_event/models/event_model.dart';
import '../../1_event/screens/event_detail_screen.dart';
import '../../1_event/screens/popular_events_screen.dart';
import '../../1_event/widgets/event_card.dart';
import '../controllers/favorites_controller.dart';

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
              try {
                final eventController = Provider.of<EventController>(context, listen: false);
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PopularEventsScreen(
                      popularEvents: eventController.popularEventsGlobal,
                      isLoading: eventController.isLoadingPopular,
                    ),
                  ),
                );
              } catch (e) {
                // Jika EventController tidak tersedia, navigasi ke event list screen
                await Navigator.pushNamed(context, '/event_list');
              }
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
      padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 80.0),
      itemCount: filteredFavorites.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final event = filteredFavorites[index];
        return EventCard(
          event: event,
          isSlidable: true,
          slidableKey: ValueKey(event.id),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EventDetailScreen(event: event),
              ),
            );
          },
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.3,
            children: [
              SlidableAction(
                onPressed: (context) async {
                  final ok = await _confirmDelete(event.name);
                  if (ok) {
                    await controller.removeFromFavorites(event.id);
                  }
                },
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                icon: Icons.delete_outline,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
          ),
        );
      },
    );
  }
}