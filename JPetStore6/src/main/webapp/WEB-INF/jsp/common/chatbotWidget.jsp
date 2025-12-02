<%--

       Copyright 2010-2025 the original author or authors.

       Licensed under the Apache License, Version 2.0 (the "License");
       you may not use this file except in compliance with the License.
       You may obtain a copy of the License at

          https://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing, software
       distributed under the License is distributed on an "AS IS" BASIS,
       WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
       See the License for the specific language governing permissions and
       limitations under the License.

--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<style>
    #chatbot-container {
        position: fixed;
        right: 24px;
        bottom: 24px;
        width: 380px;          /* 🔼 320 → 380 */
        max-height: 520px;     /* 🔼 420 → 520 */
        font-family: system-ui, sans-serif;
        z-index: 9999;
    }

    #chatbot-toggle-btn {
        background: #4f46e5;
        color: #fff;
        border: none;
        border-radius: 999px;
        padding: 12px 16px;    /* 🔼 살짝 키움 */
        font-size: 15px;       /* 🔼 14 → 15 */
        font-weight: 500;
        box-shadow: 0 8px 20px rgba(0,0,0,0.25);
        cursor: pointer;
        width: 100%;
    }

    #chatbot-panel {
        display: none;
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.18);
        border: 1px solid #ccc;
        margin-top: 8px;
        height: 480px;         /* 🔼 380 → 480 */
        flex-direction: column;
        overflow: hidden;
    }

    #chatbot-header {
        background: #fff;
        padding: 14px 18px;    /* 🔼 패딩 조금 키움 */
        border-bottom: 1px solid #eee;
        font-size: 15px;       /* 🔼 14 → 15 */
        line-height: 1.4;
    }

    #chatbot-messages {
        flex: 1;
        overflow-y: auto;
        background: #f9fafb;
        padding: 14px;         /* 🔼 12 → 14 */
    }

    .bubble {
        max-width: 90%;        /* 🔼 80% → 90% */
        margin-bottom: 12px;   /* 🔼 10 → 12 */
        padding: 11px 13px;    /* 🔼 살짝 키움 */
        border-radius: 16px;   /* 🔼 14 → 16 (좀 더 둥글게) */
        line-height: 1.5;
        box-shadow: 0 4px 10px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.05);
        word-break: break-word;
        white-space: pre-wrap;
        font-size: 14px;       /* 🔼 13 → 14 */
    }

    .user {
        margin-left: auto;
        background: #4f46e5;
        color: #fff;
    }

    .bot {
        margin-right: auto;
        background: #fff;
        color: #111;
    }

    .bot-image {
        margin-right: auto;
        background: transparent;
        box-shadow: none;
        padding: 4px;
    }

    .bot-image img {
        max-width: 260px;      /* 🔼 220 → 260 (챗봇 더 넓어졌으니 이미지도) */
        border-radius: 12px;
        display: block;
    }

    #chatbot-input-area {
        background: #fff;
        border-top: 1px solid #eee;
        display: flex;
        flex-direction: column;
        gap: 8px;              /* 🔼 6 → 8 */
        padding: 12px;         /* 🔼 10 → 12 */
    }

    #chatbot-user-input {
        flex: 1;
        border: 1px solid #d1d5db;
        border-radius: 8px;
        padding: 9px 11px;     /* 🔼 조금 키움 */
        font-size: 14px;       /* 🔼 13 → 14 */
    }

    #chatbot-send-btn {
        background: #4f46e5;
        color: #fff;
        border-radius: 8px;
        font-weight: 500;
        font-size: 14px;       /* 🔼 13 → 14 */
        padding: 9px 11px;     /* 🔼 조금 키움 */
        border: none;
        cursor: pointer;
    }

    #chatbot-quick-area {
        display: flex;
        gap: 6px;              /* 🔼 4 → 6 */
        flex-wrap: wrap;
        margin-bottom: 6px;
    }

    .chatbot-quick-btn {
        flex: 1;
        border: 1px solid #e5e7eb;
        border-radius: 999px;
        padding: 6px 10px;     /* 🔼 5x8 → 6x10 */
        font-size: 12px;       /* 🔼 11 → 12 */
        background: #f3f4f6;
        cursor: pointer;
        white-space: nowrap;
    }

    .chatbot-quick-btn:hover {
        background: #e5e7eb;
    }
</style>



