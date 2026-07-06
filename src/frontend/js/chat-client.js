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
    
    msgDiv.innerHTML = `
        ${!isSent ? `<div class="message-avatar"><img src="https://ui-avatars.com/api/?name=${msg.senderName || 'User'}&background=random" style="width:100%;height:100%;border-radius:50%;" alt="Avatar"></div>` : ''}
        <div class="message-content">
            ${msg.content}
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
