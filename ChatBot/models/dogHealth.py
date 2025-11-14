from pydantic import BaseModel
from typing import Optional

from pydantic import BaseModel, Field
from typing import Optional
from datetime import date

class DogHealth(BaseModel):
    # 기본 정보
    dog_id: Optional[int] = None
    name: Optional[str] = None
    breed: Optional[str] = None
    age: Optional[int] = Field(None, description="나이 (년)")
    weight: Optional[float] = Field(None, description="몸무게 (kg)")
    sex: Optional[str] = Field(None, description="수컷/암컷")

    # 식습관
    appetite: Optional[str] = Field(None, description="식욕 상태 (좋음/보통/저하)")
    meal_frequency: Optional[int] = Field(None, description="하루 식사 횟수")
    water_intake: Optional[str] = Field(None, description="수분 섭취 상태")

    # 활동성·행동
    activity_level: Optional[str] = Field(None, description="활동량 수준")
    sleep_pattern: Optional[str] = Field(None, description="수면 패턴 (정상/짧음/길음)")
    behavior_change: Optional[str] = Field(None, description="행동 변화 (예: 무기력, 불안, 공격성 등)")

    # 생리 상태
    stool_condition: Optional[str] = Field(None, description="배변 상태 (정상/묽음/딱딱함 등)")
    urine_frequency: Optional[str] = Field(None, description="배뇨 빈도 (정상/잦음/드묾)")
    skin_condition: Optional[str] = Field(None, description="피부 상태 (정상/가려움/붉음)")
    eye_condition: Optional[str] = Field(None, description="눈 상태 (정상/눈곱 많음/충혈)")
    breathing_condition: Optional[str] = Field(None, description="호흡 상태 (정상/헐떡임/기침 등)")
    energy_level: Optional[str] = Field(None, description="활력 수준")

    # 건강 이력
    last_checkup_date: Optional[date] = Field(None, description="최근 건강검진 일자")
    vaccination_status: Optional[str] = Field(None, description="예방접종 상태")
    medication: Optional[str] = Field(None, description="복용 중인 약이나 치료 기록")
    chronic_condition: Optional[str] = Field(None, description="만성 질환 (예: 알러지, 관절염 등)")

    # 환경 정보
    living_environment: Optional[str] = Field(None, description="실내/실외 및 계절/온도 정보")
    recent_stress_event: Optional[str] = Field(None, description="최근 스트레스 요인 (이사, 가족 변화 등)")

# class DogHealth(BaseModel):
#     dog_id: Optional[str] = None
#     name: Optional[str] = None
#     age: Optional[int] = None
#     weight: Optional[float] = None
#     breed: Optional[str] = None
#     sex: Optional[str] = None
#     appetite: Optional[str] = None
#     activity_level: Optional[str] = None
#     stool_condition: Optional[str] = None
#     skin_condition: Optional[str] = None
#     energy_level: Optional[str] = None
#     last_checkup_date: Optional[str] = None
#     vaccination_status: Optional[str] = None