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
package org.mybatis.jpetstore.service.dto;

public class PythonChatRequestDto {

  // 로그인한 사용자 ID (없으면 null 또는 "ANONYMOUS")
  private String userId;

  // 사용자가 이번에 입력한 문장
  private String message;

  // 1, 2, 3 또는 null (일반 대화 모드)
  private Integer mode;

  // account.info에 저장된 기존 프로필 정보 (문자열/JSON)
  private String profileInfo;

  // --- getter / setter ---

  public String getUserId() {
    return userId;
  }

  public void setUserId(String userId) {
    this.userId = userId;
  }

  public String getMessage() {
    return message;
  }

  public void setMessage(String message) {
    this.message = message;
  }

  public Integer getMode() {
    return mode;
  }

  public void setMode(Integer mode) {
    this.mode = mode;
  }

  public String getProfileInfo() {
    return profileInfo;
  }

  public void setProfileInfo(String profileInfo) {
    this.profileInfo = profileInfo;
  }
}
