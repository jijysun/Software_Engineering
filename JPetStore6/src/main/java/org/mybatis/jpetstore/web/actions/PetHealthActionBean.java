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
import java.util.stream.Collectors;

import javax.servlet.http.HttpServletRequest;

import net.sourceforge.stripes.action.*;
import net.sourceforge.stripes.integration.spring.SpringBean;

import org.json.JSONArray;
import org.json.JSONObject;
import org.mybatis.jpetstore.domain.HealthChatMessage;
import org.mybatis.jpetstore.service.ChatbotService;

@UrlBinding("/actions/PetHealth.action")
public class PetHealthActionBean implements ActionBean {

  private ActionBeanContext context;

  @SpringBean
  private ChatbotService healthDataService;

  @Override
  public void setContext(ActionBeanContext context) {
    this.context = context;
  }

  @Override
  public ActionBeanContext getContext() {
    return context;
  }

  // ======================================================
  // 🔥 모든 요청은 여기로 들어옴 → 우리가 직접 event 기반으로 분기한다.
  // ======================================================
  @DefaultHandler
  public Resolution route() {

    HttpServletRequest req = context.getRequest();
    String event = req.getParameter("event");

    JSONObject jsonBody = null;

    // ---------- 1) JSON Body 로부터 event 추출 ----------
    try {
      String body = req.getReader().lines().collect(Collectors.joining());
      if (body != null && !body.isEmpty()) {
        jsonBody = new JSONObject(body);

        if (event == null && jsonBody.has("event")) {
          event = jsonBody.getString("event");
        }
      }
    } catch (Exception ignored) {
    }

    // ---------- 2) event 값에 따라 분기 ----------
    if ("saveMessage".equals(event)) {
      return handleSaveMessage(jsonBody);
    }
    if ("save".equals(event)) {
      return handleSave(jsonBody);
    }
    if ("getHistory".equals(event)) {
      return handleGetHistory();
    }

    // event가 없으면 기본 조회(get)
    return handleGet();
  }

  // ======================================================
  // HEALTH_DATA 조회 (event=get)
  // ======================================================
  public Resolution handleGet() {

    String orderIdStr = context.getRequest().getParameter("orderId");
    if (orderIdStr == null) {
      return new ErrorResolution(400, "orderId is required");
    }

    int orderId = Integer.parseInt(orderIdStr);
    String detail = healthDataService.getHealthData(orderId);

    return new StreamingResolution("application/json;charset=UTF-8", detail == null ? "{}" : detail);
  }

  // ======================================================
  // HEALTH_DATA 저장 (event=save)
  // ======================================================
  public Resolution handleSave(JSONObject json) {

    if (json == null || !json.has("orderId") || !json.has("healthDetail")) {
      return new ErrorResolution(400, "orderId and healthDetail are required");
    }

    int orderId = json.getInt("orderId");
    String detail = json.get("healthDetail").toString();

    healthDataService.saveHealthData(orderId, detail);

    return new StreamingResolution("application/json;charset=UTF-8", "{\"status\":\"success\"}");
  }

  // ======================================================
  // 채팅 히스토리 조회 (event=getHistory)
  // ======================================================
  public Resolution handleGetHistory() {

    String orderIdStr = context.getRequest().getParameter("orderId");
    if (orderIdStr == null) {
      return new ErrorResolution(400, "orderId is required");
    }

    int orderId = Integer.parseInt(orderIdStr);

    List<HealthChatMessage> list = healthDataService.getHistoryByOrderId(orderId);

    JSONArray arr = new JSONArray();
    for (HealthChatMessage m : list) {
      JSONObject obj = new JSONObject();
      obj.put("role", m.getRole());
      obj.put("content", m.getContent());
      obj.put("created_at", m.getCreatedAt() == null ? null : m.getCreatedAt().toString());
      arr.put(obj);
    }

    return new StreamingResolution("application/json;charset=UTF-8", arr.toString());
  }

  // ======================================================
  // 채팅 메시지 저장 (event=saveMessage)
  // ======================================================
  public Resolution handleSaveMessage(JSONObject json) {

    if (json == null || !json.has("orderId") || !json.has("role") || !json.has("content")) {
      return new ErrorResolution(400, "orderId, role, content are required");
    }

    int orderId = json.getInt("orderId");
    String role = json.getString("role");
    String content = json.getString("content");

    healthDataService.saveMessage(orderId, role, content);

    return new StreamingResolution("application/json;charset=UTF-8", "{\"status\":\"success\"}");
  }
}
