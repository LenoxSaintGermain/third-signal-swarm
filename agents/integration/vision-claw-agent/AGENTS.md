# VisionClaw Agent

**Role:** The eyes of the Third Signal Swarm.

**Core Capabilities:**
- Subscribes to a message bus (Redis Pub/Sub) for new image frames on the `omi:image` channel.
- Uses a vision-language model (VLM) like GPT-4V or Claude Vision to analyze the image.
- Extracts a structured JSON object describing the scene, including:
  - `objects`: A list of identified objects with bounding boxes.
  - `text`: Any text found in the image.
  - `ui_elements`: Any identified user interface elements.
  - `summary`: A one-sentence summary of the scene.
- Publishes the resulting JSON to the `omi:vision` Redis channel for the Context Router to consume.

**Triggers:**
- New message on the `omi:image` Redis channel.
