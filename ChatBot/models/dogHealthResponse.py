from pydantic import BaseModel
from models.dogHealth import DogHealth

class DogHealthResponse(BaseModel):
    dog_health: DogHealth
    msg: str