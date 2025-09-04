-- =======================
-- WORKSPACE & PAGE TABLES
-- =======================
-- This script creates the necessary tables for workspace and page management
-- Run this in your Supabase SQL editor after setting up the basic auth

-- Enable RLS on all tables
ALTER TABLE IF EXISTS public.workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.workspace_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.pages ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.page_blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS public.page_comments ENABLE ROW LEVEL SECURITY;

-- =======================
-- WORKSPACES TABLE
-- =======================
CREATE TABLE IF NOT EXISTS public.workspaces (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    icon TEXT DEFAULT '📝',
    owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =======================
-- WORKSPACE MEMBERS TABLE
-- =======================
CREATE TABLE IF NOT EXISTS public.workspace_members (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workspace_id UUID REFERENCES public.workspaces(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    role TEXT CHECK (role IN ('owner', 'admin', 'member', 'viewer')) DEFAULT 'member',
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(workspace_id, user_id)
);

-- =======================
-- WORKSPACE INVITES TABLE
-- =======================
CREATE TABLE IF NOT EXISTS public.workspace_invites (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workspace_id UUID REFERENCES public.workspaces(id) ON DELETE CASCADE NOT NULL,
    email TEXT NOT NULL,
    role TEXT CHECK (role IN ('admin', 'member', 'viewer')) DEFAULT 'member',
    invited_by UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    token TEXT UNIQUE NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(workspace_id, email)
);

-- =======================
-- PAGES TABLE
-- =======================
CREATE TABLE IF NOT EXISTS public.pages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    workspace_id UUID REFERENCES public.workspaces(id) ON DELETE CASCADE NOT NULL,
    parent_id UUID REFERENCES public.pages(id) ON DELETE CASCADE,
    title TEXT NOT NULL DEFAULT 'Untitled',
    icon TEXT,
    cover_image TEXT,
    properties JSONB DEFAULT '{}',
    position INTEGER DEFAULT 0,
    is_published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMPTZ,
    created_by UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =======================
-- PAGE BLOCKS TABLE
-- =======================
CREATE TABLE IF NOT EXISTS public.page_blocks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    page_id UUID REFERENCES public.pages(id) ON DELETE CASCADE NOT NULL,
    parent_block_id UUID REFERENCES public.page_blocks(id) ON DELETE CASCADE,
    type TEXT NOT NULL CHECK (type IN (
        'paragraph', 'heading_1', 'heading_2', 'heading_3', 
        'bulleted_list', 'numbered_list', 'todo', 'toggle',
        'quote', 'divider', 'code', 'callout', 'image', 
        'video', 'file', 'bookmark', 'table', 'table_row',
        'column_list', 'column', 'embed', 'equation'
    )),
    content JSONB DEFAULT '{}',
    properties JSONB DEFAULT '{}',
    position INTEGER DEFAULT 0,
    created_by UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =======================
-- PAGE COMMENTS TABLE
-- =======================
CREATE TABLE IF NOT EXISTS public.page_comments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    page_id UUID REFERENCES public.pages(id) ON DELETE CASCADE NOT NULL,
    block_id UUID REFERENCES public.page_blocks(id) ON DELETE CASCADE,
    parent_comment_id UUID REFERENCES public.page_comments(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    resolved BOOLEAN DEFAULT FALSE,
    created_by UUID REFERENCES auth.users(id) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- =======================
-- INDEXES FOR PERFORMANCE
-- =======================
CREATE INDEX IF NOT EXISTS idx_workspaces_owner_id ON public.workspaces(owner_id);
CREATE INDEX IF NOT EXISTS idx_workspace_members_user_id ON public.workspace_members(user_id);
CREATE INDEX IF NOT EXISTS idx_workspace_members_workspace_id ON public.workspace_members(workspace_id);
CREATE INDEX IF NOT EXISTS idx_workspace_invites_email ON public.workspace_invites(email);
CREATE INDEX IF NOT EXISTS idx_workspace_invites_token ON public.workspace_invites(token);

CREATE INDEX IF NOT EXISTS idx_pages_workspace_id ON public.pages(workspace_id);
CREATE INDEX IF NOT EXISTS idx_pages_parent_id ON public.pages(parent_id);
CREATE INDEX IF NOT EXISTS idx_pages_created_by ON public.pages(created_by);
CREATE INDEX IF NOT EXISTS idx_pages_workspace_position ON public.pages(workspace_id, position);

CREATE INDEX IF NOT EXISTS idx_page_blocks_page_id ON public.page_blocks(page_id);
CREATE INDEX IF NOT EXISTS idx_page_blocks_parent_id ON public.page_blocks(parent_block_id);
CREATE INDEX IF NOT EXISTS idx_page_blocks_page_position ON public.page_blocks(page_id, position);

CREATE INDEX IF NOT EXISTS idx_page_comments_page_id ON public.page_comments(page_id);
CREATE INDEX IF NOT EXISTS idx_page_comments_block_id ON public.page_comments(block_id);
CREATE INDEX IF NOT EXISTS idx_page_comments_parent_id ON public.page_comments(parent_comment_id);

-- =======================
-- TRIGGERS FOR UPDATED_AT
-- =======================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_workspaces_updated_at ON public.workspaces;
CREATE TRIGGER trigger_workspaces_updated_at
    BEFORE UPDATE ON public.workspaces
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trigger_pages_updated_at ON public.pages;
CREATE TRIGGER trigger_pages_updated_at
    BEFORE UPDATE ON public.pages
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trigger_page_blocks_updated_at ON public.page_blocks;
CREATE TRIGGER trigger_page_blocks_updated_at
    BEFORE UPDATE ON public.page_blocks
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS trigger_page_comments_updated_at ON public.page_comments;
CREATE TRIGGER trigger_page_comments_updated_at
    BEFORE UPDATE ON public.page_comments
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =======================
-- ROW LEVEL SECURITY POLICIES
-- =======================

-- WORKSPACES POLICIES
DROP POLICY IF EXISTS "Users can view workspaces they are members of" ON public.workspaces;
CREATE POLICY "Users can view workspaces they are members of"
    ON public.workspaces FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_members
            WHERE workspace_id = workspaces.id 
            AND user_id = auth.uid()
        )
        OR owner_id = auth.uid()
    );

DROP POLICY IF EXISTS "Users can create workspaces" ON public.workspaces;
CREATE POLICY "Users can create workspaces"
    ON public.workspaces FOR INSERT
    WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Workspace owners can update their workspaces" ON public.workspaces;
CREATE POLICY "Workspace owners can update their workspaces"
    ON public.workspaces FOR UPDATE
    USING (owner_id = auth.uid())
    WITH CHECK (owner_id = auth.uid());

DROP POLICY IF EXISTS "Workspace owners can delete their workspaces" ON public.workspaces;
CREATE POLICY "Workspace owners can delete their workspaces"
    ON public.workspaces FOR DELETE
    USING (owner_id = auth.uid());

-- WORKSPACE MEMBERS POLICIES
DROP POLICY IF EXISTS "Users can view workspace members" ON public.workspace_members;
CREATE POLICY "Users can view workspace members"
    ON public.workspace_members FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_members wm2
            WHERE wm2.workspace_id = workspace_members.workspace_id 
            AND wm2.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Workspace admins can manage members" ON public.workspace_members;
CREATE POLICY "Workspace admins can manage members"
    ON public.workspace_members FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_members wm2
            WHERE wm2.workspace_id = workspace_members.workspace_id 
            AND wm2.user_id = auth.uid()
            AND wm2.role IN ('owner', 'admin')
        )
    );

