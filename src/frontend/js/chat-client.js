let socket = null;
let currentConversationId = null;

// Initialize WebSocket connection
function connectWebSocket() {
    if (!currentUserId) return;
    
    const host = window.location.host;
    // Context path assumes "/TourBuddy", adjust if different in deployment
    const ctx = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    const wsUrl = `ws://${host}${ctx}/ws/chat/${currentUserId}`;
    
    socket = new WebSocket(wsUrl);
    
    socket.onopen = function(event) {
        console.log("WebSocket connected!");
    };
    
    socket.onmessage = function(event) {
        const data = JSON.parse(event.data);
        if (data.type === 'error') {
            alert(data.message);
        } else if (data.type === 'chatMessage') {
            // Append message to UI if it belongs to the current conversation
            if (data.conversationId === currentConversationId) {
                appendMessageToUI(data);
                scrollToBottom();
            }
        }
    };
    
    socket.onclose = function(event) {
        console.log("WebSocket disconnected. Reconnecting in 3s...");
        setTimeout(connectWebSocket, 3000);
    };
    
    socket.onerror = function(error) {
        console.error("WebSocket error", error);
    };
}

// Load conversation history
function loadConversation(conversationId, name, avatarUrl) {
    currentConversationId = conversationId;
    
    // Update UI elements
    document.getElementById('emptyChat').style.display = 'none';
    document.getElementById('activeChat').style.display = 'flex';
    document.getElementById('chatHeaderName').innerText = name;
    
    if (avatarUrl) {
        document.getElementById('chatHeaderAvatar').src = avatarUrl;
    }
    
    // Highlight active conversation in sidebar
    document.querySelectorAll('.conversation-item').forEach(item => {
        item.classList.remove('active');
    });
    document.querySelector(`.conversation-item[data-id="${conversationId}"]`).classList.add('active');
    
    // Fetch history via AJAX
    const ctx = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    fetch(`${ctx}/customer/chat?action=history&conversationId=${conversationId}`)
        .then(response => response.json())
        .then(messages => {
            const historyContainer = document.getElementById('chatHistory');
            historyContainer.innerHTML = ''; // Clear current
            
            messages.forEach(msg => {
                appendMessageToUI(msg);
            });
            scrollToBottom();
        })
        .catch(err => console.error("Failed to load history", err));
}

function appendMessageToUI(msg) {
    const historyContainer = document.getElementById('chatHistory');
    const isSent = msg.senderId === currentUserId;
    
    const msgDiv = document.createElement('div');
    msgDiv.className = `message ${isSent ? 'sent' : 'received'}`;
    
    // Format timestamp
    const date = msg.createdAt ? new Date(msg.createdAt) : new Date();
    const timeStr = date.toLocaleTimeString([], {hour: '2-digit', minute:'2-digit'});
    
    let contentHtml = msg.content;
    if (msg.messageType === 'Image') {
        contentHtml = `<img src="${msg.content}" style="max-width: 100%; max-height: 300px; border-radius: 8px; margin-top: 5px;">`;
    }

    msgDiv.innerHTML = `
        ${!isSent ? `<div class="message-avatar"><img src="https://ui-avatars.com/api/?name=${msg.senderName || 'User'}&background=random" style="width:100%;height:100%;border-radius:50%;" alt="Avatar"></div>` : ''}
        <div class="message-content">
            ${contentHtml}
            <div class="message-time">${timeStr}</div>
        </div>
    `;
    
    historyContainer.appendChild(msgDiv);
}

function scrollToBottom() {
    const historyContainer = document.getElementById('chatHistory');
    historyContainer.scrollTop = historyContainer.scrollHeight;
}

function sendMessage() {
    const input = document.getElementById('messageInput');
    const content = input.value.trim();
    
    if (content === '' || !currentConversationId) return;
    
    if (socket && socket.readyState === WebSocket.OPEN) {
        const payload = {
            conversationId: currentConversationId,
            content: content
        };
        socket.send(JSON.stringify(payload));
        input.value = ''; // Clear input
    } else {
        alert("Mất kết nối máy chủ. Đang thử lại...");
    }
}

