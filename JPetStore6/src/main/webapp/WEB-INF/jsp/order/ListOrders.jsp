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
<%@ page pageEncoding="UTF-8" %>
<%@ include file="../common/IncludeTop.jsp"%>

<style>
    .page-container {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        gap: 3%;
        width: 100%;
        transition: all 0.3s ease;
    }

    .chatbot {
        width: 660px;
        height: 70%;
        padding: 10px;
        display: none;
    }

    .page-container.open .chatbot {
        display: block;
    }

    <%--
    table {
        margin: 0 auto;
    }
    --%>
</style>

<div class="page-container" id="pageContainer">

    <!-- 주문 테이블 -->
    <div>
        <h2>My Orders</h2>

        <table>
            <tr>
                <th>ChatBot</th>
                <th>Order ID</th>
                <th>Date</th>
                <th>Total Price</th>
            </tr>

            <c:forEach var="order" items="${actionBean.orderList}">
                <tr>
                    <td><a class="Button" onclick="openChatbot(${order.orderId})">Open</a></td>

                    <td>
                        <stripes:link
                                beanclass="org.mybatis.jpetstore.web.actions.OrderActionBean"
                                event="viewOrder">
                            <stripes:param name="orderId" value="${order.orderId}" />
                            ${order.orderId}
                        </stripes:link>
                    </td>

                    <td>
                        <fmt:formatDate value="${order.orderDate}"
                                        pattern="yyyy/MM/dd HH:mm:ss" />
                    </td>

                    <td>
                        $<fmt:formatNumber value="${order.totalPrice}"
                                           pattern="#,##0.00" />
                    </td>
                </tr>
            </c:forEach>
        </table>
    </div>

    <div class="chatbot" id="chatbotPanel">
        <h2>ChatBot</h2>
        <%@ include file="../ChatUI.jsp"%>
    </div>

</div>

<script>
    let currentOrderId = null;

    function openChatbot(orderId) {
        const panel = document.getElementById("pageContainer");
        const container = document.querySelector('.chat-container');

        if (currentOrderId !== orderId) {
            currentOrderId = orderId;

            if (!panel.classList.contains("open")) {
                panel.classList.add("open");
            }

            container.innerHTML = "";

            // 🔥 여기서 초기 채팅 세팅을 시작해야 함
            initChatSession(orderId);

            return;
        }

        panel.classList.toggle("open");

        if (panel.classList.contains("open")) {
            initChatSession(orderId);
        }
    }

</script>

<%@ include file="../common/IncludeBottom.jsp"%>