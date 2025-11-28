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
        width: 320px;
        max-height: 420px;
        font-family: system-ui, sans-serif;
        z-index: 9999;
    }

    #chatbot-toggle-btn {
        background: #4f46e5;
        color: #fff;
        border: none;
        border-radius: 999px;
        padding: 10px 14px;
        font-size: 14px;
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
        height: 380px;
        flex-direction: column;
        overflow: hidden;
    }

    #chatbot-header {
        background: #fff;
        padding: 12px 16px;
        border-bottom: 1px solid #eee;
        font-size: 14px;
        line-height: 1.4;
    }

    #chatbot-messages {
        flex: 1;
        overflow-y: auto;
        background: #f9fafb;
        padding: 12px;
    }

    .bubble {
        max-width: 80%;
        margin-bottom: 10px;
        padding: 10px 12px;
        border-radius: 14px;
        line-height: 1.4;
        box-shadow: 0 4px 10px rgba(0,0,0,0.07), 0 2px 4px rgba(0,0,0,0.05);
        word-break: break-word;
        white-space: pre-wrap;
        font-size: 13px;
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
        max-width: 220px;
        border-radius: 12px;
        display: block;
    }

    #chatbot-input-area {
        background: #fff;
        border-top: 1px solid #eee;
        display: flex;
        flex-direction: column;
        gap: 6px;
        padding: 10px;
    }

    #chatbot-user-input {
        flex: 1;
        border: 1px solid #d1d5db;
        border-radius: 8px;
        padding: 8px 10px;
        font-size: 13px;
    }

    #chatbot-send-btn {
        background: #4f46e5;
        color: #fff;
        border-radius: 8px;
        font-weight: 500;
        font-size: 13px;
        padding: 8px 10px;
        border: none;
        cursor: pointer;
    }

    #chatbot-quick-area {
        display: flex;
        gap: 4px;
        flex-wrap: wrap;
        margin-bottom: 6px;
    }

    .chatbot-quick-btn {
        flex: 1;
        border: 1px solid #e5e7eb;
        border-radius: 999px;
        padding: 5px 8px;
        font-size: 11px;
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
                        data-msg="너를 설명해줘"
                        data-mode="PROFILE">너를 알고 싶어 ^.^</button>

                <button class="chatbot-quick-btn"
                        data-msg="어떤 동물 추천해줄까?"
                        data-mode="RECOMMEND">동물 추천 XD</button>

                <button class="chatbot-quick-btn"
                        data-msg="지금까지의 너의 정보를 바탕으로 반려동물과 함께할 너의 미래를 그려줄께!! 어떤 동물을 그려줄까?"
                        data-mode="IMAGE">반려동물과 함께하는 미래~</button>
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

        let currentMode = null;
        let chatHistory = [];
        let isOpen = false;

        /* ------------------------------
           1. 랜덤 질문 목록(PROFILE)
           ------------------------------ */
        const profileQuestions = [
            "너의 하루 루틴을 간단히 설명해줄래?",
            "집에서 보내는 시간이 많아? 아니면 밖에서 보내는 시간이 많아?",
            "주말에는 보통 무엇을 하면서 보내?",
            "사람 많은 곳이 좋아? 조용한 곳이 좋아?",
            "너가 생각하는 너의 성격은 어떤 편이야?",
            "요즘 가장 즐기는 취미나 활동이 있다면 뭐야?",
            "하루 중 좋아하는 시간대와 이유가 있다면 알려줘.",
            "스트레스 받을 때 보통 어떻게 풀어?",
            "반려동물과 함께한다면 어떤 순간을 가장 기대해?",
            "너가 사는 집 분위기(활발/차분/가족 수)를 알려줄래?"
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
            finalizeScroll();
        }

        /* ------------------------------
           3. 서버에서 기록 1회만 불러오기
           ------------------------------ */
        async function loadServerChatHistory() {
            try {
                const resp = await fetch("<%=request.getContextPath()%>/api/chat/history", {
                    method: "GET"
                });

                if (!resp.ok) return [];
                return await resp.json();

            } catch (e) {
                return [];
            }
        }

        //여기에 created_At을 어떻게 처리할지 결정할 것 API보고
        async function initChatFromServer() {
            const loadedFlag = sessionStorage.getItem("chatHistoryLoadedFromServer");

            if (loadedFlag === "true") {
                loadLocalHistory();
                return;
            }

            const logs = await loadServerChatHistory();
            if (!logs || logs.length === 0) {
                loadLocalHistory();
                return;
            }

            // 🔥 created_at 기준으로 오름차순 정렬 (과거 → 최근)
            // logs.sort((a, b) => new Date(a.created_at) - new Date(b.created_at));

            messagesDiv.innerHTML = "";
            chatHistory = [];

            for (const log of logs) {
                appendTextBubble(log.question, "assistant", false);
                chatHistory.push({ role: "assistant", type: "text", content: log.question });

                if (log.answer && log.answer.trim() !== "") {
                    appendTextBubble(log.answer, "user", false);
                    chatHistory.push({ role: "user", type: "text", content: log.answer });
                }
            }

            finalizeScroll();
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
            return div;        // 🔥 수정: div 반환
        }

        function appendImageBubble(url, scroll = true) {
            const div = document.createElement("div");
            div.classList.add("bubble", "bot-image");
            const img = document.createElement("img");
            img.src = url;
            div.appendChild(img);
            messagesDiv.appendChild(div);
            if (scroll) finalizeScroll();
            return div;        // 🔥 수정: div 반환
        }

        function finalizeScroll() {
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        toggleBtn.addEventListener("click", () => {
            isOpen = !isOpen;
            panel.style.display = isOpen ? "flex" : "none";
            saveOpenState();
        });

        /* ------------------------------
           5. 서버 요청 (chat/log)
           ------------------------------ */
        async function sendModeLog(mode, question, answer) {
            const resp = await fetch("<%=request.getContextPath()%>/api/chat/log", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ mode, question, answer })
            });

            if (!resp.ok) throw new Error("chat/log 실패");
            return await resp.json();   // {mode, answer}
        }


        /* ------------------------------
           6. 버튼 클릭 처리 (PROFILE / RECOMMEND / IMAGE)
           ------------------------------ */
        quickBtns.forEach(btn => {
            btn.addEventListener("click", async () => {
                const mode = btn.dataset.mode;
                let msg = "";
                currentMode = mode;

                /* PROFILE */
                if (mode === "PROFILE") {
                    if (remainingProfileQuestions.length === 0)
                        remainingProfileQuestions = [...profileQuestions];

                    const idx = Math.floor(Math.random() * remainingProfileQuestions.length);
                    msg = remainingProfileQuestions[idx];
                    remainingProfileQuestions.splice(idx, 1);

                    sessionStorage.setItem("last_profile_question", msg);

                    appendTextBubble(msg, "assistant");
                    chatHistory.push({ role: "assistant", type: "text", content: msg });
                    saveHistory();
                    return;
                }

                /* IMAGE */
                if (mode === "IMAGE") {
                    msg = "지금까지의 너의 정보를 바탕으로 반려동물과 함께할 너의 미래를 그려줄께!! 어떤 동물을 그려줄까?";
                    sessionStorage.setItem("last_image_question", "동물 그려줄까?");

                    appendTextBubble(msg, "assistant");
                    chatHistory.push({ role: "assistant", type: "text", content: msg });
                    saveHistory();
                    return;
                }

                /* RECOMMEND */
                if (mode === "RECOMMEND") {
                    msg = "너의 데이터를 기반으로 추천해줄게";
                    currentMode = null;

                    appendTextBubble(msg, "assistant");
                    chatHistory.push({ role: "assistant", type: "text", content: msg });
                    saveHistory();

                    // 🔥 서버 요청 후 답변 출력
                    const loading = appendTextBubble("...", "assistant");
                    try {
                        const data = await sendModeLog("RECOMMEND", msg, "");
                        loading.textContent = data.answer || "응답이 비어 있어요 😢";

                        chatHistory.push({
                            role: "assistant",
                            type: "text",
                            content: data.answer
                        });
                        saveHistory();

                    } catch (e) {
                        loading.textContent = "추천중 오류 발생";
                    }
                }
            });
        });


        /* ------------------------------
           7. 사용자 입력 처리 (sendMessage)
           ------------------------------ */
        async function sendMessage() {
            const text = userInput.value.trim();
            if (!text) return;

            appendTextBubble(text, "user");
            chatHistory.push({ role: "user", type: "text", content: text });
            saveHistory();
            userInput.value = "";

            let modeToUse = currentMode;
            let questionToSend = "";
            let answerToSend = text;

            if (modeToUse === "PROFILE") {
                questionToSend = sessionStorage.getItem("last_profile_question") || "";
            }
            else if (modeToUse === "IMAGE") {
                questionToSend = "동물 그려줄까?";
            }
            else {
                modeToUse = null;
                questionToSend = text;
                answerToSend = "";
            }

            const loading = appendTextBubble("...", "assistant");

            try {
                const data = await sendModeLog(modeToUse, questionToSend, answerToSend);

                const modeFromServer = data.mode;
                const answer = data.answer;

                if (modeFromServer === "IMAGE") {
                    loading.textContent = "정말 잘어울려!!";

                    chatHistory.push({
                        role: "assistant",
                        type: "text",
                        content: "정말 잘어울려!!"
                    });

                    appendImageBubble(answer);
                    chatHistory.push({
                        role: "assistant",
                        type: "png",   // 🔥 수정: "png" → "image"
                        url: answer
                    });

                } else {
                    loading.textContent = answer;
                    chatHistory.push({
                        role: "assistant",
                        type: "text",
                        content: answer
                    });
                }

                saveHistory();
            } catch (e) {
                loading.textContent = "서버 오류 발생";
            }

            currentMode = null;
        }

        sendBtn.addEventListener("click", sendMessage);
        userInput.addEventListener("keydown", e => {
            if (e.key === "Enter") sendMessage();
        });

        /* ------------------------------
           8. 초기화
           ------------------------------ */
        (async function () {
            await initChatFromServer();
            loadOpenState();
        })();

    })();
</script>
