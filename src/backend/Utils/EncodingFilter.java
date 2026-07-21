package Utils;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.Locale;

/**
 * Filter này tự động ép kiểu mã hóa UTF-8 cho tất cả Request/Response
 * giúp sửa lỗi hiển thị sai font tiếng Việt (ký tự rác) trên toàn bộ website.
 */
@WebFilter(filterName = "EncodingFilter", urlPatterns = {"/*"})
public class EncodingFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        // Thiết lập định dạng ký tự UTF-8 cho dữ liệu nhận vào (Form submit)
        request.setCharacterEncoding("UTF-8");

        // Thiết lập định dạng ký tự UTF-8 cho dữ liệu phản hồi (HTML/JSP)
        response.setCharacterEncoding("UTF-8");

        // Đảm bảo Content-Type mặc định cho response HTML là UTF-8 nếu controller chưa set.
        // Tránh đặt mặc định text/html cho các tài nguyên tĩnh như CSS, JS, hình ảnh.
        HttpServletRequest req = (HttpServletRequest) request;
        String uri = req.getRequestURI().toLowerCase();
        
        if (uri.endsWith(".js")) {
            response.setContentType("application/javascript; charset=UTF-8");
        } else if (uri.endsWith(".css")) {
            response.setContentType("text/css; charset=UTF-8");
        } else {
            boolean isStaticResource = uri.endsWith(".png") || uri.endsWith(".jpg") || uri.endsWith(".jpeg") 
                    || uri.endsWith(".gif") || uri.endsWith(".svg") || uri.endsWith(".ico")
                    || uri.endsWith(".woff") || uri.endsWith(".woff2") || uri.endsWith(".ttf");

            if (response.getContentType() == null && !isStaticResource) {
                response.setContentType("text/html; charset=UTF-8");
            }
        }
        // Một số trình duyệt dựa vào Locale của response để chọn encoding mặc định
        if (response instanceof HttpServletResponse) {
            try {
                ((HttpServletResponse) response).setLocale(new Locale("vi", "VN"));
            } catch (Exception ignore) {
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
