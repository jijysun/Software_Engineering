from pydantic import BaseModel
from typing import Optional

class DogHealth(BaseModel):
    dog_id: Optional[str] = None
    name: Optional[str] = None
    age: Optional[int] = None
    weight: Optional[float] = None
    breed: Optional[str] = None
    sex: Optional[str] = None
    appetite: Optional[str] = None
    activity_level: Optional[str] = None
    stool_condition: Optional[str] = None
    skin_condition: Optional[str] = None
    energy_level: Optional[str] = None
    last_checkup_date: Optional[str] = None
    vaccination_status: Optional[str] = None