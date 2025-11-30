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

import java.io.BufferedReader;
import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

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
  // 1) HEALTH_DATA 조회
  // URL 예: /jpetstore/actions/PetHealth.action?event=get&orderId=1001
  // ======================================================
  @DefaultHandler
  public Resolution get() {

    String orderIdStr = context.getRequest().getParameter("orderId");
    if (orderIdStr == null) {
      return new ErrorResolution(400, "orderId is required");
    }

    int orderId = Integer.parseInt(orderIdStr);
    String detail = healthDataService.getHealthData(orderId);

    return new StreamingResolution("application/json;charset=UTF-8", detail == null ? "{}" : detail);
  }

  // ======================================================
  // 2) HEALTH_DATA 저장
  // URL 예: /jpetstore/actions/PetHealth.action?event=save
  //
  // Body(JSON):
  // {
  // "orderId": 1001,
  // "healthDetail": {...}
  // }
  // ======================================================
  @HandlesEvent("save")
  public Resolution save() {

    try {
      BufferedReader reader = context.getRequest().getReader();
      String body = reader.lines().collect(Collectors.joining());

      JSONObject json = new JSONObject(body);

      if (!json.has("orderId") || !json.has("healthDetail")) {
        return new ErrorResolution(400, "orderId and healthDetail are required");
      }

      int orderId = json.getInt("orderId");
      String detail = json.get("healthDetail").toString();

      healthDataService.saveHealthData(orderId, detail);

      return new StreamingResolution("application/json;charset=UTF-8", "{\"status\":\"success\"}");

    } catch (IOException e) {
      return new ErrorResolution(500, "IO error");
    }
  }

  // ============================================================
  // 3) 채팅 히스토리 조회
  // GET /actions/PetHealth.action?event=getHistory&orderId=3
  // ============================================================
  @HandlesEvent("getHistory")
  public Resolution getHistory() {

    String orderIdStr = context.getRequest().getParameter("orderId");
    if (orderIdStr == null) {
      return new ErrorResolution(400, "orderId is required");
    }

    int orderId = Integer.parseInt(orderIdStr);

    List<HealthChatMessage> list = healthDataService.getHistoryByOrderId(orderId);

    // JSON 변환
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

  // ============================================================
  // 4) 채팅 저장
  // POST /actions/PetHealth.action?event=saveMessage
  //
  // Body(JSON):
  // {
  // "orderId": 3,
  // "role": "user",
  // "content": "메시지"
  // }
  // ============================================================
  @HandlesEvent("saveMessage")
  public Resolution saveMessage() {

    try {
      BufferedReader reader = context.getRequest().getReader();
      String body = reader.lines().collect(Collectors.joining());

      JSONObject json = new JSONObject(body);

      if (!json.has("orderId") || !json.has("role") || !json.has("content")) {
        return new ErrorResolution(400, "orderId, role, content are required");
      }

      int orderId = json.getInt("orderId");
      String role = json.getString("role");
      String content = json.getString("content");

      // Service 호출 → DB 저장
      healthDataService.saveMessage(orderId, role, content);

      return new StreamingResolution("application/json;charset=UTF-8", "{\"status\":\"success\"}");

    } catch (IOException e) {
      return new ErrorResolution(500, "IO error");
    }
  }
}
