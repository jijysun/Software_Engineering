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

import java.util.List;

import javax.servlet.http.HttpSession;

import net.sourceforge.stripes.action.*;
import net.sourceforge.stripes.integration.spring.SpringBean;

import org.json.JSONArray;
import org.json.JSONObject;
import org.mybatis.jpetstore.domain.ChatMessage;
import org.mybatis.jpetstore.service.ChatbotService;

@UrlBinding("/api/chat/history.action")
public class ChatHistoryActionBean extends AbstractActionBean {

  @SpringBean
  private ChatbotService chatbotService;

  // 🔽 추가: 쿼리스트링의 mode 를 자동으로 바인딩 받기
  private Integer mode;

  // Stripes가 쓰는 getter/setter
  public Integer getMode() {
    return mode;
  }

  public void setMode(Integer mode) {
    this.mode = mode;
  }

  @DefaultHandler
  public Resolution load() {

    HttpSession session = context.getRequest().getSession();
    AccountActionBean accountBean = (AccountActionBean) session.getAttribute("accountBean");

    // 로그인 안 되어 있으면 빈 JSON 반환
    if (accountBean == null || !accountBean.isAuthenticated()) {
      JSONObject empty = new JSONObject();
      empty.put("profile", new JSONArray());
      empty.put("recommend", new JSONArray());
      empty.put("image", new JSONArray());
      empty.put("normal", new JSONArray());
      return new StreamingResolution("application/json;charset=UTF-8", empty.toString());
    }

    String userId = accountBean.getAccount().getUsername();

    // DB에서 전체 최신순으로 가져오기
    List<ChatMessage> logs = chatbotService.getMessagesByUserId(userId);

    // 🔽 1) mode 파라미터가 있는 경우 → 그 모드만 리턴
    if (mode != null) {
      JSONArray arr = new JSONArray();

      for (ChatMessage msg : logs) {

        boolean match;
        if (mode == 0) {
          // mode=0 은 "null 모드(일반 상담)" 로 해석
          match = (msg.getMode() == null);
        } else {
          match = (msg.getMode() != null && msg.getMode().intValue() == mode.intValue());
        }

        if (!match) {
          continue;
        }

        JSONObject obj = new JSONObject();
        obj.put("question", msg.getQuestion());
        obj.put("answer", msg.getAnswer());
        obj.put("created_at", msg.getCreatedAt().toString());
        arr.put(obj);
      }

      JSONObject result = new JSONObject();
      result.put("mode", mode); // 몇 번 모드 요청이었는지
      result.put("items", arr); // 해당 모드의 메시지 목록

      return new StreamingResolution("application/json;charset=UTF-8", result.toString());
    }

    // 🔼 여기까지가 "특정 모드만" 요청한 경우

    // 🔽 2) mode 파라미터가 없으면 → 기존처럼 전부 분류해서 리턴
    JSONArray profileArr = new JSONArray();
    JSONArray recommendArr = new JSONArray();
    JSONArray imageArr = new JSONArray();
    JSONArray normalArr = new JSONArray();

    for (ChatMessage msg : logs) {
      JSONObject obj = new JSONObject();
      obj.put("question", msg.getQuestion());
      obj.put("answer", msg.getAnswer());
      obj.put("created_at", msg.getCreatedAt().toString());

      // ★ 모드별 분류
      if (msg.getMode() != null) {
        switch (msg.getMode()) {
          case 1:
            profileArr.put(obj);
            break;
          case 2:
            recommendArr.put(obj);
            break;
          case 3:
            imageArr.put(obj);
            break;
        }
      } else {
        normalArr.put(obj);
      }
    }

    JSONObject result = new JSONObject();
    result.put("profile", profileArr);
    result.put("recommend", recommendArr);
    result.put("image", imageArr);
    result.put("normal", normalArr);

    return new StreamingResolution("application/json;charset=UTF-8", result.toString());
  }

}
