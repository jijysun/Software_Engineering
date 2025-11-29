/*
 *    Copyright 2010-2025 the original author or authors.
 *
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 *
 *       https://www.apache.org/licenses/LICENSE-2.0
 *
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 */
package org.mybatis.jpetstore.service;

import java.util.List;

import org.json.JSONObject;
import org.mybatis.jpetstore.domain.Account;
import org.mybatis.jpetstore.domain.ChatMessage;
import org.mybatis.jpetstore.mapper.AccountMapper;
import org.mybatis.jpetstore.mapper.ChatMapper;
import org.mybatis.jpetstore.service.dto.PythonChatRequestDto;
import org.mybatis.jpetstore.service.dto.PythonChatResponseDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class ChatbotService {

  @Autowired
  private ChatMapper chatMapper;

  @Autowired
  private AccountMapper accountMapper;

  // DB에 저장할 프로필 최대 길이 (너가 적당히 결정, 예: 4000자)
  private static final int MAX_PROFILE_LEN = 4000;

  // GPT에 보낼 때 사용할 최대 길이 (프로필/히스토리)
  private static final int MAX_PROFILE_CHARS_FOR_AI = 2000;
  private static final int MAX_HISTORY_CHARS_FOR_AI = 4000;

  // 불필요한 공백/개행 정리 + 최대 길이 제한
  private String normalizeText(String s, int maxLen) {
    if (s == null) {
      return null;
    }

    String result = s.trim(); // 앞뒤 공백 제거
    result = result.replaceAll("[ \\t]+", " "); // 연속 공백/탭 → 한 칸
    result = result.replaceAll("\\n{3,}", "\n\n"); // 개행 3개 이상 → 2개

    if (maxLen > 0 && result.length() > maxLen) {
      // 너무 길면 뒤에서 maxLen 글자만 사용
      result = result.substring(result.length() - maxLen);
    }

    return result;
  }

  // ACCOUNT.INFO 를 DB에 저장할 때 길이 제한
  private String trimProfile(String info) {
    if (info == null) {
      return null;
    }
    if (info.length() <= MAX_PROFILE_LEN) {
      return info;
    }
    // 오래된 내용은 버리고, 뒤쪽 최신 MAX_PROFILE_LEN 글자만 남김
    return info.substring(info.length() - MAX_PROFILE_LEN);
  }

  // 🔼🔼🔼 여기까지 추가 🔼🔼🔼

  /**
   * 채팅 한 턴 처리
   *
   * @param userId
   *          로그인한 사용자 ID (비로그인이면 null)
   * @param userInput
   *          사용자가 이번에 입력한 문장
   * @param mode
   *          1,2,3 또는 null
   *
   * @return 파이썬(AI) 응답을 담은 DTO
   */
  public PythonChatResponseDto handleChat(String userId, String userInput, Integer mode, String questionFromFront) {

    // 🔒 공통 방어: 입력이 완전 비어 있으면 아무것도 하지 않기
    // 1) null 은 빈 문자열로 통일 (DB NOT NULL 대비)
    if (userInput == null) {
      userInput = "";
    }

    // 2) "완전 빈 입력은 무시"는 일반 채팅(null 모드)에만 적용
    if ((mode == null || mode == 0) && userInput.trim().isEmpty()) {
      PythonChatResponseDto dto = new PythonChatResponseDto();
      dto.setAnswer("완전 빈 입력입니다");
      dto.setAiQuestion(null);
      dto.setProfileInfo(null);
      dto.setImageUrl(null);
      return dto;
    }

    // 1️⃣ 모드 1: 프로필 수집
    if (mode != null && mode == 1) {
      return handleProfile(userId, questionFromFront, userInput);
    }

    // 2️⃣ 모드 2,3,null 에서만 Python 호출
    // (로그인 체크: 모드 2,3는 로그인 필수라고 했으니까)
    if ((mode != null && (mode == 2 || mode == 3)) && (userId == null || userId.isEmpty())) {

      PythonChatResponseDto dto = new PythonChatResponseDto();
      dto.setAnswer("이 기능은 로그인 후 이용 가능합니다.");
      dto.setAiQuestion(null);
      dto.setProfileInfo(null);
      dto.setImageUrl(null);
      return dto;
    }

    // 2-0) 현재 로그인 유저 프로필 읽기 (mode 2/3/null에서 참고용)
    String profileInfo = null;
    if (userId != null && !userId.isEmpty()) {
      Account account = accountMapper.getAccountByUsername(userId);
      if (account != null) {
        profileInfo = account.getInfo();
      }
    }

    // ✅ 2-0.5) 최근 대화 N개를 읽어서 하나의 텍스트로 합치기
    String conversationHistory = null;
    if (userId != null && !userId.isEmpty()) {
      List<ChatMessage> history = chatMapper.getRecentMessagesByUserId(userId, 20);

      StringBuilder sb = new StringBuilder();
      // 최신 DESC로 가져왔으니 시간순으로 보고 싶으면 뒤에서부터 돌거나, ORDER BY ASC로 바꿔도 됨
      for (int i = history.size() - 1; i >= 0; i--) {
        ChatMessage m = history.get(i);
        sb.append("[질문] ").append(m.getQuestion()).append("\n");
        sb.append("[답변] ").append(m.getAnswer()).append("\n\n");
      }
      conversationHistory = sb.toString();
    }
    // 🔽🔽🔽 여기 추가 : GPT로 보내기 전에 정제 + 길이 제한
    profileInfo = normalizeText(profileInfo, MAX_PROFILE_CHARS_FOR_AI);
    conversationHistory = normalizeText(conversationHistory, MAX_HISTORY_CHARS_FOR_AI);
    // 🔼🔼🔼

    if (mode != null && mode == 3) {

      // 2-1) 프로필 없으면 막기 (모드1 안 한 상태)
      if (profileInfo == null || profileInfo.trim().isEmpty()) {
        PythonChatResponseDto dto = new PythonChatResponseDto();
        dto.setAnswer("이미지 생성을 사용하려면 먼저 프로필을 작성해 주세요.");
        dto.setAiQuestion(null);
        dto.setProfileInfo(null);
        dto.setImageUrl(null);
        return dto;
      }

      // 2-2) 최근 모드2 추천 결과 가져오기
      ChatMessage latestRec = chatMapper.getLatestByUserIdAndMode(userId, 2);
      if (latestRec == null || latestRec.getAnswer() == null || latestRec.getAnswer().trim().isEmpty()) {

        PythonChatResponseDto dto = new PythonChatResponseDto();
        dto.setAnswer("이미지 생성을 사용하려면 먼저 반려동물 추천을 받아야 합니다.");
        dto.setAiQuestion(null);
        dto.setProfileInfo(null);
        dto.setImageUrl(null);
        return dto;
      }

    }

    // 2-2) Python으로 보낼 DTO 만들기
    // 🔹 2-2) Python으로 보낼 메시지 구성 (특히 모드3일 때 Q/A 합치기)
    String messageForAi = userInput;

    // 3번 모드이면서 프론트에서 고정 질문을 보내준 경우
    if (mode != null && mode == 3 && questionFromFront != null && !questionFromFront.trim().isEmpty()) {

      String q = questionFromFront.trim();
      String a = userInput != null ? userInput.trim() : "";

      messageForAi = "[이미지 세부 설정]\n" + "질문: " + q + "\n" + "사용자 답변: " + a + "\n";
    }

    PythonChatRequestDto reqDto = new PythonChatRequestDto();
    reqDto.setUserId(userId);
    reqDto.setMessage(messageForAi);
    reqDto.setMode(mode);
    reqDto.setProfileInfo(profileInfo);

    // 2-3) FastAPI /chat 호출
    JSONObject payload = new JSONObject();
    payload.put("user_id", reqDto.getUserId());
    payload.put("message", reqDto.getMessage());
    payload.put("mode", reqDto.getMode());
    payload.put("profile_info", reqDto.getProfileInfo());
    payload.put("conversation_history", conversationHistory);

    // 🔹 모드3일 때 추천 텍스트 추가
    if (mode != null && mode == 3) {
      ChatMessage latestRec = chatMapper.getLatestByUserIdAndMode(userId, 2);
      String recommendedText = (latestRec != null ? latestRec.getAnswer() : null);
      payload.put("recommended_text", recommendedText);
    }

    String raw = ChatbotHttpClient.post("/chat", payload);
    JSONObject json = new JSONObject(raw);

    PythonChatResponseDto resDto = new PythonChatResponseDto();
    resDto.setAnswer(json.optString("answer", ""));
    resDto.setAiQuestion(json.optString("ai_question", null));
    resDto.setProfileInfo(json.optString("profile_info", null));
    resDto.setImageUrl(json.optString("image_url", null));

    // 2-4) CHAT_MESSAGE 저장 (모드 2,3,null 공통)
    ChatMessage msg = new ChatMessage();
    msg.setUserId(userId != null ? userId : "ANONYMOUS");
    msg.setMode(mode);

    if (mode != null && mode == 2) {
      // ✅ 모드2 : 사용자의 질문 / AI의 추천 결과 저장
      msg.setQuestion(userInput); // 사용자가 "추천해줘"라고 한 문장
      msg.setAnswer(resDto.getAnswer()); // GPT가 추천해준 동물 설명
    } else {
      // 나머지 모드(1,3,null)는 기존 방식 유지
      msg.setQuestion(userInput);
      msg.setAnswer(resDto.getAnswer());
    }

    chatMapper.insertChatMessage(msg);

    // 🔽🔽🔽 여기 추가 : 사용자별 최근 100개만 유지
    if (userId != null && !"ANONYMOUS".equals(userId)) {
      chatMapper.deleteOldMessagesByUserId(userId, 100);
    }
    // 🔼🔼🔼

    // 2-5) 모드 2에서도 프로필은 여기서 수정 안 함 (모드 1에서만 업데이트)
    return resDto;
  }

  private PythonChatResponseDto handleProfile(String userId, String questionFromFront, String userInput) {

    PythonChatResponseDto dto = new PythonChatResponseDto();

    // 1. 로그인 안 되어 있으면 바로 리턴
    if (userId == null || userId.isEmpty()) {
      dto.setAnswer("프로필을 저장하려면 먼저 로그인이 필요합니다.");
      dto.setAiQuestion(null);
      dto.setProfileInfo(null);
      dto.setImageUrl(null);
      return dto;
    }

    // 2. 기존 프로필 INFO 읽기
    Account account = accountMapper.getAccountByUsername(userId);
    String oldInfo = (account != null ? account.getInfo() : null);

    String question = (questionFromFront != null ? questionFromFront.trim() : "");
    String answer = (userInput != null ? userInput.trim() : "");

    // 3. 이번에 받은 Q/A 블록 문자열 만들기
    String newBlock;
    if (!question.isEmpty()) {
      newBlock = String.format("[질문] %s%n[답변] %s%n", question, answer);
    } else {
      // 혹시 질문이 비어있으면 답변만이라도
      newBlock = String.format("[답변] %s%n", answer);
    }

    // 4. 기존 INFO + 새 블록 합치기
    String mergedInfo;
    if (oldInfo == null || oldInfo.isEmpty()) {
      mergedInfo = newBlock;
    } else {
      mergedInfo = oldInfo + System.lineSeparator() + newBlock;
    }

    // 🔽🔽🔽 여기 추가 : 너무 길면 뒤에서만 남기기
    mergedInfo = trimProfile(mergedInfo);
    // 🔼🔼🔼

    // 5. ACCOUNT.INFO 업데이트
    accountMapper.updateInfo(userId, mergedInfo);

    // 6. CHAT_MESSAGE 에도 저장 (질문/답변/모드=1)
    ChatMessage msg = new ChatMessage();
    msg.setUserId(userId);
    msg.setQuestion(question);
    msg.setAnswer(answer);
    msg.setMode(1);
    chatMapper.insertChatMessage(msg);

    // 7. 프론트에 내려줄 메시지
    dto.setAnswer("답변이 저장되었습니다. 다음 질문으로 넘어가 주세요.");
    dto.setAiQuestion(null); // 프론트가 질문 리스트를 관리하므로 여기서는 null
    dto.setProfileInfo(null); // INFO는 DB에만 저장
    dto.setImageUrl(null);

    return dto;
  }

  public List<ChatMessage> getMessagesByUserId(String userId) {
    return chatMapper.getMessagesByUserId(userId);
  }

}
