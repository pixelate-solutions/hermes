// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hermes_models.dart';

DateTime _date(Object? value) => DateTime.parse(value as String);

Map<String, dynamic> _map(Object? value) =>
    Map<String, dynamic>.from(value as Map);

Map<String, dynamic>? _nullableMap(Object? value) =>
    value == null ? null : Map<String, dynamic>.from(value as Map);

List<dynamic>? _nullableList(Object? value) =>
    value == null ? null : List<dynamic>.from(value as List);

PlanSnapshot _$PlanSnapshotFromJson(Map<String, dynamic> json) => PlanSnapshot(
      code: json['code'] as String,
      name: json['name'] as String,
      monthlyContactCap: (json['monthly_contact_cap'] as num).toInt(),
      verifiedContactsUsed: (json['verified_contacts_used'] as num).toInt(),
      verifiedContactsRemaining:
          (json['verified_contacts_remaining'] as num).toInt(),
      allowsPhone: json['allows_phone'] as bool,
      recipesLimit: (json['recipes_limit'] as num).toInt(),
      aiMode: json['ai_mode'] as String,
      periodStart: _date(json['period_start']),
      periodEnd: _date(json['period_end']),
    );

Map<String, dynamic> _$PlanSnapshotToJson(PlanSnapshot instance) => {
      'code': instance.code,
      'name': instance.name,
      'monthly_contact_cap': instance.monthlyContactCap,
      'verified_contacts_used': instance.verifiedContactsUsed,
      'verified_contacts_remaining': instance.verifiedContactsRemaining,
      'allows_phone': instance.allowsPhone,
      'recipes_limit': instance.recipesLimit,
      'ai_mode': instance.aiMode,
      'period_start': instance.periodStart.toIso8601String(),
      'period_end': instance.periodEnd.toIso8601String(),
    };

Me _$MeFromJson(Map<String, dynamic> json) => Me(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      orgId: json['org_id'] as String,
      orgName: json['org_name'] as String,
      plan: PlanSnapshot.fromJson(_map(json['plan'])),
    );

Map<String, dynamic> _$MeToJson(Me instance) => {
      'user_id': instance.userId,
      'email': instance.email,
      'org_id': instance.orgId,
      'org_name': instance.orgName,
      'plan': instance.plan.toJson(),
    };

LeadJob _$LeadJobFromJson(Map<String, dynamic> json) => LeadJob(
      id: json['id'] as String,
      status: json['status'] as String,
      paramsJson: _map(json['params_json']),
      progressJson: _nullableMap(json['progress_json']),
      error: json['error'] as String?,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );

