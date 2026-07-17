# ACTIVITY DIAGRAM TEMPLATES - TourBuddy System
> 3 Pattern chuan cho tat ca man hinh trong he thong

---

## PATTERN 1: DISCOVERY (Xem - Don gian)
### Ap dung: Homepage, Tour Details, Search & Filter, View Media Gallery

```
+------------------------------------------------------------------+
|                    ACTIVITY DIAGRAM                               |
|                     DISCOVERY FLOW                                |
+------------------------------------------------------------------+
|  [Swimlane: Customer]  |  [Swimlane: System]                     |
+------------------------+------------------------------------------+
|                        |                                          |
|   +-----------------+  |                                          |
|   |  START          |  |                                          |
|   +--------+--------+  |                                          |
|            |            |                                          |
|            v            |                                          |
|   +-----------------+  |                                          |
|   | Access page     |--+--------------------------------------->   |
|   +--------+--------+  |                                          |
|            |            |                                          |
|            v            |                                          |
|   +-----------------+  |   +-------------------------------+       |
|   | View content    |<-+---| Load & Display data          |       |
|   | (Browse/Search) |  |   | (Tours, FAQs, Banners...)   |       |
|   +--------+--------+  |   +-------------------------------+       |
|            |            |                                          |
|            v            |                                          |
|   +-----------------+  |                                          |
|   | Interact?      |  |                                          |
|   | (Search/Filter)|  |                                          |
|   +--------+--------+  |                                          |
|            |            |                                          |
|            v            |   +-------------------------------+       |
|   +-----------------+<-+---| Filter & Return results        |       |
|   | View results   |  |   |                                |       |
|   +--------+--------+  |   +-------------------------------+       |
|            |            |                                          |
|            v            |                                          |
|   +-----------------+  |                                          |
|   | END             |  |                                          |
|   +-----------------+  |                                          |
|                        |                                          |
+------------------------+------------------------------------------+

** Dac diem:**
  - Tuyen tinh, khong co decision phuc tap
  - Chi doc du lieu (SELECT)
  - Khong thay doi trang thai he thong
  - Ket thuc bang END
```

---

## PATTERN 2: CRUD (Tao/Sua/Xoa - Admin)
### Ap dung: Manage Tours, Manage Schedules, Manage Media, Manage Favorites

```
+-------------------------------------------------------------------------+
|                    ACTIVITY DIAGRAM                                      |
|                     CRUD FLOW                                           |
+-------------------------------------------------------------------------+
|  [Swimlane: Admin]  |  [Swimlane: System]  |  [Swimlane: Database]    |
+----------------------+------------------------+---------------------------+
|                      |                        |                          |
|   +--------------+   |                        |                          |
|   | START        |   |                        |                          |
|   +------+-------+   |                        |                          |
|          |            |                        |                          |
|          v            |                        |                          |
|   +--------------+   |                        |                          |
|   | Select       |   |                        |                          |
|   | action        |   |                        |                          |
|   |(Add/Edit/    |   |                        |                          |
|   | Delete)       |   |                        |                          |
|   +------+-------+   |                        |                          |
|          |            |                        |                          |
|          v            |                        |                          |
|   +--------------+   |                        |                          |
|   | Display      |---+----------------------->|                          |
|   | form/dialog |   |                        |                          |
|   +------+-------+   |                        |                          |
|          |            |                        |                          |
|          v            |                        |                          |
|   +--------------+   |                        |                          |
|   | Fill form    |   |                        |                          |
|   | (Input data) |   |                        |                          |
|   +------+-------+   |                        |                          |
|          |            |                        |                          |
|          v            |                        |                          |
|   +--------------+   |   +---------------+      |                          |
|   | Validate     |---+   | Validate data |      |                          |
|   | locally      |   |   | (Server-side)|      |                          |
|   +------+-------+   |   +-------+-------+      |                          |
|          |            |           |              |                          |
|          |            |   +-------v--------+     |                          |
|          |            |   | Valid?         |     |                          |
|          |            |   +-----+--------+-+     |                          |
|          |            |         |          |     |                          |
|          |            |    +----+          +----+     |
|          |            |    v                    v     |
|          |            | +----------+    +----------+  |
|          |            | | NO       |    | YES      |  |
|          |            | |(Invalid) |    | (Valid)  |  |
|          |            | +----+-----+    +----+-----+  |
|          |            |      |               |       |
|          |            |      v               v       |
|          v            | +----------+    +----------+ |
|   +--------------+   | | Show     |    | Save to  |  |
|   | Show error   |<--+--| error    |    | DB      |  |
|   | message      |   | +----------+    +----+-----+  |
|   +------+-------+   |                       |       |
|          |            |                       v       |
|          |            |               +---------------+|
|          |            |               | Insert/Update ||
|          |            |               | /Delete record||
|          |            |               +-------+-------+|
|          |            |                       |         |
|          |            |                       v         |
|          |            |               +---------------+|
|          |            |               | Confirm       ||
|          |            |               | operation     ||
|          |            |               +-------+-------++
|          |            |                       |          |
|          v            |                       v          |
|   +--------------+   |               +---------------+|
|   | Back to      |   |               | Display       ||
|   | form (Loop) |   |               | success       ||
|   +--------------+   |               +-------+-------++
|                                |          |          |
|                                |          v          |
|                                |  +---------------+|
|                                |  | Refresh list  ||
|                                |  +-------+-------++
|                                |          |          |
|                                |          v          |
|                                |  +---------------+|
|                                |  | END           ||
|                                |  +---------------+|
|                                |                      |
+--------------------------------+----------------------+
```

