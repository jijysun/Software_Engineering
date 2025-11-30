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
<%-- 이건 내가 만든 코드인데 ^^ 이건 뭐냐? --%>
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
    // 안전한 요소 참조
    const dataContainer = document.querySelector('.data-container');
    const chatContainerEl = document.querySelector('.chat-container');
    const chatInputEl = document.getElementById('chatInput');

    if (!chatContainerEl) {
        console.warn('chatContainer element not found. .chat-container selector returned null.');
    }
    if (!dataContainer) {
        console.warn('dataContainer element not found. .data-container selector returned null.');
    }

    let latestPetHealth = {};
    let latestHistory = [];

    let currentPetId = null; // 실제 petId 대신 orderId 넣을 거임

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

    // ----- 데이터 렌더러 -----
    function renderData(raw) {
        if (!dataContainer) return;
        dataContainer.innerHTML = '';
        if (!raw) return;

        if (raw.pet_health && typeof raw.pet_health === 'object') {
            renderPetHealth(raw.pet_health);
            return;
        }

        const warningMsg = document.createElement('div');
        warningMsg.textContent = "오류: 메시지가 자유 의지를 주장하며 탈출을 감행함.\n현재 수색 중.";
        dataContainer.appendChild(warningMsg);
    }

    function renderPetHealth(ph) {
        if (!dataContainer) return;
        console.log('renderPetHealth called', ph);
        const stringKeys = Object.keys(ph);
        const keys = [...stringKeys];

        const dl = document.createElement('dl');
        dl.style.margin = '0';
        dl.style.fontSize = '13px';

        for (const key of keys) {
            if (hiddenKeys.includes(key)) continue;

            const label = LABELS[key] || String(key);
            const rawValue = ph[key];

            const isEmptyObject = typeof rawValue === 'object' && rawValue !== null &&
                !Array.isArray(rawValue) && Object.keys(rawValue).length === 0 &&
                Object.getOwnPropertySymbols(rawValue).length === 0;
            const isEmptyArray = Array.isArray(rawValue) && rawValue.length === 0;

            if (rawValue === null || rawValue === undefined ||
                (typeof rawValue === "string" && rawValue.trim() === "") ||
                isEmptyArray || isEmptyObject) {
                console.log('skipping empty key:', key, rawValue);
                continue;
            }

            const value = (typeof rawValue === 'object') ? JSON.stringify(rawValue) : String(rawValue);

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

        dataContainer.innerHTML = '';
        dataContainer.appendChild(dl);
    }

    // ----- 채팅 UI 유틸 -----
    function scrollToBottom() {
        if (!chatContainerEl) return;
        chatContainerEl.scrollTop = chatContainerEl.scrollHeight;
    }

    async function addMyMessage() {
        if (!chatInputEl || !chatContainerEl) return;
        const text = chatInputEl.value.trim();
        if (text === "") return;

        // 1) 내 메시지 출력
        const myMsg = document.createElement("div");
        myMsg.classList.add("msg", "me");
        myMsg.innerText = text;
        chatContainerEl.appendChild(myMsg);
        chatInputEl.value = "";

        // 2) 서버 전송
        let raw;
        let replyText = "";

        try {
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

            let textResponse = await response.text();

            try {
                raw = JSON.parse(textResponse);
            } catch {
                raw = textResponse;
            }

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
            } else if (typeof raw.message === "string") {
                replyText = raw.message;
            } else if (typeof raw.text === "string") {
                replyText = raw.text;
            } else {
                replyText = JSON.stringify(raw);
            }
        } else {
            replyText = replyText || "알 수 없는 응답입니다.";
        }

        // 4) 봇 메시지 출력
        const botMsg = document.createElement("div");
        botMsg.classList.add("msg", "bot");
        botMsg.innerText = replyText;
        chatContainerEl.appendChild(botMsg);

        requestAnimationFrame(() => scrollToBottom());
    }

    // ----- 히스토리 / 초기 데이터 로드 -----
    async function loadHistory(petId) {
        try {
            const res = await fetch(`/api/history/${currentPetId}`);
            if (!res.ok) {
                console.warn('history fetch failed', res.status);
                return [];
            }
            const history = await res.json();

            // 방어 처리: 서버가 {history: [...]} 형태로 왔을 수도 있으니 정규화
            if (Array.isArray(history)) return history;
            if (history && Array.isArray(history.history)) return history.history;

            // 그 외의 경우 빈 배열 반환
            console.warn('history format unexpected, normalized to []', history);
            return [];
        } catch (e) {
            console.error('loadHistory error', e);
            return [];
        }
    }

    // addMessageToUI는 프로젝트 내 실제 UI 렌더 함수로 가정.
    // 다양한 메시지 필드를 방어적으로 처리하도록 확장
    function addMessageToUI(msg) {
        if (!chatContainerEl) return;

        // 디버그 로그
        console.debug('addMessageToUI called with', msg);

        const el = document.createElement('div');

        // sender 또는 role로 발신자 판별
        const sender = msg.sender ?? msg.role ?? 'bot';
        if (sender === 'user') {
            el.classList.add('msg', 'me');
        } else {
            el.classList.add('msg', 'bot');
        }

        // 텍스트 추출: 여러 필드 후보 순서대로 시도
        const textCandidates = [
            msg.message,
            msg.content,
            msg.text,
            msg.msg,
            msg.body,
            // 혹시 그냥 문자열인 경우
            (typeof msg === 'string' ? msg : undefined)
        ];

        const content = textCandidates.find(x => typeof x === 'string' && x.trim() !== '');

        el.innerText = content ?? JSON.stringify(msg);
        chatContainerEl.appendChild(el);
    }

    // ----- 초기화 -----
    (function init() {
        const sendBtn = document.querySelector('.chat-input button');
        if (sendBtn) {
            sendBtn.addEventListener('click', addMyMessage);
        }

        if (chatInputEl) {
            // inline onkeydown도 있으니 중복되지만 안전성 위해 리스너 추가
            chatInputEl.addEventListener('keydown', (e) => {
                if (e.key === 'Enter') addMyMessage();
            });
        }
    })();

    async function initChatSession(orderId) {
        currentPetId = orderId;
        const container = chatContainerEl;
        container.innerHTML = "";

        // 1) 품종 질문 출력
        addMessageToUI({
            sender: "system",
            message: "반려동물 품종이 뭐예요?"
        });

        // 2) 역사 불러오기 (없으면 그냥 빈 배열)
        const history = await loadHistory(currentPetId);

        for (const msg of history) {
            addMessageToUI(msg);
        }

        scrollToBottom();
    }
</script>