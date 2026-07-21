<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" language="java" %>

    <footer class="footer">
        <div class="container footer-main">
            <div class="footer-col footer-brand">
                <a href="${pageContext.request.contextPath}/home" class="logo">
                    <div class="logo-icon">T</div>
                    <span>TourBuddy</span>
                </a>
                <p class="footer-desc">Ki&#7871;n t&#7841;o h&#224;nh tr&#236;nh du l&#7883;ch cao c&#7845;p v&#224; l&#7883;ch tr&#236;nh ngh&#7881; d&#432;&#7905;ng &#273;&#7863;t ri&#234;ng t&#7841;i nh&#7919;ng &#273;i&#7875;m &#273;&#7871;n tuy&#7879;t &#273;&#7865;p kh&#7855;p Vi&#7879;t Nam t&#7915; n&#259;m 2021.</p>
                <div class="social-links">
                    <a href="https://facebook.com/TourBuddyVN" class="btn-icon" aria-label="Facebook"><i data-lucide="facebook"></i></a>
                    <a href="https://instagram.com/tourbuddy.vn" class="btn-icon" aria-label="Instagram"><i data-lucide="instagram"></i></a>
                    <a href="https://twitter.com/TourBuddyVN" class="btn-icon" aria-label="Twitter"><i data-lucide="twitter"></i></a>
                    <a href="https://youtube.com/@TourBuddyVN" class="btn-icon" aria-label="YouTube"><i data-lucide="youtube"></i></a>
                </div>
            </div>

            <div class="footer-col">
                <h3>Kh&#225;m Ph&#225;</h3>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/tourdiscovery">G&#243;i Tour Cao C&#7845;p</a></li>
                    <li><a href="${pageContext.request.contextPath}/tourdiscovery">&#272;i&#7875;m &#272;&#7871;n Hot</a></li>
                    <li><a href="${pageContext.request.contextPath}/home#promotions">&#431;u &#272;&#227;i &#272;&#7863;c Bi&#7879;t</a></li>
                    <li><a href="${pageContext.request.contextPath}/tourdiscovery?category=adventure">Tour M&#7841;o Hi&#7875;m</a></li>
                </ul>
            </div>

            <div class="footer-col">
                <h3>H&#7895; Tr&#7907;</h3>
                <ul class="footer-links">
                    <li><a href="${pageContext.request.contextPath}/help">Trung T&#226;m Tr&#7907; Gi&#250;p</a></li>
                    <li><a href="${pageContext.request.contextPath}/guide-booking">H&#432;&#7899;ng D&#7851;n &#272;&#7863;t Tour</a></li>
                    <li><a href="${pageContext.request.contextPath}/policy/cancel">Ch&#237;nh S&#225;ch H&#7911;y</a></li>
                    <li><a href="${pageContext.request.contextPath}/contact">Li&#234;n H&#7879; H&#7895; Tr&#7907;</a></li>
                </ul>
            </div>

            <div class="footer-col footer-newsletter">
                <h3>&#272;&#259;ng K&#253; Nh&#7853;n Tin</h3>
                <p>C&#7853;p nh&#7853;t m&#227; gi&#7843;m gi&#225;, flash sale v&#224; h&#224;nh tr&#236;nh m&#7899;i nh&#7845;t t&#7915; TourBuddy.</p>
                <form class="newsletter-form" id="newsletter-subscription-form">
                    <input type="email" placeholder="Email c&#7911;a b&#7841;n" id="newsletter-email" required>
                    <button type="submit" id="newsletter-submit-btn">&#272;&#259;ng K&#253;</button>
                </form>
            </div>
        </div>

        <div class="container footer-bottom">
            <p>&copy; 2026 TourBuddy Ltd. B&#7843;o l&#432;u m&#7885;i quy&#7873;n. Thi&#7871;t k&#7871; theo ti&#234;u chu&#7849;n du l&#7883;ch cao c&#7845;p.</p>
            <div class="footer-selectors">
                <div class="selector-wrapper">
                    <select id="lang-select" aria-label="Ch&#7885;n ng&#244;n ng&#7919;">
                        <option value="vi" selected>Ti&#7871;ng Vi&#7879;t</option>
                        <option value="en">English (US)</option>
                        <option value="jp">&#26085;&#26412;&#35486;</option>
                        <option value="fr">Fran&#231;ais</option>
                    </select>
                </div>
                <div class="selector-wrapper">
                    <select id="curr-select" aria-label="Ch&#7885;n ti&#7873;n t&#7879;">
                        <option value="vnd" selected>VND (&#8363;)</option>
                        <option value="usd">USD ($)</option>
                        <option value="eur">EUR (&#8364;)</option>
                        <option value="jpy">JPY (&#165;)</option>
                    </select>
                </div>
            </div>
        </div>
    </footer>

    <script src="${pageContext.request.contextPath}/js/navigation.js?v=2.1"></script>
    <script>
        document.addEventListener('DOMContentLoaded', () => {
            const form = document.getElementById('newsletter-subscription-form');
            if (form) {
                form.addEventListener('submit', (e) => {
                    e.preventDefault();
                    const email = document.getElementById('newsletter-email').value;
                    
                    fetch('${pageContext.request.contextPath}/newsletter/subscribe', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/x-www-form-urlencoded'
                        },
                        body: 'email=' + encodeURIComponent(email)
                    })
                    .then(res => res.json())
                    .then(res => {
                        alert(res.message);
                        if (res.status === 'success') {
                            form.reset();
                        }
                    })
                    .catch(err => {
                        console.error(err);
                        alert('C\u00f3 l\u1ed7i h\u1ec7 th\u1ed1ng x\u1ea3y ra. Vui l\u00f2ng th\u1eed l\u1ea1i sau.');
                    });
                });
            }
        });
    </script>
    <% 
        String extraScript = (String) request.getAttribute("extraScript");
        if (extraScript != null && !extraScript.trim().isEmpty()) {
    %>
    <script src="${pageContext.request.contextPath}/<%= extraScript %>?v=2.2" charset="UTF-8"></script>
    <% 
        }
    %>
    <div id="toastContainer" class="toast-container"></div>
    <script>
        window.showToast = function(message, type) {
            type = type || 'success';
            let container = document.getElementById('toastContainer');
            if (!container) {
                container = document.createElement('div');
                container.id = 'toastContainer';
                container.className = 'toast-container';
                document.body.appendChild(container);
            }
            const toast = document.createElement('div');
            toast.className = 'toast ' + type;
            
            let icon = 'check-circle';
            if (type === 'error') icon = 'alert-triangle';
            else if (type === 'warning') icon = 'alert-circle';
            
            toast.innerHTML = '<i data-lucide="' + icon + '"></i> <span>' + (message || '') + '</span>';
            container.appendChild(toast);
            
            if (window.lucide) {
                try {
                    window.lucide.createIcons();
                } catch (e) {
                    console.error(e);
                }
            }
            
            setTimeout(() => {
                toast.style.animation = 'toastExit 0.35s cubic-bezier(.16,1,.3,1) forwards';
                setTimeout(() => toast.remove(), 350);
            }, 3000);
        }
    </script>
    <script src="${pageContext.request.contextPath}/js/tb-ui.js?v=1.0"></script>
</body>
</html>
