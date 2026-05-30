<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <footer class="footer">
        <div class="container footer-main">
            <div class="footer-col footer-brand">
                <a href="${pageContext.request.contextPath}/home" class="logo">
                    <div class="logo-icon">M</div>
                    <span>Mirai</span>
                </a>
                <p class="footer-desc">Kiến tạo hành trình du lịch cao cấp và lịch trình nghỉ dưỡng đặt riêng tại những điểm đến tuyệt đẹp khắp Việt Nam từ năm 2021.</p>
                <div class="social-links">
                    <a href="#" class="btn-icon" aria-label="Facebook"><i data-lucide="facebook"></i></a>
                    <a href="#" class="btn-icon" aria-label="Instagram"><i data-lucide="instagram"></i></a>
                    <a href="#" class="btn-icon" aria-label="Twitter"><i data-lucide="twitter"></i></a>
                    <a href="#" class="btn-icon" aria-label="YouTube"><i data-lucide="youtube"></i></a>
                </div>
            </div>

            <div class="footer-col">
                <h3>Khám Phá</h3>
                <ul class="footer-links">
                    <li><a href="#tours">Gói Tour Cao Cấp</a></li>
                    <li><a href="#destinations">Điểm Đến Hot</a></li>
                    <li><a href="#promotions">Ưu Đãi Đặc Biệt</a></li>
                    <li><a href="#categories-section">Tour Mạo Hiểm</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Hỗ Trợ</h3>
                <ul class="footer-links">
                    <li><a href="#">Trung Tâm Trợ Giúp</a></li>
                    <li><a href="#">Hướng Dẫn Đặt Tour</a></li>
                    <li><a href="#">Chính Sách Hủy</a></li>
                    <li><a href="#">Liên Hệ Hỗ Trợ</a></li>
                </ul>
            </div>

            <div class="footer-col footer-newsletter">
                <h3>Đăng Ký Nhận Tin</h3>
                <p>Cập nhật mã giảm giá, flash sale và hành trình mới nhất từ Mirai Travels.</p>
                <form class="newsletter-form" id="newsletter-subscription-form">
                    <input type="email" placeholder="Email của bạn" id="newsletter-email" required>
                    <button type="submit" id="newsletter-submit-btn">Đăng Ký</button>
                </form>
            </div>
        </div>

        <div class="container footer-bottom">
            <p>&copy; 2026 Mirai Travels Ltd. Bảo lưu mọi quyền. Thiết kế theo tiêu chuẩn du lịch cao cấp.</p>
            <div class="footer-selectors">
                <div class="selector-wrapper">
                    <select id="lang-select" aria-label="Chọn ngôn ngữ">
                        <option value="vi" selected>Tiếng Việt</option>
                        <option value="en">English (US)</option>
                        <option value="jp">日本語</option>
                        <option value="fr">Français</option>
                    </select>
                </div>
                <div class="selector-wrapper">
                    <select id="curr-select" aria-label="Chọn tiền tệ">
                        <option value="vnd" selected>VND (₫)</option>
                        <option value="usd">USD ($)</option>
                        <option value="eur">EUR (€)</option>
                        <option value="jpy">JPY (¥)</option>
                    </select>
                </div>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/js/navigation.js"></script>
    <script src="${pageContext.request.contextPath}/js/homepage.js"></script>
</body>
</html>
