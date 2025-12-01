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
<%@ page pageEncoding="UTF-8" %>

<style>
    .case {
        display: flex;
        align-items: flex-start;
        gap: 20px;
        width: 100%;
    }

    .chat-container {
        width: 300px;
        height: 430px;
        border: 1px solid #ccc;
        border-radius: 6px;
        padding: 10px;
        overflow-y: auto;
        background: #f9f9f9;
        box-sizing: border-box;
    }

    .data-container {
        width: 300px;
        height: 430px;
        border: 1px solid #ccc;
        border-radius: 6px;
        padding: 10px;
        overflow-y: auto;
        background: #f9f9f9;
        box-sizing: border-box;
    }

    .msg {
        max-width: 80%;
        margin-bottom: 12px;
        padding: 8px 12px;
        border-radius: 8px;
        font-size: 14px;
        line-height: 1.4;
        word-break: break-word;
    }

    .msg.bot {
        background: #e2e2ff;
        align-self: flex-start;
    }

    .msg.me {
        background: #d0f0d0;
        align-self: flex-end;
        margin-left: auto;
    }

    .chat-input {
        margin-top: 10px;
        display: flex;
        gap: 8px;
    }

    .chat-input input {
        flex: 1;
        padding: 8px;
        border: 1px solid #ccc;
        border-radius: 6px;
    }

    .chat-input button {
        padding: 8px 14px;
        cursor: pointer;
    }

    .pet-health dl {
        margin: 0;
        font-size: 13px;
    }

    .pet-health dt {
        font-weight: 600;
        margin-top: 8px;
    }

    .pet-health dd {
        margin: 0 0 6px 6px;
        white-space: pre-wrap;
    }
</style>

<div class="case">
    <div>
        <div class="chat-container"></div>

        <div class="chat-input">
            <input id="chatInput" type="text" placeholder="메시지 입력"
                   onkeydown="handleEnter(event)">
            <button onclick="addMyMessage()">Send</button>
        </div>
    </div>

    <!-- 받은 데이터 표시용 -->
    <div class="data-container"></div>
</div>

