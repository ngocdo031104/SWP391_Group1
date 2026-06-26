USE TourBuddyDB;
GO

-- 0. Alter Role table
IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE Name = N'IsSystemRole' AND Object_ID = Object_ID(N'Role'))
BEGIN
    ALTER TABLE Role ADD IsSystemRole BIT DEFAULT 0;
END
GO
UPDATE Role SET IsSystemRole = 1 WHERE RoleName IN ('Admin', 'Customer');
GO

-- 1. Create Permission Table
CREATE TABLE Permission (
    PermissionID INT IDENTITY(1,1) PRIMARY KEY,
    ModuleName NVARCHAR(100) NOT NULL,
    Action NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255),
    IsCritical BIT DEFAULT 0,
    CreatedAt DATETIME DEFAULT SYSDATETIME()
);
GO

-- 2. Create Role_Permission Table
CREATE TABLE Role_Permission (
    RoleID INT FOREIGN KEY REFERENCES Role(RoleID) ON DELETE CASCADE,
    PermissionID INT FOREIGN KEY REFERENCES Permission(PermissionID) ON DELETE CASCADE,
    PRIMARY KEY (RoleID, PermissionID)
);
GO

-- 3. Create Audit_Log Table
CREATE TABLE Audit_Log (
    LogID INT IDENTITY(1,1) PRIMARY KEY,
    AdminID INT FOREIGN KEY REFERENCES [User](UserID) ON DELETE NO ACTION,
    ActionType NVARCHAR(100),
    TargetRoleID INT NULL,
    Details NVARCHAR(500),
    CreatedAt DATETIME DEFAULT SYSDATETIME()
);
GO

-- 4. Insert Seed Data for Permissions
INSERT INTO Permission (ModuleName, Action, Description, IsCritical) VALUES
('User Management', 'Read', 'Xem danh sách người dùng', 0),
('User Management', 'Create', 'Tạo người dùng mới', 0),
('User Management', 'Update', 'Cập nhật người dùng', 0),
('User Management', 'Delete', 'Xóa người dùng', 1),
('Tour Management', 'Read', 'Xem danh sách tour', 0),
('Tour Management', 'Create', 'Tạo tour mới', 0),
('Tour Management', 'Update', 'Cập nhật tour', 0),
('Tour Management', 'Delete', 'Xóa tour', 0),
('Booking Management', 'Read', 'Xem danh sách booking', 0),
('Booking Management', 'Create', 'Tạo booking mới', 0),
('Booking Management', 'Update', 'Sửa trạng thái booking', 0),
('Booking Management', 'Delete', 'Hủy booking', 0),
('Booking Management', 'Approve', 'Duyệt booking', 0),
('System Settings', 'Read', 'Xem cấu hình', 1),
('System Settings', 'Update', 'Cập nhật cấu hình', 1),
('Role Management', 'Read', 'Xem danh sách vai trò', 1),
('Role Management', 'Create', 'Tạo vai trò', 1),
('Role Management', 'Update', 'Sửa vai trò', 1),
('Role Management', 'Delete', 'Xóa vai trò', 1);
GO

-- 5. Assign some default permissions to Super Admin (RoleID = 1)
-- Admin gets all permissions
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;
GO

-- 6. Assign some basic permissions to Staff (RoleID = 2)
-- Staff can Read and Create Tours, and Read Bookings
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 2, PermissionID FROM Permission 
WHERE (ModuleName = 'Tour Management' AND Action IN ('Read', 'Create', 'Update'))
   OR (ModuleName = 'Booking Management' AND Action IN ('Read', 'Update'));
GO

-- 7. Assign some basic permissions to Guide (RoleID = 3)
-- Guide can Read Tours
INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 3, PermissionID FROM Permission 
WHERE ModuleName = 'Tour Management' AND Action = 'Read';
GO
