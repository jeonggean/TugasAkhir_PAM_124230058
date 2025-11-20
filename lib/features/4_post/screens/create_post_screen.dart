import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/snackbar_helper.dart'; // Pastikan helper ini ada
import '../services/post_service.dart';
import '../../1_event/models/event_model.dart';
import '../../3_favorites/services/favorites_service.dart'; // Service Favorit

class CreatePostScreen extends StatefulWidget {
  final String? preFilledEventName; 

  const CreatePostScreen({super.key, this.preFilledEventName});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  
  String? _selectedEventId;
  String? _selectedEventName; 
  
  File? _imageFile;
  bool _isLoading = false;
  bool _isLoadingEvents = true;

  final ImagePicker _picker = ImagePicker();
  final PostService _postService = PostService();
  final FavoritesService _favoritesService = FavoritesService(); 

  List<EventModel> _myEvents = []; 

  @override
  void initState() {
    super.initState();
    _fetchMyFavoriteEvents();
  }
  Future<void> _fetchMyFavoriteEvents() async {
    try {
      // 1. Ambil semua favorit dari database lokal
      final events = await _favoritesService.getFavorites();

      if (mounted) {
        setState(() {
          // 2. Langsung pakai semua data (TIDAK ADA FILTER TANGGAL LAGI)
          _myEvents = events;
          
          // Logic Pre-filled (jika posting dari detail event)
          if (widget.preFilledEventName != null) {
            final exists = _myEvents.any((e) => e.name == widget.preFilledEventName);
            
            if (exists) {
              final event = _myEvents.firstWhere((e) => e.name == widget.preFilledEventName);
              _selectedEventId = event.id;
              _selectedEventName = event.name;
            }
          }
          
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      print("Error fetching favorites: $e");
      if (mounted) setState(() => _isLoadingEvents = false);
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.show(context, "Gagal mengambil gambar: $e", type: SnackBarType.error);
    }
  }

  void _showPickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.kPrimaryColor),
              title: Text('Ambil dari Galeri', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.kPrimaryColor),
              title: Text('Ambil Foto Baru', style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitPost() async {
    if (_imageFile == null) {
      SnackBarHelper.show(context, "Harap pilih foto terlebih dahulu!", type: SnackBarType.error);
      return;
    }

    if (_selectedEventName == null || _selectedEventName!.isEmpty) {
      SnackBarHelper.show(context, "Harap pilih event dari favoritmu!", type: SnackBarType.error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Simpan Foto ke Lokal (Aman dari Clear Cache)
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = path.join(directory.path, fileName);

      final File localImage = await _imageFile!.copy(localPath);

      // Simpan ke Database
      await _postService.createPost(
        eventId: _selectedEventName!, 
        imagePath: localImage.path,
        caption: _captionController.text.trim(),
      );

      if (!mounted) return;

      SnackBarHelper.show(
        context, 
        "Postingan berhasil! Selamat, Anda dapat +10 Poin! 🎉", 
        type: SnackBarType.success
      );
      
      Navigator.pop(context, true); 

    } catch (e) {
      if (!mounted) return;
      SnackBarHelper.show(context, "Gagal upload: $e", type: SnackBarType.error);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text("Buat Postingan", 
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
            color: Colors.white,)),
        backgroundColor: AppColors.kPrimaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Area Upload Foto
            GestureDetector(
              onTap: _showPickerOptions,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  image: _imageFile != null
                      ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover)
                      : null,
                ),
                child: _imageFile == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.kPrimaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.add_a_photo_rounded, size: 40, color: AppColors.kPrimaryColor),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            "Ketuk untuk tambah foto",
                            style: GoogleFonts.nunito(color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      )
                    : null,
              ),
            ),
            
            if (_imageFile != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: TextButton.icon(
                    onPressed: _showPickerOptions,
                    icon: const Icon(Icons.edit, size: 16, color: AppColors.kPrimaryColor),
                    label: Text("Ganti Foto", style: GoogleFonts.nunito(color: AppColors.kPrimaryColor)),
                  ),
                ),
              ),

            const SizedBox(height: 24),

            Text("Detail Postingan", style: GoogleFonts.nunito(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),
            
            // 2. DROPDOWN EVENT (SEMUA FAVORIT)
            _isLoadingEvents 
              ? const Center(child: LinearProgressIndicator(color: AppColors.kPrimaryColor))
              : DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: "Pilih Event",
                    hintText: "Pilih dari daftar favoritmu",
                    prefixIcon: const Icon(Icons.favorite_rounded, color: AppColors.kPrimaryColor),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.kPrimaryColor, width: 2)),
                  ),
                  isExpanded: true,
                  value: _selectedEventId,
                  items: _myEvents.isEmpty 
                    ? [
                        const DropdownMenuItem(
                          value: null, 
                          enabled: false,
                          child: Text("Belum ada event favorit")
                        )
                      ] 
                    : _myEvents.map((event) {
                        // Format tanggal sekadar info tambahan di teks
                        String dateStr = event.localDate;
                        try {
                           final dt = DateTime.parse(event.localDate);
                           dateStr = DateFormat('dd MMM yyyy').format(dt);
                        } catch (_) {}

                        return DropdownMenuItem(
                          value: event.id,
                          child: Text(
                            "${event.name} ($dateStr)",
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.nunito(fontSize: 14),
                          ),
                        );
                      }).toList(),
                  onChanged: _myEvents.isEmpty ? null : (value) {
                    setState(() {
                      _selectedEventId = value;
                      // Ambil nama event untuk disimpan ke DB
                      final event = _myEvents.firstWhere((e) => e.id == value);
                      _selectedEventName = event.name;
                    });
                  },
                ),
            
            const SizedBox(height: 16),

            // 3. Input Caption
            TextField(
              controller: _captionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Caption",
                hintText: "Ceritakan keseruan event ini...",
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 48),
                  child: Icon(Icons.chat_bubble_outline_rounded, color: AppColors.kPrimaryColor),
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.kPrimaryColor, width: 2)),
              ),
            ),

            const SizedBox(height: 32),

            // 4. Tombol Submit
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.kPrimaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24, width: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        "POSTING SEKARANG",
                        style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}