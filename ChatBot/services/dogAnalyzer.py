from openai import OpenAI
from models.dogHealth import DogHealth
from dotenv import load_dotenv
import os

load_dotenv()

client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

def analyze_dog_health(user_message: str) -> DogHealth:
    prompt = f"""
    사용자가 입력한 문장에서 반려견의 건강상태를 추출하세요.
    다음 항목에 맞춰 JSON으로 반환:
    [dog_id, name, age, weight, breed, sex, appetite, activity_level, stool_condition, 
     skin_condition, energy_level, last_checkup_date, vaccination_status]

    입력: "{user_message}"
    """

    completion = client.chat.completions.create(
        model="gpt-4o-mini",
        messages=[{"role": "system", "content": "너는 수의사 보조 챗봇이다."},
                  {"role": "user", "content": prompt}],
        response_format={ "type": "json_object" }  # JSON 형태 강제
    )

    data = completion.choices[0].message.content
    return DogHealth.model_validate_json(data)