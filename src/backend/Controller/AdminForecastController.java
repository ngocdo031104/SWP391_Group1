/*
 * Màn hình 39: Perform Predictive Analytics - Dự đoán xu hướng booking & doanh thu
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller;

import Entities.PredictionResult;
import Entities.User;
import Model.AnalyticsDAO;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet(name = "AdminForecastController", urlPatterns = {"/admin/forecast"})
public class AdminForecastController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(AdminForecastController.class.getName());

    private boolean hasForecastPermission(User user) {
        if (user == null) return false;
        if (user.getRoleId() == 1) return true; // Super Admin bypass
        if (user.getRole() != null && user.getRole().getPermissions() != null) {
            for (Entities.Permission p : user.getRole().getPermissions()) {
                if (p.getPermissionId() == 39 
                    || "Perform Predictive Analytics".equalsIgnoreCase(p.getModuleName()) 
                    || "Perform Predictive Analytics".equalsIgnoreCase(p.getAction())) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        if (!hasForecastPermission(sessionUser)) {
            response.sendRedirect(request.getContextPath() + "/home");
            return;
        }

        String ajax = request.getParameter("ajax");
        AnalyticsDAO analyticsDAO = new AnalyticsDAO();
        
        try {
            if ("true".equalsIgnoreCase(ajax)) {
                response.setContentType("application/json;charset=UTF-8");
                String action = request.getParameter("action");
                
                if ("getCalculations".equalsIgnoreCase(action)) {
                    String type = request.getParameter("type");
                    if (type == null || type.trim().isEmpty()) {
                        type = "Revenue";
                    }
                    Map<String, Object> forecastData = analyticsDAO.calculateForecast(type);
                    String json = new Gson().toJson(forecastData);
                    try (PrintWriter out = response.getWriter()) {
                        out.print(json);
                    }
                } else {
                    List<PredictionResult> history = analyticsDAO.getAllPredictions();
                    String json = new Gson().toJson(history);
                    try (PrintWriter out = response.getWriter()) {
                        out.print(json);
                    }
                }
            } else {
                List<PredictionResult> history = analyticsDAO.getAllPredictions();
                request.setAttribute("predictionsHistory", history);
                request.getRequestDispatcher("/admin/forecast.jsp").forward(request, response);
            }
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Forecast data load failure", e);
            if ("true".equalsIgnoreCase(ajax)) {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.setContentType("application/json;charset=UTF-8");
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"Lỗi hệ thống khi tải dữ liệu dự báo\"}");
                }
            } else {
                throw new ServletException(e);
            }
        } finally {
            analyticsDAO.close();
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        User sessionUser = (User) request.getSession().getAttribute("sessionUser");
        if (sessionUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }
        if (!hasForecastPermission(sessionUser)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            return;
        }

        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "Revenue";
        }

        response.setContentType("application/json;charset=UTF-8");
        AnalyticsDAO analyticsDAO = new AnalyticsDAO();
        Gson gson = new Gson();

        try {
            // Run forecast calculation engine
            Map<String, Object> forecastData = analyticsDAO.calculateForecast(type);
            
            // Extract confidence score
            double confidence = 85.0;
            if (forecastData.containsKey("confidence")) {
                confidence = ((Number) forecastData.get("confidence")).doubleValue();
            }

            // Extract input history and prediction results
            String inputDataJson = "";
            String resultDataJson = "";
            if ("Demand".equalsIgnoreCase(type)) {
                inputDataJson = gson.toJson(forecastData.get("historical_top_tours"));
                resultDataJson = gson.toJson(forecastData.get("projected_demand"));
            } else {
                inputDataJson = gson.toJson(forecastData.get("historical"));
                resultDataJson = gson.toJson(forecastData.get("forecast"));
            }

            // Save to DB snapshot
            PredictionResult pr = new PredictionResult();
            pr.setPredictionType(type);
            pr.setModelVersion("v1.0-Regression/WMA");
            pr.setInputData(inputDataJson);
            pr.setResultData(resultDataJson);
            pr.setConfidence(confidence);
            pr.setGeneratedBy(sessionUser.getUserId());

            int newId = analyticsDAO.insertPrediction(pr);

            if (newId > 0) {
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"success\",\"message\":\"Chạy mô hình dự báo thành công và đã lưu snapshot vào CSDL!\",\"newId\":" + newId + "}");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                try (PrintWriter out = response.getWriter()) {
                    out.print("{\"status\":\"error\",\"message\":\"Không thể lưu kết quả dự báo vào CSDL.\"}");
                }
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Generate forecast execution failure", e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            try (PrintWriter out = response.getWriter()) {
                out.print("{\"status\":\"error\",\"message\":\"Đã xảy ra lỗi trong quá trình dự báo: " + e.getMessage() + "\"}");
            }
        } finally {
            analyticsDAO.close();
        }
    }
}
