/*
 * Màn hình 6: Search and Filter Tours - Tìm kiếm & lọc tour
 * Tác giả: Dương Quang Sơn
 * MSSV: HE186525
 * Ngày tạo: 2026-07-21
 */
package Controller;

import Entities.Tour;
import Entities.TourCategory;
import Model.TourDAO;
import java.io.IOException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

// URL mapping "/tourdiscovery" để phục vụ cho trang tìm kiếm và lọc tour du lịch
@WebServlet(name = "TourDiscoveryController", urlPatterns = {"/tourdiscovery"})
public class TourDiscoveryController extends HttpServlet {

    /**
     * Xử lý yêu cầu HTTP GET.
     * Thực hiện tìm kiếm và lọc tour du lịch dựa trên các tham số tìm kiếm gửi từ Header hoặc Trang chủ:
     * - dest: Điểm đến mong muốn.
     * - date: Ngày khởi hành mong muốn.
     * - budget: Ngân sách tối đa của khách hàng.
     * Nạp thêm dữ liệu phụ trợ (Wishlist, Categories, Distinct Destinations, Departure Cities) chuyển tiếp sang JSP hiển thị.
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");
        response.setCharacterEncoding("UTF-8");
        
        TourDAO tourDAO = null;
        try {
            // Khởi động DAO kết nối DB
            tourDAO = new TourDAO();
            
            // Load danh sách danh mục để làm bộ lọc checkbox ở sidebar bên trái
            List<TourCategory> categories = tourDAO.getAllCategories();
            
            // Nhận các tham số tìm kiếm từ ô Search ở Header hoặc trang chủ đẩy sang
            String dest = request.getParameter("dest");             // Điểm đến (ví dụ: "Hạ Long")
            String departureDate = request.getParameter("date");    // Ngày khởi hành mong muốn
            String budgetStr = request.getParameter("budget");      // Ngân sách tối đa (kiểu chuỗi)
            
            Double maxPrice = null;
            // Ép kiểu ngân sách từ chuỗi sang Double để truyền vào query DB.
            if (budgetStr != null && !budgetStr.trim().isEmpty()) {
                try {
                    maxPrice = Double.parseDouble(budgetStr);
                } catch (NumberFormatException e) {
                    // Cứ im lặng bỏ qua, DB sẽ hiểu maxPrice = null là không lọc theo giá
                }
            }
            
            // Tìm kiếm các tour khớp với điều kiện lọc ban đầu từ database SQL Server.
            List<Tour> tours = tourDAO.searchTours(dest, null, maxPrice, departureDate);
            
            // Đối với mỗi tour tìm được, phải nạp kèm danh sách lịch trình (schedules) tương lai
            if (tours != null) {
                for (Tour tour : tours) {
                    tour.setSchedules(tourDAO.getSchedulesByTourId(tour.getTourId()));
                }
            }
            
            // Set attributes để chuyển tiếp dữ liệu hiển thị sang trang JSP
            request.setAttribute("categories", categories);
            request.setAttribute("tours", tours);
            
            // Nạp wishlist nếu người dùng đã đăng nhập
            Entities.User sessionUser = (Entities.User) request.getSession().getAttribute("sessionUser");
            if (sessionUser != null) {
                Model.WishlistDAO wishlistDAO = new Model.WishlistDAO();
                List<Integer> wishlistTourIds = wishlistDAO.getWishlistTourIds(sessionUser.getUserId());
                request.setAttribute("wishlistTourIds", wishlistTourIds);
                wishlistDAO.close();
            }
            
            // Trả lại các từ khóa tìm kiếm cũ lên form để người dùng thấy họ đã tìm gì
            request.setAttribute("searchDest", dest != null ? dest : "");
            request.setAttribute("searchDate", departureDate != null ? departureDate : "");
            request.setAttribute("searchBudget", budgetStr != null ? budgetStr : "");
            
            // Lấy danh sách tất cả các điểm đến duy nhất có trong DB để làm gợi ý autocomplete (datalist) cho ô search
            request.setAttribute("destinations", tourDAO.getDistinctDestinations());
            
            // Lấy danh sách tất cả thành phố khởi hành để render checkbox filter điểm xuất phát bên sidebar
            request.setAttribute("departureCities", tourDAO.getDistinctDepartureCities());
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            // Luôn luôn đóng kết nối DB
            if (tourDAO != null) {
                tourDAO.close();
            }
        }
        
        // Chuyển sang file tourdiscovery.jsp để render HTML + khởi tạo mảng toursData cho JS xử lý filter client-side
        request.getRequestDispatcher("/views/tourdiscovery.jsp").forward(request, response);
    }

    /**
     * Xử lý yêu cầu HTTP POST.
     * Chuyển tiếp yêu cầu trực tiếp về phương thức doGet để cùng xử lý quy trình lọc và tìm kiếm tour.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
