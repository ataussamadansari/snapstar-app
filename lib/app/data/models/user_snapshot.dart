class  UserSnapshot {
  final String uid;
  final String username;
  final String name;
  final String photoUrl;

  UserSnapshot({
    required this.uid,
    required this.username,
    required this.name,
    required this.photoUrl,
  });

  factory UserSnapshot.fromMap(Map<String, dynamic> map) {
    return UserSnapshot(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}