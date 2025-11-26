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

package org.mybatis.jpetstore.web.actions;

import javax.servlet.http.HttpSession;

import net.sourceforge.stripes.action.*;
import net.sourceforge.stripes.integration.spring.SpringBean;

import org.json.JSONObject;
import org.mybatis.jpetstore.service.ChatbotService;
import org.mybatis.jpetstore.service.dto.PythonChatResponseDto;

@UrlBinding("/actions/Chatbot.action")
public class ChatbotActionBean extends AbstractActionBean {

  @SpringBean
  private ChatbotService chatbotService;

  private String answer; // 사용자가 입력한 문장
  private Integer mode; // 1,2,3 또는 null
  private String question; // ✅ 모드1에서 프론트가 보내는 질문

  @DefaultHandler
  public Resolution send() {

    // 0. 아무 입력도 없으면 바로 종료 (GET으로 그냥 들어왔을 때 등)
    if ((answer == null || answer.trim().isEmpty()) && (mode == null)
        && (question == null || question.trim().isEmpty())) {

      JSONObject empty = new JSONObject();
      empty.put("answer", "");
      empty.put("imageUrl", JSONObject.NULL);
      empty.put("nextQuestion", JSONObject.NULL);

      return new StreamingResolution("application/json;charset=UTF-8", empty.toString());
    }

    // 1. 세션에서 AccountActionBean 꺼내오기
    HttpSession session = context.getRequest().getSession();
    AccountActionBean accountBean = (AccountActionBean) session.getAttribute("accountBean");

    String userId = null;
    if (accountBean != null && accountBean.isAuthenticated()) {
      // ★ 여기서 getAccount()는 AccountActionBean의 메서드
      userId = accountBean.getAccount().getUsername();
    }

    // 2. 서비스 호출 (question까지 같이 넘김)
    PythonChatResponseDto resDto = chatbotService.handleChat(userId, answer, mode, question);

    // 3. JSON 응답 생성
    JSONObject json = new JSONObject();
    json.put("answer", resDto.getAnswer());
    json.put("imageUrl", resDto.getImageUrl());
    json.put("nextQuestion", resDto.getAiQuestion());

    return new StreamingResolution("application/json;charset=UTF-8", json.toString());
  }

  // ===== getter / setter =====
  public String getAnswer() {
    return answer;
  }

  public void setAnswer(String answer) {
    this.answer = answer;
  }

  public Integer getMode() {
    return mode;
  }

  public void setMode(Integer mode) {
    this.mode = mode;
  }

  public String getQuestion() {
    return question;
  }

  public void setQuestion(String question) {
    this.question = question;
  }
}
