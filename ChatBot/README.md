# Software_Engineering

FastAPI 기반 AI 챗봇 서버 실행 안내

## 가상환경 설정
```bash
cd Software_Engineering/ChatBot # 폴더위치

python -m venv venv # 가상환경 생성

venv\Scripts\activate  # 가상환경 진입

pip install python-dotenv openai fastapi uvicorn # 필요한 패키지들 설치

.env 파일 생성 후 아래 내용 추가
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx

서버 실행
uvicorn main:app --reload
