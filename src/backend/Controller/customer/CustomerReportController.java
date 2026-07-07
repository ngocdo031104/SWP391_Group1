package Controller.customer;

import Entities.User;
import Model.ModerationDAO;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "CustomerReportController", urlPatterns = {"/customer/report"})
public class CustomerReportController extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(CustomerReportController.class.getName());

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson();

        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"status\":\"error\",\"message\":\"Vui lòng đăng nhập để báo cáo vi phạm!\"}");
            return;
        }

        String entityType = request.getParameter("entityType");
        String entityIdStr = request.getParameter("entityId");

        if (entityType == null || entityIdStr == null) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"error\",\"message\":\"Thiếu tham số báo cáo vi phạm!\"}");
            return;
        }

        int entityId;
        try {
            entityId = Integer.parseInt(entityIdStr);
        } catch (NumberFormatException e) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"status\":\"error\",\"message\":\"ID nội dung không hợp lệ!\"}");
            return;
        }

        ModerationDAO dao = new ModerationDAO();
        try {
            boolean success = dao.flagContent(entityType, entityId);
            if (success) {
                out.print("{\"status\":\"success\",\"message\":\"Báo cáo nội dung vi phạm thành công! Ban quản trị sẽ sớm xem xét.\"}");
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                out.print("{\"status\":\"error\",\"message\":\"Không thể ghi nhận báo cáo vào hệ thống.\"}");
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Customer flag content failure", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.print("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi: " + e.getMessage() + "\"}");
        } finally {
            dao.close();
        }
    }
}
