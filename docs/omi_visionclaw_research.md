# OMI + VisionClaw Research Notes

## OMI Glass Dev Kit
- **Hardware**: XIAO ESP32-S3 with camera, microphone, BLE
- **Firmware**: Arduino-based, OTA updates supported (v2.3.1)
- **App**: Expo/React Native (TypeScript)
- **SDKs**: Python, React Native, Swift, Expo
- **Battery**: 24hrs to several days

## OMI Developer API
- **Memories API**: CRUD for conversation memories
- **Action Items API**: Extract action items from conversations
- **Conversations API**: Access conversation data
- **API Keys**: Developer authentication
- **MCP Integration**: Model Context Protocol support

## OMI App Types
1. **Prompt-Based Apps** (no server needed):
   - Chat Prompts: Alter AI personality/knowledge
   - Memory Prompts: Customize conversation analysis
2. **Integration Apps** (webhook-based):
   - Memory Triggers: Run code when memory created
   - Real-time Transcript: Process live audio transcripts
   - Chat Tools: Custom tools invokable in Omi chat
   - Audio Streaming: Raw PCM16 audio bytes via webhook

## OMI Audio Streaming
- POST octet-stream to webhook every X seconds
- Raw PCM16 audio, sample_rate as query param (16000)
- uid passed as query param for user identification
- Can convert to WAV, accumulate chunks, run custom ASR

## VisionClaw
- **Purpose**: Visual AI agent using computer vision
- **Architecture**: OpenClaw-compatible agent
- **Core**: Screen capture → vision model analysis → action execution
- **Models**: Supports GPT-4V, Claude Vision, Gemini Pro Vision
- **Capabilities**: 
  - Screenshot analysis and understanding
  - UI element detection and interaction
  - Multi-step visual task execution
  - Browser/desktop automation via vision

## Integration Architecture: OMI Glass → VisionClaw → OpenClaw Swarm
- OMI Glass captures audio + camera frames
- Audio → real-time transcription → context for agents
- Camera frames → VisionClaw for visual understanding
- VisionClaw routes visual context to appropriate swarm agents
- Combined audio+visual context = "Third Signal" — what you see + hear + think