<script>
    const dataContainer = document.querySelector('.data-container');
    const chatContainer = document.querySelector('.chat-container');
    const chatInput = document.getElementById('chatInput');

    let latestPetHealth = {};
    let latestHistory = [];
    window.currentPetId = null;

    const hiddenKeys = ["pet_id"];

    const LABELS = {
        pet_id: "ID",
        breed: "품종",
        name: "이름",
        age: "나이",
        weight: "무게(kg)",
        sex: "성별",
        appetite: "식욕",
        meal_frequency: "급여 횟수",
        water_intake: "물 섭취",
        activity_level: "활동량",
        sleep_pattern: "수면 패턴",
        behavior_change: "행동 변화",
        stool_condition: "배변 상태",
        urine_frequency: "배뇨 빈도",
        skin_condition: "피부 상태",
        eye_condition: "눈 상태",
        breathing_condition: "호흡 상태",
        energy_level: "에너지 수준",
        last_checkup_date: "마지막 진찰일",
        vaccination_status: "예방접종",
        medication: "약물",
        chronic_condition: "만성질환",
        living_environment: "생활환경",
        recent_stress_event: "최근 스트레스"
    };

    // ----------------------------
    // 공통 메시지 UI 유틸
    // ----------------------------
    function addSystemMessage(text) {
        const el = document.createElement('div');
        el.classList.add('msg', 'bot');
        el.innerText = text;
        chatContainer.appendChild(el);
    }

    function addHistoryMessage(role, content) {
        const el = document.createElement('div');
        if (role === 'user') {
            el.classList.add('msg', 'me');
        } else {
            el.classList.add('msg', 'bot');
        }
        el.innerText = content;
        chatContainer.appendChild(el);
    }

    function scrollToBottom() {
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }

    // ----------------------------
    // HEALTH_DATA 로드 / 저장
    // ----------------------------
    async function loadPetHealth() {
        if (!window.currentPetId) return;

        const res = await fetch(
            `/jpetstore/actions/PetHealth.action?event=get&orderId=\${window.currentPetId}`
        );

        if (!res.ok) {
            latestPetHealth = {};
            return;
        }
        latestPetHealth = await res.json();
    }

    async function saveHealthData() {
        if (!window.currentPetId) return;
        await fetch("/jpetstore/actions/PetHealth.action?event=save", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                event: "save",
                orderId: window.currentPetId,
                healthDetail: latestPetHealth
            })
        });
    }

    // ----------------------------
    // 채팅 히스토리 로드 / 저장
    // ----------------------------
    async function loadHistory() {
        if (!window.currentPetId) return [];
        const res = await fetch(
            `/jpetstore/actions/PetHealth.action?event=getHistory&orderId=\${window.currentPetId}`
        );
        if (!res.ok) {
            return [];
        }
        const history = await res.json();
        return Array.isArray(history) ? history : [];
    }

    async function saveChatMessage(role, content) {
        if (!window.currentPetId) return;
        try {
            await fetch("/jpetstore/actions/PetHealth.action?event=saveMessage", {
                method: "POST",
                headers: {
                    "Content-Type": "application/json; charset=UTF-8"
                },
                body: JSON.stringify({
                    event: "saveMessage",
                    orderId: window.currentPetId,
                    role: role,      // "user" 또는 "assistant"
                    content: content // 실제 저장할 메시지 텍스트
                })
            });
        } catch (e) {
            console.error("saveChatMessage error", e);
        }
    }

    // ----------------------------
    // HEALTH_DATA 렌더링
    // ----------------------------
    function renderPetHealth() {
        dataContainer.innerHTML = '';
        const ph = latestPetHealth || {};

        const dl = document.createElement('dl');
        dl.classList.add('pet-health');

        Object.keys(ph).forEach((key) => {
            if (hiddenKeys.includes(key)) return;
            const value = ph[key];
            if (value === null || value === undefined || value === "") return;

            const dt = document.createElement('dt');
            dt.textContent = LABELS[key] || key;
            dl.appendChild(dt);

            const dd = document.createElement('dd');
            dd.textContent = value;
            dl.appendChild(dd);
        });

        dataContainer.appendChild(dl);
    }

    // ----------------------------
    // 채팅 한 턴
    // ----------------------------
    async function addMyMessage() {
        const text = chatInput.value.trim();
        if (!text) return;
        chatInput.value = "";

        // 1) 내 메시지 UI + DB 저장
        addHistoryMessage('user', text);
        saveChatMessage('user', text);

        // 2) FastAPI로 분석 요청
        let raw;
        try {
            const response = await fetch("/jpetstore/chat/analyze_health", {
                method: "POST",
                headers: { "Content-Type": "application/json; charset=UTF-8" },
                body: JSON.stringify({
                    pet_health: latestPetHealth,
                    history: latestHistory,
                    msg: text
                })
            });

            raw = await response.json();
        } catch (e) {
            console.error(e);
            addHistoryMessage('assistant', "서버 오류가 발생했습니다.");
            return;
        }

        // 3) pet_health / history 갱신
        latestPetHealth = raw.pet_health || latestPetHealth || {};
        latestHistory   = raw.history    || latestHistory   || [];

        // 4) HEALTH_DATA 저장 + 렌더링
        await saveHealthData();
        renderPetHealth();

        // 5) 챗봇 응답 텍스트 결정
        const replyText =
            (raw.msg && raw.msg.trim()) ||
            (raw.message && raw.message.trim()) ||
            (raw.text && raw.text.trim()) ||
            "응답이 비어 있습니다.";

        // 6) 봇 메시지 UI + DB 저장
        addHistoryMessage('assistant', replyText);
        saveChatMessage('assistant', replyText);

        scrollToBottom();
    }

    // ----------------------------
    // 채팅 세션 초기화 (listOrders.jsp에서 호출)
    // ----------------------------
    async function initChatSession(orderId) {
        window.currentPetId = orderId;
        chatContainer.innerHTML = "";

        // 인사말 (DB에는 저장하지 않음)
        addSystemMessage("반려동물 품종이 뭐예요?");

        // HEALTH_DATA 로드
        await loadPetHealth();
        renderPetHealth();

        // 히스토리 로드
        const history = await loadHistory();
        history.forEach((msg) => {
            addHistoryMessage(msg.role, msg.content);
        });

        scrollToBottom();
    }

    // ----------------------------
    // Enter 키 처리
    // ----------------------------
    function handleEnter(e) {
        if (e.key === "Enter") {
            addMyMessage();
        }
    }
</script>
