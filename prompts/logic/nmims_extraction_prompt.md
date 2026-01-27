# EXTRACTION PROMPT FOR NMIMS MBA QUALIFICATION AGENT

Extract structured data from the conversation based on the following schema.

## EXTRACTION FIELDS

### user_name
Yield the name of the user from the conversation.
- Extract from: Welcome message variable {first_name} or any mention during the call
- Format: String
- Example: "Yash", "Priya Sharma", "Rahul"

### user_interested
Indicate whether the user showed interest in the Online MBA program.
- Values: "yes", "no", "unclear"
- "yes" if user said: "Yes", "Interested", "Haan", "Sure", "Tell me more", "Bataiye", "Okay"
- "no" if user said: "No", "Not interested", "Nahi", "Busy", "Don't call"
- "unclear" if user gave ambiguous responses or only conversational fillers

### graduation_percentage
Yield the graduation percentage provided by the user.
- Format: Number (0-100)
- Extract only if user provided a number > 10
- Examples: 55, 75, 60.5, 82
- If user provided CGPA instead, leave this as null

### graduation_cgpa
Yield the graduation CGPA provided by the user.
- Format: Number (0-10)
- Extract only if user provided a number ≤ 10
- Examples: 7.5, 8.0, 6.2, 9.5
- If user provided percentage instead, leave this as null

### percentage_confirmed
Indicate whether the user confirmed their percentage/CGPA.
- Values: true, false
- true if user said: "Yes", "Correct", "Haan", "Ji", "Sahi hai", "Right", "Bilkul"
- false if user did not confirm or gave unclear response

