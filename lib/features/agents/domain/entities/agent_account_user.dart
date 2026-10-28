/// An agent account as its manager sees it: a lead agent's staff agent (`/agent-staff`), or — in
/// the owner's screens — a lead agent (`/lead-agents`, which also sends its store and counts).
class AgentAccountUser {
  const AgentAccountUser({
    required this.id,
    required this.phone,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.createdAt,
    this.storeId,
    this.storeName,
    this.staffCount,
    this.pendingCount,
  });

  final String id;
  final String phone;
  final String firstName;
  final String lastName;
  final bool isActive;
  final DateTime createdAt;

  /// Lead agents only: the owner's store its goods come from.
  final String? storeId;
  final String? storeName;
  final int? staffCount;

  /// Lead agents only: payment/return requests waiting for the owner.
  final int? pendingCount;

  String get fullName => '$firstName $lastName'.trim();
}

/// Mirrors `CreateAgentAccountDto` / `CreateLeadAgentDto` (the latter adds [storeId]).
class CreateAgentAccountParams {
  const CreateAgentAccountParams({
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.password,
    this.storeId,
  });

  final String firstName;
  final String lastName;
  final String phone;
  final String password;
  final String? storeId;

  Map<String, dynamic> toRequestBody() => {
    'firstName': firstName,
    'lastName': lastName,
    'phone': phone,
    'password': password,
    if (storeId != null) 'storeId': storeId,
  };
}

/// Mirrors `UpdateAgentAccountDto` / `UpdateLeadAgentDto`.
class UpdateAgentAccountParams {
  const UpdateAgentAccountParams({this.firstName, this.lastName, this.phone, this.storeId});

  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? storeId;

  Map<String, dynamic> toRequestBody() => {
    if (firstName != null) 'firstName': firstName,
    if (lastName != null) 'lastName': lastName,
    if (phone != null) 'phone': phone,
    if (storeId != null) 'storeId': storeId,
  };
}
