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

    .msg.assistant {
        background: #e2e2ff;
        color: black;
        align-self: flex-start;
    }

    .msg.user {
        background: #d0f0d0;
        color: black;
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
            <input id="chatInput" type="text" placeholder="메시지 입력" onkeydown="handleEnter(event)">
            <button onclick="sendChatMessage()">전송</button>
        </div>
    </div>

    <!-- 받은 데이터 표시용 -->
    <div class="data-container"></div>
</div>

<script>
    // 나는 겁쟁이 같은 코딩은 하지 않는다.
    // 나는 동료를 믿는다.
    const dataContainer = document.querySelector('.data-container');
    const chatContainer = document.querySelector('.chat-container');
    const chatInput = document.getElementById('chatInput');

    let latestPetHealth = {};
    let latestHistory = [];
    let currentPetId = null;

    const hiddenKeys = [
        "pet_id"
    ];

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
    // 건강 데이터 로직
    // ----------------------------
    async function loadHealthData() {
        const res = await fetch(`/jpetstore/actions/PetHealth.action?event=get&orderId=\${currentPetId}`);
        latestPetHealth = await res.json();
    }

    async function saveHealthData() {
        await fetch("/jpetstore/actions/PetHealth.action?event=save", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({
                orderId: currentPetId,
                healthDetail: latestPetHealth
            })
        });
    }

    function addHealthData() {
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
    // 채팅 메시지 로직
    // ----------------------------
    async function loadChatMessage() {
        const res = await fetch(`/jpetstore/actions/PetHealth.action?event=getHistory&orderId=\${currentPetId}`);
        return await res.json();
    }

    async function saveChatMessage(role, content) {
        await fetch("/jpetstore/actions/PetHealth.action?event=saveMessage", {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8"
            },
            body: JSON.stringify({
                orderId: currentPetId,
                role: role,
                content: content
            })
        });
    }

    function addChatMessage(role, content) {
        const el = document.createElement('div');
        el.classList.add('msg', role);
        el.innerText = content;
        chatContainer.appendChild(el);
    }

    // ----------------------------
    // 채팅 입력 로직
    // ----------------------------
    async function sendChatMessage() {
        const userMessage = chatInput.value;
        chatInput.value = "";

        addChatMessage('user', userMessage);
        await saveChatMessage('user', userMessage);

        // 프론트 엔드 히스토리에 사용자 메시지 추가
        latestHistory.push({
            role: "user",
            content: userMessage
        });

        const response = await fetch("/jpetstore/chat/analyze_health", {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            body: JSON.stringify({
                pet_health: latestPetHealth,
                history:    latestHistory,
                msg:        userMessage
            })
        });

        let raw = await response.json();

        latestPetHealth = raw.pet_health;
        //latestHistory   = raw.history;    <-- 덮어씌우면 비어버림 ㄴㄴ

        const botMessage = raw.msg || "메시지가 자아를 찾아 여행을 떠났습니다.";

        addChatMessage('assistant', botMessage);
        await saveChatMessage('assistant', botMessage);

        // assistant 메시지도 history에 추가
        latestHistory.push({
            role: "assistant",
            content: botMessage
        });

        addHealthData();
        await saveHealthData();

        autoScroll();
    }

    // ----------------------------
    // 채팅 오픈 로직
    // ----------------------------
    async function initChatSession(orderId) {
        currentPetId = orderId;
        chatContainer.innerHTML = "";

        addChatMessage('assistant' ,"반려동물 품종이 뭐예요?");

        // HEALTH_DATA 로드
        await loadHealthData();
        addHealthData();

        // 히스토리 로드
        latestHistory = await loadChatMessage();
        latestHistory.forEach((msg) => {
            addChatMessage(msg.role, msg.content);
        });

        autoScroll();
    }

    // ----------------------------
    // Enter 키 처리
    // ----------------------------
    function handleEnter(e) {
        if (e.key === "Enter") {
            sendChatMessage();
        }
    }

    // ----------------------------
    // 자동 스크롤
    // ----------------------------
    function autoScroll() {
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }
</script>