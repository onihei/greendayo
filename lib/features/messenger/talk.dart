class Talk {
  final String content;
  final String sender;
  final DateTime createdAt;

  Talk({
    required this.content,
    required this.sender,
    required this.createdAt,
  });

  factory Talk.fromJson(Map<String, dynamic> json) {
    return Talk(
      content: json['content'],
      sender: json['sender'],
      createdAt: (json['createdAt'] as dynamic).toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "sender": sender,
      "createdAt": createdAt,
    };
  }
}
