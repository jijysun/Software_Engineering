from pydantic import BaseModel
from typing import Optional

from pydantic import BaseModel, Field
from typing import Optional
from datetime import date

class petHealth(BaseModel):
    # 기본 정보
    pet_id: Optional[int] = None
    breed: Optional[str] = None
    name: Optional[str] = None
    age: Optional[int] = Field(None, description="나이 (년)")
    weight: Optional[float] = Field(None, description="몸무게 (kg)")
    sex: Optional[str] = Field(None, description="수컷/암컷/기타")

    # 식습관
    appetite: Optional[str] = Field(None, description="식욕 상태 (좋음/보통/저하)")
    meal_frequency: Optional[int] = Field(None, description="하루 식사 횟수")
    water_intake: Optional[str] = Field(None, description="수분 섭취 상태")

    # 활동성·행동
    activity_level: Optional[str] = Field(None, description="활동량 수준")
    sleep_pattern: Optional[str] = Field(None, description="수면 패턴 (정상/짧음/길음)")
    behavior_change: Optional[str] = Field(None, description="행동 변화 (무기력, 불안 등)")

    # 생리 상태 (동물별 선택적)
    stool_condition: Optional[str] = Field(None, description="배변 상태")
    urine_frequency: Optional[str] = Field(None, description="배뇨 빈도")
    skin_condition: Optional[str] = Field(None, description="피부 상태")
    eye_condition: Optional[str] = Field(None, description="눈 상태")
    breathing_condition: Optional[str] = Field(None, description="호흡 상태")
    energy_level: Optional[str] = Field(None, description="활력 수준")

    # 건강 이력
    last_checkup_date: Optional[date] = None
    vaccination_status: Optional[str] = None
    medication: Optional[str] = None
    chronic_condition: Optional[str] = None

    # 환경 정보
    living_environment: Optional[str] = None
    recent_stress_event: Optional[str] = None
    