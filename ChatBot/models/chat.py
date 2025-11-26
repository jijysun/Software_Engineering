# models/chat.py
from typing import Optional
from pydantic import BaseModel


class ChatRequest(BaseModel):
    """
    자바 → 파이썬으로 넘어오는 요청 DTO
    (ChatbotService -> Python /chat)
    """
    user_id: Optional[str] = None       # 로그인한 username (없으면 null)
    message: Optional[str] = None       # 사용자가 이번에 입력한 문장
    mode: Optional[int] = None          # 1, 2, 3, 또는 None (기본 모드)
    profile_info: Optional[str] = None  # account.info 문자열 (없으면 None)
    conversation_history: Optional[str] = None  # ✅ 추가
    recommended_text: Optional[str] = None      # (모드3용, 이미 쓰고 있으면 유지)


class ChatResponse(BaseModel):
    """
    파이썬 → 자바로 보내는 응답 DTO
    (Python /chat -> ChatbotService)
    """
    answer: str                         # 사용자에게 보여줄 최종 답변
    ai_question: Optional[str] = None   # 다음 턴에 물어볼 질문 (CHAT_MESSAGE.QUESTION)
    profile_info: Optional[str] = None  # mode 1일 때 갱신된 전체 프로필 문자열
    image_url: Optional[str] = None     # mode 3에서 사용할 이미지 URL
