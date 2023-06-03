import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';
import 'package:prohelp_app/components/inputfield/city_dropdown.dart';
import 'package:prohelp_app/components/inputfield/customdropdown.dart';
import 'package:prohelp_app/components/inputfield/state_dropdown.dart';
import 'package:prohelp_app/components/inputfield/textfield.dart';
import 'package:prohelp_app/components/text_components.dart';
import 'package:prohelp_app/data/state/statesAndCities.dart';
import 'package:prohelp_app/helper/preference/preference_manager.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

typedef void InitCallback(Map data);

class AddJobFormStep1 extends StatefulWidget {
  final PreferenceManager manager;
  final InitCallback onStep1Completed;
  const AddJobFormStep1({
    Key? key,
    required this.manager,
    required this.onStep1Completed,
  }) : super(key: key);

  @override
  State<AddJobFormStep1> createState() => _AddJobFormStep1State();
}

class _AddJobFormStep1State extends State<AddJobFormStep1> {
  final _jobTitleController = TextEditingController();
  final _jobCompanyController = TextEditingController();

  final _controller = Get.find<StateController>();

  String _selectedWorkplace = "", _selectedCountry = "", _selectedJobType = "";
  String _selectedState = "Abia";
  String _selectedCity = "Select City";
  List<String> _cities = [];

  void _onWorkplaceSelected(String val) {
    setState(() {
      _selectedWorkplace = val;
    });
    widget.onStep1Completed({
      "jobTitle": _jobTitleController.text,
      "workplaceType": val,
      "city": _selectedCity,
      "state": _selectedState,
      "country": _selectedCountry,
      "company": _jobCompanyController.text,
      "jobType": _selectedJobType
    });
  }

  void _onCountrySelected(String val) {
    setState(() {
      _selectedCountry = val;
    });
    widget.onStep1Completed({
      "jobTitle": _jobTitleController.text,
      "workplaceType": _selectedWorkplace,
      "city": _selectedCity,
      "state": _selectedState,
      "country": val,
      "company": _jobCompanyController.text,
      "jobType": _selectedJobType
    });
  }

  void _onStateSelected(String val) {
    setState(() {
      _cities = [];
    });
    _onCitySelected("Select city");
    _selectedState = val;
    var selector = stateCities.where((element) => element['state'] == val);
    setState(() {
      _cities = selector.first['cities'] as List<String>;
    });

    widget.onStep1Completed({
      "jobTitle": _jobTitleController.text,
      "workplaceType": _selectedWorkplace,
      "city": _selectedCity,
      "state": val,
      "country": _selectedCountry,
      "company": _jobCompanyController.text,
      "jobType": _selectedJobType
    });
  }

  void _onCitySelected(String val) {
    setState(() {
      _selectedCity = val;
    });

    widget.onStep1Completed({
      "jobTitle": _jobTitleController.text,
      "workplaceType": _selectedWorkplace,
      "city": val,
      "state": _selectedState,
      "country": _selectedCountry,
      "company": _jobCompanyController.text,
      "jobType": _selectedJobType
    });
  }

  void _onJobTypeSelected(String val) {
    setState(() {
      _selectedJobType = val;
    });

    widget.onStep1Completed({
      "jobTitle": _jobTitleController.text,
      "workplaceType": _selectedWorkplace,
      "city": _selectedCity,
      "state": _selectedState,
      "country": _selectedCountry,
      "company": _jobCompanyController.text,
      "jobType": val
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _jobTitleController.text = _controller.jobTitle.value;
      _jobCompanyController.text = _controller.jobCompany.value;
      _selectedCity = _controller.jobCity.value;
      _selectedState = _controller.jobState.value;
      _selectedCountry = _controller.jobCountry.value;
      _selectedJobType = _controller.jobType.value;
      _selectedWorkplace = _controller.workplaceType.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          TextPoppins(
            text: "Tell us who you want to hire",
            fontSize: 21,
            fontWeight: FontWeight.w500,
            align: TextAlign.center,
          ),
          const SizedBox(
            height: 21.0,
          ),
          CustomTextField(
            hintText: "Job title",
            onChanged: (val) {
              widget.onStep1Completed({
                "jobTitle": val,
                "workplaceType": _selectedWorkplace,
                "city": _selectedCity,
                "state": _selectedState,
                "country": _selectedCountry,
                "company": _jobCompanyController.text,
                "jobType": _selectedJobType
              });
            },
            controller: _jobTitleController,
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "Job title is required";
              }
              return null;
            },
            inputType: TextInputType.text,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomTextField(
            hintText: "Company",
            onChanged: (val) {
              widget.onStep1Completed({
                "jobTitle": _jobTitleController.text,
                "workplaceType": _selectedWorkplace,
                "city": _selectedCity,
                "state": _selectedState,
                "country": _selectedCountry,
                "company": val,
                "jobType": _selectedJobType
              });
            },
            controller: _jobCompanyController,
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "Company is required";
              }
              return null;
            },
            inputType: TextInputType.text,
            capitalization: TextCapitalization.words,
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomDropdown(
            onSelected: _onJobTypeSelected,
            hint: "Select job type",
            items: const ["Full-time", "Part-time", "Contract", "Volunteer"],
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "Job type is required";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomDropdown(
            onSelected: _onWorkplaceSelected,
            hint: "Select workplace type",
            items: const ['On-site', 'Remote', 'Hybrid'],
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "Workplace type is required";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          CustomDropdown(
            onSelected: _onCountrySelected,
            hint: "Select country",
            items: const ['Nigeria'],
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "Country is required";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          StateCustomDropdown(
            onSelected: _onStateSelected,
            hint: "Select state",
            items: stateCities,
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "State is required";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          CityCustomDropdown(
            onSelected: _onCitySelected,
            hint: _selectedCity,
            items: _cities,
            validator: (val) {
              if (val.toString().isEmpty || val == null) {
                return "City is required";
              }
              return null;
            },
          ),
          const SizedBox(
            height: 16.0,
          ),
          
        ],
      ),
    );
  }
}
