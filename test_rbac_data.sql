USE TourBuddyDB;
GO

-- Xóa dữ liệu cũ (chỉ để test an toàn nếu chạy lại nhiều lần)
-- DELETE FROM [User] WHERE Email IN ('admin.test@tourbuddy.com', 'staff.test@tourbuddy.com', 'guide.test@tourbuddy.com');

-- 1. Insert Dummy Admin (RoleID = 1)
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'admin.test@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (1, 'admin.test@tourbuddy.com', 'hashed_password_123', N'Super Admin Test', '0901234567', 1, 1, SYSDATETIME());
END
GO

-- 2. Insert Dummy Staff (RoleID = 2)
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'staff.test@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (2, 'staff.test@tourbuddy.com', 'hashed_password_123', N'Nhân viên điều hành Test', '0902345678', 1, 1, SYSDATETIME());
END
GO

-- 3. Insert Dummy Guide (RoleID = 3)
IF NOT EXISTS (SELECT 1 FROM [User] WHERE Email = 'guide.test@tourbuddy.com')
BEGIN
    INSERT INTO [User] (RoleID, Email, PasswordHash, FullName, PhoneNumber, IsActive, IsVerified, CreatedAt)
    VALUES (3, 'guide.test@tourbuddy.com', 'hashed_password_123', N'Hướng dẫn viên Test', '0903456789', 1, 1, SYSDATETIME());
END
GO

-- 4. In ra dữ liệu để kiểm tra
PRINT N'--- DANH SÁCH ROLE ---'
SELECT RoleID, RoleName, IsSystemRole FROM Role;

PRINT N'--- DANH SÁCH USER TEST ---'
SELECT UserID, FullName, Email, RoleID FROM [User] WHERE Email LIKE '%.test@tourbuddy.com';

PRINT N'--- PHÂN QUYỀN HIỆN TẠI ---'
SELECT r.RoleName, p.ModuleName, p.Action 
FROM Role_Permission rp
JOIN Role r ON rp.RoleID = r.RoleID
JOIN Permission p ON rp.PermissionID = p.PermissionID
ORDER BY r.RoleID, p.ModuleName;
GO
