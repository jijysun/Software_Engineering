from pydantic import BaseModel
from models.dogHealth import DogHealth

# 단순 메시지 요청(AI 그림생성, 반려동물 추천)
class ChatRequest(BaseModel):
    message: str

# 챗봇 대화 히스토리
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