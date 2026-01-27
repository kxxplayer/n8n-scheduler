-- Create priority_leads table
DROP TABLE IF EXISTS priority_leads;

CREATE TABLE priority_leads (
    id SERIAL PRIMARY KEY,
    original_lead_id INTEGER,
    name VARCHAR(255),
    phone VARCHAR(50),
    is_interested VARCHAR(50),
    callback_requested VARCHAR(50),
    qualification TEXT,
    summary TEXT,
    transcript TEXT,
    recording_url TEXT,
    created_at TIMESTAMP WITHOUT TIME ZONE
);

-- Insert high priority leads (Interested OR Callback Requested)
INSERT INTO priority_leads (original_lead_id, name, phone, is_interested, callback_requested, qualification, summary, transcript, recording_url, created_at)
SELECT id, name, phone, is_interested, callback_requested, qualification, summary, transcript, recording_url, created_at
FROM leads
WHERE (is_interested = 'yes' OR callback_requested = 'yes')
AND NOT (
    summary ILIKE '%voicemail%' 
    OR summary ILIKE '%call has been forwarded%'
    OR transcript ILIKE '%call has been forwarded%'
    OR transcript ILIKE '%record your message%'
)
AND NOT (
    summary ILIKE '%voicemail%' 
    OR summary ILIKE '%call has been forwarded%'
    OR transcript ILIKE '%call has been forwarded%'
    OR transcript ILIKE '%record your message%'
);

-- Verify the insertion
SELECT COUNT(*) as priority_leads_count FROM priority_leads;