---

## PATTERN 3: BOOKING TRANSACTION (Dat tour thuc te - 4 buoc)
### Ap dung: Book Tour -> Payment (Luong thuc te cua TourBuddy)

```
+---------------------------------------------------------------------------------------------+
|                    ACTIVITY DIAGRAM - BOOKING + PAYMENT FLOW                                  |
+---------------------------------------------------------------------------------------------+
|  [Customer]  |  [System]                    |  [Database]  |  [SePay - External]            |
+--------------+------------------------------+-------------+--------------------------------+
|              |                              |             |                                |
|  +---------+ |                              |             |                                |
|  | START   | |                              |             |                                |
|  +----+----+ |                              |             |                                |
|       |       |                              |             |                                |
|       v       |                              |             |                                |
|  +---------+ |  +----------------------+     |             |                                |
|  | Click   |-+->| Load Tour &           |     |             |                                |
|  | "Book"  | |  | Future Schedules     |     |             |                                |
|  +----+----+ |  +----------+-----------+     |             |                                |
|       |       |            |                   |             |                                |
|       v       |            v                   |             |                                |
|  +---------+ |  +----------------------+     |             |                                |
|  | [STEP 1]  | |  | Display booking form |     |             |                                |
|  | Fill:     |<+--| with schedules      |     |             |                                |
|  | Schedule   | |  +----------------------+     |             |                                |
|  | Count      | |                              |             |                                |
|  | Details    | |                              |             |                                |
|  +----+----+ |                              |             |                                |
|       |       |                              |             |                                |
|       v       |                              |             |                                |
|  +---------+ |  +----------------------+     |             |                                |
|  | Submit  |-+->| Validate:            |     |             |                                |
|  | form    | |  | - Schedule exists    |     |             |                                |
|  +----+----+ |  | - Date not in past  |     |             |                                |
|       |       |  | - Seats available   |     |             |                                |
|       |       |  | - No infants        |     |             |                                |
|       |       |  |   (adventure tour)  |     |             |                                |
|       |       |  +---+--------+------+--+     |             |                                |
|       |       |      |        |     |   |     |             |                                |
|       |       |  +---+---+    +----+---+--+  |             |                                |
|       |       |  | NO    |    | YES      |   |             |                                |
|       |       |  +---+---+    +----+-----+   |             |                                |
|       |       |      |             |          |             |                                |
|       |       |      v             |          |             |                                |
|       |       |  +----------+     |          |             |                                |
|       |       |  | Show     |     |          |             |                                |
|       |       |  | errors & |<----+          |             |                                |
|       |       |  | retry   |                  |             |                                |
|       |       |  +----------+                  |             |                                |
|       |       |                                |             |                                |
|       |       |            +------------------+             |                                |
|       |       |            |                                 |             |                                |
|       |       |            v                                 |             |                                |
|       |       |  +----------------------+     +-----------+     |             |                                |
|       |       |  | Create BookingDraft  |---->| Hold in   |     |             |                                |
|       |       |  | (in SESSION)         |     | SESSION   |     |             |                                |
|       |       |  | - tourId, scheduleId |     +-----------+     |             |                                |
|       |       |  | - participants        |                      |             |                                |
|       |       |  | - prices calculated  |                      |             |                                |
|       |       |  +----------+-----------+                      |             |                                |
|       |       |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |  | Redirect to /review   |                     |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |            |                                   |             |                                |
|       v       |            v                                   |             |                                |
|  +---------+ |  +----------------------+     +-----------+     |             |                                |
|  | [STEP 2]  | |  | Read BookingDraft   |<----| From      |     |             |                                |
|  | Review    |<+--| from SESSION        |     | SESSION   |     |             |                                |
|  | Booking   | |  +----------------------+     +-----------+     |             |                                |
|  +----+----+ |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |  | Display:             |                     |             |                                |
|       |       |  | - Tour info          |                     |             |                                |
|       |       |  | - Participants       |                     |             |                                |
|       |       |  | - Pricing summary   |                     |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |  | Apply Coupon?        |                     |             |                                |
|       |       |  +---+--------+------+--+                     |             |                                |
|       |       |      |        |     |   |     |             |                                |
|       |       |  +---+---+    +----+---+--+  |             |                                |
|       |       |  | YES   |    | NO       |   |             |                                |
|       |       |  +---+---+    +----+-----+   |             |                                |
|       |       |      |             |          |             |                                |
|       |       |      v             +----------+-------------+-------------+
|       |       |  +----------+                                       |
|       |       |  | Enter    |                                       |
|       |       |  | coupon   |                                       |
|       |       |  +----+-----+                                       |
|       |       |       |                                             |
|       |       |       +---------------------------------------------+
|       |       |                                                       |
|       v       |                                                       |
|  +---------+ |  +----------------------+     +-----------+             |
|  | Click   |--+->| Release expired      |<----| Delete    |             |
|  | "Confirm|  |  | pending bookings    |     | expired   |             |
|  | & Pay"  |  |  | (10 min timeout)    |     | bookings  |             |
|  +----+----+ |  +----------+-----------+     +-----------+             |
|       |       |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+     +-----------+     |             |                                |
|       |       |  | Create REAL Booking  |---->| Insert    |     |             |                                |
|       |       |  | Status="PendingPay" |     | Booking   |     |             |                                |
|       |       |  | Code="TB-timestamp" |     | to DB     |     |             |                                |
|       |       |  +----------+-----------+     +-----+-----+     |             |                                |
|       |       |            |                     |     |          |             |                                |
|       |       |            v                     v     |          |             |                                |
|       |       |  +----------------------+     +-----------+     |             |                                |
|       |       |  | Set payment hold:    |     | Decrement |     |             |                                |
|       |       |  | expiresAt=now+10min  |     | seats     |     |             |                                |
|       |       |  +----------+-----------+     +-----------+     |             |                                |
|       |       |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |  | Generate VietQR      |                     |             |                                |
|       |       |  | - Bank: TPBank (TPB) |                     |             |                                |
|       |       |  | - Account: 0393863658|                     |             |                                |
|       |       |  | - Amount: totalAmount|                     |             |                                |
|       |       |  | - Content: TB-code   |                     |             |                                |
|       |       |  +----------+-----------+                     |             |                                |
|       |       |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |  | Redirect to /payment  |                     |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |            |                                   |             |                                |
|       v       |            v                                   |             |                                |
|  +---------+ |  +----------------------+                     |             |                                |
|  | [STEP 3]  | |  | Display VietQR +    |                     |             |                                |
|  | VietQR    |<+--| 10:00 countdown     |                     |             |                                |
|  | Screen    | |  +----------------------+                     |             |                                |
|  +----+----+ |            |                                   |             |                                |
|       |       |            v                                   |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |  | Start JS polling     |                     |             |                                |
|       |       |  | every 5s             |                     |             |                                |
|       |       |  | GET /payment-status  |                     |             |                                |
|       |       |  +----------------------+                     |             |                                |
|       |       |            |                                   |             |                                |
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | SEPAY WEBHOOK (External Trigger)                |
|       |       |            |        | POST /webhook/sepay                            |
|       |       |            |        | Authorization: Apikey xxx                     |
|       |       |            |        +--------------------+-------------------------+
|       |       |            |                             |
|       |       |            |                             v
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | Extract bookingCode from                      |
|       |       |            |        | transfer content (regex TB-\d+)               |
|       |       |            |        +--------------------+-------------------------+
|       |       |            |                             |
|       |       |            |                             v
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | Validate:                                    |
|       |       |            |        | - transferType = "in"                         |
|       |       |            |        | - booking exists & not Cancelled              |
|       |       |            |        | - amount >= totalAmount                       |
|       |       |            |        +--------------------+-------------------------+
|       |       |            |                             |
|       |       |            |                   +---------+---------+
|       |       |            |                   |                   |
|       |       |            |             +-----+-----+     +-------+-----+
|       |       |            |             | NO       |     | YES         |
|       |       |            |             |(Reject)  |     |(Confirm)    |
|       |       |            |             +-----+-----+     +-------+-----+
|       |       |            |                   |                   |
|       |       |            |                   v                   |
|       |       |            |             +-----------+             |
|       |       |            |             | Return    |             |
|       |       |            |             | error     |             |
|       |       |            |             +-----------+             |
|       |       |            |                                   |
|       |       |            |                                   v
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | Insert Payment + Invoice records                 |
|       |       |            |        | (idempotency check)                             |
|       |       |            |        +--------------------+-------------------------+
|       |       |            |                             |
|       |       |            |                             v
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | Update Booking.Status = "Success"                |
|       |       |            |        +--------------------+-------------------------+
|       |       |            |                             |
|       |       |            |                             v
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | Send Notification to Customer                  |
|       |       |            |        | (channel=SYSTEM)                               |
|       |       |            |        +--------------------+-------------------------+
|       |       |            |                             |
|       |       |            |                             v
|       |       |            |        +-----------------------------------------------+
|       |       |            |        | Return {"success":true} to SePay               |
|       |       |            |        +-----------------------------------------------+
|       |       |            |                             |
|       |       |            |                             |
|       |       |            v                             |
|       |       |  +----------------------+               |
|       |       |  | Polling returns      |<--------------+
|       |       |  | paid=true            |
|       |       |  +----------+-----------+               |
|       |       |            |                            |
|       |       |            v                            |
|       |       |  +----------------------+              |
|       |       |  | Redirect to          |              |
|       |       |  | /booking/success     |              |
|       |       |  +----------+-----------+              |
|       |       |            |                            |
|       v       |            v                            |
|  +---------+ |  +----------------------+              |
|  | END     |<-+--| Clear session draft  |              |
|  |(Success)|  |  | Display confirmation |              |
|  +---------+ |  +----------------------+              |
|              |            |                            |
|              |            v                            |
|              |  +----------------------+              |
|              |  | [TIMEOUT: >10 min]   |              |
|              |  | - Release seats      |              |
|              |  | - Cancel booking     |              |
|              |  | - Redirect to create |              |
|              |  +----------------------+              |
|              |            |                            |
+--------------+------------+----------------------------+
```

