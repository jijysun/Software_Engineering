from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os

from models.dogHealth import DogHealth
from models.communications import *
from services.dogAnalyzer import analyze_dog_health
from services.imageGenerate import generate_image
from services.petRecommend import recommend_pet
load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI()

# 채팅 테스트용
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


# 사용자 동물 추천(개발중)
@app.post("/recommend_pet")
def recommendPet(req: ChatRequest):
    user_recommendation = recommend_pet(req)
    print(f"User: {req.message}\nRecommendation: {user_recommendation}")
    return {"recommendation": user_recommendation}

# 이미지 생성(개발중)
@app.post("/image")
def requestImage(req: ChatRequest):
    image = generate_image(req)
    return {"image_url": image}

# 강아지 건강 분석
@app.post("/analyze_dog_health")
def analyzeDogHealth(req: DogHealthRequest):
    dog_health = analyze_dog_health(req)
    return dog_health



'''앞으로 구현 예정인 기능들'''


# 고양이 건강 분석(예정)
@app.post("/analyze_cat_health")
def analyzeCatHealth(req: ChatRequest):
    return req

# 새 건강 분석(예정)
@app.post("/analyze_bird_health")
def analyzeBirdHealth(req: ChatRequest):
    return req

# 물고기 건강 분석(예정)
@app.post("/analyze_fish_health")
def analyzeFishHealth(req: ChatRequest):
    return req
