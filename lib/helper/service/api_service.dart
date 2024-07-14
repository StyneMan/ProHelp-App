import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_interceptor/http/http.dart';
import 'package:prohelp_app/helper/constants/constants.dart';
import 'package:prohelp_app/helper/interceptors/api_interceptors.dart';
import 'package:prohelp_app/helper/interceptors/token_retry.dart';
import 'package:prohelp_app/helper/state/state_manager.dart';

class APIService {
  final _controller = Get.find<StateController>();
  http.Client client = InterceptedClient.build(
    interceptors: [
      MyApiInterceptor(),
    ],
    retryPolicy: ExpiredTokenRetryPolicy(),
  );

  APIService() {
    // init();
  }

  // Define a StreamController
  final StreamController<http.Response> _streamController =
      StreamController<http.Response>();

  Future<http.Response> signup(Map body) async {
    return await http.post(
      Uri.parse('${Constants.baseURL}/api/register'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> login(Map body) async {
    return await http.post(
      Uri.parse('${Constants.baseURL}/api/login'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> forgotPass(Map body) async {
    return await http.post(
      Uri.parse('${Constants.baseURL}/api/forgotPassword'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> resetPass(Map body) async {
    return await http.put(
      Uri.parse('${Constants.baseURL}/api/resetPassword'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> verifyOTP(Map body) async {
    return await http.get(
      Uri.parse(
          '${Constants.baseURL}/api/verifyOTP?email=${body['email']}&code=${body['code']}'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  Future<http.Response> resendOTP({var email, var type}) async {
    return await http.get(
      Uri.parse('${Constants.baseURL}/api/resendOTP?email=$email&type=$type'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  Future<http.Response> googleAuth(Map payload) async {
    return await http.post(
      Uri.parse('${Constants.baseURL}/api/auth/google/web'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> appleAuth(String token) async {
    return await http.post(
      Uri.parse('${Constants.baseURL}/api/auth/apple'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode({"token": token}),
    );
  }

  Future<http.Response> getProfile(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/user/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Stream<http.Response> getProfileStreamed({
    required String email,
    required String accessToken,
  }) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse('${Constants.baseURL}/api/user/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> getFreelancers() async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/freelancers/'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  // Stream<http.Response> getProfessionalsByCategory({var category}) async {
  //   return await client.get(
  //     Uri.parse('${Constants.baseURL}/api/freelancers/' + category),
  //     headers: {
  //       "Content-type": "application/json",
  //     },
  //   );
  // }

  // Modify your function to return a stream
  Stream<http.Response> getProfessionalsByCategoryStreamed(
      {var category}) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse('${Constants.baseURL}/api/freelancers/$category'),
        headers: {
          "Content-type": "application/json",
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Stream<http.Response> getTransactionsStreamed({
    required String email,
    required String accessToken,
  }) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse(
            '${Constants.baseURL}/api/account/transactions/byUser/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> getRecruiters(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/recruiters/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> logout(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/logout/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> updateProfile(
      {var body, var accessToken, var email}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/updateuser/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> contactSupport(
      {var body, var accessToken, var email}) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/support/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> updatePassword(Map body, String accessToken) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/resetPassword'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> likeUser(
      Map body, String accessToken, String email) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/likeUser/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> requestConnection(
      Map body, String accessToken, String email) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/connection/request/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getSavedPros(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/users/savedPros/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> getConnections(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/users/connections/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> getProfessions() async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/profession/all'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  Future<http.Response> getSearchResults(String accessToken, String key) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/search/$key'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  // Future<http.Response> initiateChat(
  //     {var accessToken, var email, var payload}) async {
  //   return await client.post(
  //     Uri.parse('${Constants.baseURL}/api/chat/initiate/$email'),
  //     headers: {
  //       "Content-type": "application/json",
  //       "Authorization": "Bearer " + accessToken,
  //     },
  //     body: jsonEncode(payload),
  //   );
  // }

  Future<http.Response> initChat(
      {var accessToken, var email, var payload}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/chat/init/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> getUsersChats({var accessToken, var email}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/chat/allChats/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> postMessage(
      {var accessToken, var email, var payload}) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/chat/message/post/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> markasRead(
      {var accessToken, var email, var payload}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/chat/message/read/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> getConversationsByChatId(
      {var accessToken, var email, var chatId}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/chat/messages/$email/$chatId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Stream<http.Response> getConversationsByChatIdStreamed(
      {required String email,
      required String accessToken,
      required String chatId}) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse('${Constants.baseURL}/api/chat/messages/$email/$chatId'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      print("My CHATES REPINSE ::: ${response.body}");
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> postReview(
      {var accessToken, var email, var payload}) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/review/create/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> deleteReview(
      {var accessToken, var email, var payload}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/review/delete/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> replyReview(
      {var accessToken, var email, var payload}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/review/reply/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  // Future<List<dynamic> getReviewsByUserIdStreamed(
  //     {var accessToken, var email, var userId}) async {
  //   final response = await client.get(
  //     Uri.parse('${Constants.baseURL}/api/review/byUser/$email?userId=$userId'),
  //     headers: {
  //       "Content-type": "application/json",
  //       "Authorization": "Bearer " + accessToken,
  //     },
  //   );
  //   if (response.statusCode == 200) {
  //     debugPrint("REVES DATA >> ${response.body}");
  //     Map<String, dynamic> map = jsonDecode(response.body);
  //     return map['data'] as List<dynamic>;
  //   } else {
  //     throw Exception('Failed to fetch data from the backend');
  //   }
  // }

  Stream<http.Response> getReviewsByUserIdStreamed({
    required String accessToken,
    required String email,
    required var userId,
  }) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse(
            '${Constants.baseURL}/api/review/byUser/$email?userId=$userId'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> postJob(
      {var accessToken, var email, var payload}) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/job/post/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> getAllJobs() async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/job/all/'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  Future<http.Response> getUserJobs(
      {var accessToken, var email, var userId}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/job/byUser/$email?userId=$userId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<List<dynamic>> getJobsByUserIdStreamed(
      {var accessToken, var email, var userId}) async {
    final response = await client.get(
      Uri.parse('${Constants.baseURL}/api/job/byUser/$email?userId=$userId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
    if (response.statusCode == 200) {
      debugPrint("MY JOBS DATA >> ${response.body}");
      Map<String, dynamic> map = jsonDecode(response.body);
      return map['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch data from the backend');
    }
  }

  Future<http.Response> deleteJob(
      {var accessToken, var email, var jobId}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/job/delete/$email?jobId=$jobId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> updateJob(
      {var accessToken, var email, var jobId, var payload}) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/job/update/$email?jobId=$jobId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> saveJob(
      Map body, String accessToken, String email) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/job/save/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> applyJob(
    Map body,
    String accessToken,
    String email,
    var jobId,
  ) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/job/apply/$email?jobId=$jobId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getSavedJobs(
      {var accessToken, var email, var userId}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/job/savedJobs/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Stream<http.Response> getSavedJobsStreamed(
      {required String accessToken, required String email, var userId}) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse('${Constants.baseURL}/api/job/savedJobs/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> getJobApplicationsByUser(
      {var accessToken, var email}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/job/applications/byUser/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> getJobApplications(
      {var accessToken, var email, var jobId}) async {
    return await client.get(
      Uri.parse(
          '${Constants.baseURL}/api/job/applications/$email?jobId=$jobId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Stream<http.Response> getJobApplicationsStreamed(
      {var accessToken, var email, var jobId}) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse(
            '${Constants.baseURL}/api/job/applications/$email?jobId=$jobId'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> getCurrentJobApplications(
      {var email, var jobId}) async {
    return await client.get(
      Uri.parse(
          '${Constants.baseURL}/api/job/applications/byUser/$email?jobId=$jobId'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  Future<http.Response> getRecommendedJobs(
      {var accessToken, var email, var profession}) async {
    return await client.get(
      Uri.parse(
          '${Constants.baseURL}/api/job/recommended/$email?profession=$profession'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> acceptJobApplication(
    Map body,
    String accessToken,
    String email,
  ) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/job/applications/accept/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> topupWallet(
    Map body,
    String accessToken,
    String email,
  ) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/wallet/topup/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> getAlerts(
      {required String accessToken,
      required String email,
      required String userId}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/alerts/byUser/$email?userId=$userId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> getBanners() async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/banners/all/'),
      headers: {
        "Content-type": "application/json",
      },
    );
  }

  Future<http.Response> getUserConnections(
      {required String accessToken, required String email}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/connection/byUser/all/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Stream<http.Response> getUserConnectionsStreamed({
    required String accessToken,
    required String email,
  }) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse('${Constants.baseURL}/api/connection/byUser/all/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      print("USER_CONNECT RESP ::: ${response.body}");
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Stream<http.Response> getUserPastConnectionsStreamed({
    required String accessToken,
    required String email,
  }) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse('${Constants.baseURL}/api/connection/past/byUser/all/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> getUserPendingReceivedConnectionsRequest(
      {required String accessToken, required String email}) async {
    return await client.get(
      Uri.parse(
          '${Constants.baseURL}/api/connection/byUser/pending-request/received/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

// Modify your function to return a stream
  Stream<http.Response> getUserPendingReceivedConnectionsRequestStream({
    required String accessToken,
    required String email,
  }) async* {
    try {
      // Fetch data and add it to the stream
      http.Response response = await client.get(
        Uri.parse(
            '${Constants.baseURL}/api/connection/byUser/pending-request/received/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
      );
      yield response; // Yield the response to the stream
    } catch (error) {
      // Handle errors by adding an error to the stream
      _streamController.addError(error);
    }
  }

  Future<http.Response> acceptConnectionRequest({
    required String accessToken,
    required String email,
    required var payload,
    required var connectionId,
  }) async {
    return await client.put(
        Uri.parse(
            '${Constants.baseURL}/api/connection/request/accept/$email/$connectionId'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> declineConnectionRequest({
    required String accessToken,
    required String email,
    required var payload,
    required var connectionId,
  }) async {
    return await client.put(
        Uri.parse(
            '${Constants.baseURL}/api/connection/request/decline/$email/$connectionId'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> cancelConnectionRequest(
      {required String accessToken,
      required String email,
      required var payload}) async {
    return await client.post(
        Uri.parse('${Constants.baseURL}/api/connection/request/decline/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> disconnectConnection({
    required String accessToken,
    required String email,
    required var payload,
    required var connectionId,
  }) async {
    return await client.post(
        Uri.parse(
            '${Constants.baseURL}/api/connection/request/disconnect/$email/$connectionId'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> reportUser({
    required String accessToken,
    required String email,
    required var payload,
  }) async {
    return await client.post(
        Uri.parse('${Constants.baseURL}/api/account/report/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> blockUser({
    required String accessToken,
    required String email,
    required var payload,
  }) async {
    return await client.post(
        Uri.parse('${Constants.baseURL}/api/account/block/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> unblockUser({
    required String accessToken,
    required String email,
    required var payload,
  }) async {
    return await client.post(
        Uri.parse('${Constants.baseURL}/api/account/unblock/$email'),
        headers: {
          "Content-type": "application/json",
          "Authorization": "Bearer " + accessToken,
        },
        body: jsonEncode(payload));
  }

  Future<http.Response> initPayment({
    required String accessToken,
    required String email,
    required String transactionType,
    required var payload,
  }) async {
    return await client.post(
      Uri.parse(
          '${Constants.baseURL}/api/payment/init/$email?transactionType=$transactionType'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> verifyPayment({
    required String accessToken,
    required String email,
    required String transactionType,
    required var payload,
  }) async {
    return await client.post(
      Uri.parse(
          '${Constants.baseURL}/api/payment/init/$email?transactionType=$transactionType'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }
}
