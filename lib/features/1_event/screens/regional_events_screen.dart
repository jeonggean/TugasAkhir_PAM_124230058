import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';
import '../widgets/event_card.dart';

class RegionalEventsScreen extends StatefulWidget {
  final List<EventModel> regionalEvents;
  final bool isLoading;

  const RegionalEventsScreen({
    super.key,
    required this.regionalEvents,
    required this.isLoading,
  });

  @override
  State<RegionalEventsScreen> createState() => _RegionalEventsScreenState();
}

class _RegionalEventsScreenState extends State<RegionalEventsScreen> {
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

  List<EventModel> get _filteredEvents {
    if (_searchQuery.isEmpty) {
      return widget.regionalEvents;
    }
    return widget.regionalEvents.where((event) {
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
          'Acara Regional',
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
            hintText: 'Search regional events...',
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
              'No regional events found',
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
        final ev = filteredEvents[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: EventCard(
            event: ev,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EventDetailScreen(event: ev),
                ),
              );
            },
          ),
        );
      },
    );
  }
}