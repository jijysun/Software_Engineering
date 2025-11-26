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

    table {
        margin: 0 auto;
    }

    .chat-btn {
        cursor: pointer;
        color: blue;
        text-decoration: underline;
    }
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
                    <td><span class="chat-btn" onclick="openChatbot(${order.orderId})">Open</span></td>

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

        // 다른 주문 클릭 시: UI 유지 + ID만 변경
        if (currentOrderId !== orderId) {
            currentOrderId = orderId;

            if (!panel.classList.contains("open")) {
                panel.classList.add("open");
            }

            container.innerHTML = "";
            loadHistory(orderId);
            return;
        }

        // 같은 주문 클릭 시: 토글
        panel.classList.toggle("open");

        if (panel.classList.contains("open")) {
            loadHistory(orderId);
        }
    }
</script>

<%@ include file="../common/IncludeBottom.jsp"%>
