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
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;

import org.json.JSONObject;

public class ChatbotService {

  public static String sendMessage(String message) {
    try {
      // FastAPI 통신 설정
      URL url = new URL("http://127.0.0.1:8000/chat");
      HttpURLConnection conn = (HttpURLConnection) url.openConnection();

      conn.setRequestMethod("POST");
      conn.setRequestProperty("Content-Type", "application/json; utf-8");
      conn.setRequestProperty("Accept", "application/json");
      conn.setDoOutput(true);
      conn.setConnectTimeout(60000); // 응답시간
      conn.setReadTimeout(60000);

      JSONObject json = new JSONObject();
      json.put("message", message);

      try (OutputStream os = conn.getOutputStream()) {
        byte[] input = json.toString().getBytes("utf-8");
        os.write(input, 0, input.length);
      }

      int code = conn.getResponseCode();
      InputStream is = (code >= 200 && code < 300) ? conn.getInputStream() : conn.getErrorStream();

      StringBuilder response = new StringBuilder();
      try (BufferedReader br = new BufferedReader(new InputStreamReader(is, "utf-8"))) {
        String line;
        while ((line = br.readLine()) != null)
          response.append(line);
      }
      if (code < 200 || code >= 300)
        return "Error HTTP " + code + ": " + response;

      JSONObject jsonResponse = new JSONObject(response.toString());
      return jsonResponse.getString("reply");

    } catch (Exception e) {
      e.printStackTrace();
      return "Error: " + e.getMessage();
    }
  }
}
