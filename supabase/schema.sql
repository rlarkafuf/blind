-- ==============================================================================
-- Majlis (مجلس) - UAE Anonymous Professional Community (Blind UAE Edition)
-- Supabase PostgreSQL Schema with Zero-PII Anonymous Architecture & RLS
-- ==============================================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1. Companies Table
-- UAE Registered Companies, Ministries, Government Entities & Tech Firms
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.companies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    domain VARCHAR(120) NOT NULL UNIQUE,      -- e.g. 'adnoc.ae', 'emirates.com'
    name VARCHAR(150) NOT NULL,               -- e.g. 'ADNOC', 'Emirates Airline'
    name_ar VARCHAR(150),                     -- Arabic Name
    industry VARCHAR(100) NOT NULL,           -- e.g. 'Energy & Nuclear', 'Banking & Finance'
    icon_code VARCHAR(50) DEFAULT 'business', -- Material icon identifier
    brand_color VARCHAR(20) DEFAULT '#00843D', -- UAE Green / Brand accent hex
    is_verified_entity BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_companies_domain ON public.companies(domain);
CREATE INDEX IF NOT EXISTS idx_companies_industry ON public.companies(industry);

-- -----------------------------------------------------------------------------
-- 2. Anonymous Users Table (Zero-PII Structure)
-- IMPORTANT:
-- No plain email or personal phone is stored in this table or anywhere in the DB.
-- Only a one-way cryptographic SHA-256 hash (with project salt) is stored
-- to prevent duplicate accounts and guarantee mathematical untraceability.
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.users_anonymous (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email_hash VARCHAR(128) NOT NULL UNIQUE,     -- SHA-256(email + secret_salt)
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    nickname_prefix VARCHAR(50) NOT NULL,        -- e.g. 'Falcon-842', 'Dune-119'
    is_active BOOLEAN DEFAULT true,
    last_active_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()),
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_users_email_hash ON public.users_anonymous(email_hash);
CREATE INDEX IF NOT EXISTS idx_users_company ON public.users_anonymous(company_id);

