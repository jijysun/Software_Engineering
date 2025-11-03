<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
<%-- /WEB-INF/jsp/common/chatbotWidget.jsp --%>
<style>
    /* 고정 위치 컨테이너 */
    #chatbot-container {
        position: fixed;
        right: 24px;
        bottom: 24px;
        width: 320px;
        max-height: 420px;
        font-family: system-ui, sans-serif;
        z-index: 9999;
    }

    /* 토글 버튼 */
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

    /* 실제 채팅 박스 */
    #chatbot-panel {
        display: none; /* 기본은 닫혀있음, 버튼 누르면 열림 */
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 20px 40px rgba(0,0,0,0.18);
        border: 1px solid #ccc;
        margin-top: 8px;
        height: 380px;
        display: flex;
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

    #chatbot-header b {
        font-size: 14px;
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
    .loading-dots {
        opacity: 0.5;
        font-style: italic;
    }

    #chatbot-input-area {
        background: #fff;
        border-top: 1px solid #eee;
        display: flex;
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
</style>

<div id="chatbot-container">
    <button id="chatbot-toggle-btn">💬 문의하기</button>

    <div id="chatbot-panel">
        <div id="chatbot-header">
            <b>JPetStore 챗봇 🐾</b><br/>
            궁금한 걸 물어보세요!
        </div>

        <div id="chatbot-messages">
            <div class="bubble bot">
                안녕하세요! JPetStore 챗봇입니다 🐾
                무엇을 도와드릴까요?
            </div>
        </div>

        <div id="chatbot-input-area">
            <input
                    id="chatbot-user-input"
                    type="text"
                    placeholder="예) 강아지 사료 추천해줘"
            />
            <button id="chatbot-send-btn">보내기</button>
        </div>
    </div>
</div>

<script>
    (function(){
        const toggleBtn   = document.getElementById("chatbot-toggle-btn");
        const panel       = document.getElementById("chatbot-panel");
        const messagesDiv = document.getElementById("chatbot-messages");
        const userInput   = document.getElementById("chatbot-user-input");
        const sendBtn     = document.getElementById("chatbot-send-btn");

        // ---------------------------
        // 0. 세션(창 단위) 저장소
        // ---------------------------
        let chatHistory = [];
        let isOpen = false;

        // 대화 내역 저장 (sessionStorage 사용)
        function saveHistory() {
            sessionStorage.setItem("jpetstore_chat_history", JSON.stringify(chatHistory));
        }

        // 대화 내역 불러오기
        function loadHistory() {
            const raw = sessionStorage.getItem("jpetstore_chat_history");
            if (raw) {
                try {
                    const arr = JSON.parse(raw);
                    if (Array.isArray(arr)) chatHistory = arr;
                } catch (e) {
                    console.warn("history parse failed", e);
                }
            }

            if (chatHistory.length === 0) {
                chatHistory = [{
                    role: "assistant",
                    content: "안녕하세요! JPetStore 챗봇입니다 🐾 무엇을 도와드릴까요?"
                }];
            }

            messagesDiv.innerHTML = "";
            for (const msg of chatHistory) {
                appendBubble(msg.content, msg.role, false, false);
            }
            finalizeScroll();
        }

        // 열림/닫힘 상태 저장
        function saveOpenState() {
            sessionStorage.setItem("jpetstore_chat_open", isOpen ? "true" : "false");
        }

        // 열림/닫힘 상태 불러오기
        function loadOpenState() {
            const raw = sessionStorage.getItem("jpetstore_chat_open");
            isOpen = (raw === "true");
            applyOpenState();
        }

        // ---------------------------
        // 1. UI 유틸리티
        // ---------------------------
        function appendBubble(text, role, isLoading=false, shouldScroll=true) {
            const div = document.createElement("div");
            div.classList.add("bubble");
            div.classList.add(role === "user" ? "user" : "bot");
            if (isLoading) div.classList.add("loading-dots");
            div.textContent = text;
            messagesDiv.appendChild(div);
            if (shouldScroll) finalizeScroll();
            return div;
        }

        function finalizeScroll() {
            messagesDiv.scrollTop = messagesDiv.scrollHeight;
        }

        function applyOpenState() {
            panel.style.display = isOpen ? "flex" : "none";
        }

        // ---------------------------
        // 2. 챗봇 토글 버튼
        // ---------------------------
        toggleBtn.addEventListener("click", () => {
            isOpen = !isOpen;
            applyOpenState();
            saveOpenState();
        });

        // ---------------------------
        // 3. 메시지 전송 로직
        // ---------------------------
        async function sendMessage() {
            const text = userInput.value.trim();
            if (!text) return;

            appendBubble(text, "user");
            chatHistory.push({ role: "user", content: text });
            saveHistory();

            const botBubbleEl = appendBubble("...", "bot", true);
            let botTextAccum = "";

            const response = await fetch("<%=request.getContextPath()%>/api/chat/stream", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ messages: chatHistory })
            });

            if (!response.ok || !response.body) {
                botBubbleEl.textContent = "죄송해요. 답변 중 문제가 발생했어요.";
                chatHistory.push({ role: "assistant", content: "죄송해요. 답변 중 문제가 발생했어요." });
                saveHistory();
                finalizeScroll();
                userInput.value = "";
                return;
            }

            const reader = response.body.getReader();
            const decoder = new TextDecoder("utf-8");

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;
                const chunkText = decoder.decode(value, { stream: true });
                const lines = chunkText.split("\n");

                for (const line of lines) {
                    if (!line.startsWith("data:")) continue;
                    const dataStr = line.replace(/^data:\s*/, "");
                    if (dataStr === "[DONE]") break;

                    try {
                        const json = JSON.parse(dataStr);
                        if (json.delta) {
                            botTextAccum += json.delta;
                            botBubbleEl.textContent = botTextAccum;
                            finalizeScroll();
                        }
                    } catch (e) {
                        console.warn("JSON parse error", e);
                    }
                }
            }

            chatHistory.push({ role: "assistant", content: botTextAccum });
            saveHistory();
            finalizeScroll();
            userInput.value = "";
        }

        sendBtn.addEventListener("click", sendMessage);
        userInput.addEventListener("keydown", e => {
            if (e.key === "Enter") sendMessage();
        });

        // ---------------------------
        // 4. 초기화
        // ---------------------------
        loadHistory();     // 세션 내 대화 불러오기
        loadOpenState();   // 열림/닫힘 복원
    })();
</script>
