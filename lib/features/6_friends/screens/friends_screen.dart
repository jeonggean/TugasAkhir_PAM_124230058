import 'package:eventfinder/core/utils/app_colors.dart';
import 'package:eventfinder/core/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/friend_controller.dart';
import 'friend_favorites_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late final FriendsController _controller;
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = FriendsController();
    _controller.addListener(() => setState(() {}));
    _controller.loadInitialData();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // 🔍 SEARCH
  Future<void> _onSearchUser() async {
    await _controller.onSearchUser(_searchController.text.trim());
  }

  // 📨 KIRIM PERMINTAAN
  Future<void> _sendFriendRequest() async {
    final msg = await _controller.onSendFriendRequest();
    SnackBarHelper.show(
      context,
      msg,
      type: msg.contains("berhasil")
          ? SnackBarType.success
          : SnackBarType.error,
    );
  }

  // ✅ TERIMA PERMINTAAN
  Future<void> _accept(int requesterId) async {
    final msg = await _controller.onAcceptFriend(requesterId);
    SnackBarHelper.show(
      context,
      msg,
      type: msg.contains("berhasil")
          ? SnackBarType.success
          : SnackBarType.error,
    );
  }

  // ❌ TOLAK PERMINTAAN
  Future<void> _reject(int requesterId) async {
    final msg = await _controller.onRejectFriend(requesterId);
    SnackBarHelper.show(
      context,
      msg,
      type: msg.contains("berhasil")
          ? SnackBarType.info
          : SnackBarType.error,
    );
  }

  // 🗑 HAPUS TEMAN
  Future<void> _onRemoveFriend(int friendId, String username) async {
    final msg = await _controller.onRemoveFriend(friendId, username);
    SnackBarHelper.show(
      context,
      msg,
      type: msg.contains("berhasil")
          ? SnackBarType.success
          : SnackBarType.error,
    );
  }

  // ❤️ FAVORIT TEMAN
  void _openFriendFavorites(int id, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            FriendFavoritesScreen(friendId: id, friendUsername: username),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = _controller.currentUser;
    final leaderboard = <Map<String, dynamic>>[];

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
          _buildLeaderboard(top3),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _buildSearchBar(),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchResult(),
          ),
          TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.nunito(fontWeight: FontWeight.bold),
            labelColor: AppColors.kPrimaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.kPrimaryColor,
            tabs: const [
              Tab(text: "Teman Saya"),
              Tab(text: "Permintaan Teman"),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildFriendsTab(),
                _buildRequestsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 🏆 Leaderboard
  Widget _buildLeaderboard(List<Map<String, dynamic>> top3) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.kPrimaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 48),
          Text(
            'Leaderboard Teman',
            style: GoogleFonts.nunito(
                fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (i) {
              if (i >= top3.length) return _buildEmptyRank(i + 1);
              final item = top3[i];
              return _buildRankCard(
                rank: i + 1,
                name: item['isMe']
                    ? '${item['username']} (You)'
                    : item['username'],
                points: item['points'],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRank(int rank) => Column(
        children: [
          const CircleAvatar(radius: 36, backgroundColor: Colors.white24),
          const SizedBox(height: 8),
          Text('#$rank',
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );

  Widget _buildRankCard({
    required int rank,
    required String name,
    required int points,
  }) {
    final medal = {1: '🥇', 2: '🥈', 3: '🥉'}[rank] ?? '';
    return Column(
      children: [
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: FittedBox(
            child: Text(medal, style: const TextStyle(fontSize: 36)),
          ),
        ),
        const SizedBox(height: 8),
        Text(name,
            style: GoogleFonts.nunito(
                color: Colors.white, fontWeight: FontWeight.w600)),
        Text('$points pts', style: GoogleFonts.nunito(color: Colors.white70)),
      ],
    );
  }

  // 🔍 Search bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.nunito(fontSize: 16, color: Colors.grey.shade800),
        cursorColor: Colors.black,
        decoration: InputDecoration(
          hintText: 'Cari teman...',
          hintStyle:
              GoogleFonts.nunito(color: Colors.grey.shade500, fontSize: 15),
          prefixIcon: Icon(Icons.search, color: AppColors.kPrimaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onSubmitted: (_) => _onSearchUser(),
      ),
    );
  }

  // 🔎 Hasil pencarian
  Widget _buildSearchResult() {
    if (_controller.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.searchMessage != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Center(child: Text(_controller.searchMessage!)),
      );
    }
    if (_controller.searchResult != null) {
      final s = _controller.searchResult!;
      final rel = _controller.searchRelation;

      Widget trailing;
      if (rel == 'none') {
        trailing = IconButton(
            icon: const Icon(Icons.person_add, color: Colors.green),
            onPressed: _sendFriendRequest);
      } else if (rel == 'pending_out') {
        trailing = Chip(
            label: const Text("Menunggu"),
            backgroundColor: Colors.orange.shade50,
            labelStyle: const TextStyle(color: Colors.orange));
      } else if (rel == 'friends') {
        trailing = Chip(
            label: const Text("Sudah Teman"),
            backgroundColor: Colors.green.shade50,
            labelStyle: const TextStyle(color: Colors.green));
      } else {
        trailing = const SizedBox.shrink();
      }

      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(s['username'],
              style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
          subtitle: Text("Points: ${s['points']}", style: GoogleFonts.nunito()),
          trailing: trailing,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  // 👥 Tab: Teman Saya
  Widget _buildFriendsTab() {
    if (_controller.isLoadingFriends) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_controller.friendsList.isEmpty) {
      return const Center(
        child: Text('Belum ada teman yang disetujui.\nTambahkan teman baru!'),
      );
    }

    return ListView.builder(
      itemCount: _controller.friendsList.length,
      itemBuilder: (context, i) {
        final f = _controller.friendsList[i];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Slidable(
            key: ValueKey(f['id']),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.25,
              children: [
                SlidableAction(
                  onPressed: (_) => _onRemoveFriend(f['id'], f['username']),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  icon: Icons.delete_outline,
                  label: 'Hapus',
                ),
              ],
            ),
            child: Card(
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading:
                    const CircleAvatar(child: Icon(Icons.person_outline)),
                title: Text(f['username'],
                    style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
                subtitle: Text('Points: ${f['points']}',
                    style: GoogleFonts.nunito(fontSize: 14)),
                onTap: () =>
                    _openFriendFavorites(f['id'], f['username']),
              ),
            ),
          ),
        );
      },
    );
  }

  // 📨 Tab: Permintaan Teman
  Widget _buildRequestsTab() {
    if (_controller.pendingRequests.isEmpty) {
      return const Center(child: Text('Belum ada permintaan pertemanan.'));
    }

    return ListView.builder(
      itemCount: _controller.pendingRequests.length,
      itemBuilder: (context, i) {
        final req = _controller.pendingRequests[i];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.person_add_alt_1)),
            title: Text(req['username'],
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600)),
            subtitle:
                Text("Points: ${req['points']}", style: GoogleFonts.nunito()),
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                    icon: const Icon(Icons.check_circle, color: Colors.green),
                    onPressed: () => _accept(req['id'])),
                IconButton(
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    onPressed: () => _reject(req['id'])),
              ],
            ),
          ),
        );
      },
    );
  }
}
