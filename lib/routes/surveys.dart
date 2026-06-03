// ignore_for_file: unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../bottom_nav/bottom_nav.dart';
import '../constants.dart';
import '../forms/multi_step_form.dart';
import '../models/userdata.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class Surveys extends StatefulWidget {
  const Surveys({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SurveysState createState() => _SurveysState();
}

class _SurveysState extends State<Surveys> {
  bool isLeftActive = true;
  List<dynamic> surveys = [];
  List<dynamic> filteredSurveys = [];
  bool isLoading = true;
  bool isSearchVisible = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchSurveys();
    searchController.addListener(_filterSurveys);
  }

  void toggleSwitch() {
    setState(() {
      isLeftActive = !isLeftActive;
      isLoading = true;
      fetchSurveys();
    });
  }

  Future<void> fetchSurveys() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final apiService = ApiService();

    try {
      if (userProvider.username != null) {
        final Map<String, dynamic> responseData;
        if (isLeftActive) {
          print(  'userProvider.username: ${userProvider.username}'); // Debugging print
          responseData =
              await apiService.getPendingSiteSurveys(userProvider.username!);
              print(  'responseData: $responseData'); // Debugging print
        } else {
          responseData =
              await apiService.getExecutedSiteSurveys(userProvider.username!);
        }
        setState(() {
          final data = responseData['data'];
          if (data is Map && data.containsKey('site_surveys')) {
            surveys = data['site_surveys'] ?? [];
          } else {
            surveys = data is List ? data : [];
          }
          // Filter surveys where "executed" is "PENDING"
          print(  'surveys: $surveys'); // Debugging print
          var pendingSurveys = surveys
              .where((survey) => survey['executed'] == 'PENDING')
              .toList();
          // ignore: non_constant_identifier_names
          int PendingSurveyCount = pendingSurveys.length;
          filteredSurveys = surveys;
          isLoading = false;
        });
      } else {
        setState(() {
          surveys = [];
          filteredSurveys = [];
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error fetching surveys: $e'); // Debugging print
      setState(() {
        surveys = [];
        filteredSurveys = [];
        isLoading = false;
      });
    }
  }

  void _filterSurveys() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredSurveys = surveys.where((survey) {
        final clientName = survey['clientname']?.toLowerCase() ?? '';
        final email = survey['email']?.toLowerCase() ?? '';
        final phone = survey['phone']?.toLowerCase() ?? '';
        return clientName.contains(query) || email.contains(query);
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
          'Site Surveys',
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
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
      ),
      body: Column(
        children: [
          _buildTabs(),
          _buildSearchBar(),
          Expanded(child: _buildSurveyList()),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildTabItem('Pending', isLeftActive)),
          Expanded(child: _buildTabItem('Executed', !isLeftActive)),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, bool isActive) {
    return GestureDetector(
      onTap: () {
        if (!isActive) toggleSwitch();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.secondaryColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: 'Search surveys...',
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

  Widget _buildSurveyList() {
    if (isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor));
    }
    if (surveys.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No surveys found',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
            ),
          ],
        ),
      );
    }
    if (filteredSurveys.isEmpty) {
      return Center(
        child: Text(
          'No search results found',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 10, bottom: 20),
      itemCount: filteredSurveys.length,
      itemBuilder: (context, index) {
        final survey = filteredSurveys[index];
        return _buildSurveyCard(survey);
      },
    );
  }

  Widget _buildSurveyCard(Map<String, dynamic> survey) {
    String dateStr = survey['scheduledtimeforsurvey'] ?? '';
    String formattedDate = dateStr;
    try {
      if (dateStr.isNotEmpty) {
        final date = DateTime.parse(dateStr);
        formattedDate = DateFormat('MMM d, y • h:mm a').format(date);
      }
    } catch (e) {
      // Keep original string if parsing fails
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MultiStepForm(survey: survey),
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
              color: Colors.black.withOpacity(0.03),
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
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '#${survey['id']}',
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              survey['clientname'] ?? 'Unknown Client',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.secondaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    survey['siteaddress'] ?? 'No address provided',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      survey['phone'] ?? 'N/A',
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryColor.withOpacity(0.05),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right,
                      size: 20, color: AppTheme.secondaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
