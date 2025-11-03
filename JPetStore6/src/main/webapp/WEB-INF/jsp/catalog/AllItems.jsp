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

<%@ include file="../common/IncludeTop.jsp"%>

<jsp:useBean id="catalog"
             class="org.mybatis.jpetstore.web.actions.CatalogActionBean" />

<div id="BackLink"><stripes:link
        beanclass="org.mybatis.jpetstore.web.actions.CatalogActionBean"
        event="viewCategory">
  <stripes:param name="categoryId"
                 value="${actionBean.product.categoryId}" />
  Return to ${actionBean.product.categoryId}
</stripes:link></div>


<div id="Catalog">
  <h2>All Products</h2>

  <table>
    <thead>
    <tr>
      <th>Item ID</th>
      <th>Product ID</th>
      <th>Description</th>
      <th>List Price</th>
      <th>&nbsp;</th>
    </tr>
    </thead>
    <tbody>
    <c:forEach var="item" items="${actionBean.itemList}">
      <tr>
        <td>
          <stripes:link beanclass="org.mybatis.jpetstore.web.actions.CatalogActionBean" event="viewItem">
            <stripes:param name="itemId" value="${item.itemId}" />
            ${item.itemId}
          </stripes:link>
        </td>

        <!-- 모든 product의 item이므로 productId를 열에 표시 -->
        <td>${item.product.productId}</td>

        <!-- 요구한 설명: item.attr1 + product.name (필요시 attr2~5 더 이어붙여도 됨) -->
        <td>
          <c:out value="${item.attribute1}"/> <c:out value="${item.product.name}"/>
        </td>

        <td><fmt:formatNumber value="${item.listPrice}" pattern="$#,##0.00"/></td>

        <td>
          <stripes:link class="Button"
                        beanclass="org.mybatis.jpetstore.web.actions.CartActionBean"
                        event="addItemToCart">
            <stripes:param name="workingItemId" value="${item.itemId}" />
            Add to Cart
          </stripes:link>
        </td>
      </tr>
    </c:forEach>
    </tbody>
  </table>
</div>

<%@ include file="../common/IncludeBottom.jsp"%>