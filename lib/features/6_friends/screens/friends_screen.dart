import 'package:flutter/material.dart';
import '../../2_auth/services/auth_service.dart';
import '../services/friend_service.dart';
import 'friend_favorites_screen.dart'; 

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final AuthService _authService = AuthService();
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();

  int? _currentUserId;
  bool _isLoadingFriends = true;
  List<Map<String, dynamic>> _friendsList = [];
  
  bool _isSearching = false;
  Map<String, dynamic>? _searchResult;
  String? _searchMessage;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final id = await _authService.getCurrentUserId();
    if (id == null) {
      // Handle kasus jika user tidak login,
      // meskipun idealnya halaman ini tidak bisa diakses
      return;
    }
    setState(() {
      _currentUserId = id;
    });
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    if (_currentUserId == null) return;
    setState(() {
      _isLoadingFriends = true;
    });
    try {
      final friends = await _friendService.getFriends(_currentUserId!);
      setState(() {
        _friendsList = friends;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat teman: $e')),
      );
    } finally {
      setState(() {
        _isLoadingFriends = false;
      });
    }
  }

  Future<void> _onSearchUser() async {
    final username = _searchController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchResult = null;
      _searchMessage = null;
    });

    try {
      final user = await _friendService.findUserByUsername(username);
      if (user != null) {
        if(user['id'] == _currentUserId) {
          setState(() {
            _searchMessage = 'Anda tidak dapat menambahkan diri sendiri.';
          });
        } else {
          setState(() {
            _searchResult = user;
          });
        }
      } else {
        setState(() {
          _searchMessage = 'User "$username" tidak ditemukan.';
        });
      }
    } catch (e) {
      setState(() {
        _searchMessage = 'Terjadi error: $e';
      });
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _onAddFriend(int friendId, String username) async {
    if (_currentUserId == null) return;

    try {
      await _friendService.addFriend(_currentUserId!, friendId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$username berhasil ditambahkan!')),
      );
      // Reset search dan refresh daftar teman
      setState(() {
        _searchResult = null;
        _searchController.clear();
      });
      _loadFriends();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal: ${e.toString().replaceFirst("Exception: ", "")}')),
      );
    }
  }

  Future<void> _onRemoveFriend(int friendId, String username) async {
    if (_currentUserId == null) return;

    // Tampilkan dialog konfirmasi
    final bool? shouldDelete = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Teman'),
        content: Text('Anda yakin ingin menghapus $username dari daftar teman?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await _friendService.removeFriend(_currentUserId!, friendId);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$username berhasil dihapus.')),
        );
        _loadFriends(); // Refresh daftar
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  void _onViewFriendFavorites(int friendId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendFavoritesScreen(
          friendId: friendId,
          friendUsername: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Bagian Cari Teman ---
            Text('Tambah Teman Baru', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari username...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16)
                    ),
                    onSubmitted: (_) => _onSearchUser(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _onSearchUser,
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.all(16)
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSearchResult(),
            
            Divider(height: 32),

            // --- Bagian Daftar Teman ---
            Text('Daftar Teman Saya', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Expanded(
              child: _buildFriendsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResult() {
    if (_isSearching) {
      return Center(child: CircularProgressIndicator());
    }
    if (_searchMessage != null) {
      return Center(child: Text(_searchMessage!));
    }
    if (_searchResult != null) {
      return Card(
        child: ListTile(
          leading: CircleAvatar(child: Icon(Icons.person)),
          title: Text(_searchResult!['username']),
          trailing: IconButton(
            icon: Icon(Icons.person_add, color: Colors.green),
            onPressed: () => _onAddFriend(
              _searchResult!['id'],
              _searchResult!['username'],
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink(); // Tidak ada apa-apa jika belum mencari
  }

  Widget _buildFriendsList() {
    if (_isLoadingFriends) {
      return Center(child: CircularProgressIndicator());
    }
    if (_friendsList.isEmpty) {
      return Center(
        child: Text(
          'Anda belum memiliki teman. \nCari dan tambahkan teman baru di atas!',
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView.builder(
      itemCount: _friendsList.length,
      itemBuilder: (context, index) {
        final friend = _friendsList[index];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(Icons.person_outline)),
            title: Text(friend['username']),
            subtitle: Text('Points: ${friend['points']}'),
            onTap: () => _onViewFriendFavorites(friend['id'], friend['username']),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade700),
              onPressed: () => _onRemoveFriend(friend['id'], friend['username']),
            ),
          ),
        );
      },
    );
  }
}