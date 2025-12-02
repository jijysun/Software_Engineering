from openai import OpenAI
from dotenv import load_dotenv
import os

from models.petHealth import petHealth
from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def analyze_pet_health(request : PetHealthRequest) -> PetHealthResponse:
    prompt = f"""
    해야하는 일은 다음 두 가지입니다:
    1. 동물의 기존 건강 상태를 참고하여 사용자의 메시지에 응답(msg)을 생성합니다.
    2. 사용자의 메시지에서 동물의 상태 변화를 추출하여 pet_health 객체를 갱신합니다.

    응답을 생성할 때는 다음 사항들을 참고합니다:
    - 반드시 기존 건강상태에 관련된 내용을 참조할 필요는 없습니다.
    - 사용자의 요청에 따라 동물 관리에 대한 조언, 권고사항, 추천을 제공할 수 있으며 더 좋은 응답을 생성하기 위해서 사용자에게 추가적 정보를 요청하는 질문을 할 수도 있습니다.
    - 응답은 2~4문장 정도로 반환하시오.
    

    동물의 기존 건강 상태:
    {request.pet_health.model_dump_json(indent=2)}

    사용자의 메시지:
    "{request.msg}"

    요구사항:
    - breed, name과 같은 기본정보는 필드값이 비어있는 경우가 아니라면 임의로 변경하지 말고 유지하십시오.(다만 사용자가 명시적으로 변경 요청한 경우는 제외)
    - 상태 필드값은 한글로 작성하십시오.
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

    messages = [{"role": "system", "content": "당신은 사용자가 기르는 반려동물을 관리하고 상담을 제공하는 챗봇이다."}]
    messages.extend([m.model_dump() for m in request.history])
    messages.append({"role": "user", "content": prompt})


    completion = client.chat.completions.create(
        model="gpt-4o",
        messages= messages,
        response_format={ "type": "json_object" }  # JSON 형태 강제
    )

    data = completion.choices[0].message.content
    return PetHealthResponse.model_validate_json(data)