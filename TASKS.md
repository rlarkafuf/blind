# TASKS.md - Backlog for Autonomous Coding Agents (Majlis)

This backlog contains prioritized sprint tasks for autonomous coding agents (Google Jules, Antigravity, CI/CD runners). Each task is formulated as an actionable milestone. When an agent picks up a task, mark it `[x]` and ensure `flutter analyze` and `flutter test` pass with zero errors.

---

### Phase 1: Authentication & Zero-PII Verification
- [ ] **TASK-001**: Implement Supabase Auth OTP flow with custom UAE company domain validation in `lib/features/auth/repositories/auth_repository.dart`.
- [ ] **TASK-002**: Add client-side SHA-256 + Salt hashing helper in `lib/core/utils/anonymity_helper.dart` with unit tests ensuring irreversible one-way hashes.
- [ ] **TASK-003**: Create dynamic company domain autocomplete & detection during email input (instant detection for `@adnoc.ae`, `@emirates.com`, `@eand.com`, etc.).
- [ ] **TASK-004**: Add "Anonymous Nickname Generator" producing UAE-themed randomized handles (e.g. `Falcon-741`, `Dune-392`, `Oasis-105`, `Burj-820`).

---

### Phase 2: Feed, Channel & Search Systems
- [ ] **TASK-005**: Implement real Supabase client integration for `FeedRepository` with automatic fallback to `MockFeedRepository` when offline or without API keys.
- [ ] **TASK-006**: Build channel selector drawer/sheet with search filter and category grouping (All Lounge, My Company, Vertical Industries).
- [ ] **TASK-007**: Implement "Trending Topics" algorithm on the main lounge sorting posts by like/comment velocity within the last 24 hours.
- [ ] **TASK-008**: Build search functionality across titles, contents, and company badges with debounce in `lib/features/search/`.

---

### Phase 3: Post Interactions, Comments & Bookmarks
- [ ] **TASK-009**: Implement threaded nested comments (2-level hierarchy: comment -> reply) with parent-child relationship handling in `lib/features/post_detail/`.
- [ ] **TASK-010**: Implement optimistic UI updates for Post Upvote / Like toggle with local state caching in Riverpod.
- [ ] **TASK-011**: Add Post Bookmark & "Saved Posts" screen with local or cloud storage synchronization.
- [ ] **TASK-012**: Add Image & Document attachment support in `create_post` with client-side EXIF/metadata stripping to protect anonymity.

---

### Phase 4: Company Lounge & Salary Insights
- [ ] **TASK-013**: Implement strict client & RLS verification for "Company Lounge" ensuring only verified employees with the same company ID can enter.
- [ ] **TASK-014**: Build "UAE Salary & Compensation Survey" feature in `lib/features/salary/` allowing anonymous verified users to share AED salary ranges, bonus %, and End of Service benefits.
- [ ] **TASK-015**: Implement content moderation & report post dialog with automated flagging for hate speech, defaming named individuals, or PII leaks.
