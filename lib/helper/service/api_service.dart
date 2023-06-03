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

  Future<http.Response> getProfile(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/user/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> getFreelancers(String accessToken, String email) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/freelancers/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
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

  Future<http.Response> saveConnection(
      Map body, String accessToken, String email) async {
    return await client.put(
      Uri.parse('${Constants.baseURL}/api/connection/$email'),
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

  Future<http.Response> getSearchResults(String accessToken, String key) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/search/$key'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> googleAuth(String idToken) async {
    return await http.post(
      Uri.parse('${Constants.baseURL}/api/auth/google'),
      headers: {
        "Content-type": "application/json",
      },
      body: jsonEncode({"token": idToken}),
    );
  }

  Future<http.Response> initiateChat(
      {var accessToken, var email, var payload}) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/chat/initiate/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
      body: jsonEncode(payload),
    );
  }

  Future<http.Response> getUsersChats(
      {var accessToken, var email, var userId}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/chat/all/$email?userId=$userId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
  }

  Future<http.Response> postMessage(
      {var accessToken, var email, var payload}) async {
    return await client.post(
      Uri.parse('${Constants.baseURL}/api/chat/message/new/$email'),
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
      Uri.parse(
          '${Constants.baseURL}/api/chat/message/all/$email?chatId=$chatId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
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

  Future<List<dynamic>> getReviewsByUserIdStreamed(
      {var accessToken, var email, var userId}) async {
    final response = await client.get(
      Uri.parse('${Constants.baseURL}/api/review/byUser/$email?userId=$userId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
    if (response.statusCode == 200) {
      debugPrint("REVES DATA >> ${response.body}");
      Map<String, dynamic> map = jsonDecode(response.body);
      return map['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch data from the backend');
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

  Future<http.Response> getAllJobs({var accessToken, var email}) async {
    return await client.get(
      Uri.parse('${Constants.baseURL}/api/job/all/$email'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
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

  Future<List<dynamic>> getJobApplicationsStreamed(
      {var accessToken, var email, var jobId}) async {
    final response = await client.get(
      Uri.parse(
          '${Constants.baseURL}/api/job/applications/$email?jobId=$jobId'),
      headers: {
        "Content-type": "application/json",
        "Authorization": "Bearer " + accessToken,
      },
    );
    if (response.statusCode == 200) {
      debugPrint("MY JOB APPLICATIONS DATA >> ${response.body}");
      Map<String, dynamic> map = jsonDecode(response.body);
      return map['data'] as List<dynamic>;
    } else {
      throw Exception('Failed to fetch data from the backend');
    }
  }

  Future<http.Response> getRecommendedJobs(
      {var accessToken, var email, var userId}) async {
    return await client.get(
      Uri.parse(
          '${Constants.baseURL}/api/job/recommended/$email?userId=$userId'),
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
}
