# UC-FR-02: Monitor Fraudulent Transactions

## 1. Use Case Information

| Item | Description |
|---|---|
| Use Case ID | UC-FR-02 |
| Use Case Name | Monitor Fraudulent Transactions |
| Scope | TourBuddy Payment and Finance Module |
| Level | User Goal |
| Primary Actors | Admin, Accountant |
| Secondary Actors | Payment Gateway, Booking DAO, Payment DAO, Invoice DAO, Database |
| Trigger | Authorized user opens the transaction monitoring or finance review screen, or the system receives a payment webhook event |
| Business Rule | Only authorized finance-related roles may review flagged transactions. Suspected transactions must remain available for investigation history and must not be silently removed. Any confirmed fraud-related action must be traceable with timestamp and operator identity. |

## 2. Description

Allows detection and monitoring of transactions showing abnormal patterns or signs of fraud in the payment system. The system manages transaction alert data, review status, and fraud handling history. Data includes fraud alerts, flagged transactions, and investigation status.

## 3. Preconditions

1. The user is authenticated.
2. The user has permission to access finance or administrative monitoring functions.
3. Payment and booking records exist in the system.

## 4. Postconditions

1. The transaction or alert status is displayed for review.
2. The system preserves monitoring history for future investigation.
3. If a transaction is confirmed as suspicious, it remains traceable in the payment records.

## 5. Normal Flow

| Step | Actor / System Action |
|---|---|
| 1 | The authorized user opens the transaction monitoring screen. |
| 2 | The system verifies the user session and permission level. |
| 3 | The system retrieves recent payment records, invoices, and related booking information. |
| 4 | The system checks transaction values, payment status, timestamps, and duplicate references for abnormal patterns. |
| 5 | The system displays the transactions that require review or investigation. |
| 6 | The user reviews the alert details and marks the transaction as under review, cleared, or suspicious. |
| 7 | The system stores the investigation outcome and keeps the handling history. |

## 6. Alternative Flows

### A1. No suspicious transactions found

1. The system finds no abnormal or flagged records.
2. The UI displays an empty or normal-status message.

### A2. Fraud alert retrieval failure

1. The system fails to load payment or audit data.
2. The system displays an error message and does not show incomplete monitoring results.

### A3. Unauthorized access

1. The system detects that the current user does not have permission to monitor transactions.
2. The system redirects the user to the login page or returns access denied.

### A4. Duplicate payment reference detected

1. The system detects that a transaction reference already exists.
2. The system treats the event as suspicious and keeps the record available for manual review.

## 7. Business Rules

| Rule ID | Business Rule |
|---|---|
| BR-01 | Only authorized admin or accountant users may access fraud monitoring functions. |
| BR-02 | Duplicate transaction references must be treated as a suspicious condition. |
| BR-03 | Payment records must remain immutable after completion, except for status updates allowed by the workflow. |
| BR-04 | Investigation status must be retained with the transaction history. |
| BR-05 | Fraud-related cases must preserve operator identity and processing time. |
| BR-06 | Suspicious transactions must be reviewable together with booking and invoice context. |

## 8. Special Requirements

1. The system must support manual review of suspicious financial transactions.
2. The system must keep a history of investigation outcomes.
3. The monitoring screen should expose enough context to compare payment, booking, and invoice data.

## 9. Notes Derived From Code

1. The current codebase does not contain a dedicated fraud-detection engine or fraud-alert table.
2. The closest implemented safeguard is `PaymentDAO.existsByTransactionRef(...)`, which prevents duplicate payment records from the same transaction reference.
3. `SepayWebhookController` validates webhook authorization, compares transfer amount with booking total, and avoids duplicate payment creation.
4. `Payment` stores `TransactionRef`, `Amount`, `Currency`, `Status`, `PaidAt`, and `GatewayResponse`, which can be used as audit context for monitoring.
5. `InvoiceDAO` and booking status updates provide additional financial traceability, but a dedicated fraud review UI is not currently implemented.