<div id="chatbot-container">

    <button id="chatbot-toggle-btn">💬 문의하기</button>

    <div id="chatbot-panel">
        <div id="chatbot-header">
            <b>JPetStore 챗봇 🐾</b><br/>
            궁금한 걸 물어보세요!
        </div>

        <div id="chatbot-messages"></div>

        <div id="chatbot-input-area">

            <div id="chatbot-quick-area">
                <button class="chatbot-quick-btn"
                        data-msg="더 나은 서비스를 위해 고객님에 대해 알고 싶어요!😊"
                        data-mode="PROFILE">고객님을 알고 싶어요 💬</button>

                <button class="chatbot-quick-btn"
                        data-msg="고객님께 꼭 맞는 반려동물을 추천해드릴게요!!🐾"
                        data-mode="RECOMMEND">반려동물 추천받기 🐾</button>

                <button class="chatbot-quick-btn"
                        data-msg="고객님과 반려동물이 함께할 미래를 그려드릴게요 🎨 원하는 느낌을 말씀해주세요 ✨ ex) 반려동물과 함께 한강에서 산책하는 모습"
                        data-mode="IMAGE">반려동물과 함께하는 미래 보기 🎨</button>
            </div>


            <input id="chatbot-user-input" type="text" placeholder="예) 강아지 사료 추천해줘">
            <button id="chatbot-send-btn">보내기</button>
        </div>
    </div>
</div>

