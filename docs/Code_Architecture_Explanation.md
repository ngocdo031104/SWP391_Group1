# Báo Cáo Giải Thích Kiến Trúc & Luồng Dữ Liệu Hệ Thống TourBuddy

Tài liệu này cung cấp cái nhìn chi tiết và toàn diện về cấu trúc mã nguồn, cơ sở dữ liệu và luồng xử lý (Data/Code Flow) của 3 trang cốt lõi trong ứng dụng **TourBuddy**: **Trang Chủ (Homepage)**, **Trang Khám Phá (Tour Discovery)**, và **Trang Chi Tiết Tour (Tour Detail)**.

---

## 📌 Tổng Quan Kiến Trúc Dự Án
Dự án được xây dựng dựa trên mô hình chuẩn **MVC (Model-View-Controller)** sử dụng công nghệ Java Web tiêu chuẩn:
- **Model (Database Access)**: Lớp kết nối cơ sở dữ liệu `Utils.DBContext` và lớp xử lý logic truy vấn dữ liệu `Model.TourDAO`.
- **Controller (Servlets)**: Các Servlets tiếp nhận yêu cầu HTTP (`doGet`, `doPost`), truy xuất dữ liệu từ DAO, đẩy dữ liệu sang Request Attributes và chuyển tiếp (forward) yêu cầu sang JSP.
- **View (JSP, JS, CSS)**: Các trang JSP kết xuất mã HTML động sử dụng JSTL và Java Scriptlet, kết hợp với các tệp CSS tự định nghĩa (Vanilla CSS) và JavaScript phía Client-side (nhận dữ liệu JSON từ JSP và xử lý tương tác).

---

## 1. TRANG CHỦ (HOMEPAGE)

### A. Các Tệp Tin Liên Quan
*   **Controller**: [HomeController.java](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/java/Controller/HomeController.java) (Ánh xạ đường dẫn `/home`)
*   **JSP View**: [HomePage.jsp](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/JSP/HomePage.jsp)
*   **JavaScript**: [homepage.js](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/js/homepage.js)
*   **CSS**: [homepage.css](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/css/homepage.css)

### B. Các Bảng Cơ Sở Dữ Liệu Sử Dụng
Trang chủ nạp và hiển thị tổng quan các thành phần nổi bật thông qua các bảng sau:
1.  **`Tour`**: Truy vấn danh sách các tour được đánh dấu nổi bật (`IsFeatured = 1` và `Status = 'Active'`).
2.  **`TourCategory`**: Nạp danh sách các phân loại tour đang hoạt động (`IsActive = 1`) để tạo bộ lọc danh mục (Ví dụ: Nghỉ dưỡng, Khám phá biển, Trekking...).
3.  **`DestinationInfo` / `Tour`**: Lấy danh sách địa danh hot dựa trên số lượng tour được tạo đến địa danh đó.
4.  **`Review`** (kết hợp với **`User`** và **`UserProfile`**): Lấy 5 đánh giá đánh giá mới nhất có điểm số từ 4★ trở lên để làm thanh trượt đánh giá khách hàng (Testimonials Slider).
5.  **`Coupon`**: Lấy danh sách 5 mã giảm giá đang trong thời gian hiệu lực và đang kích hoạt để hiển thị trong khu vực khuyến mãi.

### C. Luồng Đi Của Code & Cách Hoạt Động (Data Flow)

#### Chi tiết các bước thực thi:
1.  **Yêu cầu Client**: Người dùng truy cập đường dẫn `/home`. Trình duyệt gửi yêu cầu HTTP GET đến `HomeController`.
2.  **Truy xuất dữ liệu (Controller)**:
    -   `HomeController` gọi `tourDAO.getAllCategories()` để lấy danh sách danh mục tour.
    -   Gọi `tourDAO.getFeaturedTours()` thực thi câu lệnh SQL:
        ```sql
        SELECT TourID, CategoryID, TourName, Description, Destination, DurationDays, BasePrice, MaxParticipants, Status, IsFeatured, ...
        FROM Tour WHERE IsFeatured = 1 AND Status = 'Active'
        ```
    -   Gọi `tourDAO.getTopReviews(5)` để truy xuất các đánh giá thực tế của người dùng:
        ```sql
        SELECT TOP 5 r.ReviewID, r.CustomerName, r.Rating, r.Content, up.AvatarURL
        FROM Review r
        INNER JOIN [User] u ON r.UserID = u.UserID
        LEFT JOIN UserProfile up ON u.UserID = up.UserID
        WHERE r.Rating >= 4 AND r.IsVisible = 1
        ORDER BY r.CreatedAt DESC
        ```
