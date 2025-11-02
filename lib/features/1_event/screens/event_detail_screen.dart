import 'dart:math';
import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/services/currency_service.dart';
import '../../../core/utils/timezone_helper.dart';
import '../../3_favorites/services/favorites_service.dart';
import '../models/event_model.dart';

class EventDetailScreen extends StatefulWidget {
  final EventModel event;
  const EventDetailScreen({super.key, required this.event});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen>
    with SingleTickerProviderStateMixin {
  final TimezoneHelper _timezoneHelper = TimezoneHelper();
  final FavoritesService _favoritesService = FavoritesService();
  final CurrencyService _currencyService = CurrencyService();

  late Future<bool> _isFavoriteFuture;

  bool _isConvertingPrice = false;
  String? _convertedPriceText;
  late List<String> _targetCurrencies;
  late String _selectedTargetCurrency;

  final Map<String, String> _targetTimezones = {
    'WIB (Jakarta)': 'Asia/Jakarta',
    'WITA (Makassar)': 'Asia/Makassar',
    'WIT (Jayapura)': 'Asia/Jayapura',
    'London (GMT)': 'Europe/London',
    'Tokyo (JST)': 'Asia/Tokyo',
    'New York (ET)': 'America/New_York',
  };
  late String _selectedTimezoneKey;
  Map<String, String>? _convertedTimeMap;

  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    _isFavoriteFuture = _favoritesService.isFavorite(widget.event);

    _targetCurrencies = ['IDR', 'USD', 'EUR', 'JPY'];
    if (widget.event.currency != 'N/A' &&
        !_targetCurrencies.contains(widget.event.currency)) {
      _targetCurrencies.add(widget.event.currency);
    }
    _selectedTargetCurrency = _targetCurrencies.first;

    _selectedTimezoneKey = _targetTimezones.keys.first;

    _loadingController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      body: Stack(
        children: [
          _bg(),
          _navBtns(),
          _sheet(),
        ],
      ),
    );
  }

  Widget _bg() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.45,
      width: double.infinity,
      child: Image.network(
        widget.event.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.grey.shade300,
          child: const Icon(Icons.broken_image,
              size: 60, color: AppColors.kSecondaryTextColor),
        ),
      ),
    );
  }

  Widget _navBtns() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CircleAvatar(
              backgroundColor: Colors.black45,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            FutureBuilder<bool>(
              future: _isFavoriteFuture,
              builder: (context, snap) {
                final fav = snap.data ?? false;
                return CircleAvatar(
                  backgroundColor: Colors.black45,
                  child: IconButton(
                    icon: Icon(
                      fav ? Icons.favorite : Icons.favorite_border_outlined,
                      color: fav ? AppColors.kPrimaryColor : Colors.white,
                    ),
                    onPressed: () => _toggleFavorite(fav),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _sheet() {
    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.event.name,
                style: GoogleFonts.nunito(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.kTextColor)),
            const SizedBox(height: 24),

            _detail(Icons.calendar_month, "Tanggal",
                _formatDate(widget.event.localDate)),
            const SizedBox(height: 16),
            _detail(Icons.access_time, "Waktu", widget.event.localTime),
            const SizedBox(height: 16),
            _detail(Icons.location_on_outlined, "Lokasi",
                "${widget.event.venueName}, ${widget.event.venueCountry}"),
            const SizedBox(height: 16),
            _detail(
              Icons.sell_rounded,
              "Harga",
              _convertedPriceText ??
                  _formatPriceRange(widget.event.minPrice,
                      widget.event.maxPrice, widget.event.currency),
            ),
            const SizedBox(height: 30),

            _convertSection(
              title: "Konversi Harga ke Mata Uang Lain",
              icon: Icons.currency_exchange_rounded,
              dropdownItems: _targetCurrencies,
              selectedValue: _selectedTargetCurrency,
              onChanged: (val) => setState(() => _selectedTargetCurrency = val!),
              buttonText: "Konversi",
              onPressed: _isConvertingPrice
                  ? null
                  : () {
                      _showConvertedPrice(_selectedTargetCurrency);
                    },
              isLoading: _isConvertingPrice,
              resultText: _convertedPriceText,
            ),
            const SizedBox(height: 30),

            _convertSection(
              title: "Lihat Jadwal di Zona Waktu Lain",
              icon: Icons.schedule_rounded,
              dropdownItems: _targetTimezones.keys.toList(),
              selectedValue: _selectedTimezoneKey,
              onChanged: (val) => setState(() => _selectedTimezoneKey = val!),
              buttonText: "Lihat",
              onPressed: _showConvertedTime,
              resultWidget: _convertedTimeMap != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _detail(Icons.today_rounded, "Tanggal (Konversi)",
                            _convertedTimeMap!['date'] ?? 'N/A'),
                        const SizedBox(height: 10),
                        _detail(Icons.access_time_filled_rounded,
                            "Waktu (Konversi)", _convertedTimeMap!['time'] ?? 'N/A'),
                      ],
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _convertSection({
    required String title,
    required IconData icon,
    required List<String> dropdownItems,
    required String selectedValue,
    required ValueChanged<String?> onChanged,
    required String buttonText,
    required VoidCallback? onPressed,
    bool isLoading = false,
    String? resultText,
    Widget? resultWidget,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.nunito(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.kTextColor)),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, color: AppColors.kPrimaryColor),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    filled: true,
                    fillColor: AppColors.kCardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  value: selectedValue,
                  items: dropdownItems
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: onChanged,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryColor,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? AnimatedBuilder(
                        animation: _loadingController,
                        builder: (context, _) => Transform.rotate(
                          angle: _loadingController.value * 2 * pi,
                          child: const Icon(Icons.autorenew, size: 18),
                        ),
                      )
                    : Text(buttonText,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          if (resultText != null || resultWidget != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.kPrimaryColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: resultWidget ??
                  Text(
                    resultText ?? '',
                    style: GoogleFonts.nunito(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kPrimaryColor,
                    ),
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detail(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.kPrimaryColor.withOpacity(0.1),
          child: Icon(icon, color: AppColors.kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.nunito(
                      fontSize: 15, color: AppColors.kSecondaryTextColor)),
              const SizedBox(height: 4),
              Text(subtitle,
                  style: GoogleFonts.nunito(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: AppColors.kTextColor)),
            ],
          ),
        ),
      ],
    );
  }

  // ====================== UTILITIES ================================

  String _formatPriceRange(double minPrice, double maxPrice, String currency) {
    if (minPrice == 0.0 && maxPrice == 0.0) return "Harga tidak tersedia";
    final f = NumberFormat.currency(symbol: "$currency ", decimalDigits: 2);
    return (maxPrice > 0 && maxPrice != minPrice)
        ? "${f.format(minPrice)} - ${f.format(maxPrice)}"
        : f.format(minPrice > 0 ? minPrice : maxPrice);
  }

  String _formatDate(String date) {
    if (date == 'TBA') return 'Tanggal Belum Diumumkan';
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
          .format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  void _toggleFavorite(bool isFav) async {
    try {
      if (isFav) {
        await _favoritesService.removeFavorite(widget.event);
      } else {
        await _favoritesService.addFavorite(widget.event);
      }
      setState(() {
        _isFavoriteFuture = _favoritesService.isFavorite(widget.event);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Future<void> _showConvertedPrice(String target) async {
    setState(() => _isConvertingPrice = true);
    try {
      final rates = await _currencyService.getRates();
      final from = widget.event.currency;
      if (!rates.containsKey(from) || !rates.containsKey(target)) {
        throw "Kurs tidak tersedia";
        }
      final fromRate = (rates[from] as num).toDouble();
      final toRate = (rates[target] as num).toDouble();
      double convert(double amount) => (amount / fromRate) * toRate;
      final converted = convert(widget.event.minPrice);
      setState(() {
        _convertedPriceText =
            NumberFormat.currency(symbol: "$target ").format(converted);
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Gagal konversi: $e')));
    } finally {
      setState(() => _isConvertingPrice = false);
    }
  }

  void _showConvertedTime() {
    final target = _targetTimezones[_selectedTimezoneKey]!;
    final iso =
        _timezoneHelper.getIsoDateTime(widget.event.localDate, widget.event.localTime);
    final result = _timezoneHelper.getConvertedTimeForZone(
        iso, widget.event.timezone, target);
    setState(() => _convertedTimeMap = result);
  }
}
