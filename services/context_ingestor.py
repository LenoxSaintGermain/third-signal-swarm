import asyncio
import redis.asyncio as redis
import uvicorn
from fastapi import FastAPI, Request, HTTPException

# --- Configuration ---
REDIS_HOST = "localhost"
REDIS_PORT = 6379

# --- FastAPI App ---
app = FastAPI()

@app.on_event("startup")
async def startup_event():
    app.state.redis = await redis.from_url(f"redis://{REDIS_HOST}:{REDIS_PORT}")

@app.on_event("shutdown")
async def shutdown_event():
    await app.state.redis.close()

@app.post("/audio")
async def audio_webhook(request: Request):
    uid = request.query_params.get("uid")
    if not uid:
        raise HTTPException(status_code=400, detail="uid query parameter is required")

    audio_bytes = await request.body()
    
    # In a real implementation, you would transcribe this audio.
    # For this PoC, we will just use a placeholder.
    transcribed_text = f"(Transcribed audio for {uid})"

    await app.state.redis.publish("omi:text", f"{uid}::{transcribed_text}")
    return {"status": "ok"}

@app.post("/image")
async def image_webhook(request: Request):
    uid = request.query_params.get("uid")
    if not uid:
        raise HTTPException(status_code=400, detail="uid query parameter is required")

    image_bytes = await request.body()
    await app.state.redis.publish("omi:image", image_bytes)
    return {"status": "ok"}

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