Map<String, dynamic> _$LeadJobToJson(LeadJob instance) => {
      'id': instance.id,
      'status': instance.status,
      'params_json': instance.paramsJson,
      'progress_json': instance.progressJson,
      'error': instance.error,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

JobList _$JobListFromJson(Map<String, dynamic> json) => JobList(
      items: (json['items'] as List<dynamic>)
          .map((e) => LeadJob.fromJson(_map(e)))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$JobListToJson(JobList instance) => {
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };

Lead _$LeadFromJson(Map<String, dynamic> json) => Lead(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      apolloContactId: json['apollo_contact_id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      title: json['title'] as String?,
      company: json['company'] as String?,
      website: json['website'] as String?,
      location: json['location'] as String?,
      companySize: json['company_size'] as String?,
      verifiedEmailBool: json['verified_email_bool'] as bool,
      verifiedPhoneBool: json['verified_phone_bool'] as bool,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      scoreInt: (json['score_int'] as num?)?.toInt(),
      tagsJson: _nullableList(json['tags_json']),
      aiJson: _nullableMap(json['ai_json']),
    );

Map<String, dynamic> _$LeadToJson(Lead instance) => {
      'id': instance.id,
      'job_id': instance.jobId,
      'apollo_contact_id': instance.apolloContactId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'title': instance.title,
      'company': instance.company,
      'website': instance.website,
      'location': instance.location,
      'company_size': instance.companySize,
      'verified_email_bool': instance.verifiedEmailBool,
      'verified_phone_bool': instance.verifiedPhoneBool,
      'email': instance.email,
      'phone': instance.phone,
      'score_int': instance.scoreInt,
      'tags_json': instance.tagsJson,
      'ai_json': instance.aiJson,
    };

LeadList _$LeadListFromJson(Map<String, dynamic> json) => LeadList(
      items: (json['items'] as List<dynamic>)
          .map((e) => Lead.fromJson(_map(e)))
          .toList(),
      nextCursor: json['next_cursor'] as String?,
    );

Map<String, dynamic> _$LeadListToJson(LeadList instance) => {
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next_cursor': instance.nextCursor,
    };

Recipe _$RecipeFromJson(Map<String, dynamic> json) => Recipe(
      id: json['id'] as String,
      name: json['name'] as String,
      paramsJson: _map(json['params_json']),
      notes: json['notes'] as String?,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );

Map<String, dynamic> _$RecipeToJson(Recipe instance) => {
      'id': instance.id,
      'name': instance.name,
      'params_json': instance.paramsJson,
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

RecipeList _$RecipeListFromJson(Map<String, dynamic> json) => RecipeList(
      items: (json['items'] as List<dynamic>)
          .map((e) => Recipe.fromJson(_map(e)))
          .toList(),
    );

Map<String, dynamic> _$RecipeListToJson(RecipeList instance) => {
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

BillingSummary _$BillingSummaryFromJson(Map<String, dynamic> json) =>
    BillingSummary(
      plan: PlanSnapshot.fromJson(_map(json['plan'])),
      renewalDate: _date(json['renewal_date']),
      stripeStatus: json['stripe_status'] as String?,
    );

Map<String, dynamic> _$BillingSummaryToJson(BillingSummary instance) => {
      'plan': instance.plan.toJson(),
      'renewal_date': instance.renewalDate.toIso8601String(),
      'stripe_status': instance.stripeStatus,
    };

Profile _$ProfileFromJson(Map<String, dynamic> json) => Profile(
      userId: json['user_id'] as String,
      orgId: json['org_id'] as String,
      company: json['company'] as String?,
      role: json['role'] as String?,
      geoJson: _nullableMap(json['geo_json']),
      industriesJson: _nullableList(json['industries_json']),
      outreachTone: json['outreach_tone'] as String?,
      whatWeSell: json['what_we_sell'] as String?,
      createdAt: _date(json['created_at']),
      updatedAt: _date(json['updated_at']),
    );

Map<String, dynamic> _$ProfileToJson(Profile instance) => {
      'user_id': instance.userId,
      'org_id': instance.orgId,
      'company': instance.company,
      'role': instance.role,
      'geo_json': instance.geoJson,
      'industries_json': instance.industriesJson,
      'outreach_tone': instance.outreachTone,
      'what_we_sell': instance.whatWeSell,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
    };

EnterpriseLeadResponse _$EnterpriseLeadResponseFromJson(
        Map<String, dynamic> json) =>
    EnterpriseLeadResponse(
      id: json['id'] as String,
      message: json['message'] as String,
    );

Map<String, dynamic> _$EnterpriseLeadResponseToJson(
        EnterpriseLeadResponse instance) =>
    {
      'id': instance.id,
      'message': instance.message,
    };

CreateLeadJobRequest _$CreateLeadJobRequestFromJson(
        Map<String, dynamic> json) =>
    CreateLeadJobRequest(
      industry: json['industry'] as String,
      geo: json['geo'] as String,
      roles:
          (json['roles'] as List<dynamic>).map((e) => e as String).toList(),
      companySize: json['company_size'] as String?,
      maxContacts: (json['max_contacts'] as num).toInt(),
      includeVerifiedEmail: json['include_verified_email'] as bool,
      includePhone: json['include_phone'] as bool,
      includeAi: json['include_ai'] as bool? ?? false,
      recipeName: json['recipe_name'] as String?,
      enrich: json['enrich'] as bool? ?? true,
    );

Map<String, dynamic> _$CreateLeadJobRequestToJson(
        CreateLeadJobRequest instance) =>
    {
      'industry': instance.industry,
      'geo': instance.geo,
      'roles': instance.roles,
      'company_size': instance.companySize,
      'max_contacts': instance.maxContacts,
      'include_verified_email': instance.includeVerifiedEmail,
      'include_phone': instance.includePhone,
      'include_ai': instance.includeAi,
      'recipe_name': instance.recipeName,
      'enrich': instance.enrich,
    };
