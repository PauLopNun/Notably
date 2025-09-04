-- Collaborative Operations Table
CREATE TABLE IF NOT EXISTS collaborative_operations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    operation_type TEXT NOT NULL CHECK (operation_type IN ('insert', 'delete', 'retain', 'format', 'cursor_move')),
    position INTEGER,
    content TEXT,
    data JSONB NOT NULL DEFAULT '{}',
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    INDEX idx_collaborative_operations_document_id ON collaborative_operations(document_id),
    INDEX idx_collaborative_operations_timestamp ON collaborative_operations(timestamp)
);

-- Document Collaborators Table
CREATE TABLE IF NOT EXISTS document_collaborators (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'editor' CHECK (role IN ('viewer', 'editor', 'admin')),
    invited_by UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    invited_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    joined_at TIMESTAMP WITH TIME ZONE,
    status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
    
    UNIQUE(document_id, email),
    INDEX idx_document_collaborators_document_id ON document_collaborators(document_id),
    INDEX idx_document_collaborators_user_id ON document_collaborators(user_id)
);

-- User Presence Table (for real-time presence)
CREATE TABLE IF NOT EXISTS user_presence (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_id UUID NOT NULL REFERENCES notes(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    cursor_position INTEGER DEFAULT 0,
    cursor_selection INTEGER DEFAULT 0,
    last_seen TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'idle', 'offline')),
    
    UNIQUE(document_id, user_id),
    INDEX idx_user_presence_document_id ON user_presence(document_id),
    INDEX idx_user_presence_last_seen ON user_presence(last_seen)
);

-- Row Level Security Policies

-- Collaborative Operations RLS
ALTER TABLE collaborative_operations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view operations for documents they have access to" ON collaborative_operations
    FOR SELECT USING (
        document_id IN (
            SELECT n.id FROM notes n WHERE n.user_id = auth.uid()
            UNION
            SELECT dc.document_id FROM document_collaborators dc 
            WHERE dc.user_id = auth.uid() AND dc.status = 'accepted'
        )
    );

CREATE POLICY "Users can insert operations for documents they have access to" ON collaborative_operations
    FOR INSERT WITH CHECK (
        auth.uid() = user_id AND
        document_id IN (
            SELECT n.id FROM notes n WHERE n.user_id = auth.uid()
            UNION
            SELECT dc.document_id FROM document_collaborators dc 
            WHERE dc.user_id = auth.uid() AND dc.status = 'accepted'
        )
    );

-- Document Collaborators RLS
ALTER TABLE document_collaborators ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Document owners can manage collaborators" ON document_collaborators
    FOR ALL USING (
        document_id IN (SELECT id FROM notes WHERE user_id = auth.uid())
    );

CREATE POLICY "Users can view their own collaboration invites" ON document_collaborators
    FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users can update their own collaboration status" ON document_collaborators
    FOR UPDATE USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- User Presence RLS
ALTER TABLE user_presence ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view presence for documents they have access to" ON user_presence
    FOR SELECT USING (
        document_id IN (
            SELECT n.id FROM notes n WHERE n.user_id = auth.uid()
            UNION
            SELECT dc.document_id FROM document_collaborators dc 
            WHERE dc.user_id = auth.uid() AND dc.status = 'accepted'
        )
    );

CREATE POLICY "Users can manage their own presence" ON user_presence
    FOR ALL USING (user_id = auth.uid())
    WITH CHECK (user_id = auth.uid());

-- Functions and Triggers

-- Function to clean old operations (keep last 1000 per document)
CREATE OR REPLACE FUNCTION cleanup_old_operations()
RETURNS void AS $$
BEGIN
    DELETE FROM collaborative_operations
    WHERE id IN (
        SELECT id FROM collaborative_operations co1
        WHERE (
            SELECT COUNT(*) FROM collaborative_operations co2
            WHERE co2.document_id = co1.document_id
            AND co2.timestamp >= co1.timestamp
        ) > 1000
    );
END;
$$ LANGUAGE plpgsql;

-- Function to update user presence
CREATE OR REPLACE FUNCTION update_user_presence(
    p_document_id UUID,
    p_cursor_position INTEGER DEFAULT 0,
    p_cursor_selection INTEGER DEFAULT 0
)
RETURNS void AS $$
BEGIN
    INSERT INTO user_presence (document_id, user_id, user_name, cursor_position, cursor_selection, last_seen, status)
    VALUES (
        p_document_id, 
        auth.uid(), 
        COALESCE((SELECT email FROM auth.users WHERE id = auth.uid()), 'Usuario'),
        p_cursor_position,
        p_cursor_selection,
        NOW(),
        'active'
    )
    ON CONFLICT (document_id, user_id) DO UPDATE SET
        cursor_position = EXCLUDED.cursor_position,
        cursor_selection = EXCLUDED.cursor_selection,
        last_seen = NOW(),
        status = 'active';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to mark user as offline
CREATE OR REPLACE FUNCTION mark_user_offline(p_document_id UUID)
RETURNS void AS $$
BEGIN
    UPDATE user_presence 
    SET status = 'offline', last_seen = NOW()
    WHERE document_id = p_document_id AND user_id = auth.uid();
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger to clean up old presence data
CREATE OR REPLACE FUNCTION cleanup_old_presence()
RETURNS void AS $$
BEGIN
    DELETE FROM user_presence 
    WHERE last_seen < NOW() - INTERVAL '24 hours' OR status = 'offline';
END;
$$ LANGUAGE plpgsql;

-- Schedule cleanup functions (if pg_cron extension is available)
-- SELECT cron.schedule('cleanup-operations', '0 2 * * *', 'SELECT cleanup_old_operations();');
-- SELECT cron.schedule('cleanup-presence', '*/10 * * * *', 'SELECT cleanup_old_presence();');

-- Grant necessary permissions
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON TABLE collaborative_operations TO authenticated;
GRANT ALL ON TABLE document_collaborators TO authenticated;
GRANT ALL ON TABLE user_presence TO authenticated;
GRANT EXECUTE ON FUNCTION update_user_presence TO authenticated;
GRANT EXECUTE ON FUNCTION mark_user_offline TO authenticated;