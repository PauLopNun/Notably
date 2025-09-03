-- Enhanced Database Schema for Notion-like Collaboration App
-- Run this SQL in your Supabase SQL Editor

-- Drop existing tables if recreating (use with caution)
-- DROP TABLE IF EXISTS note_permissions CASCADE;
-- DROP TABLE IF EXISTS workspace_members CASCADE;
-- DROP TABLE IF EXISTS page_blocks CASCADE;
-- DROP TABLE IF EXISTS pages CASCADE;
-- DROP TABLE IF EXISTS workspaces CASCADE;
-- DROP TABLE IF EXISTS notes CASCADE;

-- Create Workspaces table
CREATE TABLE IF NOT EXISTS workspaces (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  icon TEXT DEFAULT '📝',
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  settings JSONB DEFAULT '{}'::jsonb
);

-- Create Workspace Members table
CREATE TABLE IF NOT EXISTS workspace_members (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  role TEXT DEFAULT 'member' CHECK (role IN ('owner', 'admin', 'editor', 'member', 'viewer')),
  joined_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(workspace_id, user_id)
);

-- Enhanced Pages table (formerly notes)
CREATE TABLE IF NOT EXISTS pages (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE NOT NULL,
  parent_id UUID REFERENCES pages(id) ON DELETE CASCADE,
  title TEXT NOT NULL DEFAULT 'Untitled',
  icon TEXT,
  cover_image TEXT,
  content JSONB DEFAULT '[]'::jsonb,
  position INTEGER DEFAULT 0,
  is_template BOOLEAN DEFAULT FALSE,
  is_public BOOLEAN DEFAULT FALSE,
  created_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_edited_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  properties JSONB DEFAULT '{}'::jsonb
);

-- Page Blocks table for block-based content
CREATE TABLE IF NOT EXISTS page_blocks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  page_id UUID REFERENCES pages(id) ON DELETE CASCADE NOT NULL,
  parent_block_id UUID REFERENCES page_blocks(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('paragraph', 'heading1', 'heading2', 'heading3', 'bulleted_list', 'numbered_list', 'todo', 'quote', 'code', 'divider', 'image', 'video', 'file', 'embed', 'table', 'database', 'callout')),
  content JSONB DEFAULT '{}'::jsonb,
  properties JSONB DEFAULT '{}'::jsonb,
  position INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Page Permissions table
CREATE TABLE IF NOT EXISTS page_permissions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  page_id UUID REFERENCES pages(id) ON DELETE CASCADE NOT NULL,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  permission_type TEXT DEFAULT 'view' CHECK (permission_type IN ('owner', 'edit', 'comment', 'view')),
  granted_by UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  granted_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(page_id, user_id)
);

-- Comments table
CREATE TABLE IF NOT EXISTS comments (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  page_id UUID REFERENCES pages(id) ON DELETE CASCADE NOT NULL,
  block_id UUID REFERENCES page_blocks(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  content TEXT NOT NULL,
  parent_comment_id UUID REFERENCES comments(id) ON DELETE CASCADE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Activity Log table
CREATE TABLE IF NOT EXISTS activity_log (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  workspace_id UUID REFERENCES workspaces(id) ON DELETE CASCADE,
  page_id UUID REFERENCES pages(id) ON DELETE CASCADE,
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
  action TEXT NOT NULL,
  details JSONB DEFAULT '{}'::jsonb,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security (RLS) on all tables
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE page_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE page_permissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE activity_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies for Workspaces
CREATE POLICY "Users can view workspaces they are members of" ON workspaces
  FOR SELECT USING (
    id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Users can create workspaces" ON workspaces
  FOR INSERT WITH CHECK (auth.uid() = owner_id);

CREATE POLICY "Workspace owners can update their workspaces" ON workspaces
  FOR UPDATE USING (owner_id = auth.uid());

CREATE POLICY "Workspace owners can delete their workspaces" ON workspaces
  FOR DELETE USING (owner_id = auth.uid());

-- RLS Policies for Workspace Members
CREATE POLICY "Users can view members of their workspaces" ON workspace_members
  FOR SELECT USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid()
    )
  );

CREATE POLICY "Workspace admins can manage members" ON workspace_members
  FOR ALL USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- RLS Policies for Pages
CREATE POLICY "Users can view pages in their workspaces" ON pages
  FOR SELECT USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid()
    ) OR is_public = true
  );

