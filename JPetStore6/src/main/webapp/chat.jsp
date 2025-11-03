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
<%--
  Created by IntelliJ IDEA.
  User: richb
  Date: 2025-10-30
  Time: 오후 4:07
  To change this template use File | Settings | File Templates.
--%>
<%@ page import="org.mybatis.jpetstore.service.ChatbotService" %>
<%@ page contentType="text/html; charset=UTF-8" language="java" pageEncoding="UTF-8" %>
<%
    request.setCharacterEncoding("UTF-8");
%>
<html>
<body>
<form method="post" action="chat.jsp">
    <input type="text" name="msg" placeholder="메시지를 입력하세요">
    <button type="submit">보내기</button>
</form>

<%
    String msg = request.getParameter("msg");
    if (msg != null && !msg.isEmpty()) {
        String reply = ChatbotService.sendMessage(msg);
%>
<p>입력: <%= msg %></p>
<p>응답: <%= reply %></p>
<%
    }
%>
</body>
</html>