<script>
    (function () {
        const toggleBtn = document.getElementById("chatbot-toggle-btn");
        const panel = document.getElementById("chatbot-panel");
        const messagesDiv = document.getElementById("chatbot-messages");
        const userInput = document.getElementById("chatbot-user-input");
        const sendBtn = document.getElementById("chatbot-send-btn");
        const quickBtns = document.querySelectorAll(".chatbot-quick-btn");

        let currentMode = null;   // "PROFILE" / "RECOMMEND" / "IMAGE" / null
        let chatHistory = [];
        let isOpen = false;

        // 🔒 공통 요청 제어 플래그
        let isRequestInFlight = false;
        let lastRequestTime = 0;
        const REQUEST_COOLDOWN_MS = 1000; // 1초

        // ✅ "스크롤이 한 번이라도 복원된 이후에만" 저장하기 위한 플래그
        let scrollRestored = false;


        /* ------------------------------
           0. 스크롤 위치 저장
           ------------------------------ */
        messagesDiv.addEventListener("scroll", () => {
            // 아직 복원되기 전이면 저장하지 않음 (0으로 덮어쓰는 것 방지)
            if (!scrollRestored) return;

            sessionStorage.setItem(
                "jpetstore_chat_scroll",
                String(messagesDiv.scrollTop)
            );
        });

        /* ------------------------------
           1. 랜덤 질문 목록(PROFILE)
           ------------------------------ */
        const profileQuestions = [
            "고객님의 하루 일정은 어떤 편인가요?\n(예: 아침 9시에 출근하고 저녁 6시에 퇴근해)",

            "고객님은 집에서 보내는 시간이 많으신가요, 아니면 외부 활동이 더 많으신가요?\n(예: 평일엔 대부분 집에 있어)",

            "주말에는 보통 어떤 활동을 하시나요?\n(예: 영화 보거나 산책해)",

            "조용한 환경과 사람 많은 환경 중 어떤 분위기를 더 선호하시나요?\n(예: 조용한 카페를 좋아해)",

            "고객님의 성격을 한 문장으로 표현한다면 어떻게 설명할 수 있을까요?\n(예: 차분하고 조용한 편이야)",

            "최근에 즐기고 계신 취미나 활동이 있다면 알려주세요.\n(예: 러닝, 요가, 게임 등)",

            "하루 중 가장 좋아하는 시간대와 그 이유가 궁금해요.\n(예: 밤 시간이 제일 편안해서 좋아)",

            "스트레스를 받을 때는 주로 어떻게 해소하시나요?\n(예: 음악 듣기, 산책, 친구 만나기)",

            "반려동물과 함께하게 된다면 어떤 순간을 가장 기대하시나요?\n(예: 집에 오면 반겨주는 모습)",

            "고객님이 거주하시는 공간의 분위기나 형태를 알려주실 수 있을까요?\n(예: 원룸, 가족과 같이 거주, 차분한 분위기)"
        ];
        let remainingProfileQuestions = [...profileQuestions];

        /* ------------------------------
           2. 저장/로드 관련 함수
           ------------------------------ */
        function saveOpenState() {
            sessionStorage.setItem("jpetstore_chat_open", isOpen ? "true" : "false");
        }

        function loadOpenState() {
            const raw = sessionStorage.getItem("jpetstore_chat_open");
            isOpen = (raw === "true");
            panel.style.display = isOpen ? "flex" : "none";
        }

        function saveHistory() {
            sessionStorage.setItem("jpetstore_chat_history", JSON.stringify(chatHistory));
        }

        function loadLocalHistory() {
            const raw = sessionStorage.getItem("jpetstore_chat_history");
            if (!raw) return;

            try {
                chatHistory = JSON.parse(raw);
            } catch (e) {
                chatHistory = [];
                return;
            }

            messagesDiv.innerHTML = "";

            for (const m of chatHistory) {
                if (m.type === "png") appendImageBubble(m.url, false);
                else appendTextBubble(m.content, m.role, false);
            }
            // ✅ 저장된 스크롤 위치 복원
            restoreScroll();
        }

        /* ------------------------------
           3. 서버에서 기록 1회만 불러오기
           ------------------------------ */
        async function loadServerChatHistory() {
            try {
                const resp = await fetch("<%=request.getContextPath()%>/api/chat/history.action", {
                    method: "GET"
                });

                if (!resp.ok) return [];
                return await resp.json();

            } catch (e) {
                return [];
            }
        }

        async function initChatFromServer() {
            const loadedFlag = sessionStorage.getItem("chatHistoryLoadedFromServer");

            // 이미 한 번 서버 기록을 불러온 적 있으면, 세션스토리지 것만 사용
            if (loadedFlag === "true") {
                loadLocalHistory();
                return;
            }

            const logsObj = await loadServerChatHistory();

            // 응답이 없거나 에러 나면 로컬 히스토리만 사용
            if (!logsObj || typeof logsObj !== "object") {
                loadLocalHistory();
                return;
            }

            console.log("history response >>>", logsObj);

            // mode별 배열을 하나로 합치기
            const allLogs = [
                ...(logsObj.normal || []),
                ...(logsObj.profile || []),
                ...(logsObj.recommend || []),
                ...(logsObj.image || [])
            ];

            if (allLogs.length === 0) {
                loadLocalHistory();
                return;
            }

            // created_at 기준으로 과거 → 최근 정렬
            allLogs.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

            messagesDiv.innerHTML = "";
            chatHistory = [];

            for (const log of allLogs) {
                // question → 챗봇(assistant) 말풍선
                if (log.question && log.question.trim() !== "") {
                    appendTextBubble(log.question, "assistant", false);
                    chatHistory.push({
                        role: "assistant",
                        type: "text",
                        content: log.question
                    });
                }

                // answer → 사용자(user) 말풍선
                if (log.answer && log.answer.trim() !== "") {
                    appendTextBubble(log.answer, "user", false);
                    chatHistory.push({
                        role: "user",
                        type: "text",
                        content: log.answer
                    });
                }
            }

            // ✅ 서버에서 처음 불러올 때도 스크롤 복원
            restoreScroll();
            saveHistory();
            sessionStorage.setItem("chatHistoryLoadedFromServer", "true");
        }

        /* ------------------------------
           4. UI 헬퍼
           ------------------------------ */
        function appendTextBubble(text, role, scroll = true) {
            const div = document.createElement("div");
            div.classList.add("bubble", role === "user" ? "user" : "bot");
            div.textContent = text;
            messagesDiv.appendChild(div);
            if (scroll) finalizeScroll();
            return div;
        }

        function appendImageBubble(url, scroll = true) {
            const div = document.createElement("div");
            div.classList.add("bubble", "bot-image");
            const img = document.createElement("img");
            img.src = url;
            div.appendChild(img);
            messagesDiv.appendChild(div);
            if (scroll) finalizeScroll();
            return div;
        }

        function finalizeScroll() {
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        // ✅ 스크롤 위치 복원 함수
        function restoreScroll() {
            const raw = sessionStorage.getItem("jpetstore_chat_scroll");

            if (raw) {
                const pos = parseInt(raw, 10);
                // 0 이거나 숫자가 아니면 그냥 맨 아래로
                if (!Number.isNaN(pos) && pos > 0) {
                    messagesDiv.scrollTop = pos;
                } else {
                    finalizeScroll();
                }
            } else {
                // 저장된 값이 없으면 기본은 "맨 아래"
                finalizeScroll();
            }

            // 이제부터는 scroll 이벤트에서 저장해도 됨
            scrollRestored = true;
        }

        // 🔒 버튼 enable/disable
        function setButtonsDisabled(disabled) {
            sendBtn.disabled = disabled;
            quickBtns.forEach(btn => (btn.disabled = disabled));
        }

        // 🔒 새로운 요청을 보내도 되는지 체크 + 플래그 셋업
        function canSendNewRequest() {
            const now = Date.now();

            if (isRequestInFlight) {
                console.log("요청 처리중...");
                return false;
            }

            if (now - lastRequestTime < REQUEST_COOLDOWN_MS) {
                console.log("요청 쿨다운 중...");
                return false;
            }

            isRequestInFlight = true;
            lastRequestTime = now;
            setButtonsDisabled(true);
            return true;
        }

        // 🔓 요청 종료 처리
        function finishRequest() {
            isRequestInFlight = false;
            setButtonsDisabled(false);
        }

        toggleBtn.addEventListener("click", () => {
            isOpen = !isOpen;
            panel.style.display = isOpen ? "flex" : "none";

            // ✅ 패널을 열 때마다 스크롤 위치 복원
            if (isOpen) {
                restoreScroll();
            }

            saveOpenState();
        });

        /* ------------------------------
           5. Chatbot API 호출 함수
              - POST /actions/Chatbot.action
              - form-urlencoded (mode, question, answer)
           ------------------------------ */

        function mapModeToInt(mode) {
            if (mode === "PROFILE") return 1;
            if (mode === "RECOMMEND") return 2;
            if (mode === "IMAGE") return 3;
            return null; // 일반 채팅
        }

        async function sendChatRequest(mode, question, answer) {
            const params = new URLSearchParams();

            const modeInt = typeof mode === "number" ? mode : mapModeToInt(mode);
            if (modeInt != null) {
                params.append("mode", String(modeInt));
            }
            if (answer && answer.trim() !== "") {
                params.append("answer", answer.trim());
            }
            if (question && question.trim() !== "") {
                params.append("question", question.trim());
            }

            const resp = await fetch("<%=request.getContextPath()%>/actions/Chatbot.action", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8"
                },
                body: params.toString()
            });

            if (!resp.ok) throw new Error("Chatbot API 실패");
            return await resp.json();  // { answer, imageUrl, nextQuestion }
        }

        /* ------------------------------
           6. 버튼 클릭 처리 (PROFILE / RECOMMEND / IMAGE)
           ------------------------------ */
        quickBtns.forEach(btn => {
            btn.addEventListener("click", async () => {
                const mode = btn.dataset.mode;    // "PROFILE" / "RECOMMEND" / "IMAGE"
                const presetMsg = btn.dataset.msg || "";
                currentMode = mode;

                /* PROFILE: 질문만 띄우고, 다음 입력 때 mode=1 로 전송 */
                if (mode === "PROFILE") {
                    if (remainingProfileQuestions.length === 0)
                        remainingProfileQuestions = [...profileQuestions];

                    const idx = Math.floor(Math.random() * remainingProfileQuestions.length);
                    const msg = remainingProfileQuestions[idx];
                    remainingProfileQuestions.splice(idx, 1);

                    sessionStorage.setItem("last_profile_question", msg);

                    appendTextBubble(msg, "assistant");
                    chatHistory.push({ role: "assistant", type: "text", content: msg });
                    saveHistory();
                    return;
                }

                /* IMAGE: 안내 문구 먼저, 다음 입력 때 mode=3 로 전송 */
                if (mode === "IMAGE") {
                    const msg = "고객님과 반려동물이 함께할 미래를 그려드릴게요!! 🎨 원하시는 느낌을 말씀해주세요 ✨\nex) 반려동물과 함께 한강에서 산책하는 모습";
                    // 서버에 넘길 question 텍스트 (고정 질문)
                    sessionStorage.setItem("last_image_question", "이미지에 어떤 분위기와 스타일을 원하시나요?");

                    appendTextBubble(msg, "assistant");
                    chatHistory.push({ role: "assistant", type: "text", content: msg });
                    saveHistory();
                    return;
                }

                /* RECOMMEND: 바로 mode=2로 요청 보내기 */
                if (mode === "RECOMMEND") {

                    // 🔒 서버 요청 가능 여부 체크
                    if (!canSendNewRequest()) {
                        return;
                    }

                    const userMsg = presetMsg || "나에게 맞는 반려동물을 추천해줘";
                    appendTextBubble(userMsg, "user");
                    chatHistory.push({ role: "user", type: "text", content: userMsg });
                    saveHistory();

                    currentMode = null;  // 추천은 단발 요청

                    const loading = appendTextBubble("...", "assistant");
                    try {
                        const data = await sendChatRequest(2, "", userMsg);
                        const answer = data.answer || "추천 결과가 비어 있어요 😢";
                        loading.textContent = answer;

                        chatHistory.push({
                            role: "assistant",
                            type: "text",
                            content: answer
                        });

                        if (data.imageUrl) {
                            appendImageBubble(data.imageUrl);
                            chatHistory.push({
                                role: "assistant",
                                type: "png",
                                url: data.imageUrl
                            });
                        }

                        saveHistory();

                    } catch (e) {
                        console.error(e);
                        loading.textContent = "추천중 오류 발생";
                    } finally {
                        finishRequest();
                    }
                }
            });
        });


        /* ------------------------------
           7. 사용자 입력 처리 (sendMessage)
              - 일반 채팅: mode 없음
              - PROFILE: mode=1, question=마지막 프로필 질문, answer=사용자 입력
              - IMAGE: mode=3, question=고정 질문, answer=사용자 입력
           ------------------------------ */
        async function sendMessage() {
            const text = userInput.value.trim();
            if (!text) return;

            // 🔒 서버 요청 가능 여부 체크
            if (!canSendNewRequest()) {
                return;
            }

            appendTextBubble(text, "user");
            chatHistory.push({ role: "user", type: "text", content: text });
            saveHistory();
            userInput.value = "";

            let modeToUse = currentMode;   // "PROFILE" / "IMAGE" / null
            let questionToSend = "";
            let answerToSend = text;

            if (modeToUse === "PROFILE") {
                questionToSend = sessionStorage.getItem("last_profile_question") || "";
            } else if (modeToUse === "IMAGE") {
                questionToSend =
                    sessionStorage.getItem("last_image_question") ||
                    "이미지에 어떤 분위기와 스타일을 원하시나요?";
            } else {
                // 일반 상담: mode 안 보내고, answer만 전송
                modeToUse = null;
                questionToSend = "";
                answerToSend = text;
            }

            const loading = appendTextBubble("...", "assistant");

            try {
                const data = await sendChatRequest(modeToUse, questionToSend, answerToSend);

                // 공통 응답: { answer, imageUrl, nextQuestion }
                const answerText = data.answer || "응답이 비어 있어요 😢";
                const imageUrl = data.imageUrl;

                loading.textContent = answerText;
                chatHistory.push({
                    role: "assistant",
                    type: "text",
                    content: answerText
                });

                if (imageUrl) {
                    appendImageBubble(imageUrl);
                    chatHistory.push({
                        role: "assistant",
                        type: "png",
                        url: imageUrl
                    });
                }

                saveHistory();
            } catch (e) {
                console.error(e);
                loading.textContent = "서버 오류 발생";
            } finally {
                // 한 번 쓴 모드는 종료 (PROFILE/IMAGE 한턴 끝나면 일반 모드로 복귀)
                currentMode = null;
                finishRequest();
            }
        }

        sendBtn.addEventListener("click", sendMessage);
        userInput.addEventListener("keydown", e => {
            if (e.key === "Enter") sendMessage();
        });

        /* ------------------------------
           8. 로그아웃 시 sessionStorage 초기화
           ------------------------------ */
        function clearChatSession() {
            sessionStorage.removeItem("jpetstore_chat_history");
            sessionStorage.removeItem("jpetstore_chat_open");
            sessionStorage.removeItem("chatHistoryLoadedFromServer");
            sessionStorage.removeItem("last_profile_question");
            sessionStorage.removeItem("last_image_question");
            sessionStorage.removeItem("jpetstore_chat_scroll");
        }

        const logoutLink = document.querySelector('a[href*="signoff="]');

        // 1) 로그아웃 버튼 클릭 시 삭제
        if (logoutLink) {
            logoutLink.addEventListener("click", clearChatSession);
        }

        // 2) URL에 signoff= 가 포함된 경우(리다이렉트 페이지)도 삭제
        if (location.href.includes("signoff=")) {
            clearChatSession();
        }

        /* ------------------------------
           9. 초기화
           ------------------------------ */
        (async function () {
            await initChatFromServer();
            loadOpenState();
        })();

    })();
</script>
