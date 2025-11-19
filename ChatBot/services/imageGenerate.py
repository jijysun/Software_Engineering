from openai import OpenAI
from dotenv import load_dotenv
import os

from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def generate_image(request: ImageRequest) -> str:
    prompt = f"""
    사용자의 요청에 따라 실제 반려동물의 사랑스러운 모습을 담은 이미지를 생성합니다
    사용자의 정보를 참고해서 주변 환경에 반영합니다.
    사용자의 요청 : "{request.message}"
    사용자의 정보 : "{request.user_info}"
    """

    result = client.images.generate(
        model = "dall-e-3",
        prompt = prompt,
        n = 1,
        size = "1024x1024"
    )
    return result.data[0].url