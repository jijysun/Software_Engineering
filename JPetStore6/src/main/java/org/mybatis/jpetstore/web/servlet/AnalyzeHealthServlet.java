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
package org.mybatis.jpetstore.web.servlet;

import java.io.IOException;
import java.util.stream.Collectors;

import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.JSONObject;
import org.mybatis.jpetstore.service.ChatbotHttpClient;

@WebServlet("/chat/analyze_health")
public class AnalyzeHealthServlet extends HttpServlet {

  @Override
  protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {

    // 요청 Body 읽기
    String body = req.getReader().lines().collect(Collectors.joining());
    JSONObject json = new JSONObject(body);

    // FastAPI로 전달
    String result = ChatbotHttpClient.post("/analyze_health", json);

    // 응답
    resp.setContentType("application/json; charset=UTF-8");
    resp.getWriter().write(result);
  }
}
