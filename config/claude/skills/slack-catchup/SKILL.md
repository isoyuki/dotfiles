---
name: slack-catchup
description: Catch up on Slack through the Slack MCP read tools and print the result as org-mode text for the Emacs cc-hub Slack buffer. Use when asked for a Slack catch-up or /slack-catchup.
---

Read Slack and print an org-mode catch-up. Read only: never send, react, or draft.

1. Use only the Slack MCP read tools (`slack_search_public_and_private`, `slack_read_channel`, `slack_read_thread`, `slack_read_user_profile`, `slack_list_user_channels`).
2. Find messages from the last 24 hours (or since the time in the prompt) in three groups:
   - mentions of me and DMs to me
   - threads I took part in that have new replies
   - unread activity in channels I am a member of, busiest first, at most 10 channels
3. Print org-mode text only, with no preamble and no closing remarks:
   - One level-1 heading per group: `* Mentions and DMs`, `* Threads`, `* Channels`.
   - One level-2 heading per conversation: `** <channel or person> · <short topic>`.
   - Under it, at most three short lines that say what happened and what is asked of me.
     Put `TODO` in the heading when someone waits for my answer.
   - End each entry with an org link to the message permalink: `[[<permalink>][open]]`.
4. Do not quote full messages. Do not include tokens, customer IDs, or other personal data beyond names.
5. If a tool call fails, print `* Errors` with one line per failure, then the rest of the results.
