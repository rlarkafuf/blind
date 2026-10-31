import '../../../models/comment.dart';

class AnonymousMappingUtils {
  static Map<String, String> buildAnonymousMapping(List<Comment> comments, String postAuthorNickname) {
    int anonCount = 1;
    final Map<String, String> mapping = {};

    void traverse(List<Comment> cList) {
      for (var c in cList) {
        if (c.authorNickname == postAuthorNickname) {
          mapping[c.authorNickname] = '글쓴이';
        } else if (!mapping.containsKey(c.authorNickname)) {
          mapping[c.authorNickname] = '익명$anonCount';
          anonCount++;
        }
        traverse(c.replies);
      }
    }

    traverse(comments);
    return mapping;
  }
}
