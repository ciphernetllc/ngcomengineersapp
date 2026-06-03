// ignore_for_file: unused_import, unused_local_variable

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../bottom_nav/bottom_nav.dart';
import '../constants.dart';
import '../forms/multi_step_form.dart';
import '../models/userdata.dart';

class Installations extends StatefulWidget {
  const Installations({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _InstallationsState createState() => _InstallationsState();
}

class _InstallationsState extends State<Installations> {
  bool isLeftActive = true;
  List<dynamic> installations = [];
  List<dynamic> filteredInstallations = [];
  bool isLoading = true;
  bool isSearchVisible = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchInstallations();
    searchController.addListener(_filterInstallations);
  }

  void toggleSwitch() {
    setState(() {
      isLeftActive = !isLeftActive;
      isLoading = true;
      fetchInstallations();
    });
  }

  Future<void> fetchInstallations() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final url = isLeftActive
        ? 'https://lan.ngcomworld.com/api/v1/installationreportreq/getpendinginstallationbyuser?username=${userProvider.username}'
        : 'https://lan.ngcomworld.com/api/v1/installationreportreq/getpendinginstallationbyuser?username=${userProvider.username}';

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-API-KEY': '${userProvider.apiKey}',
    };

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        // print('Fetched response: $responseData'); // Debugging print

        setState(() {
          installations = responseData['data'] ?? [];
          filteredInstallations = installations;
          isLoading = false;
        });
      } else {
        // print(
        //     'Failed to load Installations: ${response.statusCode}'); // Debugging print
        // print('Unexpected data format');
        setState(() {
          installations = [];
          filteredInstallations = [];
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error fetching Installations: $e'); // Debugging print
      setState(() {
        installations = [];
        filteredInstallations = [];
        isLoading = false;
      });
    }
  }

  void _filterInstallations() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredInstallations = installations.where((installation) {
        final clientName = installation['clientname']?.toLowerCase() ?? '';
        final email = installation['email']?.toLowerCase() ?? '';
        return clientName.contains(query) || email.contains(query);
      }).toList();
    });
  }

  String truncateWithEllipsis(int cutoff, String text) {
    return (text.length <= cutoff) ? text : '${text.substring(0, cutoff)}...';
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final screenWidth = mediaQuery.size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          'Installations',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
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
      backgroundColor: scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.deepPurpleAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 4,
                      color: Colors.grey.shade200,
                      offset: const Offset(5, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (!isLeftActive) toggleSwitch();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 15, horizontal: screenWidth * 0.10),
                          decoration: BoxDecoration(
                            color: isLeftActive
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            'Pending',
                            style: TextStyle(
                              color: isLeftActive ? Colors.black : Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          if (isLeftActive) toggleSwitch();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: screenWidth * 0.10,
                          ),
                          decoration: BoxDecoration(
                            color: !isLeftActive
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text(
                            'Executed',
                            style: TextStyle(
                              color:
                                  !isLeftActive ? Colors.black : Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Installations List',
                    style: TextStyle(
                        fontSize: 18,
                        color: primaryColor,
                        fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSearchVisible = !isSearchVisible;
                      });
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'search  ',
                          style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                              fontWeight: FontWeight.w400),
                        ),
                        Icon(
                          Icons.search,
                          size: 18,
                        ),
                      ],
                    ),
                  )
                ],
              ),
              Visibility(
                visible: isSearchVisible,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 10.0,
                        horizontal: 20.0,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : installations.isEmpty
                        ? const Center(
                            child: Text(
                              'No installations found.',
                              style:
                                  TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                          )
                        : filteredInstallations.isEmpty
                            ? const Center(
                                child: Text(
                                  'No search results found.',
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredInstallations.length,
                                itemBuilder: (context, int i) {
                                  final installation = filteredInstallations[i];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration:
                                                            const BoxDecoration(
                                                                color: Colors
                                                                    .deepOrange,
                                                                shape: BoxShape
                                                                    .circle),
                                                      ),
                                                      const Icon(
                                                        CupertinoIcons.wrench,
                                                        color: Colors.white,
                                                      )
                                                    ],
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        truncateWithEllipsis(
                                                          20,
                                                          installation[
                                                                  'clientname'] ??
                                                              'No Title',
                                                        ),
                                                        style: TextStyle(
                                                            fontSize: 18,
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w700),
                                                      ),
                                                      Text(
                                                        installation['email'] ??
                                                            'Unknown',
                                                        style: TextStyle(
                                                            fontSize: 15,
                                                            color: primaryColor,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