// Initialize on page load
window.onload = function() {
    connectWebSocket();
    
    // File upload logic for paperclip
    const fileInput = document.getElementById('chatFileInput');
    if (fileInput) {
        fileInput.addEventListener('change', function() {
            const file = this.files[0];
            if (!file) return;
            
            if (file.size > 5 * 1024 * 1024) {
                alert("File ảnh không được vượt quá 5MB!");
                this.value = '';
                return;
            }

            if (!currentConversationId) {
                alert("Vui lòng chọn cuộc trò chuyện trước khi gửi ảnh.");
                this.value = '';
                return;
            }

            const formData = new FormData();
            formData.append("file", file);

            const ctx = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
            fetch(`${ctx}/customer/chat/upload`, {
                method: 'POST',
                body: formData,
                credentials: 'same-origin'
            })
            .then(res => res.json())
            .then(data => {
                if (data.url && socket && socket.readyState === WebSocket.OPEN) {
                    const payload = {
                        conversationId: currentConversationId,
                        content: data.url,
                        messageType: "Image"
                    };
                    socket.send(JSON.stringify(payload));
                } else if (data.error) {
                    alert("Lỗi: " + data.error);
                }
            })
            .catch(err => {
                console.error("Upload error", err);
                alert("Đã xảy ra lỗi khi upload file.");
            })
            .finally(() => {
                this.value = ''; // Reset input
            });
        });
    }

    // Bind click events for conversation items
    document.querySelectorAll('.conversation-item').forEach(item => {
        item.addEventListener('click', function() {
            const convId = parseInt(this.dataset.id);
            const name = this.dataset.name;
            const avatar = this.dataset.avatar;
            loadConversation(convId, name, avatar);
        });
    });

    if (typeof autoLoadConvId !== 'undefined' && autoLoadConvId !== null) {
        // find the item in sidebar
        const item = document.querySelector(`.conversation-item[data-id="${autoLoadConvId}"]`);
        if (item) {
            item.click();
        }
    }
};

// Video Call Scheduling Logic
function openScheduleModal() {
    document.getElementById('scheduleModalTitle').innerText = 'Lên lịch gọi Video';
    document.getElementById('scheduleSubmitBtn').innerText = 'Tạo lịch gọi';
    document.getElementById('callId').value = '';
    document.getElementById('scheduleForm').reset();

    document.getElementById('scheduleModal').classList.add('active');
    // Default time to 30 minutes from now
    const now = new Date();
    now.setMinutes(now.getMinutes() + 30);
    now.setMinutes(now.getMinutes() - now.getTimezoneOffset());
    document.getElementById('callTime').value = now.toISOString().slice(0, 16);
}

function closeScheduleModal() {
    document.getElementById('scheduleModal').classList.remove('active');
}

function handleScheduleSubmit(event) {
    event.preventDefault();
    if (!currentConversationId) {
        alert("Vui lòng chọn cuộc trò chuyện trước.");
        return;
    }

    const callId = document.getElementById('callId').value;
    const action = callId ? 'update' : 'create';

    const title = document.getElementById('callTitle').value;
    const time = document.getElementById('callTime').value;
    const duration = document.getElementById('callDuration').value;
    const url = document.getElementById('callUrl').value;

    const formData = new URLSearchParams();
    formData.append('action', action);
    if (callId) formData.append('callId', callId);
    formData.append('conversationId', currentConversationId);
    formData.append('title', title);
    formData.append('scheduledAt', time);
    formData.append('durationMin', duration);
    formData.append('meetingUrl', url);

    const ctx = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    fetch(`${ctx}/customer/video-call`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: formData.toString()
    })
    .then(async response => {
        const data = await response.json();
        if (response.ok) {
            return data;
        }
        throw new Error(data.message || 'Network response was not ok.');
    })
    .then(data => {
        closeScheduleModal();
        alert(action === 'create' ? 'Lên lịch gọi Video thành công!' : 'Cập nhật lịch gọi Video thành công!');
        // Trigger reload of conversation to see the system message
        const currentName = document.getElementById('chatHeaderName').innerText;
        const currentAvatar = document.getElementById('chatHeaderAvatar').src;
        loadConversation(currentConversationId, currentName, currentAvatar);
        
        // If upcoming calls modal is open, refresh it
        if (document.getElementById('upcomingCallsModal').classList.contains('active')) {
            showUpcomingCalls();
        }
    })
    .catch(error => {
        console.error('Error scheduling call:', error);
        alert(error.message);
    });
}

function closeUpcomingCallsModal() {
    document.getElementById('upcomingCallsModal').classList.remove('active');
}

