from pydantic import BaseModel
from models.petHealth import petHealth

# 단순 메시지 요청(반려동물 추천)
class ChatRequest(BaseModel):
    message: str

# AI사진 생성 요청
class ImageRequest(BaseModel):
    user_info: str
    message: str

# 챗봇 대화 히스토리
class ChatHistoryMessage(BaseModel):
    role: str
    content: str

# 반려동물 케어 응답 형식
class PetHealthResponse(BaseModel):
    pet_health: petHealth
    msg: str

# 반려동물 케어 요청 형식
class PetHealthRequest(BaseModel):
    pet_health: petHealth
    history : list[ChatHistoryMessage] = []
    msg: str