import 'dart:async';
import '../../../core/constants/channels.dart';
import '../../../models/anonymous_user.dart';
import '../../../models/channel.dart';
import '../../../models/comment.dart';
import '../../../models/post.dart';

abstract class FeedRepository {
  Future<List<Channel>> getChannels();
  Future<List<Post>> getPosts({String? channelId, String? companyId});
  Future<Post?> getPostById(String id);
  Future<Post> createPost({
    required String channelId,
    required String title,
    required String content,
    required AnonymousUser author,
  });
  Future<void> toggleLike(String postId);
  Future<void> votePoll(String postId, String optionId);
  Future<List<Comment>> getComments(String postId);
  Future<Comment> createComment({
    required String postId,
    String? parentId,
    required String content,
    required AnonymousUser author,
  });
}

/// Rich Mock Feed Repository with realistic UAE professional posts and comments.
class MockFeedRepository implements FeedRepository {
  final List<Channel> _channels = const [
    Channel(
      id: AppChannelIds.uaeLounge,
      name: 'UAE Lounge',
      nameAr: 'مجلس الإمارات',
      description: 'Open lounge for all verified professionals across Abu Dhabi, Dubai, and the Emirates',
      iconCode: 'chat',
      sortOrder: 1,
    ),
    Channel(
      id: AppChannelIds.companyLounge,
      name: 'Company Lounge',
      nameAr: 'مجلس الشركة',
      description: 'Private forum restricted strictly to colleagues verified under the same company domain',
      iconCode: 'domain',
      isCompanyRestricted: true,
      sortOrder: 2,
    ),
    Channel(
      id: AppChannelIds.energyNuclear,
      name: 'Energy & Nuclear',
      nameAr: 'الطاقة والنووي',
      description: 'ADNOC, ENEC Barakah Nuclear, Masdar, Clean Energy, Oil & Gas upstream/downstream',
      iconCode: 'bolt',
      sortOrder: 3,
    ),
    Channel(
      id: AppChannelIds.bankingFinance,
      name: 'Banking & Finance',
      nameAr: 'البنوك والتمويل',
      description: 'DIFC, ADGM, FAB, Emirates NBD, Sovereign Wealth Funds (ADIA/Mubadala) & Islamic Finance',
      iconCode: 'account_balance',
      sortOrder: 4,
    ),
    Channel(
      id: AppChannelIds.techAi,
      name: 'Tech & AI',
      nameAr: 'التكنولوجيا والذكاء الاصطناعي',
      description: 'Sovereign AI, Falcon LLM, Careem, Talabat, Cloud Infrastructure & Startups',
      iconCode: 'code',
      sortOrder: 5,
    ),
    Channel(
      id: AppChannelIds.realEstateLiving,
      name: 'Real Estate & Living',
      nameAr: 'العقارات والمعيشة',
      description: 'Rental rates, Ejari, Off-plan investments, Dubai Hills vs Yas Island, schooling',
      iconCode: 'apartment',
      sortOrder: 6,
    ),
    Channel(
      id: AppChannelIds.salaryVisa,
      name: 'Salary & Golden Visa',
      nameAr: 'الرواتب والتأشيرة الذهبية',
      description: 'AED 30k Golden Visa thresholds, DEWS Gratuity, Bonus multipliers, Relocation packages',
      iconCode: 'payments',
      sortOrder: 7,
    ),
    Channel(
      id: AppChannelIds.taxInvestment,
      name: 'Tax & Investment',
      nameAr: 'الضرائب والاستثمار',
      description: '9% Corporate Tax, Qualifying Free Zone Person (QFZP), DFM/ADX equities, crypto regulations',
      iconCode: 'trending_up',
      sortOrder: 8,
    ),
  ];

  late final List<Post> _posts;
  late final Map<String, List<Comment>> _comments;

  MockFeedRepository() {
    _initMockData();
  }

