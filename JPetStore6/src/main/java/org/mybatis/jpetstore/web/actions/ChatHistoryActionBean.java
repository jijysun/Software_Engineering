package org.mybatis.jpetstore.web.actions;


import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;
import net.sourceforge.stripes.action.UrlBinding;
import net.sourceforge.stripes.integration.spring.SpringBean;
import org.json.JSONArray;
import org.json.JSONObject;
import org.mybatis.jpetstore.domain.ChatMessage;
import org.mybatis.jpetstore.service.ChatbotService;

import javax.servlet.http.HttpSession;
import java.util.List;

//앤드 포인트 GET /api/chat/history
@UrlBinding("/api/chat/history")
public class ChatHistoryActionBean extends AbstractActionBean {

    @SpringBean
    private ChatbotService chatbotService;

    @DefaultHandler
    public Resolution load() {

        HttpSession session = context.getRequest().getSession();
        AccountActionBean accountBean = (AccountActionBean) session.getAttribute("accountBean");

        if (accountBean == null || !accountBean.isAuthenticated()) {
            return new StreamingResolution("application/json;charset=UTF-8", "[]");
        }

        String userId = accountBean.getAccount().getUsername();
        List<ChatMessage> logs = chatbotService.getMessagesByUserId(userId);

        JSONArray arr = new JSONArray();
        for (ChatMessage msg : logs) {
            JSONObject obj = new JSONObject();
            obj.put("question", msg.getQuestion());
            obj.put("answer", msg.getAnswer());
            obj.put("created_at", msg.getCreatedAt().toString());
            arr.put(obj);
        }

        return new StreamingResolution("application/json;charset=UTF-8", arr.toString());
    }
}
