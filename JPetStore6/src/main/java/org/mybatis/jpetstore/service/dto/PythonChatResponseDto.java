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

public class PythonChatResponseDto {

  // 사용자에게 보여줄 최종 답변 문장
  private String answer;

  // (옵션) AI가 이어서 하고 싶은 질문 (DB question에 저장 가능)
  private String aiQuestion;

  // (옵션) mode 1에서 갱신된 프로필 문자열 (account.info에 저장)
  private String profileInfo;

  // (옵션) mode 3에서 쓸 이미지 URL
  private String imageUrl;

  // --- getter / setter ---

  public String getAnswer() {
    return answer;
  }

  public void setAnswer(String answer) {
    this.answer = answer;
  }

  public String getAiQuestion() {
    return aiQuestion;
  }

  public void setAiQuestion(String aiQuestion) {
    this.aiQuestion = aiQuestion;
  }

  public String getProfileInfo() {
    return profileInfo;
  }

  public void setProfileInfo(String profileInfo) {
    this.profileInfo = profileInfo;
  }

  public String getImageUrl() {
    return imageUrl;
  }

  public void setImageUrl(String imageUrl) {
    this.imageUrl = imageUrl;
  }
}