-- WORKSPACE INVITES POLICIES
DROP POLICY IF EXISTS "Workspace admins can manage invites" ON public.workspace_invites;
CREATE POLICY "Workspace admins can manage invites"
    ON public.workspace_invites FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_members wm
            WHERE wm.workspace_id = workspace_invites.workspace_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin')
        )
    );

-- PAGES POLICIES
DROP POLICY IF EXISTS "Users can view pages in their workspaces" ON public.pages;
CREATE POLICY "Users can view pages in their workspaces"
    ON public.pages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.workspace_members wm
            WHERE wm.workspace_id = pages.workspace_id 
            AND wm.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Workspace members can create pages" ON public.pages;
CREATE POLICY "Workspace members can create pages"
    ON public.pages FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.workspace_members wm
            WHERE wm.workspace_id = pages.workspace_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin', 'member')
        )
        AND created_by = auth.uid()
    );

DROP POLICY IF EXISTS "Page creators and workspace admins can update pages" ON public.pages;
CREATE POLICY "Page creators and workspace admins can update pages"
    ON public.pages FOR UPDATE
    USING (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.workspace_members wm
            WHERE wm.workspace_id = pages.workspace_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin')
        )
    );

DROP POLICY IF EXISTS "Page creators and workspace admins can delete pages" ON public.pages;
CREATE POLICY "Page creators and workspace admins can delete pages"
    ON public.pages FOR DELETE
    USING (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.workspace_members wm
            WHERE wm.workspace_id = pages.workspace_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin')
        )
    );

-- PAGE BLOCKS POLICIES
DROP POLICY IF EXISTS "Users can view page blocks" ON public.page_blocks;
CREATE POLICY "Users can view page blocks"
    ON public.page_blocks FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.pages p
            JOIN public.workspace_members wm ON wm.workspace_id = p.workspace_id
            WHERE p.id = page_blocks.page_id 
            AND wm.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Workspace members can manage page blocks" ON public.page_blocks;
