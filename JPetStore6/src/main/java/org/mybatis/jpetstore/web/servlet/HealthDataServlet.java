package src.main.java.org.mybatis.jpetstore.web.servlet;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

import org.mybatis.jpetstore.service.HealthDataService;

@WebServlet("/chat/health")
public class HealthDataServlet extends HttpServlet {

    @Autowired
    private HealthDataService healthDataService;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "orderId is required");
            return;
        }

        int orderId = Integer.parseInt(orderIdStr);
        String detail = healthDataService.getHealthData(orderId);

        resp.setContentType("application/json; charset=UTF-8");
        resp.getWriter().write(
                detail == null ? "{}" : detail
        );
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");

        String orderIdStr = req.getParameter("orderId");
        String detail = req.getParameter("detail");

        if (orderIdStr == null || detail == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "orderId and detail required");
            return;
        }

        int orderId = Integer.parseInt(orderIdStr);

        healthDataService.saveHealthData(orderId, detail);

        resp.setContentType("text/plain; charset=UTF-8");
        resp.getWriter().write("success");
    }
}
