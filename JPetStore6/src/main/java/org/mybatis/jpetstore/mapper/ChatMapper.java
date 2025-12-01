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
package org.mybatis.jpetstore.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Param;
import org.mybatis.jpetstore.domain.ChatMessage;
import org.mybatis.jpetstore.domain.HealthChatMessage;

public interface ChatMapper {

  void insertChatMessage(ChatMessage message);

  List<ChatMessage> getMessagesByUserId(String userId);

  // ✅ userId + mode 로 가장 최신 메시지 1개 조회
  ChatMessage getLatestByUserIdAndMode(@Param("userId") String userId, @Param("mode") int mode);

  // ✅ 최근 대화 N개
  List<ChatMessage> getRecentMessagesByUserId(@Param("userId") String userId, @Param("limit") int limit);

  // ✅ 사용자별로 최근 keep개만 남기고 나머지 삭제
  void deleteOldMessagesByUserId(@Param("userId") String userId, @Param("keep") int keep);

  // 아래부터는
  // 반려동물 상태 관리 챗봇 부분

  // HEALTH_DATA에서 HEALTH_DETAIL을 한 줄(String)로 조회
  String getHealthDataByOrderId(@Param("value") int orderId);

  // HEALTH_DATA에 insert 또는 update를 수행
  void upsertHealthData(@Param("orderId") int orderId, @Param("healthDetail") String healthDetail);

  // order_id 기반으로 채팅 히스토리 조회
  List<HealthChatMessage> getHealthChatHistoryByOrderId(int orderId);

  // 채팅 메시지 저장
  void insertHealthChatMessage(HealthChatMessage message);
}