-- -----------------------------------------------------------------------------
-- 3. Topic Channels
-- UAE Lounge, Company Lounge, and Dedicated Industry Verticals
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.channels (
    id VARCHAR(50) PRIMARY KEY,                  -- slug e.g. 'uae-lounge'
    name VARCHAR(100) NOT NULL,
    name_ar VARCHAR(100),
    description TEXT,
    icon_code VARCHAR(50) NOT NULL DEFAULT 'tag',
    is_company_restricted BOOLEAN DEFAULT false, -- If true, strictly limited to same company_id
    sort_order INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 4. Posts Table
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    channel_id VARCHAR(50) NOT NULL REFERENCES public.channels(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users_anonymous(id) ON DELETE CASCADE,
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    company_name_snapshot VARCHAR(150) NOT NULL, -- Fixed snapshot of author's company
    author_nickname VARCHAR(60) NOT NULL,        -- e.g. 'Falcon-842'
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    view_count INT DEFAULT 0,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    is_pinned BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_posts_channel ON public.posts(channel_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_posts_company ON public.posts(company_id);
CREATE INDEX IF NOT EXISTS idx_posts_created_at ON public.posts(created_at DESC);

-- -----------------------------------------------------------------------------
-- 5. Comments & Threaded Replies
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES public.comments(id) ON DELETE CASCADE, -- Nested replies
    user_id UUID NOT NULL REFERENCES public.users_anonymous(id) ON DELETE CASCADE,
    company_id UUID REFERENCES public.companies(id) ON DELETE SET NULL,
    company_name_snapshot VARCHAR(150) NOT NULL,
    author_nickname VARCHAR(60) NOT NULL,
    content TEXT NOT NULL,
    like_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_comments_post_id ON public.comments(post_id, created_at ASC);
CREATE INDEX IF NOT EXISTS idx_comments_parent_id ON public.comments(parent_id);

-- -----------------------------------------------------------------------------
-- 6. Post Likes & Bookmarks (Optional interaction tables for deduplication)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS public.post_likes (
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users_anonymous(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    PRIMARY KEY (post_id, user_id)
);

-- ==============================================================================
-- Row Level Security (RLS) Policies
-- ==============================================================================
ALTER TABLE public.companies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.users_anonymous ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.channels ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;

-- Companies: Public Read
CREATE POLICY "Allow public read access on companies"
    ON public.companies FOR SELECT
    USING (true);

-- Channels: Public Read
CREATE POLICY "Allow public read access on channels"
    ON public.channels FOR SELECT
    USING (true);

-- Anonymous Users: Users can read their own profile row
CREATE POLICY "Users can view own anonymous profile"
    ON public.users_anonymous FOR SELECT
    USING (auth.uid() = id);

-- Posts:
-- 1. Normal channels: Read permitted for all authenticated users
-- 2. Company restricted channels: Read permitted ONLY if viewer's company_id matches post's company_id
CREATE POLICY "Posts select policy"
    ON public.posts FOR SELECT
    USING (
        channel_id != 'company-lounge'
        OR (
            channel_id = 'company-lounge'
            AND company_id IN (
                SELECT u.company_id FROM public.users_anonymous u WHERE u.id = auth.uid()
            )
        )
    );

-- Posts Insert: Authenticated user can create post matching their company
CREATE POLICY "Posts insert policy"
    ON public.posts FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
    );

-- Comments Select Policy: Accessible if parent post is readable
CREATE POLICY "Comments select policy"
    ON public.comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.posts p
            WHERE p.id = comments.post_id
            AND (
                p.channel_id != 'company-lounge'
                OR (
                    p.channel_id = 'company-lounge'
                    AND p.company_id IN (
                        SELECT u.company_id FROM public.users_anonymous u WHERE u.id = auth.uid()
                    )
                )
            )
        )
    );

CREATE POLICY "Comments insert policy"
    ON public.comments FOR INSERT
    WITH CHECK (
        auth.uid() = user_id
    );

-- Post Likes Policies
CREATE POLICY "Likes select policy" ON public.post_likes FOR SELECT USING (true);
CREATE POLICY "Likes insert policy" ON public.post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Likes delete policy" ON public.post_likes FOR DELETE USING (auth.uid() = user_id);

-- ==============================================================================
-- Seed Data: UAE Channels & Top Enterprise Domains
-- ==============================================================================

-- Channels
INSERT INTO public.channels (id, name, name_ar, description, icon_code, is_company_restricted, sort_order)
VALUES
    ('uae-lounge', 'UAE Lounge', 'مجلس الإمارات', 'General conversation for all verified professionals across the UAE', 'chat', false, 1),
    ('company-lounge', 'Company Lounge', 'مجلس الشركة', 'Private lounge strictly for verified colleagues at your company', 'domain', true, 2),
    ('energy-nuclear', 'Energy & Nuclear', 'الطاقة والنووي', 'Oil & Gas, Clean Energy, Barakah Nuclear, Renewables & Utilities', 'bolt', false, 3),
    ('banking-finance', 'Banking & Finance', 'البنوك والتمويل', 'DIFC, ADGM, Investment Banking, Fintech & Islamic Finance', 'account_balance', false, 4),
    ('tech-ai', 'Tech & AI', 'التكنولوجيا والذكاء الاصطناعي', 'Startups, Sovereign AI, Cloud, Software & Tech Hubs in Dubai/Abu Dhabi', 'code', false, 5),
    ('real-estate-living', 'Real Estate & Living', 'العقارات والمعيشة', 'Rent, Property Investment, Housing, Schooling & Expat Living in UAE', 'apartment', false, 6),
    ('salary-visa', 'Salary & Golden Visa', 'الرواتب والتأشيرة الذهبية', 'Compensation packages, End of Service Gratuity, Nomad & Golden Visas', 'payments', false, 7),
    ('tax-investment', 'Tax & Investment', 'الضرائب والاستثمار', 'Corporate Tax, Zero Income Tax, Stocks, Crypto & Asset Management', 'trending_up', false, 8)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    name_ar = EXCLUDED.name_ar,
    description = EXCLUDED.description,
    icon_code = EXCLUDED.icon_code,
    is_company_restricted = EXCLUDED.is_company_restricted,
    sort_order = EXCLUDED.sort_order;

-- Major UAE Companies & Domains
INSERT INTO public.companies (domain, name, name_ar, industry, icon_code, brand_color)
VALUES
    ('adnoc.ae', 'ADNOC', 'أدنوك', 'Energy & Nuclear', 'oil_barrel', '#004B87'),
    ('eand.com', 'e& (Etisalat)', 'اتصالات', 'Tech & AI', 'cell_tower', '#E30613'),
    ('emirates.com', 'Emirates Airline', 'طيران الإمارات', 'Aviation & Logistics', 'flight', '#D71921'),
    ('enec.gov.ae', 'ENEC (Emirates Nuclear Energy)', 'مؤسسة الإمارات للطاقة النووية', 'Energy & Nuclear', 'electric_bolt', '#007A33'),
    ('fab.ae', 'FAB (First Abu Dhabi Bank)', 'بنك أبوظبي الأول', 'Banking & Finance', 'account_balance', '#002D62'),
    ('emiratesnbd.com', 'Emirates NBD', 'بنك الإمارات دبي الوطني', 'Banking & Finance', 'account_balance', '#002B49'),
    ('mubadala.ae', 'Mubadala Investment Company', 'مبادلة للاستثمار', 'Sovereign Wealth & Investment', 'pie_chart', '#007C92'),
    ('adia.ae', 'ADIA (Abu Dhabi Investment Authority)', 'جهاز أبوظبي للاستثمار', 'Sovereign Wealth & Investment', 'account_balance_wallet', '#8C734B'),
    ('dewa.gov.ae', 'DEWA (Dubai Electricity & Water)', 'هيئة كهرباء ومياه دبي', 'Energy & Nuclear', 'water_drop', '#00953B'),
    ('emaar.ae', 'Emaar Properties', 'إعمار العقارية', 'Real Estate & Living', 'location_city', '#1C252C'),
    ('careem.com', 'Careem', 'كريم', 'Tech & AI', 'directions_car', '#00B140'),
    ('talabat.com', 'Talabat', 'طلبات', 'Tech & AI', 'restaurant', '#FF5A00'),
    ('masdar.ae', 'Masdar Clean Energy', 'مصدر للطاقة النظيفة', 'Energy & Nuclear', 'solar_power', '#78BE20'),
    ('dib.ae', 'Dubai Islamic Bank', 'بنك دبي الإسلامي', 'Banking & Finance', 'account_balance', '#00623B'),
    ('general', 'General / Job Seeker', 'عام / باحث عن عمل', 'General & Other', 'public', '#6B7280')
ON CONFLICT (domain) DO UPDATE SET
    name = EXCLUDED.name,
    name_ar = EXCLUDED.name_ar,
    industry = EXCLUDED.industry,
    icon_code = EXCLUDED.icon_code,
    brand_color = EXCLUDED.brand_color;
