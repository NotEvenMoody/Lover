-- Supabase Setup for Love/Memories Website
-- Run this in Supabase Dashboard → SQL Editor → New Query

-- ============================================
-- 1. MEMORIES TABLE (Main data storage)
-- ============================================
CREATE TABLE IF NOT EXISTS memories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  type TEXT NOT NULL CHECK (type IN ('image', 'message', 'audio')),
  content TEXT,
  storage_url TEXT,
  bucket_name TEXT DEFAULT 'moody-love',
  file_path TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  category TEXT DEFAULT 'general',
  notes TEXT
);

-- ============================================
-- 2. LOVE DATA TABLE (Aggregated content)
-- ============================================
CREATE TABLE IF NOT EXISTS love_data (
  id BIGINT PRIMARY KEY,
  first_date_images JSONB DEFAULT '[]',
  bday_rumi_images JSONB DEFAULT '[]',
  bday_moody_images JSONB DEFAULT '[]',
  ring_image TEXT DEFAULT '',
  ring_message TEXT DEFAULT '',
  love_message TEXT DEFAULT '',
  bg_audio_url TEXT DEFAULT '',
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. SEED DATA
-- ============================================
INSERT INTO love_data (id) VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 4. INDEXES FOR PERFORMANCE
-- ============================================
CREATE INDEX IF NOT EXISTS idx_memories_type ON memories(type);
CREATE INDEX IF NOT EXISTS idx_memories_category ON memories(category);
CREATE INDEX IF NOT EXISTS idx_memories_created_at ON memories(created_at DESC);

-- ============================================
-- 5. ENABLE ROW LEVEL SECURITY
-- ============================================
ALTER TABLE memories ENABLE ROW LEVEL SECURITY;
ALTER TABLE love_data ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 6. POLICIES FOR MEMORIES TABLE
-- ============================================
CREATE POLICY "Allow public read memories"
  ON memories FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert memories"
  ON memories FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update memories"
  ON memories FOR UPDATE
  USING (true);

CREATE POLICY "Allow public delete memories"
  ON memories FOR DELETE
  USING (true);

-- ============================================
-- 7. POLICIES FOR LOVE_DATA TABLE
-- ============================================
CREATE POLICY "Allow public read love_data"
  ON love_data FOR SELECT
  USING (true);

CREATE POLICY "Allow public insert love_data"
  ON love_data FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Allow public update love_data"
  ON love_data FOR UPDATE
  USING (true);

-- ============================================
-- 8. STORAGE BUCKET POLICIES
-- ============================================
CREATE POLICY "Public read moody-love"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'moody-love');

CREATE POLICY "Public upload moody-love"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'moody-love');

CREATE POLICY "Public update moody-love"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'moody-love');

CREATE POLICY "Public delete moody-love"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'moody-love');

-- ============================================
-- 9. TRIGGER TO UPDATE UPDATED_AT TIMESTAMPS
-- ============================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_memories_updated_at
  BEFORE UPDATE ON memories
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_love_data_updated_at
  BEFORE UPDATE ON love_data
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