CREATE POLICY "Users can create pages in their workspaces" ON pages
  FOR INSERT WITH CHECK (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin', 'editor', 'member')
    )
  );

CREATE POLICY "Users can update pages they have edit access to" ON pages
  FOR UPDATE USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin', 'editor', 'member')
    )
  );

CREATE POLICY "Users can delete pages they created or have admin access" ON pages
  FOR DELETE USING (
    created_by = auth.uid() OR 
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid() AND role IN ('owner', 'admin')
    )
  );

-- RLS Policies for Page Blocks
CREATE POLICY "Users can view blocks of accessible pages" ON page_blocks
  FOR SELECT USING (
    page_id IN (
      SELECT id FROM pages WHERE 
        workspace_id IN (
          SELECT workspace_id FROM workspace_members 
          WHERE user_id = auth.uid()
        ) OR is_public = true
    )
  );

CREATE POLICY "Users can manage blocks of editable pages" ON page_blocks
  FOR ALL USING (
    page_id IN (
      SELECT id FROM pages WHERE 
        workspace_id IN (
          SELECT workspace_id FROM workspace_members 
          WHERE user_id = auth.uid() AND role IN ('owner', 'admin', 'editor', 'member')
        )
    )
  );

-- RLS Policies for Comments
CREATE POLICY "Users can view comments on accessible pages" ON comments
  FOR SELECT USING (
    page_id IN (
      SELECT id FROM pages WHERE 
        workspace_id IN (
          SELECT workspace_id FROM workspace_members 
          WHERE user_id = auth.uid()
        ) OR is_public = true
    )
  );

CREATE POLICY "Users can create comments on accessible pages" ON comments
  FOR INSERT WITH CHECK (
    user_id = auth.uid() AND
    page_id IN (
      SELECT id FROM pages WHERE 
        workspace_id IN (
          SELECT workspace_id FROM workspace_members 
          WHERE user_id = auth.uid()
        )
    )
  );

-- RLS Policies for Activity Log
CREATE POLICY "Users can view activity in their workspaces" ON activity_log
  FOR SELECT USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members 
      WHERE user_id = auth.uid()
    )
  );

-- Create indexes for better performance
CREATE INDEX idx_workspaces_owner_id ON workspaces(owner_id);
CREATE INDEX idx_workspace_members_workspace_id ON workspace_members(workspace_id);
CREATE INDEX idx_workspace_members_user_id ON workspace_members(user_id);
CREATE INDEX idx_pages_workspace_id ON pages(workspace_id);
CREATE INDEX idx_pages_parent_id ON pages(parent_id);
CREATE INDEX idx_pages_created_by ON pages(created_by);
CREATE INDEX idx_page_blocks_page_id ON page_blocks(page_id);
CREATE INDEX idx_page_blocks_parent_block_id ON page_blocks(parent_block_id);
CREATE INDEX idx_page_blocks_position ON page_blocks(page_id, position);
CREATE INDEX idx_comments_page_id ON comments(page_id);
CREATE INDEX idx_comments_user_id ON comments(user_id);
CREATE INDEX idx_activity_log_workspace_id ON activity_log(workspace_id);
CREATE INDEX idx_activity_log_user_id ON activity_log(user_id);

-- Create updated_at triggers
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_workspaces_updated_at BEFORE UPDATE ON workspaces 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_pages_updated_at BEFORE UPDATE ON pages 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_page_blocks_updated_at BEFORE UPDATE ON page_blocks 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_comments_updated_at BEFORE UPDATE ON comments 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Create a default workspace for existing users
DO $$
DECLARE
    user_record RECORD;
BEGIN
    FOR user_record IN SELECT id FROM auth.users LOOP
        INSERT INTO workspaces (name, description, owner_id)
        VALUES ('My Workspace', 'Default workspace', user_record.id)
        ON CONFLICT DO NOTHING;
        
        INSERT INTO workspace_members (workspace_id, user_id, role)
        SELECT id, user_record.id, 'owner'
        FROM workspaces 
        WHERE owner_id = user_record.id
        ON CONFLICT DO NOTHING;
    END LOOP;
END $$;