function showUpcomingCalls() {
    if (!currentConversationId) return;
    const ctx = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    fetch(`${ctx}/customer/video-call?action=list&conversationId=${currentConversationId}`)
        .then(response => response.json())
        .then(data => {
            const listContainer = document.getElementById('upcomingCallsList');
            listContainer.innerHTML = '';
            
            if (data.length === 0) {
                listContainer.innerHTML = '<p style="padding: 20px; text-align: center; color: #6b7280;">Không có lịch hẹn video nào sắp tới.</p>';
            } else {
                data.forEach(call => {
                    const time = new Date(call.scheduledAt).toLocaleString();
                    const isOrganizer = call.organizedBy === currentUserId;
                    
                    const callDiv = document.createElement('div');
                    callDiv.style.cssText = 'border-bottom: 1px solid #e5e7eb; padding: 15px 0; display: flex; justify-content: space-between; align-items: center;';
                    
                    let actionsHtml = '';
                    if (isOrganizer) {
                        actionsHtml = `
                            <button onclick='editCall(${JSON.stringify(call).replace(/'/g, "&apos;")})' style="background: none; border: none; color: #3b82f6; cursor: pointer; margin-right: 10px;">Sửa</button>
                            <button onclick="cancelCall(${call.callId})" style="background: none; border: none; color: #ef4444; cursor: pointer;">Hủy</button>
                        `;
                    }

                    callDiv.innerHTML = `
                        <div>
                            <h4 style="margin: 0 0 5px 0; color: #111827;">${call.title}</h4>
                            <p style="margin: 0; font-size: 0.85rem; color: #6b7280;">
                                ${time} (${call.durationMin} phút) - Bởi ${call.organizerName}
                            </p>
                            <a href="${call.meetingUrl}" target="_blank" style="font-size: 0.85rem; color: #3b82f6; text-decoration: none; margin-top: 5px; display: inline-block;">Tham gia cuộc họp</a>
                        </div>
                        <div>
                            ${actionsHtml}
                        </div>
                    `;
                    listContainer.appendChild(callDiv);
                });
            }
            document.getElementById('upcomingCallsModal').classList.add('active');
        })
        .catch(err => {
            console.error(err);
            alert("Không thể tải danh sách lịch gọi.");
        });
}

function editCall(call) {
    closeUpcomingCallsModal();
    document.getElementById('scheduleModalTitle').innerText = 'Sửa lịch gọi Video';
    document.getElementById('scheduleSubmitBtn').innerText = 'Cập nhật';
    document.getElementById('callId').value = call.callId;
    document.getElementById('callTitle').value = call.title;
    
    // Convert to datetime-local format (YYYY-MM-DDThh:mm)
    const date = new Date(call.scheduledAt);
    date.setMinutes(date.getMinutes() - date.getTimezoneOffset());
    document.getElementById('callTime').value = date.toISOString().slice(0, 16);
    
    document.getElementById('callDuration').value = call.durationMin;
    document.getElementById('callUrl').value = call.meetingUrl;
    
    document.getElementById('scheduleModal').classList.add('active');
}

function cancelCall(callId) {
    if (!confirm("Bạn có chắc chắn muốn hủy lịch gọi này?")) return;
    
    const formData = new URLSearchParams();
    formData.append('action', 'cancel');
    formData.append('callId', callId);
    formData.append('conversationId', currentConversationId);
    
    const ctx = window.location.pathname.substring(0, window.location.pathname.indexOf('/', 1));
    fetch(`${ctx}/customer/video-call`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
        body: formData.toString()
    })
    .then(async response => {
        const data = await response.json();
        if (response.ok) return data;
        throw new Error(data.message || 'Lỗi khi hủy');
    })
    .then(data => {
        alert("Đã hủy lịch gọi thành công.");
        showUpcomingCalls(); // refresh list
        
        // Trigger reload of conversation
        const currentName = document.getElementById('chatHeaderName').innerText;
        const currentAvatar = document.getElementById('chatHeaderAvatar').src;
        loadConversation(currentConversationId, currentName, currentAvatar);
    })
    .catch(error => {
        console.error(error);
        alert(error.message);
    });
}

// Create Group Chat Logic
function openCreateGroupModal() {
    document.getElementById('createGroupModal').style.display = 'flex';
}

function closeCreateGroupModal() {
    document.getElementById('createGroupModal').style.display = 'none';
}

function submitCreateGroup() {
    const groupName = document.getElementById('groupName').value.trim();
    if (!groupName) {
        alert('Vui lòng nhập tên nhóm!');
        return;
    }
    const checkboxes = document.querySelectorAll('input[name="participants"]:checked');
    if (checkboxes.length === 0) {
        alert('Vui lòng chọn ít nhất 1 bạn bè để tạo nhóm!');
        return;
    }
    document.getElementById('createGroupForm').submit();
}
