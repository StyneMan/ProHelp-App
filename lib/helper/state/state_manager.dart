import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prohelp_app/helper/service/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';
import '../preference/preference_manager.dart';

class StateController extends GetxController {
  Dao? myDao;

  StateController({this.myDao});

  PreferenceManager? manager;

  var isAppClosed = false;
  var isLoading = false.obs;
  var isAuthenticated = false.obs;
  var hideNavbar = false.obs;
  var showPlan = false.obs;
  var hasInternetAccess = true.obs;

  var allProfessions = [].obs;

  var currentUser = FirebaseAuth.instance.currentUser;
  var croppedPic = "".obs;
  var customSearchBar = [].obs;

  //Skills Management
  var shouldAddSkills = false.obs;

  // var tabController = PersistentTabController(initialIndex: 0);

  //Control Experience/Education navigation
  var shouldExitExpEdu = false.obs;

  var productsData = "".obs;

  // var onboardingIndex = 0.obs;

  var userData = {}.obs;
  var searchData = [].obs;
  var freelancers = [].obs;
  var recruiters = [].obs;
  var conversationData = {}.obs;
  var currentConversation = [].obs;
  var isConversationLoading = true.obs;
  var myChats = [].obs;
  var currentMessages = [].obs;
  var selectedConversation = {}.obs;
  var myJobs = [].obs;
  var myJobsApplied = [].obs;
  var savedJobs = [].obs;
  var allJobs = [].obs;

  // ****** ALL Clearable Jobs Data ******
  var jobQuestions = [].obs;
  var jobRequirements = [].obs;
  var currentJobStep = 0.obs;
  var jobTitle = "".obs;
  var jobCompany = "".obs;
  var jobType = "".obs;
  var workplaceType = "".obs;
  var jobState = "".obs;
  var jobCity = "".obs;
  var jobCountry = "".obs;
  var jobDescription = "".obs;
  var jobMinQualification = "".obs;

  // ****** ALL Clearable Job Application Data ******
  // var resumee;
  var applicantScreeningAnswers = [].obs;
  var currentApplicationStep = 0.obs;
  var applicationEmail = "".obs;
  var applicationPhone = "".obs;

  // ****** ALL Clearable State Data ******
  var pickedDocuments = [].obs;
  var documentsModel = [].obs;
  var languagesSpoken = [].obs;
  var languagesSpeakWrite = [].obs;
  var accountType = "Boy".obs;
  var currentProfileStep = 0.obs;
  var registrationEmail = "".obs;
  var registrationPhone = "".obs;

  // ****** PROFILE SETUP STEP ONE *******
  var firstname = "".obs;
  var middlename = "".obs;
  var lastname = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var address = "".obs;
  var gender = "".obs;
  var state = "".obs;
  var maritalStatus = "".obs;
  var dob = "".obs;
  var experience = "".obs;
  var city = "".obs;
  var country = "".obs;
  var profession = "".obs;

  // ****** PROFILE SETUP STEP TWO *******
  var nokName = "".obs;
  var nokEmail = "".obs;
  var nokPhone = "".obs;
  var nokAddress = "".obs;
  var nokRelationship = "".obs;

  // ****** PROFILE SETUP STEP THREE *******
  var school = "".obs;
  var degree = "".obs;
  var fieldStudy = "".obs;
  var dateGraduated = "".obs;

  ScrollController transactionsScrollController = ScrollController();
  ScrollController messagesScrollController = ScrollController();

  var accessToken = "".obs;
  String _token = "";
  RxString dbItem = 'Awaiting data'.obs;

  final Connectivity _connectivity = Connectivity();

  Future<void> initDao() async {
    // instantiate Dao only if null (i.e. not supplied in constructor)
    myDao = await Dao.createAsync();
    dbItem.value = myDao!.dbValue;
  }