CREATE POLICY "Workspace members can manage page blocks"
    ON public.page_blocks FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.pages p
            JOIN public.workspace_members wm ON wm.workspace_id = p.workspace_id
            WHERE p.id = page_blocks.page_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin', 'member')
        )
    );

-- PAGE COMMENTS POLICIES
DROP POLICY IF EXISTS "Users can view page comments" ON public.page_comments;
CREATE POLICY "Users can view page comments"
    ON public.page_comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.pages p
            JOIN public.workspace_members wm ON wm.workspace_id = p.workspace_id
            WHERE p.id = page_comments.page_id 
            AND wm.user_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "Workspace members can create comments" ON public.page_comments;
CREATE POLICY "Workspace members can create comments"
    ON public.page_comments FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.pages p
            JOIN public.workspace_members wm ON wm.workspace_id = p.workspace_id
            WHERE p.id = page_comments.page_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin', 'member')
        )
        AND created_by = auth.uid()
    );

DROP POLICY IF EXISTS "Comment creators can update their comments" ON public.page_comments;
CREATE POLICY "Comment creators can update their comments"
    ON public.page_comments FOR UPDATE
    USING (created_by = auth.uid());

DROP POLICY IF EXISTS "Comment creators and workspace admins can delete comments" ON public.page_comments;
CREATE POLICY "Comment creators and workspace admins can delete comments"
    ON public.page_comments FOR DELETE
    USING (
        created_by = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.pages p
            JOIN public.workspace_members wm ON wm.workspace_id = p.workspace_id
            WHERE p.id = page_comments.page_id 
            AND wm.user_id = auth.uid()
            AND wm.role IN ('owner', 'admin')
        )
    );

-- =======================
-- FUNCTIONS FOR WORKSPACE MANAGEMENT
-- =======================

-- Function to automatically add workspace owner as member
CREATE OR REPLACE FUNCTION public.add_workspace_owner_as_member()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.workspace_members (workspace_id, user_id, role)
    VALUES (NEW.id, NEW.owner_id, 'owner');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_add_workspace_owner_as_member ON public.workspaces;
CREATE TRIGGER trigger_add_workspace_owner_as_member
    AFTER INSERT ON public.workspaces
    FOR EACH ROW EXECUTE FUNCTION public.add_workspace_owner_as_member();

-- Function to accept workspace invite
CREATE OR REPLACE FUNCTION public.accept_workspace_invite(invite_token TEXT)
RETURNS JSONB AS $$
DECLARE
    invite_record public.workspace_invites;
    user_email TEXT;
    result JSONB;
BEGIN
    -- Get current user email
    SELECT email INTO user_email FROM auth.users WHERE id = auth.uid();
    
    -- Find the invite
    SELECT * INTO invite_record 
    FROM public.workspace_invites 
    WHERE token = invite_token 
    AND email = user_email 
    AND expires_at > NOW() 
    AND used_at IS NULL;
    
    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', false, 'error', 'Invalid or expired invite');
    END IF;
    
    -- Check if user is already a member
    IF EXISTS (
        SELECT 1 FROM public.workspace_members 
        WHERE workspace_id = invite_record.workspace_id 
        AND user_id = auth.uid()
    ) THEN
        RETURN jsonb_build_object('success', false, 'error', 'User is already a member');
    END IF;
    
    -- Add user to workspace
    INSERT INTO public.workspace_members (workspace_id, user_id, role)
    VALUES (invite_record.workspace_id, auth.uid(), invite_record.role);
    
    -- Mark invite as used
    UPDATE public.workspace_invites 
    SET used_at = NOW()
    WHERE id = invite_record.id;
    
    RETURN jsonb_build_object('success', true, 'workspace_id', invite_record.workspace_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =======================
-- FUNCTIONS FOR PAGE SEARCH
-- =======================
CREATE OR REPLACE FUNCTION public.search_pages(workspace_id_param UUID, search_query TEXT)
RETURNS TABLE (
    id UUID,
    title TEXT,
    icon TEXT,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.title,
        p.icon,
        p.created_at,
        p.updated_at
    FROM public.pages p
    JOIN public.workspace_members wm ON wm.workspace_id = p.workspace_id
    WHERE wm.user_id = auth.uid()
    AND p.workspace_id = workspace_id_param
    AND (
        p.title ILIKE '%' || search_query || '%'
        OR EXISTS (
            SELECT 1 FROM public.page_blocks pb
            WHERE pb.page_id = p.id
            AND pb.content->>'text' ILIKE '%' || search_query || '%'
        )
    )
    ORDER BY p.updated_at DESC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- =======================
-- COMPLETION MESSAGE
-- =======================
SELECT 'Workspace and page tables created successfully!' as message;