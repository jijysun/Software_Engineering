from openai import OpenAI
from dotenv import load_dotenv
import os

from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def recommend_pet(request: ChatRequest) -> ChatRequest:
    # 향후 구현 예정
    return request