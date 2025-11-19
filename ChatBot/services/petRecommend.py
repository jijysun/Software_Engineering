from openai import OpenAI
from dotenv import load_dotenv
import os

from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def recommend_pet(request: ChatRequest) -> str:
    prompt = f"""
    사용자의 상태 : "{request.message}"
    위 상태를 바탕으로 키우기 적합한 반려동물을 추천해 주세요.
    """
    response = client.chat.completions.create(
        model = "gpt-4o-mini",
        messages = [
            {"role": "system", "content": "너는 사용자의 상태와 성향을 분석하여 가장 적합한 반려동물을 추천해주는 챗봇이다."},
            {"role": "user", "content": prompt}
        ]
    )
    reply = response.choices[0].message.content
    return reply
