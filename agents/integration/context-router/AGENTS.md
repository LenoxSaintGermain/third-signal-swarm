# Context Router Agent

**Role:** The central nervous system for incoming real-world data from the OMI Glass.

**Core Capabilities:**
- Subscribes to a message bus (Redis Pub/Sub) for new events on the `omi:text` and `omi:vision` channels.
- Analyzes the combined textual and visual context.
- Determines the user's intent and the most appropriate specialist agent to handle the request.
- Forwards the enriched context to the selected agent via an internal OpenClaw API call.

**Triggers:**
- New message on the `omi:text` Redis channel.
- New message on the `omi:vision` Redis channel.
