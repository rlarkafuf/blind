import 'package:flutter_test/flutter_test.dart';
import 'package:majlis/models/post.dart';
import 'package:majlis/models/comment.dart';
import 'package:majlis/features/post_detail/utils/anonymous_mapping.dart';

void main() {
  group('Poll Logic Tests', () {
    test('Poll percent calculation works properly', () {
      final options = [
        const PollOption(id: '1', text: 'Option A', votes: 10),
        const PollOption(id: '2', text: 'Option B', votes: 30),
      ];
      final poll = Poll(id: 'poll-1', title: 'Test', options: options);

      final totalVotes = poll.options.fold(0, (sum, opt) => sum + opt.votes);
      expect(totalVotes, 40);

      final percentA = poll.options[0].votes / totalVotes;
      expect(percentA, 0.25);
    });

    test('Anonymous Mapping Logic Tests', () {
      final postAuthorNickname = 'Author-123';

      final comments = [
        Comment(
          id: '1',
          postId: 'post-1',
          companyNameSnapshot: 'Company A',
          authorNickname: 'Author-123',
          content: 'Hello',
          createdAt: DateTime.now(),
        ),
        Comment(
          id: '2',
          postId: 'post-1',
          companyNameSnapshot: 'Company B',
          authorNickname: 'Random-456',
          content: 'Hi',
          createdAt: DateTime.now(),
        ),
        Comment(
          id: '3',
          postId: 'post-1',
          companyNameSnapshot: 'Company C',
          authorNickname: 'Another-789',
          content: 'Hey',
          createdAt: DateTime.now(),
        ),
        Comment(
          id: '4',
          postId: 'post-1',
          companyNameSnapshot: 'Company B',
          authorNickname: 'Random-456',
          content: 'Hi again',
          createdAt: DateTime.now(),
        ),
      ];

      final mapping = AnonymousMappingUtils.buildAnonymousMapping(comments, postAuthorNickname);

      expect(mapping['Author-123'], '글쓴이');
      expect(mapping['Random-456'], '익명1');
      expect(mapping['Another-789'], '익명2');
    });
  });
}
