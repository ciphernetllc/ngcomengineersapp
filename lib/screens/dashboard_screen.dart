import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/api_service.dart';
import '../services/background_location_service.dart';
import '../theme/app_theme.dart';
import '../models/userdata.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _apiService = ApiService();
  late Future<Map<String, dynamic>> _dashboardFuture;
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    final username = Provider.of<UserProvider>(context, listen: false).username ?? '';
    _dashboardFuture = _apiService.getDashboardData(username);
    _checkServiceStatus();
  }

  Future<void> _checkServiceStatus() async {
    try {
      await BackgroundLocationService.initializeService();
    } catch (e) {
      debugPrint("Error initializing background service: $e");
    }
    final running = await FlutterBackgroundService().isRunning();
    if (mounted) {
      setState(() {
        _isServiceRunning = running;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Stack(
        children: [
          // Purple background for the top quarter of the screen
          Container(
            height: MediaQuery.of(context).size.height / 2,
            color: Colors.deepPurple,
          ),
          // Main dashboard content, positioned to overlay the background
          // Note: If you want the content to start below the purple section,
          // you can use Positioned(top: MediaQuery.of(context).size.height * 0.25, ...)
          // However, typically headers overlay such background sections.
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return SafeArea(
                child: FutureBuilder<Map<String, dynamic>>(
                  future: _dashboardFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final dashboardData = snapshot.data?['data'] ?? {};
                    final int unreadChats = dashboardData['unread_chats'] ?? 0;

                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(userProvider, unreadChats),
                          const SizedBox(height: 16), // Space between header and stats
                          Stack(
                            children: [
                              // This container provides the white background.
                              // The margin provides the space for the stats cards to overlap the purple area.
                              // A large minHeight ensures the white background extends to the bottom,
                              // even if the content is short, and the SingleChildScrollView will handle scrolling.
                              Container(
                                margin: const EdgeInsets.only(top: 100),
                                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height),
                                decoration: const BoxDecoration(
                                  color: AppTheme.backgroundColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(30),
                                    topRight: Radius.circular(30),
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  const SizedBox(height: 20),
                                  _buildStatsSectionContent(dashboardData),
                                  _buildQuickActions(unreadChats),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserProvider userProvider, int unreadChatsCount) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello,', // Adjusted for purple background
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8), // Adjusted for purple background
                    ),
              ),
              Text(
                userProvider.firstname ?? 'User',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    size: 8,
                    color: _isServiceRunning ? Colors.greenAccent : Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isServiceRunning ? 'Tracking Active' : 'Tracking Paused',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/messages'),
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: Colors.white),
                ),
                if (unreadChatsCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                      child: Text(
                        '$unreadChatsCount',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildQuickActions(int unreadChatsCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
          ),
        ),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          mainAxisSpacing: 16,
          children: [
            _buildActionItem('Chat', FontAwesomeIcons.commentDots, '/messages', badgeCount: unreadChatsCount),
            _buildActionItem('Tickets', FontAwesomeIcons.ticket, '/tickets', badgeCount: 0),
            _buildActionItem('Survey', FontAwesomeIcons.mapLocationDot, '/survey', badgeCount: 0),
            _buildActionItem('Installs', FontAwesomeIcons.tools, '/installations', badgeCount: 0),
            // _buildActionItem('Request', FontAwesomeIcons.paperPlane, '/req'),
            // _buildActionItem('Usage', FontAwesomeIcons.chartLine, '/dashboard'),
            _buildActionItem('Profile', FontAwesomeIcons.userGear, '/profile'),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildActionItem(String title, FaIconData icon, String route, {int? badgeCount}) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none, // Allows the badge to overflow
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: FaIcon(icon, color: Color(Colors.deepPurple.value), size: 20),
              ),
              if (badgeCount != null && badgeCount > 0)
                Positioned(
                  right: -5,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text('$badgeCount', style: const TextStyle(color: Colors.white, fontSize: 10), textAlign: TextAlign.center),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSectionContent(Map<String, dynamic> data) {
    // This widget now directly receives the dashboard data
        final int pendingInstalls = data['installations_pending'] ?? 0;
        final int pendingSurveys = data['surveys_pending'] ?? 0;
        final int totalFieldWork = pendingInstalls + pendingSurveys;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Text(
                'Performance Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildGroupedStatCard(title: 'My Tickets', mainValue: data['my_tickets_active_total']?.toString() ?? '0', mainLabel: 'Active', icon: FontAwesomeIcons.userCheck, color: AppTheme.primaryColor, subStats: [_buildSubStatItem('Open', data['my_tickets_open']), _buildSubStatItem('In Progress', data['my_tickets_inprogress']),]),
                  _buildGroupedStatCard(title: 'Field Work', mainValue: totalFieldWork.toString(), mainLabel: 'Pending', icon: FontAwesomeIcons.personDigging, color: Colors.teal, subStats: [_buildSubStatItem('Installs', data['installations_pending']), _buildSubStatItem('Surveys', data['surveys_pending']),]),
                  _buildGroupedStatCard(title: 'All Tickets', mainValue: data['tickets_active_total']?.toString() ?? '0', mainLabel: 'Active', icon: FontAwesomeIcons.ticket, color: Colors.blue, subStats: [_buildSubStatItem('Open', data['tickets_open']), _buildSubStatItem('High Prio', data['tickets_priority_high']),]),
                  _buildStatCard('Unread Chats', data['unread_chats'], FontAwesomeIcons.commentDots, Colors.green),
                ],
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms); // Animation remains
  }

  Widget _buildGroupedStatCard({
    required String title,
    required String mainValue,
    required String mainLabel,
    required FaIconData icon,
    required Color color,
    required List<Widget> subStats,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.secondaryColor.withValues(alpha: 0.8),
                ),
              ),
              FaIcon(icon, color: color, size: 20),
            ],
          ),
          const Spacer(),
          Text(
            mainValue,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          Text(
            mainLabel,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryColor.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12.0,
            runSpacing: 4.0,
            children: subStats,
          ),
        ],
      ),
    );
  }

  Widget _buildSubStatItem(String label, dynamic value) {
    final displayValue = value?.toString() ?? '0';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            fontSize: 11,
            color: AppTheme.secondaryColor.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          displayValue,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.secondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, dynamic value, FaIconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor.withValues(alpha: 0.8))),
            FaIcon(icon, color: color, size: 20),
          ]),
          Text(value?.toString() ?? '0', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.secondaryColor.withValues(alpha: 0.4),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.support_agent), label: 'Support'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tasks'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}
