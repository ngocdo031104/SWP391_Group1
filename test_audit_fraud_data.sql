-- Chú ý: Hãy chắc chắn bạn đã chọn đúng Database của dự án TourBuddy trong SSMS trước khi chạy lệnh này.
PRINT '--- Bắt đầu chèn dữ liệu test cho Kiểm Toán & Giám Sát Gian Lận ---';

-- Test Case 1: Giao dịch hợp lệ (Sẽ xuất hiện ở Kiểm Toán Tài Chính với trạng thái Success)
INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse)
VALUES (1, 'VNPAY', 'TEST-VNPAY-001', 7560000, 'VND', 'Success', SYSDATETIME(), '{"msg": "Valid payment"}');

DECLARE @ValidPaymentID INT = SCOPE_IDENTITY();
INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt)
VALUES ('Payment', @ValidPaymentID, 'Process Payment', '', N'Số tiền: 7,560,000 VND, Trạng thái: Success', NULL, SYSDATETIME());

-- Test Case 2: Thanh toán lệch số tiền (Sẽ xuất hiện ở Giám Sát Gian Lận cảnh báo "Lệch số tiền")
-- Ghi chú: Booking 2 có TotalAmount = 3,780,000 nhưng thanh toán chỉ 1,000,000
INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse)
VALUES (2, 'MOMO', 'TEST-MOMO-002', 1000000, 'VND', 'Success', SYSDATETIME(), '{"msg": "Mismatch payment"}');

DECLARE @MismatchPaymentID INT = SCOPE_IDENTITY();
INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt)
VALUES ('Payment', @MismatchPaymentID, 'Process Payment', '', N'Số tiền: 1,000,000 VND, Trạng thái: Success', NULL, SYSDATETIME());

-- Test Case 3: Thanh toán trùng lặp (Sẽ xuất hiện ở Giám Sát Gian Lận cảnh báo "Thanh toán trùng lặp")
INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse)
VALUES (3, 'BankTransfer', 'TEST-BANK-003-A', 9072000, 'VND', 'Success', DATEADD(minute, -10, SYSDATETIME()), '{"msg": "First payment"}');

DECLARE @DuplicateA INT = SCOPE_IDENTITY();
INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt)
VALUES ('Payment', @DuplicateA, 'Process Payment', '', N'Số tiền: 9,072,000 VND, Trạng thái: Success', NULL, DATEADD(minute, -10, SYSDATETIME()));

INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse)
VALUES (3, 'BankTransfer', 'TEST-BANK-003-B', 9072000, 'VND', 'Success', SYSDATETIME(), '{"msg": "Second payment duplicate"}');

DECLARE @DuplicateB INT = SCOPE_IDENTITY();
INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt)
VALUES ('Payment', @DuplicateB, 'Process Payment', '', N'Số tiền: 9,072,000 VND, Trạng thái: Success', NULL, SYSDATETIME());

-- Test Case 4: Kế toán hoàn tiền (Sẽ xuất hiện ở Kiểm Toán Tài Chính do thao tác thủ công)
INSERT INTO Payment (BookingID, PaymentMethod, TransactionRef, Amount, Currency, Status, PaidAt, GatewayResponse)
VALUES (3, 'BankTransfer', 'TEST-REFUND-004', 9072000, 'VND', 'Refunded', SYSDATETIME(), '{"msg": "Refunded successfully"}');

DECLARE @RefundID INT = SCOPE_IDENTITY();
-- Giả sử ID người quản trị thao tác là 1
INSERT INTO FinancialAuditLog (EntityType, EntityID, Action, OldValues, NewValues, PerformedBy, CreatedAt)
VALUES ('Payment', @RefundID, 'Refund', '', N'Hoàn tiền cho khách hàng: 9,072,000 VND', 1, SYSDATETIME());

PRINT '--- Thêm dữ liệu test THÀNH CÔNG ---';
