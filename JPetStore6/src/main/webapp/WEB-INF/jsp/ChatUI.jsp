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

    <!-- 받은 데이터 표시용, jsp 내에서 토글로 공개 여부 설정 가능 -->
    <div class="data-container">

    </div>
</div>

<script>
    const dataContainer = document.querySelector('.data-container');
    const chatContainer = document.querySelector('.chat-container');
    const chatInput = document.getElementById('chatInput');

    let latestPetHealth = {};
    let latestHistory = [];
    let currentPetId = null;
    let isChatInitialized = false;

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

    function addMessageToUI(msg) {
        const el = document.createElement('div');
        el.classList.add('msg', msg.role);
        el.innerText = msg.message;
        chatContainer.appendChild(el);
    }

    async function addMyMessage() {
        const text = chatInput.value;
        chatInput.value = "";

        // 내 메시지
        const myMsg = document.createElement("div");
        myMsg.classList.add("msg", "me");
        myMsg.innerText = text;
        chatContainer.appendChild(myMsg);

        // 서버 전송 (실패 시 어차피 터짐)
        const response = await fetch("/jpetstore/chat/analyze_health", {
            method: "POST",
            headers: { "Content-Type": "application/json; charset=UTF-8" },
            body: JSON.stringify({
                pet_health: latestPetHealth,
                history: [...latestHistory, { role: "user", content: text }],
                msg: text
            })
        });

        const raw = await response.json();

        latestPetHealth = raw.pet_health;
        latestHistory = raw.history;

        await saveHealthData();

        renderPetHealth();

        // 서버가 msg를 항상 준다고 믿는다
        const replyText = raw.msg;

        const botMsg = document.createElement("div");
        botMsg.classList.add("msg", "bot");
        botMsg.innerText = replyText;
        chatContainer.appendChild(botMsg);

        scrollToBottom();
    }

    // --------------------------------------------------------------------------------------
    // 채팅 시작
    // --------------------------------------------------------------------------------------
    async function initChatSession(orderId) {
        currentPetId = orderId;
        chatContainer.innerHTML = "";

        addMessageToUI({
            role: "bot",
            message: "반려동물 품종이 뭐예요?"
        });

        await loadPetHealth();

        renderPetHealth();

        scrollToBottom();
    }

    async function saveHealthData() {
        const res = await fetch("/jpetstore/actions/PetHealth.action?event=save", {
            method: "POST",
            headers: {
                "Content-Type": "application/json"
            },
            body: JSON.stringify({
                event: "save",
                orderId: currentPetId,
                healthDetail: latestPetHealth
            })
        });

        return await res.json();
    }

    // --------------------------------------------------------------------------------------
    // 히스토리 로드 (서버가 항상 배열만 보내준다고 믿는다)
    // --------------------------------------------------------------------------------------
    async function loadPetHealth() {
        const res = await fetch(`/jpetstore/actions/PetHealth.action?event=get&orderId=` + currentPetId);
        latestPetHealth = await res.json();
    }

    // --------------------------------------------------------------------------------------
    // 데이터 렌더러 (검증 없음)
    // --------------------------------------------------------------------------------------
    function renderPetHealth() {
        dataContainer.innerHTML = '';
        const ph = latestPetHealth;
        const dl = document.createElement('dl');
        dl.classList.add('pet-health');

        for (const key of Object.keys(ph)) {
            if (hiddenKeys.includes(key)) continue;
            if (ph[key] === null) continue;

            const dt = document.createElement('dt');
            dt.textContent = LABELS[key];
            dl.appendChild(dt);

            const dd = document.createElement('dd');
            dd.textContent = ph[key];
            dl.appendChild(dd);
        }

        dataContainer.appendChild(dl);
    }

    // --------------------------------------------------------------------------------------
    // 채팅 UI
    // --------------------------------------------------------------------------------------
    function scrollToBottom() {
        chatContainer.scrollTop = chatContainer.scrollHeight;
    }

</script>