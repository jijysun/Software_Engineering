from openai import OpenAI
from dotenv import load_dotenv
import os

from models.petHealth import petHealth
from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def analyze_pet_health(request : PetHealthRequest) -> PetHealthResponse:
    prompt = f"""
    해야하는 일은 다음 두 가지입니다.
    1. 동물의 현재 건강 상태를 참고하여 사용자의 입력에 자연스러운 대화를 이어나갑니다.
    2. 사용자의 입력에서 동물의 상태 변화를 추출하여 pet_health 객체를 갱신합니다.

    동물의 현재 건강 상태:
    {request.pet_health.model_dump_json(indent=2)}

    사용자의 입력:
    "{request.msg}"

    요구사항:
    - 상태 필드값은 한글로 작성하십시오.
    - 조언(msg)은 생활 관리 중심으로 2~4문장 정도로 반환하시오.
    - 위험 신호가 명확할 때만 병원 방문 권고를 1문장 덧붙이십시오.
    - 아래 **반환 JSON 스키마**를 정확히 따르십시오.

    반환 JSON 스키마: 
    {{
        "pet_health": {{
            "pet_id": number | null,
            "breed": string | null,
            "name": string | null,
            "age": number | null,
            "weight": number | null,
            "sex": string | null,

            "appetite": string | null,
            "meal_frequency": number | null,
            "water_intake": string | null,

            "activity_level": string | null,
            "sleep_pattern": string | null,
            "behavior_change": string | null,

            "stool_condition": string | null,
            "urine_frequency": string | null,
            "skin_condition": string | null,
            "eye_condition": string | null,
            "breathing_condition": string | null,
            "energy_level": string | null,

            "last_checkup_date": string | null,
            "vaccination_status": string | null,
            "medication": string | null,
            "chronic_condition": string | null,

            "living_environment": string | null,
            "recent_stress_event": string | null
        }},
        "msg": string
    }}
    """.strip()

    messages = [{"role": "system", "content": "당신은 사용자가 기르는 동물의 케어 어시스턴트입니다."}]
    messages.extend([m.model_dump() for m in request.history])
    messages.append({"role": "user", "content": prompt})


    completion = client.chat.completions.create(
        model="gpt-4o",
        messages= messages,
        response_format={ "type": "json_object" }  # JSON 형태 강제
    )

    data = completion.choices[0].message.content
    return PetHealthResponse.model_validate_json(data)