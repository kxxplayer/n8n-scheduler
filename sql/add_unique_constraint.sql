-- Add UNIQUE constraint to contacts table to prevent duplicate entries
-- This ensures only ONE entry per phone number

-- Option 1: Prevent duplicate phone numbers (RECOMMENDED)
-- Uncomment this if you want one survey result per phone number
ALTER TABLE contacts 
ADD CONSTRAINT unique_phone_number UNIQUE (phone_number);

-- Option 2: Prevent duplicate call_sid (allows multiple surveys from same number)
-- Uncomment this instead if you want to allow multiple surveys from same number
-- but prevent duplicate entries for the same call
-- ALTER TABLE contacts 
-- ADD CONSTRAINT unique_call_sid UNIQUE (call_sid);

-- Verify the constraint was added
SELECT 
    conname AS constraint_name,
    contype AS constraint_type,
    pg_get_constraintdef(oid) AS constraint_definition
FROM pg_constraint
WHERE conrelid = 'contacts'::regclass
AND contype = 'u';
