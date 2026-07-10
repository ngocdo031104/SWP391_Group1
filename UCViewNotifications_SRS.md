# UC-NT-01: View Notifications

## 1. Use Case Information

| Item | Description |
|---|---|
| Use Case ID | UC-NT-01 |
| Use Case Name | View Notifications |
| Scope | TourBuddy Notification Module |
| Level | User Goal |
| Primary Actors | All authenticated users |
| Secondary Actors | Notification Controller, Notification DAO, Database |
| Trigger | User opens the notification center |
| Business Rule | Only authenticated users can access the notification center. Notifications scheduled for the future are not displayed. The system must allow users to mark a single notification as read or mark all notifications as read. |

## 2. Description

Displays notifications related to bookings, tours, promotions, system announcements, and account activities. The user can view notification details, filter the list, and update read status.

## 3. Preconditions

1. The user is authenticated.
2. The system has notification data stored for the user.

## 4. Postconditions

1. Notification read status is updated when the user marks a notification as read or marks all notifications as read.
2. The unread notification count is refreshed for display in the user interface.

## 5. Normal Flow

| Step | Actor / System Action |
|---|---|
| 1 | The user opens the notification center. |
| 2 | The system verifies the session and confirms that the user is authenticated. |
| 3 | The system retrieves the notification list for the current user. |
| 4 | The system applies any active filters such as category, keyword, or unread-only. |
| 5 | The system displays the notification list together with the unread notification count. |
| 6 | The user selects a notification to view its details. |
| 7 | The user marks the notification as read, or selects the option to mark all notifications as read. |
| 8 | The system updates the read status in the database. |
| 9 | The system refreshes the notification list and unread count. |

## 6. Alternative Flows

### A1. No notifications

1. The system retrieves an empty notification list.
2. The UI displays an empty-state message indicating that no notifications are available.

### A2. Notification retrieval failure

1. The system fails to retrieve notifications due to an internal error or database issue.
2. The system shows an error message and does not display notification data.

### A3. User is not authenticated

1. The system detects that the session is invalid or missing.
2. The system redirects the user to the login page.

## 7. Business Rules

| Rule ID | Business Rule |
|---|---|
| BR-01 | Only authenticated users can access notification pages and actions. |
| BR-02 | Notifications with `scheduledAt` in the future must not be shown. |
| BR-03 | The notification list can be filtered by category, keyword, and unread-only status. |
| BR-04 | Users can mark a single notification as read. |
| BR-05 | Users can mark all notifications as read at once. |
| BR-06 | The unread count shown in the UI must reflect only available notifications. |

## 8. Special Requirements

1. The notification screen must display the current unread count.
2. The interface must support quick filtering by notification type and unread status.
3. The system must keep the notification list ordered by newest first.

## 9. Notes Derived From Code

1. The notification center is served by `GET /customer/notifications`.
2. Marking one notification as read is handled by `GET /customer/notifications/read?id=...`.
3. Marking all notifications as read is handled by `GET /customer/notifications/read-all`.
4. Filtering is performed using `category`, `keyword`, and `unreadOnly` request parameters.
5. The notification header badge uses the unread count returned from `HeaderDataController`.

