// ignore_for_file: unnecessary_import

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/userdata.dart';

class MultiStepForm extends StatefulWidget {
  final Map<String, dynamic> survey;

  const MultiStepForm({super.key, required this.survey});

  @override
  // ignore: library_private_types_in_public_api
  _MultiStepFormState createState() => _MultiStepFormState();
}

class _MultiStepFormState extends State<MultiStepForm> {
  int _currentStep = 0;

  late List<Widget> _steps;

  @override
  void initState() {
    super.initState();
    _steps = [
      Step1(survey: widget.survey),
      Step2(survey: widget.survey),
      Step3(survey: widget.survey),
      const Step4(),
    ];
  }

  void _nextStep() {
    setState(() {
      if (_currentStep < _steps.length - 1) {
        _currentStep++;
      }
    });
  }

  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: const Text(
          'Survey Execution Form',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            StepProgressIndicator(
                currentStep: _currentStep + 1, totalSteps: _steps.length),
            Expanded(
              child: IndexedStack(
                index: _currentStep,
                children: _steps,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _currentStep > 0
                      ? GestureDetector(
                          onTap: _previousStep,
                          child: Container(
                            padding: const EdgeInsets.all(17),
                            margin: const EdgeInsets.symmetric(horizontal: 25),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                // color: Colors.deepOrange,
                                color: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(
                              CupertinoIcons.arrow_left,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(),
                  _currentStep < _steps.length - 1
                      ? GestureDetector(
                          onTap: _nextStep,
                          child: Container(
                            padding: const EdgeInsets.all(17),
                            margin: const EdgeInsets.symmetric(horizontal: 25),
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                // color: Colors.deepOrange,
                                color: Colors.deepPurpleAccent,
                                borderRadius: BorderRadius.circular(50)),
                            child: const Icon(
                              CupertinoIcons.arrow_right,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
            // const SizedBox(
            //   height: 50,
            // )
          ],
        ),
      ),
    );
  }
}

class Step1 extends StatefulWidget {
  final Map<String, dynamic> survey; // Add this line

  const Step1({super.key, required this.survey});

  @override
  // ignore: library_private_types_in_public_api
  _Step1State createState() => _Step1State();
}

class _Step1State extends State<Step1> {
  String? achievable;
  String? isfibre;
  late TextEditingController sitesurveynumber;
  late TextEditingController phone;
  late TextEditingController clientname;
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with survey data
    sitesurveynumber =
        TextEditingController(text: widget.survey['sitesurveynumber']);
    phone = TextEditingController(text: widget.survey['phone']);
    clientname = TextEditingController(text: widget.survey['clientname']);
    achievable = widget.survey['achievable'];
    isfibre = widget.survey['is_fibre'];
    selectedDate = widget.survey['surveydate'] != null
        ? DateTime.parse(widget.survey['surveydate'])
        : null;
  }

  @override
  void dispose() {
    sitesurveynumber.dispose();
    phone.dispose();
    clientname.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      fillColor: Colors.grey.shade200,
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: customInputDecoration('Achievable'),
                initialValue: achievable,
                onChanged: (String? newValue) {
                  setState(() {
                    achievable = newValue;
                  });
                },
                items: <String>['YES', 'NO']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: customInputDecoration('Fibre'),
                initialValue: isfibre,
                onChanged: (String? newValue) {
                  setState(() {
                    isfibre = newValue;
                  });
                },
                items: <String>['YES', 'NO']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: sitesurveynumber,
                decoration: customInputDecoration('Survey Number'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                readOnly: true,
                decoration: customInputDecoration('Survey Date').copyWith(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                onTap: () => _selectDate(context),
                controller: TextEditingController(
                  text: selectedDate == null
                      ? ''
                      : "${selectedDate!.toLocal()}".split(' ')[0],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: clientname,
                decoration: customInputDecoration('Client Name'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: phone,
                decoration: customInputDecoration('Client Phone'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Step2 extends StatefulWidget {
  final Map<String, dynamic> survey;

  const Step2({super.key, required this.survey});

  @override
  // ignore: library_private_types_in_public_api
  _Step2State createState() => _Step2State();
}

class _Step2State extends State<Step2> {
  late TextEditingController emailController;
  late TextEditingController siteaddressController;
  String? btscoordinate;
  late TextEditingController distanceController;
  String? isamastinstalled;
  List<String> btsOptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text: widget.survey['email']);
    siteaddressController =
        TextEditingController(text: widget.survey['siteaddress']);
    distanceController = TextEditingController(text: widget.survey['distance']);
    isamastinstalled = widget.survey['isamastinstalled'];
    fetchBtsOptions();
  }

  Future<void> fetchBtsOptions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    const url =
        'https://lan.ngcomworld.com/api/v1/installationreportreq/getbasestations'; // Replace with your actual API URL

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-API-KEY': '${userProvider.apiKey}',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          btsOptions = (data['data'] as List<dynamic>)
              .map((item) => '${item['name']} - ${item['coordinates']}')
              .toList();

          btscoordinate = widget.survey['btscoordinate'] ??
              (btsOptions.isNotEmpty ? btsOptions[0] : null);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(double startLatitude, double startLongitude,
      double endLatitude, double endLongitude) {
    return Geolocator.distanceBetween(
            startLatitude, startLongitude, endLatitude, endLongitude) /
        1000; // Convert to kilometers
  }

  void _getClientsCoordinates() async {
    try {
      Position position = await _determinePosition();
      double clientLatitude = position.latitude;
      double clientLongitude = position.longitude;

      if (btscoordinate != null) {
        final coordinates = btscoordinate!.split('-').last.trim().split(',');
        double btsLatitude = double.parse(coordinates[0]);
        double btsLongitude = double.parse(coordinates[1]);

        double distance = _calculateDistance(
            clientLatitude, clientLongitude, btsLatitude, btsLongitude);
        distanceController.text = '${distance.toStringAsFixed(2)} km';
        // distanceController.text = distance.toStringAsFixed(2) + ' km';
      }
    } catch (e) {
      // print(e);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    siteaddressController.dispose();
    distanceController.dispose();
    super.dispose();
  }

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      fillColor: Colors.grey.shade200,
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: emailController,
                decoration: customInputDecoration('Email'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: siteaddressController,
                decoration: customInputDecoration('Site Address'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: customInputDecoration('Base Station'),
                      initialValue: btscoordinate,
                      onChanged: (String? newValue) {
                        setState(() {
                          btscoordinate = newValue;
                        });
                      },
                      items: btsOptions.isEmpty
                          ? []
                          : btsOptions
                              .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                      isExpanded: true,
                    ),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: _getClientsCoordinates,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                margin:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8.0),
                height: 60,
                width: screenWidth * 0.80,
                decoration: BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: const Center(
                  child: Text(
                    'Get Clients Coordinates',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: distanceController,
                decoration: customInputDecoration('Distance'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: customInputDecoration('Mast Installed'),
                initialValue: isamastinstalled,
                onChanged: (String? newValue) {
                  setState(() {
                    isamastinstalled = newValue;
                  });
                },
                items: <String>['Yes', 'No']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Step3 extends StatefulWidget {
  final Map<String, dynamic> survey;

  const Step3({super.key, required this.survey});

  @override
  // ignore: library_private_types_in_public_api
  _Step3State createState() => _Step3State();
}

class _Step3State extends State<Step3> {
  String? possibleobstaclesController;
  late TextEditingController typeofobstaclesController;
  late TextEditingController pathanalysistController;
  late TextEditingController estimatedcablelengthmetresController;
  late TextEditingController othermaterialsneededController;
  String? installationradio;
  List<String> radioOptions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    possibleobstaclesController = widget.survey['possibleobstacles'];
    typeofobstaclesController =
        TextEditingController(text: widget.survey['typeofobstacles']);
    pathanalysistController =
        TextEditingController(text: widget.survey['pathanalysis']);
    installationradio = widget.survey['installation_radio'];
    estimatedcablelengthmetresController = TextEditingController(
        text: widget.survey['estimatedcablelengthmetres']);
    othermaterialsneededController =
        TextEditingController(text: widget.survey['othermaterialsneeded']);
    fetchRadioOptions();
  }

  Future<void> fetchRadioOptions() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    // ignore: prefer_const_declarations
    final url =
        'https://lan.ngcomworld.com/api/v1/sitesurveyreq/recommendedradio'; // Replace with your actual API URL

    final headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'X-API-KEY': '${userProvider.apiKey}',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // print('Radio Options Response: $data');
        /// Log the entire response
        setState(() {
          radioOptions = (data['installation_radios'] as List<dynamic>)
              .map((item) => item['radio'] as String)
              .toList();
          isLoading = false;
        });
        // print('Radio Options Response: $radioOptions');
      } else {
        // print('Failed to load radio options');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // print('Error fetching radio options: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    typeofobstaclesController.dispose();
    pathanalysistController.dispose();
    estimatedcablelengthmetresController.dispose();
    othermaterialsneededController.dispose();
    super.dispose();
  }

  InputDecoration customInputDecoration(String hintText) {
    return InputDecoration(
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.white),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.deepPurple),
        borderRadius: BorderRadius.all(Radius.circular(9.0)),
      ),
      fillColor: Colors.grey.shade200,
      filled: true,
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.grey[500]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: DropdownButtonFormField<String>(
                decoration: customInputDecoration('Possible Obstacles'),
                initialValue: possibleobstaclesController,
                onChanged: (String? newValue) {
                  setState(() {
                    possibleobstaclesController = newValue;
                  });
                },
                items: <String>['Yes', 'No']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: typeofobstaclesController,
                decoration: customInputDecoration('Type of Obstacles'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: pathanalysistController,
                decoration: customInputDecoration('Path Analysis'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: isLoading
                  ? const CircularProgressIndicator()
                  : DropdownButtonFormField<String>(
                      decoration: customInputDecoration('Recommended Radio'),
                      initialValue: installationradio,
                      onChanged: (String? newValue) {
                        setState(() {
                          installationradio = newValue;
                        });
                      },
                      items: radioOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style:
                                const TextStyle(color: Colors.deepPurpleAccent),
                          ),
                        );
                      }).toList(),

                      // Add this part to make the dropdown scrollable
                      dropdownColor: Colors.white,
                      isExpanded: true,
                      // The below parameter defines the maximum height of the dropdown
                      menuMaxHeight: 200,
                    ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: estimatedcablelengthmetresController,
                decoration:
                    customInputDecoration('Estimated Cable Length (metres)'),
              ),
            ),
            const SizedBox(height: 15),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
              child: TextField(
                controller: othermaterialsneededController,
                decoration: customInputDecoration('Other Materials Needed'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Step4 extends StatefulWidget {
  const Step4({super.key});

  @override
  _Step4State createState() => _Step4State();
}

class _Step4State extends State<Step4> {
  File? _image1;
  File? _image2;
  File? _image3;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(int imageNumber) async {
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        switch (imageNumber) {
          case 1:
            _image1 = File(pickedImage.path);
            break;
          case 2:
            _image2 = File(pickedImage.path);
            break;
          case 3:
            _image3 = File(pickedImage.path);
            break;
        }
      });
    }
  }

  Widget _buildImageContainer(int imageNumber, File? imageFile) {
    return GestureDetector(
      onTap: () => _pickImage(imageNumber),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          border: Border.all(width: 2, color: Colors.grey),
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey[200],
        ),
        child: imageFile != null
            ? Image.file(imageFile, fit: BoxFit.cover)
            : Icon(Icons.camera_alt, color: Colors.grey[800]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildImageContainer(1, _image1),
              _buildImageContainer(2, _image2),
              _buildImageContainer(3, _image3),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => _pickImage(1),
                child: const Text('Select Image 1'),
              ),
              TextButton(
                onPressed: () => _pickImage(2),
                child: const Text('Select Image 2'),
              ),
              TextButton(
                onPressed: () => _pickImage(3),
                child: const Text('Select Image 3'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepProgressIndicator(
      {super.key, required this.currentStep, required this.totalSteps});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(height: 15),
        Container(
          padding: const EdgeInsets.all(17),
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                // strokeCap: StrokeCap.round,
                value: currentStep / totalSteps,
              ),
              Text(
                '$currentStep/$totalSteps',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