3.  **Truyền tải View**: `HomeController` đóng gói toàn bộ danh sách kết quả vào các thuộc tính request (`request.setAttribute`) và thực hiện `forward` sang `JSP/HomePage.jsp`.
4.  **Kết xuất HTML (JSP)**:
    -   Sử dụng thẻ `<c:forEach>` của JSTL để lặp qua danh mục, danh sách mã giảm giá (`activeCoupons`) để hiển thị trực tiếp.
    -   Dữ liệu danh sách tour được chuyển đổi sang định dạng JSON và gán vào biến toàn cục `window.toursData` để JavaScript xử lý.
5.  **Tương tác Client-side (JavaScript - `homepage.js`)**:
    -   **Bộ lọc danh mục**: Lắng nghe sự kiện click trên các nút danh mục. Khi click, lọc các phần tử có `category` tương ứng trong mảng `toursData`, ẩn các tour không khớp và chỉ hiển thị tối đa 9 tour nổi bật đầu tiên.
    -   **Thu gọn / Xem thêm**: Ẩn bớt các điểm đến từ phần tử thứ 7 trở đi và các tour từ phần tử thứ 10 trở đi. Khi click nút "Xem thêm", mở rộng hiển thị toàn bộ và chuyển đổi nhãn nút cùng icon mũi tên. Khi nhấn "Thu gọn", co lại danh sách và thực hiện hiệu ứng cuộn mượt (`scrollIntoView`) lên đầu lưới hiển thị.
    -   **Slider Đánh Giá**: Tự động chuyển slide đánh giá mỗi 5 giây hoặc khi click vào các nút chấm chỉ số bên dưới.

---

## 2. TRANG KHÁM PHÁ TOUR (TOUR DISCOVERY)

### A. Các Tệp Tin Liên Quan
*   **Controller**: [TourDiscoveryController.java](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/java/Controller/TourDiscoveryController.java) (Ánh xạ `/tourdiscovery`)
*   **JSP View**: [tourdiscovery.jsp](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/JSP/tourdiscovery.jsp)
*   **JavaScript**: [tourdiscovery.js](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/js/tourdiscovery.js)
*   **CSS**: [tourdiscovery.css](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/css/tourdiscovery.css)

### B. Các Bảng Cơ Sở Dữ Liệu Sử Dụng
1.  **`Tour`**: Tìm kiếm các tour khớp với từ khóa tìm kiếm điểm đến (`Destination`) hoặc khoảng giá. Lấy danh sách điểm đến không trùng lặp (`getDistinctDestinations`) và thành phố khởi hành (`getDistinctDepartureCities`).
2.  **`TourCategory`**: Nạp danh sách phân loại tour để render tab lọc.
3.  **`TourSchedule`**: Lấy thông tin các lịch khởi hành sắp tới của từng tour để tính toán số ghế trống thời gian thực.

### C. Luồng Đi Của Code & Cách Hoạt Động (Data Flow)

#### Chi tiết các bước thực thi:
1.  **Yêu cầu tìm kiếm**: Khi người dùng nhấn nút Tìm kiếm ở Navbar hoặc trang chủ, trình duyệt điều hướng đến `/tourdiscovery` kèm theo các tham số truy vấn như: `?dest=Hạ Long&budget=6000000`.
2.  **Bộ lọc dữ liệu (Controller)**:
    -   `TourDiscoveryController` đọc các tham số bằng `request.getParameter()`.
    -   Nạp danh sách địa điểm và thành phố khởi hành độc lập từ DB để render bộ lọc thanh bên (sidebar):
        -   `tourDAO.getDistinctDestinations()` thực thi `SELECT DISTINCT Destination FROM Tour`.
        -   `tourDAO.getDistinctDepartureCities()` thực thi `SELECT DISTINCT DepartureCity FROM Tour`.
    -   Gọi `tourDAO.searchTours(dest, categoryId, maxPrice, date)` để thực hiện tìm kiếm động trong DB:
        ```sql
        SELECT DISTINCT t.TourID, t.TourName, t.Destination, t.BasePrice, ...
        FROM Tour t
        LEFT JOIN TourSchedule s ON t.TourID = s.TourID
        WHERE t.Status = 'Active' AND t.Destination LIKE ? AND t.BasePrice <= ?
        ```
    -   Đồng thời nạp lịch khởi hành cho từng tour để lấy thông tin số chỗ trống thời gian thực.
