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
    let latestPetHealth = {};
    let latestHistory = [];

    // 숨길 요소 생기면, 여기에 추가하면 됨.
    const hiddenKeys = [];

    // 필드 키 -> 사용자 표시명(간단 매핑)
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

    function renderData(raw) {
        dataContainer.innerHTML = '';
        if (!raw) return;

        // JSON 객체인지?
        if (typeof raw === 'object' && raw !== null) {

            // pet_health가 존재하면 → 전용 렌더러 실행
            if (raw.pet_health && typeof raw.pet_health === 'object') {
                renderPetHealth(raw.pet_health);
                return;
            }
        }

        // pet_health 없거나 문자열/기타 객체인 경우 → 워닝 메시지
        const warningMsg = document.createElement('div');
        warningMsg.textContent = "오류: 메시지가 자유 의지를 주장하며 탈출을 감행함.\n현재 수색 중.";
        dataContainer.appendChild(warningMsg);
    }

    // ------------------------
    // pet_health 전용 출력
    // ------------------------
    function renderPetHealth(ph) {
        const keys = Object.keys(ph);
        if (keys.length === 0) return;   // 빈 객체면 표시 안 함

        const dl = document.createElement('dl');
        dl.style.margin = '0';
        dl.style.fontSize = '13px';

        for (const key of keys) {
            if (hiddenKeys.includes(key)) continue;

            const label = LABELS[key] || key;
            const value = ph[key] === null ? '' : String(ph[key]);

            const dt = document.createElement('dt');
            dt.textContent = label;
            dt.style.fontWeight = '600';
            dt.style.marginTop = '8px';

            const dd = document.createElement('dd');
            dd.textContent = value;
            dd.style.margin = '0 0 6px 6px';
            dd.style.whiteSpace = 'pre-wrap';

            dl.appendChild(dt);
            dl.appendChild(dd);
        }

        dataContainer.appendChild(dl);
    }

    // ------------------------
    // JSON 전체 출력 (pet_health 없는 객체)
    // ------------------------
    /*
    function renderJson(obj) {
        const pre = document.createElement('pre');
        pre.style.whiteSpace = 'pre-wrap';
        pre.style.fontSize = '12px';
        pre.textContent = JSON.stringify(obj, null, 2);
        dataContainer.appendChild(pre);
    }*/

    // ------------------------
    // 문자열 그대로 출력
    // ------------------------
    /*function renderText(str) {
        const txt = document.createElement('div');
        txt.textContent = str;
        txt.style.whiteSpace = 'pre-wrap';
        dataContainer.appendChild(txt);
    }*/

    function scrollToBottom() {
        const container = document.querySelector('.chat-container');
        container.scrollTop = container.scrollHeight;
    }

    // 메시지 보내기
    async function addMyMessage() {
        const input = document.getElementById("chatInput");
        const text = input.value.trim();
        if (text === "") return;

        const container = document.querySelector('.chat-container');

        // 1) 내 메시지 출력
        const myMsg = document.createElement("div");
        myMsg.classList.add("msg", "me");
        myMsg.innerText = text;
        container.appendChild(myMsg);
        input.value = "";

        // 2) 서버에 메시지 전송
        let raw;
        let replyText = "";

        try {
            //const response = await fetch("chat/analyze_health", {
            const response = await fetch("/jpetstore/chat/analyze_health", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    pet_health: latestPetHealth ?? {},
                    history: [
                        ...(latestHistory ?? []),
                        { role: "user", content: text }
                    ],
                    msg: text
                })
            });

            // ★ 항상 문자열로 먼저 받기
            let textResponse = await response.text();

            // ★ JSON 파싱 시도
            try {
                raw = JSON.parse(textResponse);
            } catch {
                raw = textResponse;  // JSON 아니면 문자열로 처리
            }

            // JSON이면 최신 데이터 업데이트
            if (typeof raw === "object" && raw !== null) {
                latestPetHealth = raw.pet_health ?? latestPetHealth ?? {};
                latestHistory = raw.history ?? latestHistory ?? [];

                if (raw.pet_health) {
                    renderData(raw);
                }
            }

        } catch (e) {
            console.error(e);
            replyText = "서버 오류가 발생했습니다.";
        }

        // 3) 응답 텍스트 결정
        if (typeof raw === "string") {
            replyText = raw;
        } else if (typeof raw === "object" && raw !== null) {
            if (typeof raw.msg === "string" && raw.msg.trim() !== "") {
                replyText = raw.msg;
            }
            else if (typeof raw.message === "string") {
                replyText = raw.message;
            }
            else if (typeof raw.text === "string") {
                replyText = raw.text;
            }
            else {
                replyText = JSON.stringify(raw);
            }
        } else {
            replyText = "알 수 없는 응답입니다.";
        }

        // 4) 봇 메시지 출력
        const botMsg = document.createElement("div");
        botMsg.classList.add("msg", "bot");
        botMsg.innerText = replyText;
        container.appendChild(botMsg);

        requestAnimationFrame(() => scrollToBottom());
    }

    function handleEnter(event) {
        if (event.key === "Enter") {
            addMyMessage();
        }
    }

    // 히스토리 로드 (orderId 기반)
    async function loadHistory(orderId) {
        const container = document.querySelector('.chat-container');
        container.innerHTML = "";

        let raw;

        try {
            const response = await fetch(`/chat/history?orderId=${orderId}`, {
                method: "GET",
                headers: { "Accept": "application/json" }
            });

            const contentType = response.headers.get("content-type");

            if (contentType && contentType.includes("application/json")) {
                raw = await response.json();
            } else {
                raw = [];
            }
        } catch (e) {
            console.error("History load failed:", e);
            return;
        }

        if (!Array.isArray(raw)) return;

        raw.forEach(msg => {
            const div = document.createElement("div");
            const sender = msg.sender === "me" ? "me" : "bot";

            div.classList.add("msg", sender);
            div.innerText = msg.text || msg.message || JSON.stringify(msg);

            container.appendChild(div);
        });

        // 서버에 보낼 latestHistory도 동기화
        latestHistory = raw.map(msg => ({
            role: msg.sender === "me" ? "user" : "assistant",
            content: msg.text || msg.message || ""
        }));

        scrollToBottom();
    }
</script>