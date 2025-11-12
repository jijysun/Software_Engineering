from openai import OpenAI
from models.dogHealth import DogHealth
from models.dogHealthResponse import DogHealthResponse
from dotenv import load_dotenv
import os

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))


def analyze_dog_health(request : DogHealthResponse) -> DogHealthResponse:

    prompt = f"""
    아래는 반려견의 이전 건강 상태입니다:
    {request.dog_health.model_dump_json(indent=2)}

    사용자의 입력:
    "{request.msg}"

    위 정보를 참고해 필요한 부분만 갱신하고,
    새로운 dog_health와 조언(msg)을 JSON으로 반환하세요.
    """

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "system", "content": "너는 반려동물의 일상 건강과 습관을 함께 관리하는 케어 어시스턴트이다. 사용자와 대화하면서 반려견의 건강 상태를 분석하고, 필요한 조언을 제공한다."},
                  {"role": "user", "content": prompt}],
        response_format={ "type": "json_object" }  # JSON 형태 강제
    )

    data = completion.choices[0].message.content
    print(f"Analyzed Dog Health Data: {data}")
    return DogHealthResponse.model_validate_json(data)