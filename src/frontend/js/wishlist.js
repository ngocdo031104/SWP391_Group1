document.addEventListener("DOMContentLoaded", () => {
    const removeButtons = document.querySelectorAll(".wishlist-btn-remove");
    const grid = document.querySelector(".wishlist-grid");

    removeButtons.forEach(btn => {
        btn.addEventListener("click", (e) => {
            e.preventDefault();
            const tourId = btn.getAttribute("data-tour-id");
            const card = btn.closest(".wishlist-card");
            const contextPath = window.contextPath || '';

            fetch(`${contextPath}/customer/wishlist/toggle?tourId=${tourId}`, {
                method: "POST"
            })
            .then(res => {
                if (res.status === 401) {
                    window.showToast("Vui l\u00f2ng \u0111\u0103ng nh\u1eadp \u0111\u1ec3 th\u1ef1c hi\u1ec7n t\u00e1c v\u1ee5.", "warning");
                    return null;
                }
                if (!res.ok) throw new Error("L\u1ed7i k\u1ebft n\u1ed1i h\u1ec7 th\u1ed1ng");
                return res.json();
            })
            .then(data => {
                if (!data) return;

                if (data.status === "success" || data.status === "removed") {
                    window.showToast("\u0110\u00E3 x\u00F3a tour kh\u1ECFi danh s\u00E1ch y\u00EAu th\u00EDch!", "success");
                    
                    // Add fade out class
                    card.classList.add("fade-out");
                    
                    // Wait for CSS animation to finish, then remove
                    setTimeout(() => {
                        card.remove();
                        
                        // Check if grid is now empty
                        const remainingCards = document.querySelectorAll(".wishlist-card");
                        if (remainingCards.length === 0) {
                            if (grid) {
                                grid.style.display = "none";
                            }
                            // Show empty state
                            const emptyState = document.getElementById("wishlist-empty-state");
                            if (emptyState) {
                                emptyState.style.display = "block";
                            }
                        }
                    }, 400);
                } else {
                    window.showToast(data.message, "error");
                }
            })
            .catch(err => {
                console.error(err);
                window.showToast("\u0110\u00e3 x\u1ea3y ra l\u1ed7i m\u1ea1ng!", "error");
            });
        });
    });
});
