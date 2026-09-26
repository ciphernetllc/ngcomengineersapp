// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../bottom_nav/bottom_nav.dart';
import '../constants.dart';
import '../forms/multi_step_form.dart';
import '../models/userdata.dart';
import 'ticket_details_screen.dart';
import '../theme/app_theme.dart';

class Tickets extends StatefulWidget {
  const Tickets({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TicketsState createState() => _TicketsState();
}

class _TicketsState extends State<Tickets> {
  List<dynamic> tickets = [];
  List<dynamic> filteredTickets = [];
  bool isLoading = true;
  bool isSearchVisible = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTickets();
    searchController.addListener(_filterTickets);
  }

  Future<void> fetchTickets() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final apiService = ApiService();

    // Ensure ApiService has credentials
    if (userProvider.username != null && userProvider.apiKey != null) {
      apiService.setCredentials(userProvider.username!, userProvider.apiKey!);
    }

    try {
      if (userProvider.username != null) {
        final responseData =
            await apiService.getMyTickets(userProvider.username!);
        setState(() {
          if (responseData.containsKey('tickets') && responseData['tickets'] is List) {
            tickets = List.from(responseData['tickets']);
            print('Fetched ${tickets.length} tickets');
          } else {
            tickets = [];
          }
          filteredTickets = List.from(tickets);
          isLoading = false;
        });
      } else {
        setState(() {
          tickets = [];
          filteredTickets = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        tickets = [];
        filteredTickets = [];
        isLoading = false;
      });
    }
  }

  void _filterTickets() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredTickets = tickets.where((ticket) {
        if (ticket is! Map) return false;
        final customerRaw = ticket['customer'];
        final customer = customerRaw is Map ? customerRaw : null;
        final clientName = customer != null ? '${customer['firstname'] ?? ''} ${customer['lastname'] ?? ''}'.toLowerCase() : '';
        final ticketId = ticket['ticket_id']?.toString().toLowerCase() ?? '';
        final complaintRaw = ticket['complaint'];
        final complaintMap = complaintRaw is Map ? complaintRaw : null;
        final complaint = complaintMap?['complaint']?.toString().toLowerCase() ?? '';
        return clientName.contains(query) || ticketId.contains(query) || complaint.contains(query);
      }).toList();
    });
  }

  String truncateWithEllipsis(int cutoff, String text) {
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Tickets',
          style: TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.secondaryColor,
            size: 20,
          ),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacementNamed(context, '/dashboard');
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildTicketList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search by name, ticket ID, or complaint...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildTicketList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('No tickets found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
          ],
        ),
      );
    }
    if (filteredTickets.isEmpty) {
      return Center(
        child: Text('No search results found', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: filteredTickets.length,
      itemBuilder: (context, index) {
        final ticket = filteredTickets[index];
        return _buildTicketCard(ticket);
      },
    );
  }

  Widget _buildTicketCard(dynamic ticketItem) {
    final ticket = Map<String, dynamic>.from(ticketItem as Map);
    final customerRaw = ticket['customer'];
    final customer = customerRaw is Map ? Map<String, dynamic>.from(customerRaw) : <String, dynamic>{};
    final complaintRaw = ticket['complaint'];
    final complaint = complaintRaw is Map ? Map<String, dynamic>.from(complaintRaw) : <String, dynamic>{};
    final status = ticket['ticket_status']?.toString().toUpperCase() ?? 'UNKNOWN';

    String dateStr = ticket['ticket_open_date'] ?? '';
    String formattedDate = dateStr;
    try {
      if (dateStr.isNotEmpty) {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM d, y').format(date);
      }
    } catch (e) { /* Keep original string if parsing fails */ }

    Color statusColor;
    switch (status) {
      case 'OPEN':
        statusColor = Colors.blue;
        break;
      case 'INPROGRESS':
        statusColor = Colors.orange;
        break;
      case 'CLOSED':
        statusColor = Colors.green;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TicketDetailsScreen(
              ticketId: ticket['ticket_id'] as String,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${ticket['ticket_id'] ?? 'N/A'}',
                  style: const TextStyle(color: AppTheme.secondaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              complaint['complaint'] ?? 'No Subject',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
            ),
            const SizedBox(height: 4),
            Text(
              '${customer['firstname'] ?? ''} ${customer['lastname'] ?? ''}',
              style: TextStyle(fontSize: 13, color: AppTheme.secondaryColor.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(
                      'Opened: $formattedDate',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    ),
                  ],
                ),
                const Icon(Icons.chevron_right, size: 20, color: AppTheme.secondaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
