---
name: morning-brief
description: Build the morning brief (Slack mentions, today's calendar, Linear notifications and my open issues) through MCP read tools and print it as org-mode text for the Emacs cc-hub brief buffer. Use when asked for a morning brief or /morning-brief.
---

Build a morning brief and print it as org-mode text. Read only: change nothing in any tool.

1. Use only MCP read tools:
   - Slack: `slack_search_public_and_private` for mentions of me and DMs since yesterday 18:00 local time.
   - Google Calendar: `list_events` for today.
   - Linear: `get_notifications` (unread) and `list_issues` with assignee "me" in the current cycle.
2. Print org-mode text only, with no preamble and no closing remarks, in this order:
   - `* Today` with one line per calendar event: `- HH:MM–HH:MM <title>` and the meeting link as an org link.
   - `* Waiting on me` with one `** TODO` heading per Slack mention or Linear notification that needs my answer, a one-line summary, and an org link to it.
   - `* My issues` with one line per issue: `- <KEY> [<state>] <title>` and an org link. Put the issue key first, because cc-hub joins agents to issues by key.
   - `* Suggested first task` with one sentence that names one issue key and why.
3. Keep each line under 120 characters. Do not quote full messages or include personal data beyond names.
4. If a tool call fails, print `* Errors` with one line per failure, then the rest of the brief.
