# 📞 AI Voice Call Receptionist

An **automated voice call system** powered by n8n, Twilio, and AI that makes outbound calls, asks questions, and stores all responses in a database.

## 🎯 What This Does

This system enables you to:
- ✅ Make **automated outbound calls** to contacts
- ✅ Use **AI-powered conversation** to ask questions naturally
- ✅ **Store all responses** in a PostgreSQL database
- ✅ **Schedule calls** in batches or individually
- ✅ **Track call analytics** and performance metrics
- ✅ **Integrate with your existing** AI Receptionist system

## 🎥 Demo Flow

```
1. System calls contact: "+1234567890"
2. Contact answers
3. AI: "Hello! Thank you for taking our call. May I know your name?"
4. Contact: "John Doe"
5. AI: "Thank you, John Doe. What is your email address?"
6. Contact: "john@example.com"
7. AI: "Are you interested in scheduling a meeting? Press 1 for yes, 2 for no."
8. Contact: Presses 1
9. AI: "What would be your preferred time? Morning, afternoon, or evening?"
10. Contact: "Morning"
11. AI: "Thank you for your time. We'll send you a confirmation email. Goodbye!"
12. Call ends → All responses saved to database
```

## 🏗️ Architecture

```
┌──────────────┐
│   Schedule   │ Trigger calls hourly/daily
│   Trigger    │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Get Call   │ Fetch contacts from database
│     List     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Twilio    │ Make outbound call
│  Make Call   │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Webhook    │ Receive call events
│   Handler    │ (answered, speech, DTMF)
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  AI Agent    │ Process response
│  (OpenAI)    │ Generate next question
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Generate   │ Create TwiML response
│    TwiML     │ with text-to-speech
└──────┬───────┘
       │
       ▼
┌──────────────┐
│    Store     │ Save to PostgreSQL
│   Response   │
└──────────────┘
```

## 📁 Project Structure

```
workflow/
├── VOICE_CALL_SYSTEM.md      # Complete documentation (architecture, setup, features)
├── voice_call_workflow.json  # n8n workflow (import this)
├── database_schema.sql        # PostgreSQL schema (run this first)
├── QUICK_START.md            # 30-minute setup guide
└── README_VOICE_CALLS.md     # This file
```

## 🚀 Quick Start (30 Minutes)

### Prerequisites
- n8n instance (self-hosted or cloud)
- PostgreSQL database
- Twilio account (free trial available)
- OpenAI API key

### Setup Steps

