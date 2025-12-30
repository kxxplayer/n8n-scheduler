# AI Voice Calling & Lead Qualification System

A resilient, autonomous outbound calling agent powered by **n8n**, **Bolna AI**, and **PostgreSQL**. Designed to handle high-throughput lead qualification campaigns with concurrency management, state persistence, and automated retries.

## 🚀 Features

-   **High-Concurrency Orchestration:** Manages up to **10 concurrent calls** using cron-based batch scheduling and dynamic throttling.
-   **Resilient State Management:** PostgreSQL-backed system to track call lifecycles (`pending` → `calling` → `completed` / `no-answer`).
-   **Automated Retries:** Automatically queues unanswered calls for retry while preventing duplicates.
-   **Webhook Filtering:** Intelligent parsing of Bolna webhooks to filter intermediate statuses and reduce execution noise.
-   **Bulk Lead Ingestion:** HTTP endpoint for uploading CSV lead lists directly into the queue.
-   **Analytics Ready:** Captures detailed call metrics (duration, transcript, sentiment, qualification status) for reporting.

## 🛠️ Architecture

The system consists of three main components:

1.  **n8n Workflow:** Orchestrates the logic, handles webhooks, and manages the database state.
2.  **Bolna AI:** Provides the conversational voice AI agent.
3.  **PostgreSQL:** Persists lead data, call queue status, and campaign analytics.

### Workflow Logic
1.  **Cron Trigger (Every 2 mins):** Checks for available concurrency slots and time window (12 PM - 4 PM IST).
2.  **Batch Processing:** Fetches pending leads from `call_queue` and initiates calls via Bolna API.
3.  **Webhook Handling:** Receives call completion events, parses extracted data (name, intent, qualification), and updates the database.
4.  **No-Answer Handling:** If a call fails or isn't answered, it's marked for retry in `pending_callbacks`.

## 📦 Setup & Installation

### 1. Database Setup
Run the included SQL scripts to set up your PostgreSQL schema:

```sql
-- Create the necessary tables
\i create_call_queue_table.sql

-- Add constraints
\i add_unique_constraint.sql
```

### 2. n8n Configuration
1.  Import `workflow.json` into your n8n instance.
2.  Set up your **PostgreSQL** credentials in n8n.
3.  Set up your **Bolna AI** API key in n8n credentials.
4.  Configure the `Scheduled Trigger` node to your desired frequency (default: 2 mins).

### 3. Environment Variables
Ensure your n8n instance has access to:
-   `POSTGRES_HOST`
-   `POSTGRES_USER`
-   `POSTGRES_PASSWORD`
-   `BOLNA_API_KEY`
-   `BOLNA_AGENT_ID`

## 📊 Database Schema

-   `call_queue`: Manages the immediate calling list and current status.
-   `leads`: Stores historical data of all processed calls, including transcripts and recording URLs.
-   `pending_callbacks`: Queue for retrying failed or unanswered calls.

## 📝 Usage

### Uploading Leads
Send a POST request to the n8n webhook endpoint with your CSV data:
```bash
curl -X POST https://your-n8n-instance/webhook/upload-leads \
  -H "Content-Type: application/json" \
  -d '{"data": [{"name": "John Doe", "phone": "+1234567890"}]}'
```

### Monitoring
Check the `call_queue` table for real-time status:
```sql
SELECT status, COUNT(*) FROM call_queue GROUP BY status;
```

## 📄 License
This project is licensed under the MIT License.
