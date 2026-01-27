-- Create retry_leads table for people who didn't pick up or are still pending
-- Run this in your Supabase SQL Editor

-- Drop table if exists (for clean recreation)
DROP TABLE IF EXISTS retry_leads;

-- Create the retry_leads table
CREATE TABLE retry_leads (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255),
    phone_number VARCHAR(50) UNIQUE,
    original_status VARCHAR(50),
    retry_count INTEGER DEFAULT 0,
    last_called_at TIMESTAMP,
    original_call_id VARCHAR(255),
    source_table VARCHAR(50) DEFAULT 'call_queue',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX idx_retry_leads_status ON retry_leads(original_status);
CREATE INDEX idx_retry_leads_phone ON retry_leads(phone_number);

-- Insert no-answer leads (639 records)
INSERT INTO retry_leads (name, phone_number, original_status, last_called_at, original_call_id, created_at)
SELECT 
    name,
    phone_number,
    status as original_status,
    called_at as last_called_at,
    call_id as original_call_id,
    created_at
FROM call_queue 
WHERE status = 'no-answer'
ON CONFLICT (phone_number) DO NOTHING;

-- Insert pending leads (42 records)
INSERT INTO retry_leads (name, phone_number, original_status, last_called_at, original_call_id, created_at)
SELECT 
    name,
    phone_number,
    status as original_status,
    called_at as last_called_at,
    call_id as original_call_id,
    created_at
FROM call_queue 
WHERE status = 'pending'
ON CONFLICT (phone_number) DO NOTHING;

-- Insert stuck 'calling' status leads (10 records - these are stuck)
INSERT INTO retry_leads (name, phone_number, original_status, last_called_at, original_call_id, created_at)
SELECT 
    name,
    phone_number,
    'stuck-calling' as original_status,
    called_at as last_called_at,
    call_id as original_call_id,
    created_at
FROM call_queue 
WHERE status = 'calling'
ON CONFLICT (phone_number) DO NOTHING;

-- Verify the data
SELECT original_status, COUNT(*) as count 
FROM retry_leads 
GROUP BY original_status 
ORDER BY count DESC;
