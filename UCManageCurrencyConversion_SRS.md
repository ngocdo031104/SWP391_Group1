# UC-PT-01: Manage Currency Conversion

## 1. Use Case Information

| Item | Description |
|---|---|
| Use Case ID | UC-PT-01 |
| Use Case Name | Manage Currency Conversion |
| Scope | TourBuddy Payment and Booking Module |
| Level | User Goal |
| Primary Actors | Customer, System Administrator |
| Secondary Actors | Payment Gateway, Database |
| Trigger | User views prices in another currency or the system processes a payment involving a supported currency |
| Business Rule | The system must use a defined exchange rate for every supported currency and must keep conversion values consistent during booking and payment processing. If a payment is recorded, the stored payment currency must match the currency used at the time of transaction. |

## 2. Description

Allows processing and conversion of multiple currencies during payment and international booking management. The system manages exchange rate data, supported currencies, and rate update history. Data includes currency codes, exchange rates, and conversion records.

## 3. Preconditions

1. The user is authenticated when the currency setting is tied to booking or payment actions.
2. Exchange rate data exists for supported currencies.
3. The booking or payment context is available.

## 4. Postconditions

1. The selected or applied currency is stored for the transaction.
2. The converted amount is calculated and displayed or recorded.
3. If a rate update is performed, the new rate is saved with history.

## 5. Normal Flow

| Step | Actor / System Action |
|---|---|
| 1 | The user opens a page that displays prices or payment amounts. |
| 2 | The system loads the default currency and supported currency options. |
| 3 | The user selects a target currency or the system applies the transaction currency automatically. |
| 4 | The system retrieves the exchange rate for the selected currency. |
| 5 | The system converts the base amount into the target currency. |
| 6 | The system displays the converted price or stores the converted payment value. |
| 7 | If the conversion is used for payment, the system records the transaction currency together with the payment. |

## 6. Alternative Flows

### A1. Unsupported currency

1. The user selects a currency that is not supported.
2. The system rejects the selection and falls back to the default currency.

### A2. Exchange rate unavailable

1. The system cannot find a valid exchange rate for the selected currency.
2. The system shows an error message and keeps the previous amount unchanged.

### A3. Rate update failure

1. The administrator tries to update an exchange rate.
2. The update fails because of invalid data or a database error.
3. The system shows an error and does not change the active rate.

## 7. Business Rules

| Rule ID | Business Rule |
|---|---|
| BR-01 | Every supported currency must have a valid currency code. |
| BR-02 | Exchange rates must be stored and applied consistently for the same transaction. |
| BR-03 | Conversion results must be calculated from the active exchange rate at the time of use. |
| BR-04 | Payment records must store the transaction currency. |
| BR-05 | Exchange rate changes must be tracked in history for audit purposes. |

## 8. Special Requirements

1. Currency conversion must be accurate enough for payment presentation and booking calculation.
2. The system must handle the default currency used by the platform.
3. The system must allow rate updates without affecting past completed transactions.

## 9. Notes Derived From Code

1. In the current codebase, payment records store a `currency` field in `Payment`.
2. The existing payment flow saves `VND` for successful bank-transfer payments processed by the webhook.
3. The frontend currently formats some prices in VND and uses a fixed exchange-rate constant in JavaScript for price display.
4. I did not find a dedicated backend module for currency master data, exchange rate history, or conversion record persistence, so this UC is written as an SRS-level requirement rather than an existing implemented feature.

