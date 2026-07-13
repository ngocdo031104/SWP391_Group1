<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

<jsp:include page="/common/header.jsp" />

<div class="container" style="margin-top: 120px; margin-bottom: 60px; max-width: 600px; font-family: 'Inter', sans-serif;">
    <h1 style="font-family: 'Outfit', sans-serif; font-size: 2.5rem; color: #1e1b4b; text-align: center; margin-bottom: 10px;">Liên Hệ Hỗ Trợ</h1>
    <p style="text-align: center; color: #64748b; margin-bottom: 30px; font-size: 1.1rem;">Hãy để lại lời nhắn, đội ngũ hỗ trợ sẽ liên hệ với bạn sớm nhất.</p>

    <div style="background: #ffffff; border-radius: 12px; box-shadow: 0 4px 20px rgba(0,0,0,0.05); padding: 30px;">
        <%
            String successMessage = (String) request.getAttribute("successMessage");
            if (successMessage != null) {
        %>
            <div style="background: #ecfdf5; border: 1px solid #10b981; color: #065f46; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: 500; font-size: 0.95rem;">
                <%= successMessage %>
            </div>
        <%
            }
            String errorMessage = (String) request.getAttribute("errorMessage");
            if (errorMessage != null) {
        %>
            <div style="background: #fef2f2; border: 1px solid #ef4444; color: #991b1b; padding: 15px; border-radius: 8px; margin-bottom: 20px; font-weight: 500; font-size: 0.95rem;">
                <%= errorMessage %>
            </div>
        <%
            }
        %>

        <%
            // Lấy thông tin user đăng nhập
            Entities.User currentUser = (Entities.User) session.getAttribute("sessionUser");
            String fullName = currentUser != null ? currentUser.getFullName() : "";
            String email = currentUser != null ? currentUser.getEmail() : "";
        %>

        <form action="${pageContext.request.contextPath}/contact" method="POST" style="display: flex; flex-direction: column; gap: 20px;">
            <div style="display: flex; flex-direction: column; gap: 8px;">
                <label for="contact-name" style="font-weight: 600; color: #334155; font-size: 0.95rem;">Họ và Tên *</label>
                <input type="text" id="contact-name" name="name" value="<%= fullName %>" readonly required style="padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; outline: none; background-color: #f1f5f9; cursor: not-allowed;">
            </div>

            <div style="display: flex; flex-direction: column; gap: 8px;">
                <label for="contact-email" style="font-weight: 600; color: #334155; font-size: 0.95rem;">Địa chỉ Email *</label>
                <input type="email" id="contact-email" name="email" value="<%= email %>" readonly required style="padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; outline: none; background-color: #f1f5f9; cursor: not-allowed;">
            </div>

            <div style="display: flex; flex-direction: column; gap: 8px;">
                <label for="contact-subject" style="font-weight: 600; color: #334155; font-size: 0.95rem;">Chủ đề cần hỗ trợ</label>
                <input type="text" id="contact-subject" name="subject" style="padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; outline: none; transition: border 0.2s;" onfocus="this.style.borderColor='#4f46e5'" onblur="this.style.borderColor='#cbd5e1'">
            </div>

            <div style="display: flex; flex-direction: column; gap: 8px;">
                <label for="contact-message" style="font-weight: 600; color: #334155; font-size: 0.95rem;">Nội dung lời nhắn *</label>
                <textarea id="contact-message" name="message" rows="5" required style="padding: 10px 14px; border: 1px solid #cbd5e1; border-radius: 6px; font-size: 0.95rem; outline: none; resize: vertical; min-height: 120px; transition: border 0.2s;" onfocus="this.style.borderColor='#4f46e5'" onblur="this.style.borderColor='#cbd5e1'"></textarea>
            </div>

            <button type="submit" class="btn btn-primary" style="padding: 12px; font-weight: 600; cursor: pointer; text-align: center; border: none;">Gửi lời nhắn liên hệ &rarr;</button>
        </form>
    </div>
</div>

<jsp:include page="/common/footer.jsp" />
