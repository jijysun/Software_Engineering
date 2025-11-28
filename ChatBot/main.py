from fastapi import FastAPI
from pydantic import BaseModel
from openai import OpenAI
from dotenv import load_dotenv
import os

from models.chat import ChatRequest, ChatResponse
from models.petHealth import petHealth
from models.communications import ImageRequest, PetHealthRequest 

from services.petAnalyzer import analyze_pet_health
from services.imageGenerate import generate_image
from services.petRecommend import recommend_pet

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

app = FastAPI()


def call_gpt(system_prompt: str, user_prompt: str) -> str:
    """공통 GPT 호출 함수"""
    response = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt},
        ],
    )
    return response.choices[0].message.content.strip()


@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    """
    mode 사용 규칙:
      - 2 : 프로필 + 대화 기반 반려동물 추천 (추천 모드)
      - 3 : 프로필 + 직전 추천 결과 기반 이미지 설명/프롬프트 (이미지 모드)
      - None : 일반 상담 (프로필 참고만)
    👉 1번 모드는 자바에서만 처리하고, 이 API는 호출하지 않는다.
    """
    base_system = (
        "너는 반려동물 입양을 도와주는 친절한 상담 챗봇이야.\n"
        "사용자의 거주 환경, 소득 수준, 가용 시간, 가족 구성 등을 고려해서 "
        "현실적으로 가능한 반려동물을 추천하고 설명해줘."
    )

    profile_info = req.profile_info or ""
    history = req.conversation_history or ""   # ✅ 자바에서 온 대화 히스토리

    # ----- mode 2: 프로필 + 대화 기반 반려동물 추천 -----
    if req.mode == 2:
        system = (
            base_system
            + "\n지금은 '반려동물 추천 모드'야. "
            "사용자의 프로필과 지금까지의 대화 내용을 최대한 활용해서 "
            "무조건 한 종류의 반려동물을 추천하고, 이 동물의 이름만 출력해야해.\n"
            "아래 목록은 JPetStore에 실제로 존재하는 모든 동물 이름 목록이야. "
            "반려동물 추천 시 반드시 이 목록 안에서만 선택해야 한다.\n\n"
            "[사용 가능한 동물 목록]\n"
            "- Adult Male Amazon Parrot\n"
            "- Adult Male Finch\n"
            "- Adult Female Persian\n"
            "- Adult Male Persian\n"
            "- Tailless Manx\n"
            "- With tail Manx\n"
            "- Male Adult Bulldog\n"
            "- Female Puppy Bulldog\n"
            "- Adult Male Chihuahua\n"
            "- Adult Female Chihuahua\n"
            "- Spotted Adult Female Dalmation\n"
            "- Spotless Male Puppy Dalmation\n"
            "- Male Puppy Poodle\n"
            "- Adult Female Golden Retriever\n"
            "- Adult Male Labrador Retriever\n"
            "- Adult Female Labrador Retriever\n"
            "- Spotted Koi\n"
            "- Spotless Koi\n"
            "- Adult Male Goldfish\n"
            "- Adult Female Goldfish\n"
            "- Large Angelfish\n"
            "- Small Angelfish\n"
            "- Toothless Tiger Shark\n"
            "- Green Adult Iguana\n"
            "- Venomless Rattlesnake\n"
            "- Rattleless Rattlesnake\n\n"
            "위 목록에 없는 동물은 절대로 추천하지 마.\n"
            "출력 형식은 반드시 '동물 이름' 한 줄만 출력해야 한다."
        )


        # 버튼만 눌러도 되게, message가 비어 있으면 기본 문장으로
        user_message = (req.message or "").strip() or \
            "지금까지의 프로필과 대화를 바탕으로 저에게 맞는 반려동물을 추천해 주세요."

        user_prompt = (
            f"[사용자 프로필]\n{profile_info}\n\n"
            f"[지금까지의 대화 내용]\n{history}\n\n"
            f"[사용자의 요청]\n{user_message}\n\n"
            "위 모든 정보를 종합해서 반려동물을 추천해줘."
        )

        answer = call_gpt(system, user_prompt)


        return ChatResponse(
            answer=answer,
            ai_question=None,
            profile_info=None,
            image_url=None,
        )

    # ----- mode 3: 프로필 + 추천 결과 기반 이미지 설명 모드 -----
    elif req.mode == 3:
        system = (
            base_system
            + "추천된 반려동물과 사용자가 함께 있는 장면을 한 장의 사진으로 그린다고 생각하고, "
            "이 설명은 이미지 생성 모델에 넣을 프롬프트로 사용할 수 있어야 해."
        )
        image_detail = req.message or ""

        user_prompt = (
            f"[사용자 프로필]\n{profile_info}\n\n"
            f"[추천 받은 동물]\n{req.recommended_text}\n\n"
            f"{image_detail}\n\n"
            "위의 [이미지 세부 설정]에 사용자가 적은 분위기/스타일을 반드시 그대로 포함해서,\n"
        )

        prompt_for_image = call_gpt(system, user_prompt)

        # 다른 개발자 코드 재사용 (ImageRequest는 models.communications 쪽에 있다고 가정)
        image_req = ImageRequest(
            message=prompt_for_image,
            user_info=profile_info or ""
        )
        image_url = generate_image(image_req)

        answer_text = (
            "추천해 드린 반려동물과 함께 있는 장면을 이미지로 생성했어요.\n"
            "아래 URL의 이미지를 확인해 주세요."
        )

        return ChatResponse(
            answer=answer_text,
            ai_question=None,
            profile_info=None,
            image_url=image_url,
        )



    # ----- 기본 모드(None): 일반 상담 -----
    else:
        system = (
            base_system
            + "너는 반려동물 입양을 도와주는 친절한 상담 챗봇이야.\n"
            "사용자가 제공한 프로필 정보는 여러 줄일 수 있지만,"
            "항상 가장 마지막 질문/답변 블록이 최신 정보다.\n"
            "반드시 마지막 블록의 값만 사용하고, 이전 내용은 무시해야 한다.\n"
        )

        if profile_info:
            user_prompt = (
                f"[사용자 프로필]\n{profile_info}\n\n"
                f"[사용자 발화]\n{req.message}"
            )
        else:
            user_prompt = req.message

        answer = call_gpt(system, user_prompt)

        return ChatResponse(
            answer=answer,
            ai_question=None,
            profile_info=None,
            image_url=None,
        )


# 사용자 동물 추천
@app.post("/recommend_pet")
def recommendPet(req: ChatRequest):
    user_recommendation = recommend_pet(req)
    print(f"User: {req.message}\nRecommendation: {user_recommendation}")
    return {"recommendation": user_recommendation}

# 이미지 생성(개발중)
@app.post("/image")
def requestImage(req: ImageRequest):
    image = generate_image(req)
    print(f"Image URL: {image}")
    return {"image_url": image}

# 반려동물 건강 분석
@app.post("/analyze_health")
def analyzePetHealth(req: PetHealthRequest):
    pet_health = analyze_pet_health(req)
    print(f"Pet Health Analysis Result: {pet_health}")
    return pet_health

