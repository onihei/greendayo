class Article {
  final String content;
  final String signature;
  final num left;
  final num top;
  final num width;
  final DateTime createdAt;
  final String createdBy;

  bool get isPhoto {
    return content.contains('<img');
  }

  double? get rotation {
    if (!isPhoto) {
      return null;
    }
    final pattern = RegExp('<img src="(.+)" data-rotation="(.+)"');
    final matches = pattern.allMatches(content);
    if (matches.isEmpty) {
      return null;
    }
    final rotation = matches.single.group(2);
    if (rotation == null) {
      return null;
    }
    return double.parse(rotation);
  }

  Article({
    required this.content,
    required this.signature,
    required this.left,
    required this.top,
    required this.width,
    required this.createdAt,
    required this.createdBy,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      content: json['content'],
      signature: json['signature'],
      left: json['left'],
      top: json['top'],
      width: json['width'],
      createdAt: (json['createdAt'] as dynamic).toDate(),
      createdBy: json['createdBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "content": content,
      "signature": signature,
      "left": left,
      "top": top,
      "width": width,
      "createdAt": createdAt,
      "createdBy": createdBy,
    };
  }
}
