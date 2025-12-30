-- Create a separate table for managing call queue
-- This table stores phone numbers that need to be called

CREATE TABLE call_queue (
    id SERIAL PRIMARY KEY,
    phone_number VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(255),
    scheduled_for TIMESTAMP DEFAULT NOW(),
    priority INTEGER DEFAULT 0,
    attempts INTEGER DEFAULT 0,
    last_attempt_at TIMESTAMP,
    status VARCHAR(50) DEFAULT 'pending', -- pending, calling, completed, failed
    notes TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX idx_call_queue_status ON call_queue(status);
CREATE INDEX idx_call_queue_scheduled ON call_queue(scheduled_for);
CREATE INDEX idx_call_queue_priority ON call_queue(priority DESC);
CREATE INDEX idx_call_queue_phone ON call_queue(phone_number);

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_call_queue_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_call_queue_updated_at_trigger
    BEFORE UPDATE ON call_queue 
    FOR EACH ROW 
    EXECUTE FUNCTION update_call_queue_updated_at();

-- Insert sample data (optional - remove if not needed)
INSERT INTO call_queue (phone_number, name, status, priority) VALUES
('+918130838398', 'Test Contact', 'pending', 1);

-- View to see pending calls
CREATE VIEW pending_calls AS
SELECT 
    id,
    phone_number,
    name,
    scheduled_for,
    priority,
    attempts,
    last_attempt_at,
    created_at
FROM call_queue
WHERE status = 'pending'
ORDER BY priority DESC, scheduled_for ASC;

-- Query to get next contacts to call (what n8n will use)
-- This is what you'll use in the "Get Call List" node
SELECT 
    id,
    phone_number,
    name,
    priority
FROM call_queue
WHERE status = 'pending'
  AND scheduled_for <= NOW()
ORDER BY priority DESC, scheduled_for ASC
LIMIT 10;
