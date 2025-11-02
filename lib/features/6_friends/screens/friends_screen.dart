import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:eventfinder/core/utils/app_colors.dart';
import '../controllers/friend_controller.dart';
import 'friend_favorites_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  late final FriendsController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = FriendsController();
    _controller.addListener(_onStateChanged);
    _controller.loadInitialData();
  }

  void _onStateChanged() {
    if (_controller.searchResult == null) {
      _searchController.clear();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onSearchUser() async {
    await _controller.onSearchUser(_searchController.text.trim());
  }

  Future<void> _onAddFriend() async {
    final message = await _controller.onAddFriend();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDelete(String username) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Hapus Teman'),
            content: Text('Anda yakin ingin menghapus $username dari daftar teman?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _onRemoveFriend(int friendId, String username) async {
    final ok = await _confirmDelete(username);
    if (!ok) return;
    final message = await _controller.onRemoveFriend(friendId, username);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _onViewFriendFavorites(int friendId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendFavoritesScreen(friendId: friendId, friendUsername: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = _controller.currentUser;
    final List<Map<String, dynamic>> leaderboard = [];
    if (me != null) {
      leaderboard.add({
        'id': me['id'],
        'username': me['username'],
        'points': me['points'] ?? 0,
        'isMe': true,
      });
    }
    leaderboard.addAll(_controller.friendsList.map((f) => {
          'id': f['id'],
          'username': f['username'],
          'points': f['points'] ?? 0,
          'isMe': false,
        }));

    leaderboard.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
    final top3 = leaderboard.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.kBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.kPrimaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.kPrimaryColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(top: 28, bottom: 24),
            child: Column(
              children: [
                const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 48),
                Text(
                  'Leaderboard Teman',
                  style: GoogleFonts.nunito(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(3, (i) {
                    if (i >= top3.length) return _buildEmptyRank(i + 1);
                    final item = top3[i];
                    final isMiddle = i == 1;
                    return _buildRankCard(
                      rank: i + 1,
                      name: item['isMe'] ? '${item['username']} (You)' : item['username'],
                      points: item['points'],
                      size: isMiddle ? 96 : 76,
                      highlight: item['isMe'] == true,
                    );
                  }),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Tambah Teman Baru',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade800),
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Cari teman...',
                        hintStyle: GoogleFonts.nunito(color: Colors.grey.shade500, fontSize: 15),
                        prefixIcon: Icon(Icons.search, color: AppColors.kPrimaryColor),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onSubmitted: (_) => _onSearchUser(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSearchResult(),
                  const Divider(height: 32),
                  Text(
                    'Daftar Teman Saya',
                    style: GoogleFonts.nunito(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: _buildFriendsList(AppColors.kPrimaryColor)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRank(int rank) {
    return Column(
      children: [
        const CircleAvatar(radius: 36, backgroundColor: Colors.white24),
        const SizedBox(height: 8),
        Text('#$rank', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildRankCard({
    required int rank,
    required String name,
    required int points,
    required double size,
    bool highlight = false,
  }) {
    final medal = {1: '🥇', 2: '🥈', 3: '🥉'}[rank] ?? '';
    final Color glow = rank == 1 ? Colors.amberAccent : Colors.white.withOpacity(0.4);
    final double blur = rank == 1 ? 22 : 8;
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: glow, blurRadius: blur, spreadRadius: rank == 1 ? 6 : 2),
                ],
              ),
              child: CircleAvatar(
                radius: size / 2,
                backgroundColor: Colors.white,
                child: FittedBox(child: Text(medal, style: const TextStyle(fontSize: 36))),
              ),
            ),
            Positioned(
              bottom: -6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('#$rank', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.kPrimaryColor)),
              ),
            ),
            if (highlight)
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(Icons.person, size: 14, color: AppColors.kPrimaryColor),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 110,
          child: Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.nunito(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        Text('${points} pts', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  Widget _buildSearchResult() {
    if (_controller.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.searchMessage != null) {
      return Center(child: Text(_controller.searchMessage!));
    }
    if (_controller.searchResult != null) {
      final s = _controller.searchResult!;
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(s['username'], style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          trailing: IconButton(
            icon: const Icon(Icons.person_add, color: Colors.green),
            onPressed: _onAddFriend,
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildFriendsList(Color primary) {
    if (_controller.isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.friendsList.isEmpty) {
      return const Center(
        child: Text('Anda belum memiliki teman.\nCari dan tambahkan teman baru di atas!', textAlign: TextAlign.center),
      );
    }

    return ListView.builder(
      itemCount: _controller.friendsList.length,
      itemBuilder: (context, index) {
        final friend = _controller.friendsList[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Slidable(
            key: ValueKey(friend['id']),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (context) async {
                    final ok = await _confirmDelete(friend['username']);
                    if (ok) {
                      await _onRemoveFriend(friend['id'], friend['username']);
                    }
                  },
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Hapus',
                  borderRadius: BorderRadius.circular(12),
                ),
              ],
            ),
            child: Card(
              elevation: 1.5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(friend['username'], style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                subtitle: Text('Points: ${friend['points']}', style: GoogleFonts.nunito()),
                onTap: () => _onViewFriendFavorites(friend['id'], friend['username']),
              ),
            ),
          ),
        );
      },
    );
  }
}
