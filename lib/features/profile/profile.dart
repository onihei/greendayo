class Profile {
  final String userId;
  final String nickname;
  final String? photoUrl;

  final String? age;
  final String? born;
  final String? job;
  final String? interesting;
  final String? book;
  final String? movie;
  final String? goal;
  final String? treasure;
  final String? text;

  Profile({
    required this.userId,
    required this.nickname,
    required this.photoUrl,
    this.age,
    this.born,
    this.job,
    this.interesting,
    this.book,
    this.movie,
    this.goal,
    this.treasure,
    this.text,
  });

  factory Profile.anonymous() {
    return Profile(userId: "anonymous", nickname: "no_name", photoUrl: null);
  }

  factory Profile.fromJson(String id, Map<String, dynamic> json) {
    return Profile(
      userId: id,
      nickname: json['nickname'],
      photoUrl: json['photoUrl'],
      age: json['age'],
      born: json['born'],
      job: json['job'],
      interesting: json['interesting'],
      book: json['book'],
      movie: json['movie'],
      goal: json['goal'],
      treasure: json['treasure'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "nickname": nickname,
      "photoUrl": photoUrl,
      "age": age,
      "born": born,
      "job": job,
      "interesting": interesting,
      "book": book,
      "movie": movie,
      "goal": goal,
      "treasure": treasure,
      "text": text,
    };
  }

  Profile copyWith({
    String? userId,
    String? nickname,
    String? photoUrl,
    String? age,
    String? born,
    String? job,
    String? interesting,
    String? book,
    String? movie,
    String? goal,
    String? treasure,
    String? text,
  }) {
    return Profile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      age: age ?? this.age,
      born: born ?? this.born,
      job: job ?? this.job,
      interesting: interesting ?? this.interesting,
      book: book ?? this.book,
      movie: movie ?? this.movie,
      goal: goal ?? this.goal,
      treasure: treasure ?? this.treasure,
      text: text ?? this.text,
    );
  }
}
