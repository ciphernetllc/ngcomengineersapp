import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/userdata.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class TicketDetailsScreen extends StatefulWidget {
  final String ticketId;
  const TicketDetailsScreen({super.key, required this.ticketId});

  @override
  State<TicketDetailsScreen> createState() => _TicketDetailsScreenState();
}

class _TicketDetailsScreenState extends State<TicketDetailsScreen> {
  late Future<Map<String, dynamic>> _detailsFuture;
  final _replyController = TextEditingController();
  bool _isSending = false;
  Map<String, dynamic>? _ticketData;

  @override
  void initState() {
    super.initState();
    _loadTicketDetails();
  }

  void _loadTicketDetails() {
    final apiService = ApiService();
    final future = apiService.getTicketDetails(widget.ticketId);

    future.then((data) {
      if (mounted && data['ticket'] != null) {
        setState(() {
          _ticketData = data['ticket'] as Map<String, dynamic>;
        });
      }
    });

    if (mounted) {
      setState(() {
        _detailsFuture = future;
      });
    }
  }

  Future<void> _sendReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isSending = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final result = await ApiService().addMessageToTicket(
        widget.ticketId,
        userProvider.username ?? '',
        _replyController.text.trim(),
        userProvider.role ?? 'user', // Assuming role is available in UserProvider
      );
      
      if (mounted && result['status'] == true) {
        _replyController.clear();
        // Refresh the ticket details to show the new message
        _loadTicketDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send message: ${result['message'] ?? 'Unknown error'}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Future<void> _handleCheckMst() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled. Please enable them.')),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied, we cannot request permissions.')),
        );
      }
      return;
    }


    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text("Getting your location...", style: TextStyle(color: Colors.white, fontSize: 16, decoration: TextDecoration.none)),
          ],
        ),
      ),
    );

    try {
      final position = await Geolocator.getCurrentPosition();
      print(  'User location: ${position.latitude}, ${position.longitude}');
      final result = await ApiService().checkMst(position.latitude, position.longitude);
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading

      final data = result['data'];
      final isServiceable = data['is_serviceable'] as bool;
      final message = result['message'] as String;
      
      showDialog(
        context: context,
        builder: (context) {
          final title = Text(isServiceable ? 'In Service Range' : 'Out of Service Range');
          final content = _buildMstResultContent(context, message, data);
          
          return AlertDialog(
            title: title,
            content: content,
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Dismiss loading
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to check MST: $e')));
    }
  }

  Widget _buildMstResultContent(BuildContext context, String message, Map<String, dynamic> data) {
    final isServiceable = data['is_serviceable'] as bool;

    if (isServiceable) {
      return Text(message);
    }

    final closestMst = data['closest_mst'] as Map<String, dynamic>?;
    final distance = data['distance_km'];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (closestMst != null) ...[
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Closest MST Details:',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildDialogInfoRow('Name', closestMst['name'] ?? 'N/A'),
            _buildDialogInfoRow('Estate', closestMst['estate_name'] ?? 'N/A'),
            if (distance != null)
              _buildDialogInfoRow('Distance', '${(distance as num).toStringAsFixed(2)} km'),
          ]
        ],
      ),
    );
  }

  Widget _buildDialogInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text('#${widget.ticketId}'),
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _handleCheckMst,
            child: const Text('Check Coverage'),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!['ticket'] == null) {
            return const Center(child: Text('Ticket not found.'));
          }

          final ticket = snapshot.data!['ticket'] as Map<String, dynamic>;
          final messages = (snapshot.data!['ticket_messages'] as List<dynamic>?)?.whereType<Map<String, dynamic>>().toList() ?? [];

          return Column(
            children: [
              _buildTicketInfoCard(ticket),
              Expanded(
                child: _buildChatMessages(messages),
              ),
              _buildReplyBar(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketInfoCard(Map<String, dynamic> ticket) {
    final customer = ticket['customer'] as Map<String, dynamic>? ?? {};
    final status = ticket['ticket_status']?.toString().toUpperCase() ?? 'UNKNOWN';
    Color statusColor;
    switch (status) {
      case 'OPEN': statusColor = Colors.blue; break;
      case 'INPROGRESS': statusColor = Colors.orange; break;
      case 'CLOSED': statusColor = Colors.green; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Ticket Details',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow(Icons.person_outline, 'Customer', '${customer['firstname'] ?? ''} ${customer['lastname'] ?? ticket['customer_email'] ?? 'N/A'}'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.phone_outlined, 'Phone', ticket['customer_phone'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.location_on_outlined, 'Address', ticket['customer_address'] ?? 'N/A'),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.priority_high, 'Priority', ticket['priority'] ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.secondaryColor.withOpacity(0.6)),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.secondaryColor.withOpacity(0.8)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: AppTheme.secondaryColor),
          ),
        ),
      ],
    );
  }

  Widget _buildChatMessages(List<Map<String, dynamic>> messages) {
    final currentUser = Provider.of<UserProvider>(context, listen: false).username;
    if (messages.isEmpty) {
      return const Center(child: Text('No messages for this ticket yet.'));
    }

    return ListView.builder(
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[messages.length - 1 - index];
        return _buildMessageBubble(message, currentUser ?? '');
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message, String currentUsername) {
    final bool isMe = message['username'] == currentUsername;
    final user = message['user'] as Map<String, dynamic>?;
    final senderName = user?['firstname'] ?? message['username'] ?? 'Customer';
    final messageTime = message['message_date'] != null
        ? DateFormat('MMM d, h:mm a').format(DateTime.parse(message['message_date']))
        : '';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(16).subtract(
            isMe ? const BorderRadius.only(bottomRight: Radius.circular(16)) : const BorderRadius.only(bottomLeft: Radius.circular(16)),
          ),
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              senderName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: isMe ? Colors.white.withOpacity(0.8) : AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              message['message'] ?? '',
              style: TextStyle(color: isMe ? Colors.white : AppTheme.secondaryColor),
            ),
            const SizedBox(height: 6),
            Text(
              messageTime,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white.withOpacity(0.6) : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyBar() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _replyController,
                decoration: InputDecoration(
                  hintText: 'Type a reply...',
                  fillColor: AppTheme.backgroundColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: _isSending 
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.send, color: AppTheme.primaryColor),
              onPressed: _isSending ? null : _sendReply,
            ),
          ],
        ),
      ),
    );
  }
}