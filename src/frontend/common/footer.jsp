<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

    <footer class="footer">
        <div class="container footer-main">
            <div class="footer-col footer-brand">
                <a href="${pageContext.request.contextPath}/home" class="logo">
                    <div class="logo-icon">T</div>
                    <span>TourBuddy</span>
                </a>
                <p class="footer-desc">Kiến tạo hành trình du lịch cao cấp và lịch trình nghỉ dưỡng đặt riêng tại những điểm đến tuyệt đẹp khắp Việt Nam từ năm 2021.</p>
                <div class="social-links">
                    <a href="https://facebook.com/TourBuddyVN" class="btn-icon" aria-label="Facebook"><i data-lucide="facebook"></i></a>
                    <a href="https://instagram.com/tourbuddy.vn" class="btn-icon" aria-label="Instagram"><i data-lucide="instagram"></i></a>
                    <a href="https://twitter.com/TourBuddyVN" class="btn-icon" aria-label="Twitter"><i data-lucide="twitter"></i></a>
                    <a href="https://youtube.com/@TourBuddyVN" class="btn-icon" aria-label="YouTube"><i data-lucide="youtube"></i></a>
                </div>
            </div>

            <div class="footer-col">
                <h3>Khám Phá</h3>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/tourdiscovery">Gói Tour Cao Cấp</a></li>
                    <li><a href="${pageContext.request.contextPath}/tourdiscovery">Điểm Đến Hot</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#promotions">Ưu Đãi Đặc Biệt</a></li>
                    <li><a href="${pageContext.request.contextPath}/tourdiscovery?category=adventure">Tour Mạo Hiểm</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>Hỗ Trợ</h3>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/help">Trung Tâm Trợ Giúp</a></li>
                    <li><a href="${pageContext.request.contextPath}/guide-booking">Hướng Dẫn Đặt Tour</a></li>
                    <li><a href="${pageContext.request.contextPath}/policy/cancel">Chính Sách Hủy</a></li>
                    <li><a href="${pageContext.request.contextPath}/contact">Liên Hệ Hỗ Trợ</a></li>
                </ul>
            </div>

            <div class="footer-col footer-newsletter">
                <h3>Đăng Ký Nhận Tin</h3>
                <p>Cập nhật mã giảm giá, flash sale và hành trình mới nhất từ TourBuddy.</p>
                <form class="newsletter-form" id="newsletter-subscription-form">
                    <input type="email" placeholder="Email của bạn" id="newsletter-email" required>
                    <button type="submit" id="newsletter-submit-btn">Đăng Ký</button>
                </form>
            </div>
        </div>

        <div class="container footer-bottom">
            <p>&copy; 2026 TourBuddy Ltd. Bảo lưu mọi quyền. Thiết kế theo tiêu chuẩn du lịch cao cấp.</p>
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

    <script src="${pageContext.request.contextPath}/js/navigation.js?v=2.1"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const form = document.getElementById('newsletter-subscription-form');
            if (form) {
                form.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const email = document.getElementById('newsletter-email').value;
                    
                    fetch('${pageContext.request.contextPath}/newsletter/subscribe', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: 'email=' + encodeURIComponent(email)
                    })
                    .then(res => res.json())
                    .then(res => {
                        alert(res.message);
                        if (res.status === 'success') {
                            form.reset();
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        alert('Có lỗi hệ thống xảy ra. Vui lòng thử lại sau.');
                    });
                });
            }
        });
    </script>
    <% 
        String extraScript = (String) request.getAttribute("extraScript");
        if (extraScript != null && !extraScript.trim().isEmpty()) {
    %>
    <script src="${pageContext.request.contextPath}/<%= extraScript %>?v=2.1"></script>
    <% 
        }
    %>
</body>
</html>
