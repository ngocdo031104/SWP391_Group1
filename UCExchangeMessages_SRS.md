# UC-EX-01: Exchange Messages

## 1. Use Case Information

| Item | Description |
|---|---|
| Use Case ID | UC-EX-01 |
| Use Case Name | Exchange Messages |
| Scope | TourBuddy Chat Module |
| Level | User Goal |
| Primary Actor | Customer (authenticated user) |
| Supporting Actors | WebSocket Server, Chat Controller, Chat DAO, Database |
| Trigger | User opens the chat page and selects a conversation, or sends a new message in an active conversation |
| Business Rule | Only authenticated users can access the chat module. Users who are blocked by each other cannot exchange messages. Image uploads are limited to image files only and the file size must not exceed 5 MB. |

## 2. Goal

Allow an authenticated customer to exchange text and image messages with another user through a direct conversation or a group conversation.

## 3. Preconditions

1. The user has already logged in successfully.
2. The user has access to the chat module.
3. At least one conversation exists, or the system can create a direct conversation when needed.
4. For image sending, the browser supports file upload.

## 4. Postconditions

1. The sent message is stored in the database.
2. The message is delivered to the sender immediately through WebSocket.
3. If the recipient is online, the message is pushed to the recipient in real time.
4. The conversation history is updated and unread messages are marked as read when the conversation is opened.

## 5. Main Flow

| Step | Actor / System Action |
|---|---|
| 1 | The customer opens the chat page. |
| 2 | The system verifies the session and loads the list of conversations that belong to the customer. |
| 3 | The customer selects a conversation from the sidebar. |
| 4 | The system loads the message history of that conversation and marks messages in that conversation as read for the current user. |
| 5 | The customer enters a text message and presses Send. |
| 6 | The client sends the message content, conversation ID, and sender information to the WebSocket endpoint. |
| 7 | The system validates the message content. If the conversation does not exist for a direct chat, the system creates the conversation first. |
| 8 | The system checks the block list to ensure the sender and recipient are allowed to communicate. |
| 9 | The system saves the message to the database. |
| 10 | The system returns the saved message to the sender and pushes it to the recipient if the recipient is online. |
| 11 | The customer may attach an image. The system uploads the image, returns the image URL, and sends it as an image message in the same conversation. |

## 6. Alternative Flows

### 6.1 User is not logged in

1. The system detects that there is no valid session.
2. The system redirects the user to the login page.

### 6.2 Invalid message parameters

1. The system receives invalid conversation information or malformed data.
2. The system returns a bad request response and does not save the message.

### 6.3 Blocked communication

1. The system detects that the sender and recipient are blocked from each other.
2. The system rejects the message and returns an error to the sender.

### 6.4 Image upload is invalid

1. The user uploads a file that is not an image or exceeds the allowed size.
2. The system rejects the upload and returns an error message.

### 6.5 Recipient is offline

1. The system saves the message successfully.
2. The system delivers the message to the sender.
3. The system does not push the message to the recipient because the recipient is offline.

## 7. Business Rules

| Rule ID | Business Rule |
|---|---|
| BR-01 | Only authenticated users can access `/customer/chat` and `/customer/chat/upload`. |
| BR-02 | A direct conversation must be created automatically if a message is sent without an existing conversation ID. |
| BR-03 | A user cannot send messages to another user if either side is present in the block list. |
| BR-04 | Only image files are accepted for chat attachment upload. |
| BR-05 | The maximum image upload size is 5 MB. |
| BR-06 | Unread messages in a conversation are marked as read when that conversation history is opened. |

## 8. Special Requirements

1. The chat page must support real-time delivery of text messages.
2. The chat page must support image sending through a separate upload step.
3. The conversation list must show direct conversations and group conversations.
4. The system must keep message history available for later retrieval.

## 9. Notes Derived From Code

1. The chat module uses a WebSocket endpoint at `/ws/chat/{userId}` for live message delivery.
2. Message history is loaded through `GET /customer/chat?action=history&conversationId=...`.
3. Direct conversations are created on demand through `POST /customer/chat?action=create`.
4. Group conversations are created through `POST /customer/chat?action=createGroup`.
5. Image attachments are uploaded through `POST /customer/chat/upload` and then sent as image messages.

