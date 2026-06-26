USE TourBuddyDB;
GO

DELETE FROM Role_Permission;
DELETE FROM Permission;

DBCC CHECKIDENT ('Permission', RESEED, 0);

INSERT INTO Permission (ModuleName, Action, Description, IsCritical) VALUES
('Tour Management', 'Read', N'View Tour', 0),
('Tour Management', 'Create', N'Create Tour', 0),
('Tour Management', 'Update', N'Update Tour', 0),
('Tour Management', 'Delete', N'Delete Tour', 1),

('Booking Management', 'Read', N'View Booking', 0),
('Booking Management', 'Create', N'Create Booking', 0),
('Booking Management', 'Update', N'Update Booking', 0),
('Booking Management', 'Delete', N'Delete Booking', 1),

('User Management', 'Read', N'View Users', 0),
('User Management', 'Create', N'Create Users', 0),
('User Management', 'Update', N'Update Users', 0),
('User Management', 'Delete', N'Delete Users', 1),

('Role Management', 'Read', N'View Roles', 1),
('Role Management', 'Create', N'Create Roles', 1),
('Role Management', 'Update', N'Update Roles', 1),
('Role Management', 'Delete', N'Delete Roles', 1),

('Matching Management', 'Read', N'View Matching', 0),
('Matching Management', 'Create', N'Create Matching', 0),
('Matching Management', 'Update', N'Update Matching', 0),
('Matching Management', 'Delete', N'Delete Matching', 0),

('Request Management', 'Read', N'View Requests', 0),
('Request Management', 'Create', N'Create Requests', 0),
('Request Management', 'Update', N'Update Requests', 0),
('Request Management', 'Delete', N'Delete Requests', 0),

('Review Management', 'Read', N'View Reviews', 0),
('Review Management', 'Create', N'Create Reviews', 0),
('Review Management', 'Update', N'Update Reviews', 0),
('Review Management', 'Delete', N'Delete Reviews', 0),

('Payment Management', 'Read', N'View Payments', 0),
('Payment Management', 'Create', N'Create Payments', 0),
('Payment Management', 'Update', N'Update Payments', 0),
('Payment Management', 'Delete', N'Delete Payments', 1),

('System Settings', 'Read', N'View Reports', 1),
('System Settings', 'Export', N'Export Reports', 1),

('Content Management', 'Read', N'View Content', 0),
('Content Management', 'Create', N'Create Content', 0),
('Content Management', 'Update', N'Update Content', 0),
('Content Management', 'Delete', N'Delete Content', 1);

INSERT INTO Role_Permission (RoleID, PermissionID)
SELECT 1, PermissionID FROM Permission;
GO
