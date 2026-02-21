-- =====================================================================
-- 🗄️ KAVACHVERIFY - SUPABASE TABLE CREATION QUERIES
-- Run these in the Supabase SQL Editor (https://supabase.com/dashboard)
-- =====================================================================


-- 1. USERS TABLE
-- Stores user accounts, profiles, and stats
CREATE TABLE IF NOT EXISTS users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    name TEXT DEFAULT '',
    phone TEXT DEFAULT '',
    bio TEXT DEFAULT '',
    avatar_url TEXT DEFAULT '',
    total_verified INTEGER DEFAULT 0,
    accuracy_score FLOAT DEFAULT 0.0,
    community_rank TEXT DEFAULT 'Beginner',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);


-- 2. DETECTIONS TABLE
-- Stores all verification/detection history items
CREATE TABLE IF NOT EXISTS detections (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    image_url TEXT,
    location TEXT DEFAULT '',
    category TEXT NOT NULL DEFAULT 'text',  -- text, image, video, voice, document, link
    detected_at TIMESTAMPTZ DEFAULT NOW(),
    confidence_score FLOAT DEFAULT 0.0,
    analysis_details TEXT DEFAULT '',
    is_fake BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- 3. CHAT MESSAGES TABLE
-- Stores chat conversation messages per user
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    is_user BOOLEAN DEFAULT TRUE,
    attachment_path TEXT,
    attachment_type TEXT,  -- image, video, document, voice, govid
    created_at TIMESTAMPTZ DEFAULT NOW()
);


-- 4. REPORTS TABLE
-- Stores filed misinformation reports
CREATE TABLE IF NOT EXISTS reports (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    description TEXT NOT NULL,
    proof_urls JSONB DEFAULT '[]',
    documentation_urls JSONB DEFAULT '[]',
    status TEXT DEFAULT 'pending',  -- pending, reviewed, resolved
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);


-- 5. FEEDBACK TABLE
-- Stores user feedback submissions
CREATE TABLE IF NOT EXISTS feedback (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    rating INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
    message TEXT DEFAULT '',
    submitted_at TIMESTAMPTZ DEFAULT NOW()
);


-- =====================================================================
-- 🔧 INDEXES FOR PERFORMANCE
-- =====================================================================
CREATE INDEX IF NOT EXISTS idx_detections_user_id ON detections(user_id);
CREATE INDEX IF NOT EXISTS idx_detections_detected_at ON detections(detected_at DESC);
CREATE INDEX IF NOT EXISTS idx_chat_messages_user_id ON chat_messages(user_id);
CREATE INDEX IF NOT EXISTS idx_chat_messages_created_at ON chat_messages(created_at);
CREATE INDEX IF NOT EXISTS idx_reports_user_id ON reports(user_id);
CREATE INDEX IF NOT EXISTS idx_feedback_user_id ON feedback(user_id);
CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);


-- =====================================================================
-- 🔓 ROW LEVEL SECURITY (RLS) - DISABLED FOR HACKATHON
-- Enable RLS later for production security
-- =====================================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE detections ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE feedback ENABLE ROW LEVEL SECURITY;

-- Allow all operations via service key (for hackathon / server-side access)
CREATE POLICY "Allow all for service role" ON users FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for service role" ON detections FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for service role" ON chat_messages FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for service role" ON reports FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for service role" ON feedback FOR ALL USING (true) WITH CHECK (true);
