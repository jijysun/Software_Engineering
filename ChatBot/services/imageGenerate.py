from openai import OpenAI
from dotenv import load_dotenv
import os

from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def generate_image(request: ImageRequest) -> str:
    prompt2 = f"""
    사용자가 실제로 이 반려동물과 함께 살아가는 모습을 자연스럽게 상상할 수 있도록,
    따뜻하고 현실적인 '라이프스타일 사진'을 생성합니다.

    [목표]
    - 반려동물이 이미 사용자의 가정에 함께 있는 것처럼 보이는 장면을 구성합니다.
    - 편안하고 친근하며 감정적으로 호감 가는 분위기를 연출합니다.
    - 사용자가 반려동물 입양 또는 구매를 긍정적으로 느낄 수 있도록,
    일상 속 행복한 순간을 자연스럽게 보여줍니다.

    [사용자 요청]
    {request.message}

    [사용자 환경 및 선호 정보]
    {request.user_info}

    [이미지 스타일 지침]
    - 매우 사실적이고 고해상도의 사진 느낌
    - 깨끗하고 건강하며 잘 관리된 반려동물
    - 사용자의 환경에 맞는 자연스러운 실내/실외 조명
    - 따뜻하고 편안한 분위기
    - 비현실적 요소 금지
    - 신체 비율 왜곡 금지
    - 텍스트, 로고, 글자 등 포함 금지
    - DSLR 사진처럼 자연스럽고 정교한 색감과 구도

    최종 결과물은 실제로 촬영한 듯 자연스럽고,
    사용자가 이 반려동물과 함께할 삶을 떠올리기 쉽게 구성합니다.
    """

    result = client.images.generate(
        model = "dall-e-3",
        prompt = prompt2,
        n = 1,
        size = "1024x1024"
    )
    return result.data[0].url