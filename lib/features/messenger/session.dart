class Session {
  final List<String> members;
  final DateTime updatedAt;

  Session({required this.members, required this.updatedAt});

  List<String> membersExclude(String userId) {
    return members.where((id) => id != userId).toList();
  }

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      members: [...json['members']],
      updatedAt: (json['updatedAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "members": members,
      "updatedAt": updatedAt,
    };
  }
}
