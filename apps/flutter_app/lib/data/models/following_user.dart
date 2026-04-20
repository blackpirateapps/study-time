class FollowingUser {
  const FollowingUser({
    required this.uid,
    required this.displayName,
  });

  final String uid;
  final String displayName;

  static FollowingUser fromJson(Map<String, dynamic> json) {
    return FollowingUser(
      uid: json['uid'] as String,
      displayName: json['display_name'] as String,
    );
  }
}
