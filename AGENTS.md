# AGENTS.md - Autonomous Coding Agent Guide for Majlis (مجلس)

Welcome, Autonomous Agent (e.g. Google Jules, Antigravity Agent, CI/CD automated coders).
This document defines the strict operational rules, architectural guidelines, and validation protocols for developing **Majlis** (UAE Professional Anonymous Community - UAE's Blind).

---

## 1. Project Overview & Philosophy
- **App Name**: Majlis (مجلس) - UAE Professional Anonymous Community
- **Target Audience**: Professionals working in UAE (Abu Dhabi, Dubai, Sharjah, etc.) across Oil & Gas, Nuclear, Banking, Sovereign Wealth Funds, Tech, Real Estate, and Government Entities.
- **Core Value Proposition**:
  1. **Strict Zero-PII Anonymity**: Never store plaintext emails or personal identifiers.
  2. **Domain-Verified Prestige**: Verified company badges (e.g. `[ADNOC · Falcon-491]`, `[Emirates · Dune-812]`).
  3. **UAE-Centric Channels**: Specialized topics including Barakah Nuclear/Energy, Golden Visa, DIFC/ADGM Finance, and Corporate Tax.

---

## 2. Tech Stack & Architecture

### Frontend (Flutter)
- **SDK**: Flutter (cross-platform: iOS, Android, Web)
- **State Management**: `flutter_riverpod` (v2.x) - Notifiers, StateNotifiers, or AsyncNotifiers. Avoid raw `setState` for business logic.
- **Routing**: `go_router` (declarative routing with auth state redirects).
- **Styling**: Modern dark theme by default (OLED black & slate backgrounds `#0F172A`, `#1E293B`, with UAE emerald accent `#00843D` and gold highlights `#D4AF37`).
- **Typography**: Google Fonts (`Inter` or system fonts).

### Backend & Database (Supabase)
- **Database**: PostgreSQL with Row Level Security (RLS).
- **Zero-PII Engine**: Verification emails must be hashed with SHA-256 + secret salt before storing in `users_anonymous.email_hash`.
- **Database Schema**: Located in `supabase/schema.sql`.

---

## 3. Directory Structure Convention

```
lib/
├── core/
│   ├── constants/       # App constants, channel lists, UAE company domain maps
│   ├── theme/           # App colors, typography, dark/light theme definitions
│   ├── router/          # GoRouter setup and route definitions
│   └── utils/           # Anonymity hashing (SHA-256), date formatting, validators
├── models/              # Immutable domain entities (Company, AnonymousUser, Channel, Post, Comment)
├── features/
│   ├── auth/            # Work email OTP verification, domain resolution, hash generation
│   ├── feed/            # Main lounge, channel tabs, post list, post card component
│   ├── post_detail/     # Post thread, anonymous comment tree, nested replies
│   ├── create_post/     # Anonymous post creation with company badge preview
│   └── company/         # Company directory, domain verification rules
└── main.dart            # Entry point with ProviderScope and theme initialization
```

---

## 4. Operational Rules for Automated Agents

### Rule 1: Zero-PII Anonymity Must Never Be Compromised
- **NEVER** add columns like `email`, `phone`, `full_name`, or `ip_address` to `posts`, `comments`, or `users_anonymous`.
- Always verify that the company snapshot stored on posts (`company_name_snapshot`) is derived from the authenticated domain at time of posting, and cannot be linked back to an individual mailbox.

### Rule 2: Code Quality & Analysis Verification
Before committing or submitting a PR, you **MUST** run:
```bash
flutter analyze
```
- **Zero Errors / Zero Warnings Requirement**: No code should be committed if `flutter analyze` reports any issues.
- Follow Flutter lints (`package:flutter_lints`). Always specify types for public APIs, use `const` constructors where possible, and avoid deprecated members.

### Rule 3: Database & Migration Rules
- Any DB changes must be documented in `supabase/migrations/` or appended cleanly to `supabase/schema.sql`.
- **Row Level Security (RLS)** is mandatory on every new table. Never disable RLS in production or schemas.
- If modifying the Company Lounge logic, guarantee that only users with matching `company_id` can query `company-lounge` posts.

### Rule 4: Mock-First Fallback
- All features should provide or support a mock data repository (`MockFeedRepository`, `MockAuthRepository`) so that the Flutter app can run, be tested, and visually previewed without live Supabase credentials.

---

## 5. Testing Instructions
- **Unit & Widget Tests**:
  ```bash
  flutter test
  ```
- Write unit tests for company domain resolution (`@adnoc.ae` -> ADNOC) and email hash idempotency.
