// Format Response — handles auth buttons and regular messages
const items = $input.all();

if (!items || items.length === 0) {
  return [];
}

const results = [];
for (const item of items) {
  const agentOutput = item.json || {};
  const inputData = $('Extract Trigger Data').first().json;

  let chatId = inputData.chat_id || '000000';
  let message = '';

  // Extract message from agent output
  if (typeof agentOutput.output === 'string') {
    try {
      const parsed = JSON.parse(agentOutput.output);
      message = parsed.message || agentOutput.output;
      chatId = String(parsed.chat_id || chatId);
    } catch (e) {
      message = agentOutput.output;
    }
  } else if (agentOutput.output && typeof agentOutput.output === 'object') {
    message = agentOutput.output.message || 'Response processed.';
    chatId = String(agentOutput.output.chat_id || chatId);
  } else {
    message = agentOutput.message || agentOutput.text || 'Response processed.';
  }

  // Check if message contains [GOOGLE_AUTH_BUTTON] placeholder
  if (message.includes('[GOOGLE_AUTH_BUTTON]')) {
    // Generate auth URL
    const clientId = "504277064500-544sugt0ik01fj7m3mbn0evdlb8a2n6p.apps.googleusercontent.com";
    const redirectUri = "https://groviaindia.app.n8n.cloud/webhook/oauth-callback";
    const scope = "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/gmail.send";
    
    const authUrl = `https://accounts.google.com/o/oauth2/auth?client_id=${clientId}&redirect_uri=${encodeURIComponent(redirectUri)}&scope=${encodeURIComponent(scope)}&response_type=code&access_type=offline&prompt=consent&state=${chatId}`;

    // Remove placeholder and add inline keyboard
    message = message.replace('[GOOGLE_AUTH_BUTTON]', '');
    
    results.push({
      json: {
        response_type: 'organizer_complete',
        telegram_data: {
          chat_id: chatId,
          message: message.trim(),
          parse_mode: 'HTML',
          reply_markup: {
            inline_keyboard: [[{
              text: '🔗 Connect Google Account',
              url: authUrl
            }]]
          }
        }
      }
    });
  } else {
    // Regular message without button
    results.push({
      json: {
        response_type: 'organizer_complete',
        telegram_data: {
          chat_id: chatId,
          message,
          parse_mode: 'HTML'
        }
      }
    });
  }
}

return results;
