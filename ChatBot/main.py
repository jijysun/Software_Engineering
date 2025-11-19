from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os

from models.petHealth import petHealth
from models.communications import *

from services.petAnalyzer import analyze_pet_health # 반려견 건강 분석
from services.imageGenerate import generate_image # 이미지 생성
from services.petRecommend import recommend_pet # 반려동물 추천

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI()

# 사용자 동물 추천
@app.post("/recommend_pet")
def recommendPet(req: ChatRequest):
    user_recommendation = recommend_pet(req)
    print(f"User: {req.message}\nRecommendation: {user_recommendation}")
    return {"recommendation": user_recommendation}

# 이미지 생성(개발중)
@app.post("/image")
def requestImage(req: ChatRequest):
    image = generate_image(req)
    print(f"Image URL: {image}")
    return {"image_url": image}

# 반려동물 건강 분석
@app.post("/analyze_health")
def analyzePetHealth(req: PetHealthRequest):
    pet_health = analyze_pet_health(req)
    print(f"Pet Health Analysis Result: {pet_health}")
    return pet_health

