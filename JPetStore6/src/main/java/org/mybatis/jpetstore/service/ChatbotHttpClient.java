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

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

import org.json.JSONObject;

public class ChatbotHttpClient {

  private static final String BASE_URL = "http://127.0.0.1:8000";

  public static String post(String endpoint, JSONObject payload) {
    try {
      URL url = new URL(BASE_URL + endpoint);
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();
      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json; charset=UTF-8");
      conn.setDoOutput(true);

      try (OutputStream os = conn.getOutputStream()) {
        os.write(payload.toString().getBytes(StandardCharsets.UTF_8));
      }

      BufferedReader br = new BufferedReader(new InputStreamReader(conn.getInputStream(), StandardCharsets.UTF_8));

      StringBuilder sb = new StringBuilder();
      String line;

      while ((line = br.readLine()) != null) {
        sb.append(line);
      }

      return sb.toString();

    } catch (Exception e) {
      return "{\"error\": \"" + e.getMessage() + "\"}";
    }
  }
}

// vvvvvv 최준이 추가함 vvvvvv

@WebServlet("/chat/analyze_health")
public class AnalyzeHealthServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String body = req.getReader().lines().collect(Collectors.joining());
        JSONObject payload = new JSONObject(body);

        // FastAPI로 전달
        String result = ChatbotHttpClient.post("/analyze_health", payload);

        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(result);
    }
}

// ^^^^^^ 최준이 추가함 ^^^^^^