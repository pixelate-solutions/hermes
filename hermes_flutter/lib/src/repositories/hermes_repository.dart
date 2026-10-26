import 'dart:typed_data';

import '../api/api_client.dart';
import '../models/hermes_models.dart';

class HermesRepository {
  const HermesRepository(this._api);

  final ApiClient _api;

  Future<Me> me(String? token) async =>
      Me.fromJson(await _api.getJson('/me', token: token));

  Future<JobList> jobs(
    String? token, {
    int limit = 25,
    String? cursor,
    String? status,
  }) async {
    return JobList.fromJson(await _api.getJson(
      '/leads/jobs',
      token: token,
      query: {
        'limit': limit,
        'cursor': ?cursor,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    ));
  }

  Future<LeadJob> job(String? token, String id) async =>
      LeadJob.fromJson(await _api.getJson('/leads/jobs/$id', token: token));

  Future<LeadJob> createJob(String? token, CreateLeadJobRequest request) async =>
      LeadJob.fromJson(await _api.postJson(
        '/leads/jobs',
        token: token,
        body: request.toJson(),
      ));

  Future<void> cancelJob(String? token, String id) async {
    await _api.postJson('/leads/jobs/$id/cancel', token: token);
  }

  Future<LeadList> results(
    String? token, {
    int limit = 100,
    String? cursor,
    String? jobId,
    String? q,
  }) async {
    return LeadList.fromJson(await _api.getJson(
      '/leads/results',
      token: token,
      query: {
        'limit': limit,
        'cursor': ?cursor,
        'job_id': ?jobId,
        if (q != null && q.isNotEmpty) 'q': q,
      },
    ));
  }

  Future<LeadList> jobResults(String? token, String jobId) async =>
      LeadList.fromJson(await _api.getJson(
        '/leads/jobs/$jobId/results',
        token: token,
      ));

  Future<Uint8List> exportJobCsv(String? token, String jobId) =>
      _api.getBytes('/leads/jobs/$jobId/export.csv', token: token);

  Future<RecipeList> recipes(String? token) async =>
      RecipeList.fromJson(await _api.getJson('/recipes', token: token));

  Future<Recipe> createRecipe(
    String? token, {
    required String name,
    required Map<String, dynamic> paramsJson,
    String? notes,
  }) async {
    return Recipe.fromJson(await _api.postJson(
      '/recipes',
      token: token,
      body: {'name': name, 'params_json': paramsJson, 'notes': notes},
    ));
  }

  Future<String> rerunRecipe(String? token, String id) async {
    final json = await _api.postJson('/recipes/$id/rerun', token: token);
    return json['job_id'].toString();
  }

  Future<BillingSummary> billing(String? token) async =>
      BillingSummary.fromJson(
          await _api.getJson('/billing/summary', token: token));

  Future<String> checkout(String? token, String planCode, String platform) async {
    final json = await _api.postJson(
      '/billing/create-checkout-session',
      token: token,
      body: {'plan_code': planCode, 'platform': platform},
    );
    return json['checkout_url'].toString();
  }

  Future<String> billingPortal(String? token, String platform) async {
    final json = await _api.postJson(
      '/billing/portal-session',
      token: token,
      body: {'platform': platform},
    );
    return json['portal_url'].toString();
  }

  Future<Profile> profile(String? token) async =>
      Profile.fromJson(await _api.getJson('/profile', token: token));

  Future<Profile> saveProfile(String? token, Map<String, dynamic> body) async =>
      Profile.fromJson(await _api.putJson('/profile', token: token, body: body));

  Future<void> acceptTerms(String? token) async {
    await _api.postJson('/profile/accept-terms', token: token, body: {});
  }

  Future<EnterpriseLeadResponse> createEnterpriseLead({
    required String name,
    required String email,
    required String company,
    required String useCase,
    required String desiredVolume,
  }) async {
    return EnterpriseLeadResponse.fromJson(await _api.postJson(
      '/public/enterprise-lead',
      body: {
        'name': name,
        'email': email,
        'company': company,
        'use_case': useCase,
        'desired_volume': desiredVolume,
      },
    ));
  }
}
