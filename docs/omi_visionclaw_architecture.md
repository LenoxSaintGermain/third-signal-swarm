# OMI + VisionClaw Integration Architecture

**Version:** 1.0
**Author:** Manus AI

## 1. Overview

This document outlines the architecture for integrating the **OMI Glass** wearable with **VisionClaw** and the **Third Signal Swarm** of OpenClaw agents. The goal is to create a real-time, context-aware agentic system that can perceive, understand, and act on the user's environment by combining audio and visual data streams.

This creates a powerful "Third Signal" — the fusion of what the user sees, hears, and intends — feeding a continuous stream of high-fidelity context into the agent swarm.

## 2. System Architecture & Data Flow

The architecture consists of four main components: OMI Glass, a new **Context Ingestor** service, VisionClaw, and the existing OpenClaw agent swarm.

```mermaid
graph TD
    A[OMI Glass] -->|1. Raw Audio (PCM16) via Webhook| B(Context Ingestor Service)
    A -->|2. Image Frames via Webhook| B

    B -->|3. Transcribed Text| C{Message Bus / PubSub}
    B -->|4. Image Frames| C

    C -->|5. Text| D[OpenClaw Swarm]
    C -->|6. Image| E[VisionClaw Agent]

    E -->|7. Visual Analysis JSON| D

    subgraph "Real-World Context"
        A
    end

    subgraph "Cloud/Local Processing"
        B
        C
    end

    subgraph "Agentic Core"
        D
        E
    end
```

| Step | From | To | Data | Protocol | Description |
|---|---|---|---|---|---|
| 1 | OMI Glass | Context Ingestor | Raw PCM16 Audio | Webhook (POST) | OMI streams audio chunks every X seconds. |
| 2 | OMI Glass | Context Ingestor | JPEG/PNG Frames | Webhook (POST) | A custom firmware modification will send camera frames. |
| 3 | Context Ingestor | Message Bus | Transcribed Text | Pub/Sub | The ingestor uses a local ASR model (e.g., Whisper) to transcribe audio. |
| 4 | Context Ingestor | Message Bus | Image Frames | Pub/Sub | Raw image frames are published for visual processing. |
| 5 | Message Bus | OpenClaw Swarm | Transcribed Text | Pub/Sub | The swarm's router agent subscribes to the text topic. |
| 6 | Message Bus | VisionClaw Agent | Image Frames | Pub/Sub | VisionClaw subscribes to the image topic. |
| 7 | VisionClaw Agent | OpenClaw Swarm | Visual Analysis | Direct API Call | VisionClaw analyzes the image and sends structured JSON (objects, text, UI elements) to the swarm's router. |

## 3. New Components

### 3.1. OMI Glass Firmware Modification

The stock OMI firmware needs a minor modification to add a new webhook for sending camera frames. This will be a simple function triggered by a button press or a voice command, which captures a frame from the camera and POSTs it to a configurable endpoint.

### 3.2. Context Ingestor Service

This is a new, lightweight FastAPI service responsible for:

-   **Receiving Data:** Exposing two webhook endpoints (`/audio` and `/image`) to receive data from the OMI Glass.
-   **Audio Transcription:** Using a local speech-to-text model (like Whisper) to transcribe the incoming raw audio bytes.
-   **Publishing:** Publishing the transcribed text and raw image frames to a message bus (e.g., Redis Pub/Sub, RabbitMQ).

This service decouples the hardware from the agentic core, providing a robust and scalable data pipeline.

### 3.3. New OpenClaw Agents

Two new agents will be added to the Third Signal Swarm:

1.  **Context Router (`context-router.md`)**
    -   **Role:** The central nervous system for incoming real-world data.
    -   **Triggers:** Subscribes to the message bus for new text and visual analysis events.
    -   **Capabilities:** Analyzes the incoming context and routes it to the appropriate specialist agent in the swarm. For example, if the user says "remind me to buy milk" while looking at a fridge, the router will combine the text ("buy milk") with the visual context ("fridge") and route it to the `task-manager` agent.

2.  **VisionClaw Agent (`vision-claw-agent.md`)**
    -   **Role:** The swarm's eyes.
    -   **Triggers:** Subscribes to the message bus for new image frames.
    -   **Capabilities:** Uses a vision model (e.g., GPT-4V, Claude Vision) to analyze the image. It will extract objects, read text, identify UI elements, and provide a structured JSON description of the scene. This JSON is then published back to the message bus for the `context-router`.

## 4. Implementation Plan

1.  **Phase 1: Firmware & Ingestor**
    -   Modify OMI firmware to add image webhook.
    -   Build and deploy the Context Ingestor service.
2.  **Phase 2: Agent Development**
    -   Create the `context-router` and `vision-claw-agent` spec files.
    -   Implement the logic for both agents.
3.  **Phase 3: Integration & Testing**
    -   Configure the OMI glass, Context Ingestor, and OpenClaw agents to communicate.
    -   Perform end-to-end testing with real-world scenarios.

## 5. Next Steps

Proceed with Phase 4 of the master plan: "Build the integration — agents, scripts, and config."
