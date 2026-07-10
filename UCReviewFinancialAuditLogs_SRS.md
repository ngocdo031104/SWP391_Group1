# UC-FL-01: Review Financial Audit Logs

## 1. Use Case Information

| Item | Description |
|---|---|
| Use Case ID | UC-FL-01 |
| Use Case Name | Review Financial Audit Logs |
| Scope | TourBuddy Finance and Administration Module |
| Level | User Goal |
| Primary Actors | Admin, Accountant |
| Secondary Actors | Audit Log DAO, Payment DAO, Booking DAO, Database |
| Trigger | Authorized user opens the financial audit log or transaction history screen |
| Business Rule | Only authorized finance-related roles can review audit records. Audit data must be shown in descending time order so that the most recent financial actions appear first. Financial logs must preserve the operator, timestamp, and action details for traceability. |

## 2. Description

Allows tracking and storing the history of financial transactions and payment-related operations in the system. The system manages transaction log data, processing timestamps, and operator information. Data includes financial records, audit logs, and transaction operators.

## 3. Preconditions

1. The user is authenticated.
2. The user has sufficient permission to view financial logs.
3. Audit log data exists in the database.

## 4. Postconditions

1. The selected audit log entries are displayed to the user.
2. The system preserves the historical financial records for later review.

## 5. Normal Flow

| Step | Actor / System Action |
|---|---|
| 1 | The authorized user opens the financial audit log screen. |
| 2 | The system verifies the user session and permission level. |
| 3 | The system retrieves the audit log entries related to financial or payment operations. |
| 4 | The system retrieves operator information and processing timestamps for each entry. |
| 5 | The system sorts the records by newest first. |
| 6 | The system displays the financial audit log list to the user. |
| 7 | The user reviews the transaction history, operator, action type, and log details. |

## 6. Alternative Flows

### A1. No audit logs available

1. The system finds no matching financial audit log entries.
2. The UI displays an empty-state message.

### A2. Unauthorized access

1. The system detects that the current user does not have permission to view audit logs.
2. The system redirects the user to the login page or returns an access denied response.

### A3. Log retrieval failure

1. The system fails to read audit records because of a database or query error.
2. The system displays an error message and does not show partial results.

## 7. Business Rules

| Rule ID | Business Rule |
|---|---|
| BR-01 | Only authorized roles may access audit log data. |
| BR-02 | Audit log entries must include operator identity and timestamp. |
| BR-03 | Log entries must be displayed in reverse chronological order. |
| BR-04 | Payment-related actions must be traceable to a specific transaction or operator. |
| BR-05 | Historical logs must not be deleted through this use case. |

## 8. Special Requirements

1. The system must support review of historical financial events for audit and compliance purposes.
2. The audit screen must clearly show the action type, details, and created time.
3. The audit record view should be readable by administrators and finance staff.

## 9. Notes Derived From Code

1. The current codebase contains `AuditLogDAO.getAllAuditLogs()`, which reads from `Audit_Log` and joins the admin account for display.
2. `ManageUserController` currently uses audit logs for admin actions such as lock, unlock, bulk role assignment, and bulk delete.
3. The payment flow stores transaction data in `Payment`, including `TransactionRef`, `Amount`, `Currency`, `Status`, and `PaidAt`.
4. The SePay webhook creates successful payment records and generates invoices, which are the main financial events currently visible in the system.
5. I did not find a dedicated finance-audit screen or controller specifically limited to payment logs, so this UC is written at SRS level to cover the intended requirement and the current logged financial operations.

