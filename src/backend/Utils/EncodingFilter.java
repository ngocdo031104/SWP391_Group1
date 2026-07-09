package Utils;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import java.io.IOException;

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
        
        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {
    }
}