---

## DAC DIEM THEO CODE THUC TE TOURBUDDY

| Buoc | Mo ta | Luu y |
|------|-------|-------|
| STEP 1 | Create BookingDraft in SESSION | Chua co trong DB, chi luu tam |
| STEP 2 | Review & Apply Coupon | Co the nhap ma giam gia |
| STEP 3 | VietQR + 10 min countdown | Polling 5s, SePay webhook |
| STEP 4 | Success | Xoa session, hien thong bao |

| Thanh phan | Gia tri |
|------------|---------|
| Bank | TPBank (TPB) |
| Account | 0393863658 |
| Owner | Do Manh Duong |
| BookingCode | "TB-" + timestamp |
| Timeout | 10 phut |
| Polling | 5 giay |

---

## QUICK REFERENCE - Chon Pattern dung

| Man hinh | Pattern | Ghi chu |
|----------|---------|---------|
| Homepage (4) | **Pattern 1** | Chi view |
| Tour Details (5) | **Pattern 1** | Chi view |
| Search & Filter (6) | **Pattern 1** | Search cung la view |
| Manage Tours (7) | **Pattern 2** | CRUD |
| Guide Dashboard (14) | **Pattern 2** | Simple CRUD |
| Manage Favorites (15) | **Pattern 2** | Toggle, nhung simple CRUD |
| Manage Media (22) | **Pattern 2** | CRUD |
| **Book Tour** | **Pattern 3** | 4 buoc, co SePay |
| Check-in (29) | **Pattern 3** | State: pending->checked-in |
| Update Status (42) | **Pattern 3** | State transition |
| Report Incident (43) | **Pattern 3** | Multi-step workflow |

---

Generated for TourBuddy SWP391 Project
