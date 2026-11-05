# AGENTS.md - Autonomous Coding Agent Guide for Blind (블라인드)

Welcome, Autonomous Agent (e.g. Google Jules, Antigravity Agent, CI/CD automated coders).
This document defines the strict operational rules, architectural guidelines, and validation protocols for developing **Blind (블라인드)** - Korea's Premier Professional Anonymous Community.

---

## 1. Project Overview & Philosophy
- **App Name**: Blind (블라인드) - Korean Workplace Anonymous Community
- **Target Audience**: Korean corporate professionals across Big Tech (Naver, Kakao, Coupang, Toss, Line), Conglomerates (Samsung, SK, Hyundai, LG), Startups, Finance, and Public Sectors.
- **Core Value Proposition**:
  1. **Strict Zero-PII Anonymity**: Never store plaintext emails or personal identifiers. Zero trace back to employees.
  2. **Verified Company Badges**: Author badges display verified company names only (e.g. `[삼성전자 · 작성자]`, `[네이버]`, `[카카오]`).
  3. **Dual-Lounge Architecture**:
     - **우리 회사 라운지 (Company Lounge)**: Closed, strictly private board accessible only to verified employees of the same company.
     - **통합 라운지 & 토픽**: Open community for all Korean professionals (인기글, 블라블라, 이직·커리어, 회사생활, 썸·연애, 주식·투자, IT/인터넷).

---

## 2. Tech Stack & Architecture

### Frontend (Flutter)
- **SDK**: Flutter (cross-platform: iOS, Android, Web)
- **State Management**: `flutter_riverpod` (v2.x) - Notifiers, StateNotifiers, or AsyncNotifiers. Avoid raw `setState` for business logic.
- **Routing**: `go_router` (declarative routing with auth state redirects).
- **Styling**:
  - Dark Theme: Modern Deep Dark (`#121212`, card `#1E1E1E`, text `#EDEDED`)
  - Accent Color: Blind Signature Red/Coral (`#FF3B30` or `#EA4335`)
  - Typography: Clean sans-serif / Pretendard / Inter.

### Backend & Database (Supabase)
- **Database**: PostgreSQL with Row Level Security (RLS).
- **Zero-PII Engine**: Verification emails must be hashed with SHA-256 + secret salt before storing in `users_anonymous.email_hash`.
- **Database Schema**: Located in `supabase/schema.sql`.

---

## 3. Directory Structure Convention

```
lib/
├── core/
│   ├── constants/       # App constants, channel lists, Korean company domain maps
│   ├── theme/           # App colors, typography, dark/light theme definitions
│   ├── router/          # GoRouter setup and route definitions
│   └── utils/           # Anonymity hashing (SHA-256), date formatting, validators
├── models/              # Immutable domain entities (Company, AnonymousUser, Channel, Post, Comment)
├── features/
│   ├── auth/            # Work email OTP verification, domain resolution, hash generation
│   ├── feed/            # Main lounge, channel tabs, post list, post card component
│   ├── company_lounge/  # Closed private board restricted to same company employees
│   ├── post_detail/     # Post thread, anonymous comment tree, poll voting
│   ├── create_post/     # Anonymous post creation with company badge preview & poll builder
│   ├── inbox/           # 1:1 anonymous chat & notification center
│   └── profile/         # Company badge status, my posts, scrap list
└── main.dart            # Entry point with ProviderScope and theme initialization
```

---

## 4. Operational Rules for Automated Agents

### Rule 1: Zero-PII Anonymity Must Never Be Compromised
- **NEVER** add columns like `email`, `phone`, `full_name`, or `ip_address` to `posts`, `comments`, or `users_anonymous`.
- Posts and comments must only expose `company_name_snapshot` without any personal identifier.

### Rule 2: Code Quality & Analysis Verification
Before completing any task, you **MUST** run:
```bash
flutter analyze
flutter test
```
- **Zero Errors / Zero Warnings Requirement**: No code should be committed if `flutter analyze` or `flutter test` reports any issues.

### Rule 3: Mock-First Fallback
- All features must provide robust mock data repositories (`MockFeedRepository`, `MockAuthRepository`) so that the Flutter app can run, be tested, and visually previewed without live Supabase credentials.

---

## 5. Testing Instructions
- **Unit & Widget Tests**:
  ```bash
  flutter test
  ```
- Write unit tests for company domain resolution (`@samsung.com` -> 삼성전자) and email hash idempotency.
