# 🧠 Software_Engineering

AI 기반 FastAPI 챗봇 서버 구성 안내

---

## 📦 가상환경 설정

```bash
cd Software_Engineering/ChatBot
python -m venv venv
가상환경 활성화 (Windows)
bash
코드 복사
venv\Scripts\activate
가상환경 활성화 (macOS / Linux)
bash
코드 복사
source venv/bin/activate
📚 필수 패키지 설치
bash
코드 복사
pip install python-dotenv openai fastapi uvicorn
※ python-dotenv는 .env 환경변수 파일을 읽기 위해 필요합니다.

⚙️ 환경변수 설정
ChatBot 폴더 내부에 .env 파일을 생성하고 아래와 같이 작성하세요.

ini
코드 복사
OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
API 키는 절대 Git에 커밋하지 마세요.

🚀 서버 실행
bash
코드 복사
uvicorn main:app --reload
서버가 정상적으로 실행되면 다음 주소에서 확인할 수 있습니다.

👉 http://127.0.0.1:8000
👉 http://127.0.0.1:8000/docs (Swagger UI)

📁 프로젝트 구조 예시
bash
코드 복사
Software_Engineering/
├─ JPetStore6/           # 기존 JSP 기반 쇼핑몰
└─ ChatBot/              # FastAPI 기반 AI 서버
   ├─ main.py
   ├─ .env
   ├─ venv/
   ├─ requirements.txt
   └─ __pycache__/
🧩 참고
FastAPI 실행 위치: ChatBot 폴더 내부

.env 파일은 main.py와 같은 폴더에 위치해야 함

JPetStore6(Java 서버) ↔ ChatBot(Python 서버) 간 HTTP 통신 가능

yaml
코드 복사

---

이 형태로 저장하면 GitHub에서 보기에도 서식이 깔끔하게 정렬됩니다.