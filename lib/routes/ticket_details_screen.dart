import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
  String? _selectedDepartmentRole;
  bool _isCardExpanded = false;

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: cleanPhone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch phone call to $phoneNumber')),
        );
      }
    }
  }

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

    if (_selectedDepartmentRole == null || _selectedDepartmentRole!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a department role first before adding a comment.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSending = true);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final result = await ApiService().addMessageToTicket(
        widget.ticketId,
        userProvider.username ?? '',
        _replyController.text.trim(),
        _selectedDepartmentRole!,
      );
      
      if (mounted && (result['status'] == true || result['status'] == 'success' || result['operation_status'] == 'success')) {
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
          final activeUsers = (snapshot.data!['active_on_tickets'] as List<dynamic>?)?.whereType<Map<String, dynamic>>().toList() ?? [];
          final rawRoles = snapshot.data!['departmentrole'] as List<dynamic>? ?? [];

          final List<String> departmentRoles = rawRoles.map((e) {
            if (e is Map) {
              return (e['name'] ?? e['role'] ?? e['roleid'] ?? e['id'] ?? '').toString();
            }
            return e.toString();
          }).where((s) => s.trim().isNotEmpty).toList();

          if (_selectedDepartmentRole != null &&
              _selectedDepartmentRole!.isNotEmpty &&
              !departmentRoles.contains(_selectedDepartmentRole)) {
            departmentRoles.insert(0, _selectedDepartmentRole!);
          }

          final currentUser = Provider.of<UserProvider>(context, listen: false).username ?? '';

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  itemCount: messages.isEmpty ? 2 : messages.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _buildTicketInfoCard(ticket, activeUsers);
                    }
                    if (messages.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Center(
                          child: Text(
                            'No messages for this ticket yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    final message = messages[index - 1];
                    return _buildMessageBubble(message, currentUser);
                  },
                ),
              ),
              _buildReplyBar(departmentRoles),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTicketInfoCard(Map<String, dynamic> ticket, List<Map<String, dynamic>> activeUsers) {
    final customer = ticket['customer'] as Map<String, dynamic>? ?? {};
    final status = ticket['ticket_status']?.toString().toUpperCase() ?? 'UNKNOWN';
    final customerName = '${customer['firstname'] ?? ''} ${customer['lastname'] ?? ticket['customer_email'] ?? 'N/A'}'.trim();
    final customerPhone = ticket['customer_phone']?.toString() ?? customer['phone']?.toString() ?? '';
    final customerAddress = ticket['customer_address']?.toString() ?? 'N/A';
    final priority = ticket['priority']?.toString().toUpperCase() ?? 'NORMAL';
    final assignedRole = ticket['assigned_role']?.toString() ?? 'Unassigned';
    final assignedTo = ticket['assigned_to']?.toString() ?? 'None';
    final customerNote = ticket['customer_note']?.toString();
    final openDate = ticket['ticket_open_date'] != null
        ? DateFormat('MMM d, yyyy h:mm a').format(DateTime.parse(ticket['ticket_open_date']))
        : 'N/A';

    Color statusColor;
    switch (status) {
      case 'OPEN': statusColor = Colors.blue; break;
      case 'INPROGRESS': statusColor = Colors.orange; break;
      case 'CLOSED': statusColor = Colors.green; break;
      default: statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Ticket #${widget.ticketId}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(_isCardExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                  onPressed: () => setState(() => _isCardExpanded = !_isCardExpanded),
                ),
              ],
            ),
          ),

          // Active Staff Bar (if any staff is active on ticket)
          if (activeUsers.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              color: Colors.green.withOpacity(0.08),
              child: Row(
                children: [
                  const Icon(Icons.circle, color: Colors.green, size: 8),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Active Staff: ${activeUsers.map((u) => u['username'] ?? u['firstname'] ?? 'User').join(', ')}',
                      style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          // Primary info (Always visible)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoRow(Icons.person_outline, 'Customer', customerName.isNotEmpty ? customerName : 'N/A'),
                ),
                if (customerPhone.isNotEmpty)
                  InkWell(
                    onTap: () => _makePhoneCall(customerPhone),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, size: 14, color: AppTheme.primaryColor),
                          SizedBox(width: 4),
                          Text('Call', style: TextStyle(fontSize: 12, color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Expanded Content
          if (_isCardExpanded) ...[
            const Divider(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.phone_outlined, 'Phone', customerPhone.isNotEmpty ? customerPhone : 'N/A'),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.location_on_outlined, 'Address', customerAddress),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.badge_outlined, 'Assigned Role', assignedRole),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.person_pin_outlined, 'Assigned User', assignedTo),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.priority_high, 'Priority', priority),
                  const SizedBox(height: 6),
                  _buildInfoRow(Icons.calendar_today_outlined, 'Opened Date', openDate),
                  if (customerNote != null && customerNote.trim().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer Note:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.secondaryColor.withOpacity(0.8))),
                          const SizedBox(height: 4),
                          Text(customerNote, style: const TextStyle(fontSize: 12, color: AppTheme.secondaryColor)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
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

  Widget _buildReplyBar(List<String> departmentRoles) {
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 2, bottom: 6),
              child: Row(
                children: [
                  Icon(Icons.swap_horiz_rounded, size: 16, color: AppTheme.primaryColor),
                  SizedBox(width: 6),
                  Text(
                    'Reassign / Escalation Department Role *',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.secondaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDepartmentRole == null
                      ? Colors.orange.withOpacity(0.8)
                      : AppTheme.primaryColor.withOpacity(0.4),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: (departmentRoles.contains(_selectedDepartmentRole))
                      ? _selectedDepartmentRole
                      : null,
                  hint: Row(
                    children: [
                      const Icon(Icons.touch_app_outlined, size: 18, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'Choose department role to forward ticket...',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.secondaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  icon: const Icon(Icons.arrow_drop_down),
                  items: departmentRoles.map((role) {
                    return DropdownMenuItem<String>(
                      value: role,
                      child: Row(
                        children: [
                          const Icon(Icons.group_outlined, size: 18, color: AppTheme.primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            role,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedDepartmentRole = val;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
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
          ],
        ),
      ),
    );
  }
}