### is_eligible
Indicate whether the user is eligible for the Online MBA program.
- Values: true, false, null
- true if: percentage ≥ 50 OR cgpa ≥ 5.0
- false if: percentage < 50 OR cgpa < 5.0
- null if: eligibility was not calculated (user not interested or didn't provide score)

### call_outcome
Indicate the final outcome of the call.
- Values: "eligible", "not_eligible", "not_interested", "unclear", "callback_offered", "wrong_number"
- "eligible": User interested, provided score, confirmed, and is eligible (≥50% or ≥5.0 CGPA)
- "not_eligible": User interested, provided score, confirmed, but not eligible (<50% or <5.0 CGPA)
- "not_interested": User explicitly said they are not interested
- "unclear": User gave ambiguous responses and conversation couldn't progress
- "callback_offered": User couldn't provide percentage/CGPA, so callback was offered
- "wrong_number": User confirmed they are not the intended person

### language_used
Indicate the primary language used during the conversation.
- Values: "english", "hindi", "hinglish"
- "english" if conversation was primarily in English
- "hindi" if conversation was primarily in Hindi (Devanagari)
- "hinglish" if conversation mixed Hindi and English

### rejection_reason
If user was not interested, indicate the reason.
- Values: "not_interested", "busy", "wrong_number", "unclear", null
- "not_interested": User explicitly said not interested
- "busy": User said they are busy
- "wrong_number": Wrong person or number
- "unclear": User gave unclear rejection
- null: User was interested or no rejection occurred

### conversation_duration_seconds
Yield the total duration of the conversation in seconds.
- Format: Number
- Example: 45, 120, 78

### agent_name
Yield the name of the agent who made the call.
- Fixed value: "Saira"

### university_name
Yield the name of the university.
- Fixed value: "Narsee Monjee (NMIMS) Online Education"

### program_name
Yield the name of the program being offered.
- Fixed value: "Online MBA"

### call_timestamp
Yield the timestamp when the call was made.
- Format: ISO 8601 datetime string
- Example: "2026-01-16T18:09:00+05:30"

---

## EXTRACTION SCHEMA (JSON FORMAT)

```json
{
  "user_name": "string",
  "user_interested": "yes | no | unclear",
  "graduation_percentage": "number | null",
  "graduation_cgpa": "number | null",
  "percentage_confirmed": "boolean",
  "is_eligible": "boolean | null",
  "call_outcome": "eligible | not_eligible | not_interested | unclear | callback_offered | wrong_number",
  "language_used": "english | hindi | hinglish",
  "rejection_reason": "not_interested | busy | wrong_number | unclear | null",
  "conversation_duration_seconds": "number",
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "ISO 8601 datetime string"
}
```

---

## EXTRACTION EXAMPLES

### Example 1: Eligible User

**Conversation:**
```
Agent: Hello Yash, I'm Saira from Narsee Monjee Online Education. Are you interested in an Online MBA?
User: Yes, interested.
Agent: Great! What was your graduation percentage or CGPA?
User: 75 percent.
Agent: Just to confirm, that was 75 percent, right?
User: Yes, correct.
Agent: Perfect! You are eligible. A senior counselor will call you shortly. Thank you!
```

**Extracted Data:**
```json
{
  "user_name": "Yash",
  "user_interested": "yes",
  "graduation_percentage": 75,
  "graduation_cgpa": null,
  "percentage_confirmed": true,
  "is_eligible": true,
  "call_outcome": "eligible",
  "language_used": "english",
  "rejection_reason": null,
  "conversation_duration_seconds": 45,
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "2026-01-16T18:00:00+05:30"
}
```

---

### Example 2: Not Eligible User (CGPA)

**Conversation:**
```
Agent: Hello Priya, I'm Saira from Narsee Monjee. Are you interested in an Online MBA?
User: Haan, bataiye.
Agent: Great! Aapka graduation percentage ya CGPA kya tha?
User: 4.5 CGPA.
Agent: Confirm karne ke liye, woh 4.5 CGPA tha, sahi hai?
User: Ji haan.
Agent: Unfortunately, the program requires minimum 5.0 CGPA. Thank you for your interest!
```

**Extracted Data:**
```json
{
  "user_name": "Priya",
  "user_interested": "yes",
  "graduation_percentage": null,
  "graduation_cgpa": 4.5,
  "percentage_confirmed": true,
  "is_eligible": false,
  "call_outcome": "not_eligible",
  "language_used": "hinglish",
  "rejection_reason": null,
  "conversation_duration_seconds": 52,
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "2026-01-16T18:05:00+05:30"
}
```

---

### Example 3: Not Interested

**Conversation:**
```
Agent: Hello Rahul, I'm Saira from Narsee Monjee. Are you interested in an Online MBA?
User: No, not interested.
Agent: No problem. Thank you for your time. Have a great day!
```

**Extracted Data:**
```json
{
  "user_name": "Rahul",
  "user_interested": "no",
  "graduation_percentage": null,
  "graduation_cgpa": null,
  "percentage_confirmed": false,
  "is_eligible": null,
  "call_outcome": "not_interested",
  "language_used": "english",
  "rejection_reason": "not_interested",
  "conversation_duration_seconds": 18,
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "2026-01-16T18:10:00+05:30"
}
```

---

### Example 4: User Busy

**Conversation:**
```
Agent: Hello Anjali, I'm Saira from Narsee Monjee. Are you interested in an Online MBA?
User: I'm busy right now.
Agent: No problem. Thank you for your time. Have a great day!
```

**Extracted Data:**
```json
{
  "user_name": "Anjali",
  "user_interested": "no",
  "graduation_percentage": null,
  "graduation_cgpa": null,
  "percentage_confirmed": false,
  "is_eligible": null,
  "call_outcome": "not_interested",
  "language_used": "english",
  "rejection_reason": "busy",
  "conversation_duration_seconds": 15,
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "2026-01-16T18:12:00+05:30"
}
```

---

### Example 5: Callback Offered

**Conversation:**
```
Agent: Hello Vikram, I'm Saira from Narsee Monjee. Are you interested in an Online MBA?
User: Yes.
Agent: Great! What was your graduation percentage or CGPA?
User: I don't remember right now.
Agent: No problem. Could you check and let me know?
User: Pata nahi, yaad nahi aa raha.
Agent: That's okay. A senior counselor will call you to help. Thank you!
```

**Extracted Data:**
```json
{
  "user_name": "Vikram",
  "user_interested": "yes",
  "graduation_percentage": null,
  "graduation_cgpa": null,
  "percentage_confirmed": false,
  "is_eligible": null,
  "call_outcome": "callback_offered",
  "language_used": "hinglish",
  "rejection_reason": null,
  "conversation_duration_seconds": 38,
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "2026-01-16T18:15:00+05:30"
}
```

---

### Example 6: Wrong Number

**Conversation:**
```
Agent: Hello Neha, I'm Saira from Narsee Monjee. Are you interested in an Online MBA?
User: I think you have the wrong number. I'm not Neha.
Agent: I'm looking for Neha. Is that you?
User: No, wrong number.
Agent: I'm sorry for the inconvenience. Thank you, goodbye.
```

**Extracted Data:**
```json
{
  "user_name": "Neha",
  "user_interested": "no",
  "graduation_percentage": null,
  "graduation_cgpa": null,
  "percentage_confirmed": false,
  "is_eligible": null,
  "call_outcome": "wrong_number",
  "language_used": "english",
  "rejection_reason": "wrong_number",
  "conversation_duration_seconds": 22,
  "agent_name": "Saira",
  "university_name": "Narsee Monjee (NMIMS) Online Education",
  "program_name": "Online MBA",
  "call_timestamp": "2026-01-16T18:18:00+05:30"
}
```

---

## EXTRACTION RULES

1. **Always extract user_name** from the {first_name} variable or conversation
2. **Only fill graduation_percentage OR graduation_cgpa**, never both
3. **Set is_eligible to null** if user didn't provide score or wasn't interested
4. **Use call_outcome to summarize** the final state of the conversation
5. **Extract language_used** based on the dominant language in the conversation
6. **Set rejection_reason only if user was not interested**, otherwise null
7. **Calculate conversation_duration_seconds** from call start to end
8. **Use fixed values** for agent_name, university_name, and program_name
9. **Format call_timestamp** in ISO 8601 with timezone

---

## IMPORTANT NOTES

- If user provides CGPA, convert it mentally but DO NOT store the converted percentage
- Store only what the user actually said (either percentage OR CGPA)
- If user corrects their number, extract the final confirmed value
- If confirmation was unclear and agent offered callback, set percentage_confirmed to false
- Language detection should be based on majority of user responses, not agent responses
