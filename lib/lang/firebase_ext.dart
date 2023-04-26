import 'package:cloud_firestore/cloud_firestore.dart';

extension DocumentSnapshotExt on DocumentSnapshot<Map<String, dynamic>> {
  dynamic getIfExists(String key) {
    if (data()?.containsKey(key) ?? false) {
      return get(key);
    }
    return null;
  }
}