  void _initMockData() {
    final now = DateTime.now();

    _posts = [
      Post(
        id: 'post-1',
        channelId: AppChannelIds.salaryVisa,
        userId: 'user-adnoc-1',
        companyId: 'comp-adnoc',
        companyNameSnapshot: 'ADNOC',
        authorNickname: 'Falcon-491',
        title: 'Golden Visa under Skilled Professional category (AED 30,000 threshold) experience?',
        content:
            'Hi everyone, applying for the 10-year Golden Visa through MOHRE & ICP with ADNOC salary certificate. For those who recently got it processed in Abu Dhabi (TAMM) or Dubai (GDRFA), how long did the labor contract verification take? Also did you need an attested university degree for Level 1/2 occupational classifications?',
        viewCount: 1420,
        likeCount: 48,
        commentCount: 14,
        isLiked: false,
        isPinned: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
      ),
      Post(
        id: 'post-2',
        channelId: AppChannelIds.energyNuclear,
        userId: 'user-enec-1',
        companyId: 'comp-enec',
        companyNameSnapshot: 'ENEC (Barakah Nuclear)',
        authorNickname: 'Oryx-802',
        title: 'Barakah Nuclear Plant commercial operations & career opportunities in Al Dhafra',
        content:
            'With all 4 units producing 25% of UAE electricity demand, how is the current work-life balance for reactor ops and cyber engineers stationed in Al Dhafra / Ruwais camp? Looking to connect with fellow engineers considering the transition from traditional O&G.',
        viewCount: 980,
        likeCount: 37,
        commentCount: 9,
        isLiked: true,
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      Post(
        id: 'post-3',
        channelId: AppChannelIds.companyLounge,
        userId: 'user-adnoc-2',
        companyId: 'comp-adnoc',
        companyNameSnapshot: 'ADNOC',
        authorNickname: 'Dune-112',
        title: 'ADNOC Annual Performance Bonus multiplier expectations for 2026',
        content:
            'Internal colleagues only: considering the strong gas export revenues and downstream expansions, what multiplier range is HR signaling for Grade 15+? Anyone heard about updates on the remote work policy on Fridays?',
        viewCount: 650,
        likeCount: 29,
        commentCount: 11,
        isLiked: false,
        createdAt: now.subtract(const Duration(hours: 8)),
        updatedAt: now.subtract(const Duration(hours: 8)),
      ),
      Post(
        id: 'post-4',
        channelId: AppChannelIds.techAi,
        userId: 'user-careem-1',
        companyId: 'comp-careem',
        companyNameSnapshot: 'Careem',
        authorNickname: 'Pearl-304',
        title: 'Engineering culture in Dubai tech ecosystem: In-house vs Sovereign Cloud models',
        content:
            'Seeing massive investments in local data centers (Khazna / Core42) and LLM deployments across UAE ministries. Are other tech teams shifting to localized Sovereign AI hosting or remaining on standard AWS Bahrain / UAE regions?',
        viewCount: 1150,
        likeCount: 52,
        commentCount: 16,
        isLiked: false,
        createdAt: now.subtract(const Duration(hours: 12)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      Post(
        id: 'post-5',
        channelId: AppChannelIds.bankingFinance,
        userId: 'user-fab-1',
        companyId: 'comp-fab',
        companyNameSnapshot: 'FAB (First Abu Dhabi Bank)',
        authorNickname: 'Burj-955',
        title: 'DIFC vs ADGM: Compensation packages and hedge fund inflows',
        content:
            'Seeing a huge migration of European and Asian family offices setting up SPVs in ADGM Al Maryah Island. How do front-office VP/Director base salaries compare between DIFC Gate Village and ADGM Square?',
        viewCount: 840,
        likeCount: 41,
        commentCount: 7,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      Post(
        id: 'post-6',
        channelId: AppChannelIds.realEstateLiving,
        userId: 'user-emirates-1',
        companyId: 'comp-emirates',
        companyNameSnapshot: 'Emirates Airline',
        authorNickname: 'Ghaf-210',
        title: 'RERA Rental Index update: 15% renewal hike vs moving to Dubai Hills / Creek Harbour',
        content:
            'Landlord issued a notice based on the revised RERA calculator demanding a 15% increase in Downtown. For those commuting towards DXB Airport or Business Bay, is Dubai Hills or Dubai Creek Harbour a better quality-of-life alternative?',
        viewCount: 1320,
        likeCount: 63,
        commentCount: 22,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 1, hours: 4)),
        updatedAt: now.subtract(const Duration(days: 1, hours: 4)),
      ),
      Post(
        id: 'post-7',
        channelId: AppChannelIds.taxInvestment,
        userId: 'user-mubadala-1',
        companyId: 'comp-mubadala',
        companyNameSnapshot: 'Mubadala Investment Co.',
        authorNickname: 'Liwa-774',
        title: '9% UAE Corporate Tax audit guidelines for Qualifying Free Zone Persons',
        content:
            'For professionals managing corporate treasury or holding companies in DMCC / DIFC: FTA has updated guidelines regarding qualifying revenue and de minimis requirements. Always audit your transactions with mainland entities to ensure you preserve 0% qualifying status.',
        viewCount: 790,
        likeCount: 34,
        commentCount: 5,
        isLiked: false,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];

    _comments = {
      'post-1': [
        Comment(
          id: 'comm-1',
          postId: 'post-1',
          companyNameSnapshot: 'Emirates Airline',
          authorNickname: 'Aviation-502',
          content:
              'Did mine last month through GDRFA Dubai. Labor contract was verified within 48 hours. Degree attestation via MOFA UAE is mandatory if your title is Engineer/Manager.',
          likeCount: 12,
          isLiked: false,
          createdAt: now.subtract(const Duration(hours: 1, minutes: 40)),
          replies: [
            Comment(
              id: 'reply-1',
              postId: 'post-1',
              parentId: 'comm-1',
              companyNameSnapshot: 'ADNOC',
              authorNickname: 'Falcon-491',
              content: 'Thanks! Did you use the official digital salary certificate from HR with QR code?',
              likeCount: 4,
              isLiked: false,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 20)),
            ),
            Comment(
              id: 'reply-2',
              postId: 'post-1',
              parentId: 'comm-1',
              companyNameSnapshot: 'Emirates Airline',
              authorNickname: 'Aviation-502',
              content: 'Yes, digital QR certificate from HR was accepted instantly without physical stamping.',
              likeCount: 6,
              isLiked: false,
              createdAt: now.subtract(const Duration(hours: 1, minutes: 5)),
            ),
          ],
        ),
        Comment(
          id: 'comm-2',
          postId: 'post-1',
          companyNameSnapshot: 'FAB (First Abu Dhabi Bank)',
          authorNickname: 'Finance-118',
          content:
              'In Abu Dhabi via TAMM it took 4 working days total. Make sure bank statements for the last 6 months reflect the 30k+ salary transfer matching WPS.',
          likeCount: 8,
          isLiked: true,
          createdAt: now.subtract(const Duration(minutes: 50)),
        ),
      ],
      'post-2': [
        Comment(
          id: 'comm-3',
          postId: 'post-2',
          companyNameSnapshot: 'ENEC (Barakah Nuclear)',
          authorNickname: 'Nuclear-919',
          content:
              'Camp facilities in Ruwais/Barakah are top tier (Olympic pools, sports facilities, private villas). Shift rotation for operations is 4 days on, 4 days off. Transportation to Abu Dhabi city is provided.',
          likeCount: 15,
          createdAt: now.subtract(const Duration(hours: 3)),
        ),
      ],
      'post-3': [
        Comment(
          id: 'comm-4',
          postId: 'post-3',
          companyNameSnapshot: 'ADNOC',
          authorNickname: 'Refinery-330',
          content: 'Rumor is between 3.5x to 4.2x based on business unit scorecard. Town hall next Tuesday.',
          likeCount: 9,
          createdAt: now.subtract(const Duration(hours: 6)),
        ),
      ],
    };
  }

  @override
  Future<List<Channel>> getChannels() async {
    return _channels;
  }

  @override
  Future<List<Post>> getPosts({String? channelId, String? companyId}) async {
    await Future.delayed(const Duration(milliseconds: 200));

    var result = List<Post>.from(_posts);

    if (channelId != null && channelId.isNotEmpty) {
      if (channelId == AppChannelIds.companyLounge) {
        // Company lounge only shows posts matching user's company
        if (companyId != null) {
          result = result.where((p) => p.channelId == channelId && p.companyId == companyId).toList();
        } else {
          result = [];
        }
      } else {
        result = result.where((p) => p.channelId == channelId).toList();
      }
    }

    // Sort by pinned first, then newest
    result.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    return result;
  }

  @override
  Future<Post?> getPostById(String id) async {
    try {
      return _posts.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Post> createPost({
    required String channelId,
    required String title,
    required String content,
    required AnonymousUser author,
  }) async {
    final now = DateTime.now();
    final newPost = Post(
      id: 'post-${now.millisecondsSinceEpoch}',
      channelId: channelId,
      userId: author.id,
      companyId: author.company.id,
      companyNameSnapshot: author.company.name,
      authorNickname: author.nickname,
      title: title,
      content: content,
      viewCount: 1,
      likeCount: 0,
      commentCount: 0,
      createdAt: now,
      updatedAt: now,
    );

    _posts.insert(0, newPost);
    return newPost;
  }


  @override
  Future<void> toggleLike(String postId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final p = _posts[index];
      final newLiked = !p.isLiked;
      final newCount = newLiked ? p.likeCount + 1 : (p.likeCount > 0 ? p.likeCount - 1 : 0);
      _posts[index] = p.copyWith(isLiked: newLiked, likeCount: newCount);
    }
  }

  @override
  Future<void> votePoll(String postId, String optionId) async {
    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final p = _posts[index];
      if (p.poll != null) {
        final updatedOptions = p.poll!.options.map((opt) {
          if (opt.id == optionId) {
            return opt.copyWith(votes: opt.votes + 1);
          }
          return opt;
        }).toList();

        final updatedPoll = p.poll!.copyWith(options: updatedOptions);
        _posts[index] = p.copyWith(poll: updatedPoll);
      }
    }
  }


  @override
  Future<List<Comment>> getComments(String postId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    return _comments[postId] ?? [];
  }

  @override
  Future<Comment> createComment({
    required String postId,
    String? parentId,
    required String content,
    required AnonymousUser author,
  }) async {
    final now = DateTime.now();
    final newComment = Comment(
      id: 'comm-${now.millisecondsSinceEpoch}',
      postId: postId,
      parentId: parentId,
      companyNameSnapshot: author.company.name,
      authorNickname: author.nickname,
      content: content,
      likeCount: 0,
      createdAt: now,
    );

    final currentComments = _comments[postId] ?? [];

    if (parentId == null) {
      currentComments.add(newComment);
    } else {
      // Find parent and add as reply
      final parentIndex = currentComments.indexWhere((c) => c.id == parentId);
      if (parentIndex != -1) {
        final parent = currentComments[parentIndex];
        final updatedReplies = List<Comment>.from(parent.replies)..add(newComment);
        currentComments[parentIndex] = parent.copyWith(replies: updatedReplies);
      } else {
        currentComments.add(newComment);
      }
    }

    _comments[postId] = currentComments;

    // Increment post comment count
    final pIndex = _posts.indexWhere((p) => p.id == postId);
    if (pIndex != -1) {
      _posts[pIndex] = _posts[pIndex].copyWith(
        commentCount: _posts[pIndex].commentCount + 1,
      );
    }

    return newComment;
  }
}
