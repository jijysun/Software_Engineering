from openai import OpenAI
from dotenv import load_dotenv
import os

from models.petHealth import petHealth
from models.communications import *

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def analyze_pet_health(request : PetHealthRequest) -> PetHealthResponse:
    prompt = f"""
    아래는 반려동물의 이전 건강 상태입니다:
    {request.pet_health.model_dump_json(indent=2)}

    사용자의 입력:
    "{request.msg}"

    위 정보를 참고해 새로운 pet_health와 조언(msg)을 반드시 JSON 형식으로 반환하세요.
    pet_health를 갱신할때는 가장 최근의 사용자 입력만 반영하고, breed에 따라 필요한 건강 상태만 선택적으로 갱신하세요.
    조언을 제공할 때에는 대화 이력 전체를 고려하세요.
    """

    messages = [{"role": "system", "content": "너는 반려동물의 일상 건강과 습관을 함께 관리하는 케어 어시스턴트이다. 사용자와 대화하면서 반려견의 건강 상태를 분석하고, 필요한 조언을 제공한다."}]
    messages.extend([m.model_dump() for m in request.history])
    messages.append({"role": "user", "content": prompt})

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages= messages,
        response_format={ "type": "json_object" }  # JSON 형태 강제
    )

    data = completion.choices[0].message.content
    return PetHealthResponse.model_validate_json(data)