1. **Set up Twilio** (5 min)
   - Sign up at [twilio.com](https://www.twilio.com/try-twilio)
   - Get Account SID and Auth Token
   - Purchase a phone number with voice capabilities

2. **Create Database** (5 min)
   ```bash
   psql -U postgres -c "CREATE DATABASE ai_voice_receptionist;"
   psql -U postgres -d ai_voice_receptionist -f database_schema.sql
   ```

3. **Import Workflow** (10 min)
   - Open n8n
   - Import `voice_call_workflow.json`
   - Add credentials (Twilio, PostgreSQL, OpenAI)
   - Update webhook URLs with your n8n instance URL

4. **Configure Twilio** (5 min)
   - Go to Twilio Console → Phone Numbers
   - Set webhook URL: `https://your-n8n.com/webhook/twilio-voice-start`

5. **Test** (5 min)
   - Execute workflow with your phone number
   - Answer the call and respond to questions
   - Check database for saved responses

📖 **Detailed instructions**: See [QUICK_START.md](./QUICK_START.md)

## 📊 Database Tables

### `call_logs`
Tracks all calls and their status
```sql
id, call_sid, phone_number, call_status, call_duration, 
started_at, ended_at, total_questions, completed
```

### `call_responses`
Stores individual Q&A pairs
```sql
id, call_sid, question_number, question_text, response_text, 
response_type, confidence_score, timestamp
```

### `call_questions`
Question bank for the AI
```sql
id, question_order, question_text, question_type, 
is_required, active
```

### `call_schedules`
Schedule future calls
```sql
id, phone_number, scheduled_time, call_purpose, status
```

## 🎨 Customization

### Change Questions
```sql
-- Update existing question
UPDATE call_questions 
SET question_text = 'What is your company name?'
WHERE question_order = 2;

-- Add new question
INSERT INTO call_questions (question_order, question_text, question_type)
VALUES (6, 'Would you like a product demo?', 'yes_no');
```

### Modify AI Behavior
Edit the AI Agent system prompt in the workflow to:
- Change tone (formal/casual)
- Add specific business logic
- Handle edge cases
- Customize acknowledgments

### Change Voice
```xml
<!-- Available Twilio voices -->
<Say voice="Polly.Joanna">Female US English</Say>
<Say voice="Polly.Matthew">Male US English</Say>
<Say voice="Polly.Amy">Female British English</Say>
<Say voice="Google.en-US-Neural2-F">Google Female</Say>
```

## 📈 Analytics & Monitoring

### View Call Statistics
```sql
-- Today's performance
SELECT * FROM v_call_success_rate WHERE call_date = CURRENT_DATE;

-- Recent calls with full conversation
SELECT * FROM v_recent_calls LIMIT 10;

-- Question response rates
SELECT * FROM v_question_analysis;
```

### Key Metrics
- **Call Completion Rate**: % of calls that completed all questions
- **Average Call Duration**: Time per call
- **Response Rate**: % of questions answered
- **Cost per Call**: Twilio + AI costs

## 💰 Cost Estimation

### Per Call (3 minutes, 5 questions)
- Twilio call: $0.039 (3 min × $0.013/min)
- Speech recognition: $0.10 (5 questions × $0.02)
- OpenAI GPT-3.5: $0.002 (~500 tokens)
- **Total: ~$0.14 per call**

### Monthly (1000 calls)
- **Total: ~$140/month**

💡 **Tip**: Use GPT-3.5 instead of GPT-4 to reduce costs by 90%

## 🔧 Advanced Features

### 1. Call Recording
```xml
<Response>
    <Say>This call will be recorded.</Say>
    <Record action="/webhook/recording-complete" maxLength="300"/>
</Response>
```

### 2. Transfer to Human
```xml
<Response>
    <Say>Let me transfer you to a representative.</Say>
    <Dial>+1234567890</Dial>
</Response>
```

### 3. Multi-language Support
```javascript
// Detect language and switch voice
const language = detectLanguage(response);
const voice = language === 'es' ? 'Polly.Conchita' : 'Polly.Joanna';
```

### 4. Sentiment Analysis
```javascript
// Analyze caller sentiment
const sentiment = analyzeSentiment(response);
if (sentiment === 'negative') {
    // Escalate or adjust tone
}
```

## 🔗 Integration with Existing AI Receptionist

### Sync with Telegram Bot
After call completion, send summary to organizer:
```javascript
// Send to Telegram
const summary = `
📞 Call Completed
Name: ${responses.name}
Email: ${responses.email}
Interested: ${responses.interested ? 'Yes' : 'No'}
`;
```

### Update Contacts Table
```sql
UPDATE contacts 
SET last_call_date = NOW(),
    call_count = call_count + 1
WHERE phone_number = '{{phone_number}}';
```

## 🐛 Troubleshooting

### Call not connecting?
- ✅ Check Twilio account balance
- ✅ Verify phone number is verified
- ✅ Check webhook URL is accessible
- ✅ Review Twilio debugger logs

### Speech not recognized?
- ✅ Increase timeout in `<Gather>` tag
- ✅ Use DTMF for critical inputs
- ✅ Add speech hints for expected words

### Database not saving?
- ✅ Check PostgreSQL credentials
- ✅ Verify tables exist
- ✅ Check n8n execution logs

### AI responses too slow?
- ✅ Use GPT-3.5 instead of GPT-4
- ✅ Pre-generate common responses
- ✅ Reduce system prompt length

## 📚 Documentation

- **[VOICE_CALL_SYSTEM.md](./VOICE_CALL_SYSTEM.md)** - Complete system documentation
- **[QUICK_START.md](./QUICK_START.md)** - 30-minute setup guide
- **[database_schema.sql](./database_schema.sql)** - Database schema with comments
- **[voice_call_workflow.json](./voice_call_workflow.json)** - n8n workflow

## 🎯 Use Cases

### 1. Customer Surveys
Automatically call customers and collect feedback

### 2. Appointment Reminders
Confirm upcoming appointments and handle rescheduling

### 3. Lead Qualification
Call leads and qualify them based on responses

### 4. Event Registration
Call attendees to confirm registration and collect details

### 5. Payment Reminders
Remind customers about pending payments

### 6. Product Feedback
Collect feedback after product delivery

## 🔐 Security & Compliance

### Best Practices
- ✅ Always announce call recording (legal requirement)
- ✅ Respect Do Not Call lists
- ✅ Implement opt-out mechanism
- ✅ Store data securely (encrypt sensitive info)
- ✅ Set call duration limits
- ✅ Log all calls for audit trail

### GDPR Compliance
```sql
-- Delete user data on request
DELETE FROM call_responses WHERE call_sid IN (
    SELECT call_sid FROM call_logs WHERE phone_number = '+1234567890'
);
DELETE FROM call_logs WHERE phone_number = '+1234567890';
```

## 🚀 Production Checklist

Before going live:
- [ ] Test with 10+ different phone numbers
- [ ] Verify all questions work correctly
- [ ] Set up monitoring and alerts
- [ ] Configure error handling
- [ ] Add call recording (if required)
- [ ] Implement Do Not Call checking
- [ ] Set up data backup
- [ ] Configure rate limiting
- [ ] Document custom questions
- [ ] Train team on monitoring

## 📞 Support

Need help?
- 📖 Read [VOICE_CALL_SYSTEM.md](./VOICE_CALL_SYSTEM.md) for detailed docs
- 🚀 Follow [QUICK_START.md](./QUICK_START.md) for setup
- 💬 Join [n8n Community](https://community.n8n.io/)
- 📱 Check [Twilio Docs](https://www.twilio.com/docs/voice)

## 🎉 What's Next?

1. **Test the system** with your phone number
2. **Customize questions** for your use case
3. **Schedule batch calls** to your contacts
4. **Monitor analytics** and optimize
5. **Integrate with CRM** for full automation

---

**Built with:**
- [n8n](https://n8n.io/) - Workflow automation
- [Twilio](https://www.twilio.com/) - Voice calls
- [OpenAI](https://openai.com/) - AI conversation
- [PostgreSQL](https://www.postgresql.org/) - Database

**License:** MIT

**Version:** 1.0.0

---

🎯 **Ready to get started?** Follow the [Quick Start Guide](./QUICK_START.md)
