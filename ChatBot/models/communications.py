from pydantic import BaseModel
from models.dogHealth import DogHealth

class ChatHistoryMessage(BaseModel):
    role: str
    content: str

# 개 응답 형식
class DogHealthResponse(BaseModel):
    dog_health: DogHealth
    msg: str

# 개 요청 형식
class DogHealthRequest(BaseModel):
    dog_health: DogHealth
    history : list[ChatHistoryMessage] = []
    msg: str