  _init() async {
    try {
      final response = await APIService().getProfessions();
      debugPrint("RESPONSI UOT ==>> ${response.body}");
      Map<String, dynamic> map = jsonDecode(response.body);
      debugPrint("RESPONS  ==>> ${map['docs']}");
      allProfessions.value = map['docs'];
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onInit() async {
    super.onInit();
    initDao();

    final _prefs = await SharedPreferences.getInstance();
    var user = _prefs.getString("user") ?? "{}";
    var _token = _prefs.getString("accessToken") ?? "";
    Map<String, dynamic> map = jsonDecode(user);
    // debugDebugPrintdebugPrint("US EMIA >> ${map['email']}");

    _init();

    if (_token.isNotEmpty) {
      //Get User Profile
      APIService().getProfile(_token, map['email']).then((value) {
        // debugDebugPrintdebugPrint("STATE GET PROFILE >>> ${value.body}");
        Map<String, dynamic> data = jsonDecode(value.body);
        userData.value = data['data'];
        _prefs.setString("user", jsonEncode(data['data']));

        //Update preference here
      }).catchError((onError) {
        debugPrint("STATE GET PROFILE ERROR >>> $onError");
        if (onError.toString().contains("rk is unreachable")) {
          hasInternetAccess.value = false;
        }
      });

      if (_token.isNotEmpty) {
        //Get User Profile
        APIService()
            .getUsersChats(accessToken: _token, email: map['email'])
            .then((value) {
          debugPrint("STATE GET CHATS >>> ${value.body}");
          Map<String, dynamic> data = jsonDecode(value.body);
          myChats.value = data['data'];
          // _prefs.setString("user", jsonEncode(data['data']));

          //Update preference here
        }).catchError((onError) {
          debugPrint("STATE GET MYCHATS ERROR>>> $onError");
          if (onError.toString().contains("rk is unreachable")) {
            hasInternetAccess.value = false;
          }
        });

        // if (map['accountType'] != "freelancer") {
        APIService().getFreelancers().then((value) {
          debugPrint("STATE GET FREELANCERS >>> ${value.body}");
          Map<String, dynamic> data = jsonDecode(value.body);
          freelancers.value = data['docs'];
        }).catchError((onError) {
          if (onError.toString().contains("rk is unreachable")) {
            hasInternetAccess.value = false;
          }
          debugPrint("STATE GET freelancer ERROR >>> $onError");
        });

        APIService().getAllJobs().then((value) {
          debugPrint("STATE GET JOBS >>> ${value.body}");
          Map<String, dynamic> data = jsonDecode(value.body);
          allJobs.value = data['docs'];
        }).catchError((onError) {
          debugPrint("STATE GET jobs ERROR >>> $onError");
          if (onError.toString().contains("rk is unreachable")) {
            hasInternetAccess.value = false;
          }
        });

        // myJobs.value = [];

        final myJobsResp = await APIService().getUserJobs(
          accessToken: _token,
          email: map['email'],
          userId: map['id'],
        );

        debugPrint("MY JOBS RESPONSE >> ${myJobsResp.body}");

        if (myJobsResp.statusCode == 200) {
          Map<String, dynamic> jobMap = jsonDecode(myJobsResp.body);
          myJobs.value = jobMap['docs'];
        }
      }
    }
  }

  void _updateConnectionStatus(ConnectivityResult connectivityResult) {
    if (connectivityResult == ConnectivityResult.none) {
      Get.rawSnackbar(
          messageText: const Text('PLEASE CONNECT TO THE INTERNET',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          isDismissible: false,
          duration: const Duration(days: 1),
          backgroundColor: Colors.red[400]!,
          icon: const Icon(
            Icons.wifi_off,
            color: Colors.white,
            size: 35,
          ),
          margin: EdgeInsets.zero,
          snackStyle: SnackStyle.GROUNDED);
    } else {
      if (Get.isSnackbarOpen) {
        Get.closeCurrentSnackbar();
      }
    }
  }

  Widget currentScreen = const SizedBox();

  var currentPage = "Home";
  List<String> pageKeys = [
    "Home",
    "Categories",
    "Promos",
    "Services",
    "Account"
  ];
  Map<String, GlobalKey<NavigatorState>> navigatorKeys = {
    "Home": GlobalKey<NavigatorState>(),
    "Categories": GlobalKey<NavigatorState>(),
    "Promos": GlobalKey<NavigatorState>(),
    "Services": GlobalKey<NavigatorState>(),
    "Account": GlobalKey<NavigatorState>(),
  };

  var selectedIndex = 0.obs; //Bottom Navigation Dashboard tab

  setUserData(var value) {
    if (value != null) {
      userData.value = value;
    }
  }

  clearJobsData() {
    jobCity.value = "";
    jobState.value = "";
    jobCountry.value = "";
    jobTitle.value = "";
    jobType.value = "";
    jobCompany.value = "";
    jobDescription.value = "";
    workplaceType.value = "";
    jobQuestions.value = [];
    jobRequirements.value = [];
    jobMinQualification.value = "";
    currentJobStep.value = 0;
  }

  clearApplicationData() {
    applicationEmail.value = "";
    applicationPhone.value = "";
    currentApplicationStep.value = 0;
  }

  clearTempProfile() {
    dateGraduated.value = "";
    fieldStudy.value = "";
    degree.value = "";
    school.value = "";
    nokRelationship.value = "";
    nokAddress.value = "";
    nokPhone.value = "";
    nokEmail.value = "";
    nokName.value = "";
    dob.value = "";
    address.value = "";
    gender.value = "";
    phone.value = "";
    email.value = "";
    firstname.value = "";
    middlename.value = "";
    lastname.value = "";
    profession.value = "";
    city.value = "";
    state.value = "";
    country.value = "";
    registrationPhone.value = "";
    registrationEmail.value = "";
    currentProfileStep.value = 0;
    accountType.value = "Boy";
    pickedDocuments.value = [];
  }

  setSearchData(var data) {
    searchData.value.add(data);
  }

  void setAccessToken(String token) {
    accessToken.value = token;
  }

  void setHasInternet(bool state) {
    hasInternetAccess.value = state;
  }

  void setShowPlan(bool state) {
    showPlan.value = state;
  }

  void setProductsData(String state) {
    productsData.value = state;
  }

  void jumpTo(int pos) {
    // tabController.jumpToTab(pos);
  }

  setLoading(bool state) {
    isLoading.value = state;
  }

  void resetAll() {}

  @override
  void onClose() {
    super.onClose();
    transactionsScrollController.dispose();
    messagesScrollController.dispose();
  }
}
