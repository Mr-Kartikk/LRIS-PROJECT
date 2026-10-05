import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lris/providers/auth_provider.dart';
import 'package:lris/providers/Item_provider.dart';
import 'package:lris/screens/items/add_lost_item.dart';
import 'package:lris/screens/items/add_found_item.dart';
import 'package:lris/screens/items/lost_items_screen.dart';
import 'package:lris/screens/items/found_items_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const Color _ink = Color(0xFF193C36);
  static const Color _green = Color(0xFF176B57);
  static const Color _muted = Color(0xFF74827D);
  static const Color _paper = Color(0xFFF6F8F5);

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final items = context.watch<ItemProvider>();
    final recentItems = [
      ...items.allLostItems.map(
        (item) => _RecentItem(
          title: item.title,
          location: item.locationName,
          datePosted: item.datePosted,
          isLost: true,
        ),
      ),
      ...items.allFoundItems.map(
        (item) => _RecentItem(
          title: item.title,
          location: item.locationName,
          datePosted: item.datePosted,
          isLost: false,
        ),
      ),
    ]..sort((a, b) => b.datePosted.compareTo(a.datePosted));

    final firstName = user?.fullName.trim().split(' ').first;

    return Container(
      color: _paper,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final actionColumns = constraints.maxWidth >= 800 ? 4 : 2;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeCard(
                      firstName?.isNotEmpty == true ? firstName! : 'there',
                    ),
                    const SizedBox(height: 18),
                    _buildStatistics(
                      lostCount: items.allLostItems.length,
                      foundCount: items.allFoundItems.length,
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeading(
                      title: 'How can we help?',
                      subtitle: 'Small actions can make someone’s day.',
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: actionColumns,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.24,
                      children: [
                        _buildActionCard(
                          icon: Icons.search_rounded,
                          title: 'I lost something',
                          subtitle: 'Report a missing item',
                          color: const Color(0xFFB85E47),
                          tint: const Color(0xFFFFEEE8),
                          onTap: () =>
                              _openScreen(context, const AddLostItemScreen()),
                        ),
                        _buildActionCard(
                          icon: Icons.volunteer_activism_rounded,
                          title: 'I found something',
                          subtitle: 'Help it get home',
                          color: _green,
                          tint: const Color(0xFFE4F3EC),
                          onTap: () =>
                              _openScreen(context, const AddFoundItemScreen()),
                        ),
                        _buildActionCard(
                          icon: Icons.travel_explore_rounded,
                          title: 'Browse lost items',
                          subtitle: 'See what’s missing',
                          color: const Color(0xFF9A6B21),
                          tint: const Color(0xFFFBF1DC),
                          onTap: () =>
                              _openScreen(context, const LostItemsScreen()),
                        ),
                        _buildActionCard(
                          icon: Icons.inventory_2_outlined,
                          title: 'Browse found items',
                          subtitle: 'Find a familiar item',
                          color: const Color(0xFF4E6DA2),
                          tint: const Color(0xFFEAF0FB),
                          onTap: () =>
                              _openScreen(context, const FoundItemsScreen()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    _buildSectionHeading(
                      title: 'Recently posted',
                      subtitle: 'The latest items shared by your community.',
                    ),
                    const SizedBox(height: 14),
                    if (recentItems.isEmpty)
                      _buildEmptyState()
                    else
                      ...recentItems.take(4).map(_buildRecentItem),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(String firstName) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF174F43), Color(0xFF247B61)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.20),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -42,
            top: -54,
            child: Container(
              width: 166,
              height: 166,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withValues(alpha: 0.10), width: 24),
              ),
            ),
          ),
          Positioned(
            right: 29,
            bottom: -55,
            child: Container(
              width: 105,
              height: 105,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(23),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'A KINDER COMMUNITY',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Good to see you,\n$firstName.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 29,
                    height: 1.13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.6,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  'Let’s help lost things find their way home.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.82),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    const Icon(Icons.favorite_rounded, color: Color(0xFFFFD88A), size: 17),
                    const SizedBox(width: 7),
                    Text(
                      'Every little bit of kindness counts',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.92),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics({required int lostCount, required int foundCount}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE9EEEA)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStat(
              count: '$lostCount',
              label: 'items reported lost',
              color: const Color(0xFFB85E47),
              icon: Icons.search_rounded,
            ),
          ),
          Container(width: 1, height: 42, color: const Color(0xFFE9EEEA)),
          Expanded(
            child: _buildStat(
              count: '$foundCount',
              label: 'items found',
              color: _green,
              icon: Icons.volunteer_activism_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat({
    required String count,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 39,
          height: 39,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              count,
              style: const TextStyle(
                color: _ink,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(color: _muted, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionHeading({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: _ink,
            fontSize: 20,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: const TextStyle(color: _muted, fontSize: 12)),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color tint,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE9EEEA)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: _ink,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(color: _muted, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentItem(_RecentItem item) {
    final color = item.isLost ? const Color(0xFFB85E47) : _green;
    final tint = item.isLost ? const Color(0xFFFFEEE8) : const Color(0xFFE4F3EC);
    final kind = item.isLost ? 'LOST' : 'FOUND';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEEA)),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              item.isLost ? Icons.search_rounded : Icons.volunteer_activism_rounded,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, size: 13, color: _muted),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        item.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _muted, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              kind,
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 26),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE9EEEA)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.waving_hand_rounded, color: Color(0xFF9A6B21), size: 30),
          SizedBox(height: 10),
          Text(
            'A fresh start for the community',
            style: TextStyle(color: _ink, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Newly shared items will show up here.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _openScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

class _RecentItem {
  const _RecentItem({
    required this.title,
    required this.location,
    required this.datePosted,
    required this.isLost,
  });

  final String title;
  final String location;
  final DateTime datePosted;
  final bool isLost;
}
