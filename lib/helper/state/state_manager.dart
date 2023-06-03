import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
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
  var myJobs = [].obs;
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
  var accountType = "Boy".obs;
  var currentProfileStep = 0.obs;
  var registrationEmail = "".obs;
  var registrationPhone = "".obs;

  // ****** PROFILE SETUP STEP ONE *******
  var name = "".obs;
  var email = "".obs;
  var phone = "".obs;
  var address = "".obs;
  var gender = "".obs;
  var state = "".obs;
  var dob = "".obs;
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

  _init() async {
    try {} catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void onInit() async {
    super.onInit();
    initDao();
    final _prefs = await SharedPreferences.getInstance();
    var user = _prefs.getString("user") ?? "";
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

      // if (map['accountType'] != "freelancer") {
      APIService().getFreelancers(_token, map['email']).then((value) {
        debugPrint("STATE GET FREELANCERS >>> ${value.body}");
        Map<String, dynamic> data = jsonDecode(value.body);
        freelancers.value = data['data'];
      }).catchError((onError) {
        if (onError.toString().contains("rk is unreachable")) {
          hasInternetAccess.value = false;
        }
        debugPrint("STATE GET freelancer ERROR >>> $onError");
      });

      APIService()
          .getAllJobs(accessToken: _token, email: map['email'])
          .then((value) {
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
        userId: map['_id'],
      );
      debugPrint("MY JOBS RESPONSE >> ${myJobsResp.body}");

      if (myJobsResp.statusCode == 200) {
        Map<String, dynamic> jobMap = jsonDecode(myJobsResp.body);
        myJobs.value = jobMap['data'];
      }
    }
  }

  Future<void> initDao() async {
    // instantiate Dao only if null (i.e. not supplied in constructor)
    myDao = await Dao.createAsync();
    dbItem.value = myDao!.dbValue;
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
    name.value = "";
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

  Future<bool?> _isItemAlreadyAdded(var data, var userId) async {
    bool _res = false;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc("${currentUser?.uid}")
          .get()
          .then((documentSnapshot) {
        documentSnapshot.data()!['cart'].forEach((v) {
          if ((data['id']) == v['productId']) {
            debugPrint('Added');
            _res = true;
          } else {
            debugPrint('Not Yet Added');
            _res = false;
          }
          // debugPrint("VELO: ${v['price']}");
          // cart!.add(CartModel.fromJson(v));
        });
      });
    } catch (e) {
      debugPrint(e.toString());
    }

    return _res;
  }

  Future<dynamic> addOrder(
      var cartItems, resp, userName, email, var userId) async {
    DateTime currentPhoneDate = DateTime.now(); //DateTime
    Timestamp myTimeStamp = Timestamp.fromDate(currentPhoneDate); //T

    await FirebaseFirestore.instance
        .collection("orders")
        .doc("${currentPhoneDate.microsecondsSinceEpoch}")
        .set({
      "id": currentPhoneDate.microsecondsSinceEpoch,
      "orderNo": resp['data']['reference'],
      "createdAt": myTimeStamp,
      "customerId": userId,
      "customerName": userName,
      "email": email,
      "paidAt": resp['data']['paid_at'],
      "deliveryFee": 1000,
      // "deliveryInfo": deliveryInfo,
      "paymentMethod": resp['data']['channel'],
      "status": "Pending",
      "items": [],
      "strItems": cartItems.toString(),
    });

    return cartItems?.forEach((element) async {
      // debugPrint("Hi..>>..");
      await FirebaseFirestore.instance
          .collection("users")
          .doc("$userId")
          .update({
        "orders": FieldValue.arrayUnion([
          {
            "orderNo": resp['data']['reference'],
            "name": element['name'],
            "price": element['price'],
            "image": element['image'],
            "paidAt": resp['data']['paid_at'],
            "productId": element['productId'],
            "menu": element['menu'],
            "cost": element['cost'],
            "quantity": element['quantity'],
            // "deliveryInfo": deliveryInfo,
            "paymentMethod": resp['data']['channel'],
          }
        ])
      });

      await FirebaseFirestore.instance
          .collection("products")
          .doc("${element['productId']}")
          .update({"quantity": FieldValue.increment(-element['quantity'])});

      //Add to orders collection too db
      FirebaseFirestore.instance
          .collection("orders")
          .doc("${currentPhoneDate.microsecondsSinceEpoch}")
          .update({
        "items": FieldValue.arrayUnion([
          {
            "name": element['name'],
            "price": element['price'],
            "image": element['image'],
            "productId": element['productId'],
            "menu": element['menu'],
            "cost": element['cost'],
            "quantity": element['quantity'],
          }
        ])
      });

      FirebaseFirestore.instance
          .collection("orders")
          .doc("${currentPhoneDate.microsecondsSinceEpoch}")
          .update({
        "strItems": FieldValue.arrayUnion([
          {
            "name": element['name'],
            "price": element['price'],
            "image": element['image'],
            "productId": element['productId'],
            "menu": element['menu'],
            "cost": element['cost'],
            "quantity": element['quantity'],
          }.toString()
        ])
      });
    });
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

  void setLoading(bool state) {
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