3.  **Forward sang View**: Đẩy dữ liệu qua request attributes và forward sang `tourdiscovery.jsp`.
4.  **Hiển thị & Xử lý bộ lọc nâng cao (JavaScript - `tourdiscovery.js`)**:
    -   Dữ liệu được inject vào `window.toursData`.
    -   JavaScript lắng nghe sự thay đổi trên thanh lọc sidebar:
        -   **Chọn thành phố khởi hành** (Checkboxes).
        -   **Chọn thời lượng** (Checkboxes: Dưới 3 ngày, 3-5 ngày, Trên 5 ngày).
        -   **Thanh kéo khoảng giá** (Range slider).
        -   **Lọc danh mục** (Categories tab).
    -   Mỗi khi có bộ lọc thay đổi, JS lọc lại mảng `toursData` phía Client, xóa trắng container danh sách tour và vẽ lại các card tour khớp điều kiện mà không cần tải lại toàn bộ trang web (Ajax-like rendering).

---

## 3. TRANG CHI TIẾT TOUR (TOUR DETAIL)

### A. Các Tệp Tin Liên Quan
*   **Controller**: [DetailController.java](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/java/Controller/DetailController.java) (Ánh xạ `/detail`)
*   **JSP View**: [detail.jsp](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/JSP/detail.jsp)
*   **JavaScript**: [detail.js](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/js/detail.js)
*   **CSS**: [detail.css](file:///c:/Users/sonkb/Desktop/SWP391_Group1/src/main/webapp/css/detail.css)

### B. Các Bảng Cơ Sở Dữ Liệu Sử Dụng
Trang chi tiết tích hợp sâu và nạp toàn bộ thông tin quan hệ của một Tour thông qua các bảng sau:
1.  **`Tour`**: Lấy thông tin cơ bản của tour (Tiêu đề, Mô tả, Giá cơ bản, Ngôn ngữ, Thành phố khởi hành).
2.  **`TourCategory`**: Lấy tên danh mục dịch vụ.
3.  **`TourMedia`**: Lấy danh sách ảnh/video để tạo thư viện ảnh (Grid Gallery & Lightbox).
4.  **`TourSchedule`** (kết hợp với **`User`** & **`UserProfile`**): Lấy lịch khởi hành gần nhất, số chỗ trống (`AvailableSeats`), và thông tin của Hướng dẫn viên được phân công (`GuideID`).
5.  **`TourItinerary`**: Lấy lộ trình chi tiết từng ngày (DayNumber, Title, Description, ImageURL) để xây dựng Trục thời gian (Timeline Accordion).
6.  **`TourInclusion`**: Lấy thông tin dịch vụ bao gồm và không bao gồm của tour.
7.  **`TourFAQ`**: Lấy danh sách các câu hỏi thường gặp FAQ.
8.  **`Review`**: Lấy các đánh giá thật của khách hàng, đếm số sao và tính toán động bảng điểm phân phối đánh giá (Rating Scorecard).
9.  **`Coupon`**: Lấy 10 mã giảm giá đang hoạt động để người dùng có thể nhập kiểm tra trong hóa đơn sidebar.

### C. Luồng Đi Của Code & Cách Hoạt Động (Data Flow)

#### 3.1. Luồng Xem Chi Tiết Tour (HTTP GET)

##### Chi tiết xử lý tại View:
1.  **JSP (Server-side rendering)**:
    -   Hiển thị tiêu đề, mô tả, ảnh đại diện, danh sách Inclusion/Exclusion và FAQ.
    -   Tính toán tỷ lệ phân bổ sao của các đánh giá trong DB:
        -   Lặp qua danh sách `reviews` và tính tổng số đánh giá cho từng mức (1★ đến 5★).
        -   Tính tỷ lệ phần trăm tương ứng và kết xuất trực tiếp lên thanh biểu đồ phần trăm đánh giá.
    -   Nhúng mảng dữ liệu lịch trình (`window.itinerariesData`) và mã giảm giá (`window.activeCoupons`) dưới dạng mảng JSON JavaScript.
2.  **JavaScript (Client-side rendering - `detail.js`)**:
    -   **Vẽ trục thời gian (Timeline)**: Lấy dữ liệu từ `window.itinerariesData[activeTour.id]` và tạo các node HTML dọc để hiển thị lộ trình từng ngày. Thiết lập sự kiện click để mở/thu gọn nội dung chi tiết của ngày đó (Accordion).
    -   **Lightbox Xem Ảnh**: Lắng nghe sự kiện click trên các ảnh nhỏ trong Grid Gallery, hiển thị ảnh phóng to ở màn hình phủ (overlay Modal) hỗ trợ chuyển ảnh bằng phím mũi tên hoặc click nút Next/Prev.
    -   **Lịch tính toán giá sidebar & Áp mã giảm giá**:
        -   **Sửa lỗi crash do thiếu DOM**: Các tệp biến và mã kiểm tra của sidebar (như nhập mã giảm giá, hiển thị hóa đơn nháp) được bọc trong các kiểm tra null (`if (billCalcLabel)`) giúp JavaScript chạy mượt mà, không bị xung đột khi chúng ta lược bỏ giao diện tính tiền cũ theo yêu cầu người dùng.
        -   **Mã giảm giá động**: So khớp mã người dùng nhập với danh sách `window.activeCoupons`. Kiểm tra điều kiện mua tối thiểu (`MinOrderAmount`). Nếu đạt yêu cầu, tự động trừ tiền theo định dạng % hoặc tiền mặt cố định.
    -   **Nút Thanh Toán Cao Cấp**:
        -   Được thiết kế lại bao gồm viền bao bảo mật chuyên nghiệp (`.payment-section-box`), chấm xanh nhấp nháy động báo trạng thái kết nối tốt, nút bấm dạng Gradient kèm hiệu ứng quét sáng kim loại (`hover shine effect`) và hàng cam kết an toàn giao dịch (`payment-trust-footer`).
        -   Khi click nút, JavaScript chuyển tiếp người dùng sang liên kết thanh toán (`window.open('', '_blank')`).

---

#### 3.2. Luồng Gửi Đánh Giá Mới (HTTP POST)

##### Chi tiết xử lý gửi đánh giá:
1.  **Form Nhập liệu**: Khách hàng chọn số sao trên bộ chọn sao bằng chuột (JavaScript lắng nghe sự kiện click trên `#stars-selector`, cập nhật hiệu ứng sáng của sao và gán số sao vào input ẩn `#review-rating-input`). Khách hàng nhập tên, email, nội dung bình luận và bấm **Gửi Đánh Giá**.
2.  **Gửi dữ liệu**: Form thực hiện gửi dữ liệu bằng phương thức POST lên Servlet `/detail`.
3.  **Lưu trữ (Servlet)**: `DetailController` nhận dữ liệu bằng `request.getParameter()`, mã hóa UTF-8 để giữ nguyên chữ tiếng Việt có dấu, khởi tạo DAO và gọi `tourDAO.insertReview(...)` thực thi chèn bản ghi vào database.
4.  **Tải lại trang an toàn (PRG Pattern)**:
    -   Sau khi thêm thành công, Servlet dùng lệnh `response.sendRedirect(...)` chuyển hướng trình duyệt của người dùng thực hiện một yêu cầu GET mới quay lại trang chi tiết.
    -   Cơ chế này giúp chặn hoàn toàn hiện tượng gửi trùng lặp đánh giá (nếu người dùng nhấn nút tải lại trang F5, trình duyệt chỉ gửi lại yêu cầu GET thay vì gửi lại yêu cầu POST chèn dữ liệu cũ).

---

## 4. SƠ ĐỒ QUAN HỆ CƠ SỞ DỮ LIỆU (DATABASE SCHEMAS)

```
[TourCategory] (1) <---+
                       |
[DestinationInfo] <----+
                       |
                       +-- (1..*) [Tour] (1) <---+-- (1..*) [TourMedia]
                                                 +-- (1..*) [TourItinerary]
                                                 +-- (1..*) [TourInclusion]
                                                 +-- (1..*) [TourFAQ]
                                                 +-- (1..*) [TourSchedule] (GuideID FK)
                                                 +-- (1..*) [Review] (UserID FK)
                                                                |
                                                                | (Many-to-1)
                                                                v
                                                             [User] (1) <---> (1) [UserProfile]
```
