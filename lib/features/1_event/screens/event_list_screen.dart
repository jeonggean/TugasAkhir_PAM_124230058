import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/location_service.dart';
import '../../2_auth/services/auth_service.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';
import 'event_detail_screen.dart';
import 'popular_events_screen.dart';
import 'regional_events_screen.dart';

class EventListScreen extends StatefulWidget {
  EventListScreen({super.key});

  @override
  State<EventListScreen> createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  late final EventController _controller;
  final TextEditingController _searchController = TextEditingController();
  final LocationService _locationService = LocationService();
  final AuthService _authService = AuthService();

  String? _currentLocationName;
  bool _isLocationLoading = true;
  late Future<String?> _usernameFuture;

  @override
  void initState() {
    super.initState();
    _controller = EventController();
    _controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _fetchLocationName();
    _usernameFuture = _authService.getCurrentUsername();
  }

  Future<void> _fetchLocationName() async {
    setState(() {
      _isLocationLoading = true;
    });
    try {
      final cityName = await _locationService.getCityName();
      if (mounted) {
        setState(() {
          _currentLocationName = cityName ?? "Lokasi Tidak Ditemukan";
          _isLocationLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentLocationName = "Gagal Mendeteksi Lokasi";
          _isLocationLoading = false;
        });
      }
    }
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
      decimalDigits: 0,
    );
    return format.format(price);
  }

  void _goToPopularEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PopularEventsScreen(
          popularEvents: _controller.popularEventsGlobal,
          isLoading: _controller.isLoadingPopular,
        ),
      ),
    );
  }

  void _goToRegionalEvents() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegionalEventsScreen(
          regionalEvents: _controller.regionalEvents,
          isLoading: _controller.isLoadingRegional,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: Column(
        children: [
          _buildPurpleHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  _buildPopularEventsSection(),
                  const SizedBox(height: 32),
                  _buildRegionalEventsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurpleHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.kPrimaryColor,
            AppColors.kPrimaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.event_note_outlined,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'EvenFinder',
                            style: GoogleFonts.nunito(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FutureBuilder<String?>(
                        future: _usernameFuture,
                        builder: (context, snapshot) {
                          final username = snapshot.data ?? 'User';
                          return Text(
                            'Hello $username',
                            style: GoogleFonts.nunito(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Temukan Acara Favoritmu ',
                        style: GoogleFonts.nunito(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "Lokasi Anda: ",
                    style: GoogleFonts.nunito(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  _isLocationLoading
                      ? Text(
                          'Mencari...',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        )
                      : Flexible(
                          child: Text(
                            _currentLocationName ?? 'Tidak Ditemukan',
                            style: GoogleFonts.nunito(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(color: AppColors.kTextColor),
                  decoration: InputDecoration(
                    hintText: 'Cari acara...',
                    hintStyle: TextStyle(color: AppColors.kSecondaryTextColor),
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppColors.kPrimaryColor,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.kSecondaryTextColor,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _controller.loadRegionalEvents();
                              _controller.loadPopularGlobalEvents();
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 16.0,
                    ),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) => setState(() {}),
                  onSubmitted: (keyword) {
                    if (keyword.isNotEmpty) {
                      _controller.searchEvents(keyword);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Acara Populer',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kTextColor,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _goToPopularEvents,
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.nunito(
                    color: AppColors.kAccentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildPopularEventsList(),
      ],
    );
  }

  Widget _buildPopularEventsList() {
    if (_controller.isLoadingPopular) {
      return Container(
        height: 250,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
        ),
      );
    }

    if (_controller.popularEventsGlobal.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          'Tidak ada acara populer ditemukan',
          style: GoogleFonts.nunito(color: AppColors.kSecondaryTextColor),
        ),
      );
    }

    final displayEvents = _controller.popularEventsGlobal.take(5).toList();

    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: displayEvents.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < displayEvents.length - 1 ? 16.0 : 0,
            ),
            child: _buildEventCard(displayEvents[index]),
          );
        },
      ),
    );
  }

  Widget _buildRegionalEventsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Acara Regional ',
                    style: GoogleFonts.nunito(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.kTextColor,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: _goToRegionalEvents,
                child: Text(
                  'Lihat Semua',
                  style: GoogleFonts.nunito(
                    color: AppColors.kAccentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _buildRegionalEventsList(),
      ],
    );
  }

  Widget _buildRegionalEventsList() {
    if (_controller.isLoadingRegional) {
      return Container(
        height: 280,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.kPrimaryColor),
        ),
      );
    }

    if (_controller.errorMessage.isNotEmpty &&
        _controller.regionalEvents.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24.0),
        child: Text(
          _controller.errorMessage.contains('lokasi')
              ? 'Nyalakan GPS dan izin lokasi untuk melihat acara regional.'
              : 'Gagal memuat event regional.',
          style: GoogleFonts.nunito(color: AppColors.kSecondaryTextColor),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_controller.regionalEvents.isEmpty) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          'Tidak ada acara regional ditemukan',
          style: GoogleFonts.nunito(color: AppColors.kSecondaryTextColor),
        ),
      );
    }

    final displayEvents = _controller.regionalEvents.take(5).toList();

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        itemCount: displayEvents.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < displayEvents.length - 1 ? 16.0 : 0,
            ),
            child: _buildEventCard(displayEvents[index]),
          );
        },
      ),
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
        width: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: AppColors.kCardColor,
          boxShadow: [
            BoxShadow(
              color: AppColors.kPrimaryColor.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              child: Image.network(
                event.imageUrl,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 140,
                  color: AppColors.kBackgroundColor,
                  child: Icon(
                    Icons.broken_image,
                    color: AppColors.kSecondaryTextColor,
                    size: 60,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        event.name,
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.kTextColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 13,
                            color: AppColors.kSecondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              event.venueCity != 'N/A'
                                  ? event.venueCity
                                  : event.venueCountry,
                              style: GoogleFonts.nunito(
                                fontSize: 12,
                                color: AppColors.kSecondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              _formatCurrency(event.minPrice, event.currency),
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.kPrimaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 13,
                            color: AppColors.kSecondaryTextColor,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "${event.localDate} • ${event.localTime}",
                              style: GoogleFonts.nunito(
                                fontSize: 11,
                                color: AppColors.kSecondaryTextColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
