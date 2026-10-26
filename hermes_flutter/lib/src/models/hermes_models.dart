import 'package:json_annotation/json_annotation.dart';

part 'hermes_models.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PlanSnapshot {
  const PlanSnapshot({
    required this.code,
    required this.name,
    required this.monthlyContactCap,
    required this.verifiedContactsUsed,
    required this.verifiedContactsRemaining,
    required this.allowsPhone,
    required this.recipesLimit,
    required this.aiMode,
    required this.periodStart,
    required this.periodEnd,
  });

  final String code;
  final String name;
  final int monthlyContactCap;
  final int verifiedContactsUsed;
  final int verifiedContactsRemaining;
  final bool allowsPhone;
  final int recipesLimit;
  final String aiMode;
  final DateTime periodStart;
  final DateTime periodEnd;

  factory PlanSnapshot.fromJson(Map<String, dynamic> json) =>
      _$PlanSnapshotFromJson(json);
  Map<String, dynamic> toJson() => _$PlanSnapshotToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Me {
  const Me({
    required this.userId,
    required this.email,
    required this.orgId,
    required this.orgName,
    required this.plan,
  });

  final String userId;
  final String email;
  final String orgId;
  final String orgName;
  final PlanSnapshot plan;

  factory Me.fromJson(Map<String, dynamic> json) => _$MeFromJson(json);
  Map<String, dynamic> toJson() => _$MeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LeadJob {
  const LeadJob({
    required this.id,
    required this.status,
    required this.paramsJson,
    this.progressJson,
    this.error,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String status;
  final Map<String, dynamic> paramsJson;
  final Map<String, dynamic>? progressJson;
  final String? error;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isRunning => status == 'queued' || status == 'running';

  factory LeadJob.fromJson(Map<String, dynamic> json) =>
      _$LeadJobFromJson(json);
  Map<String, dynamic> toJson() => _$LeadJobToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class JobList {
  const JobList({required this.items, this.nextCursor});

  final List<LeadJob> items;
  final String? nextCursor;

  factory JobList.fromJson(Map<String, dynamic> json) =>
      _$JobListFromJson(json);
  Map<String, dynamic> toJson() => _$JobListToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Lead {
  const Lead({
    required this.id,
    required this.jobId,
    required this.apolloContactId,
    this.firstName,
    this.lastName,
    this.title,
    this.company,
    this.website,
    this.location,
    this.companySize,
    required this.verifiedEmailBool,
    required this.verifiedPhoneBool,
    this.email,
    this.phone,
    this.scoreInt,
    this.tagsJson,
    this.aiJson,
  });

  final String id;
  final String jobId;
  final String apolloContactId;
  final String? firstName;
  final String? lastName;
  final String? title;
  final String? company;
  final String? website;
  final String? location;
  final String? companySize;
  final bool verifiedEmailBool;
  final bool verifiedPhoneBool;
  final String? email;
  final String? phone;
  final int? scoreInt;
  final List<dynamic>? tagsJson;
  final Map<String, dynamic>? aiJson;

  String get name =>
      [firstName, lastName].whereType<String>().where((v) => v.isNotEmpty).join(' ');

  factory Lead.fromJson(Map<String, dynamic> json) => _$LeadFromJson(json);
  Map<String, dynamic> toJson() => _$LeadToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class LeadList {
  const LeadList({required this.items, this.nextCursor});

  final List<Lead> items;
  final String? nextCursor;

  factory LeadList.fromJson(Map<String, dynamic> json) =>
      _$LeadListFromJson(json);
  Map<String, dynamic> toJson() => _$LeadListToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.paramsJson,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final Map<String, dynamic> paramsJson;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Recipe.fromJson(Map<String, dynamic> json) => _$RecipeFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class RecipeList {
  const RecipeList({required this.items});

  final List<Recipe> items;

  factory RecipeList.fromJson(Map<String, dynamic> json) =>
      _$RecipeListFromJson(json);
  Map<String, dynamic> toJson() => _$RecipeListToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class BillingSummary {
  const BillingSummary({
    required this.plan,
    required this.renewalDate,
    this.stripeStatus,
  });

  final PlanSnapshot plan;
  final DateTime renewalDate;
  final String? stripeStatus;

  factory BillingSummary.fromJson(Map<String, dynamic> json) =>
      _$BillingSummaryFromJson(json);
  Map<String, dynamic> toJson() => _$BillingSummaryToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class Profile {
  const Profile({
    required this.userId,
    required this.orgId,
    this.company,
    this.role,
    this.geoJson,
    this.industriesJson,
    this.outreachTone,
    this.whatWeSell,
    required this.createdAt,
    required this.updatedAt,
  });

  final String userId;
  final String orgId;
  final String? company;
  final String? role;
  final Map<String, dynamic>? geoJson;
  final List<dynamic>? industriesJson;
  final String? outreachTone;
  final String? whatWeSell;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class EnterpriseLeadResponse {
  const EnterpriseLeadResponse({required this.id, required this.message});

  final String id;
  final String message;

  factory EnterpriseLeadResponse.fromJson(Map<String, dynamic> json) =>
      _$EnterpriseLeadResponseFromJson(json);
  Map<String, dynamic> toJson() => _$EnterpriseLeadResponseToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class CreateLeadJobRequest {
  const CreateLeadJobRequest({
    required this.industry,
    required this.geo,
    required this.roles,
    this.companySize,
    required this.maxContacts,
    required this.includeVerifiedEmail,
    required this.includePhone,
    this.includeAi = false,
    this.recipeName,
    this.enrich = true,
  });

  final String industry;
  final String geo;
  final List<String> roles;
  final String? companySize;
  final int maxContacts;
  final bool includeVerifiedEmail;
  final bool includePhone;
  final bool includeAi;
  final String? recipeName;
  final bool enrich;

  factory CreateLeadJobRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateLeadJobRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateLeadJobRequestToJson(this);
}
