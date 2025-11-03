from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI()

class ChatRequest(BaseModel):
    message: str

@app.post("/chat")
def chat(req: ChatRequest):
    response = client.chat.completions.create(
        model="gpt-4o-mini",  # 모델명 (gpt-3.5-turbo, gpt-4o-mini 등 가능)
        messages=[
            {"role": "system", "content": "너는 친절한 반려동물 상담 챗봇이야."},
            {"role": "user", "content": req.message}
        ]
    )

    reply = response.choices[0].message.content
    print(f"User: {req.message}\nBot: {reply}")
    return {"reply": reply}