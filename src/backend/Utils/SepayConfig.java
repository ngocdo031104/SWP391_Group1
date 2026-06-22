package Utils;

// Người làm: Dương
// Thời gian tạo: 04/06/2026
// Chức năng: Lưu cấu hình SePay/VietQR cho luồng thanh toán booking.
// Ý nghĩa: Gom mã ngân hàng, số tài khoản, tên chủ tài khoản và API key webhook để các controller/JSP dùng chung một nguồn cấu hình.

public class SepayConfig {
    // Mã ngân hàng TPBank dùng trong URL ảnh VietQR.
    public static final String BANK_CODE = "TPB";
    // Số tài khoản nhận tiền khi khách chuyển khoản qua VietQR.
    public static final String ACCOUNT_NO = "0393863658";
    // Tên chủ tài khoản hiển thị trên QR và khung thông tin thanh toán.
    public static final String ACCOUNT_NAME = "Do Manh Duong";
    // API key phải nhập giống hệt trong tab Bảo mật của webhook SePay.
    public static final String WEBHOOK_API_KEY = "TB_SEPAY_DUONG_2026_9F3A7C1B";

    private SepayConfig() {
    }
}