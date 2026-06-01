document.addEventListener('DOMContentLoaded', () => {
    // Initialize Lucide Icons
    lucide.createIcons();

    // Constant for Currency Rate
    const EXCHANGE_RATE = 25000; // 1 USD = 25,000 VND

    /* ==========================================================================
       DỮ LIỆU CƠ BẢN TOUR ĐỒNG BỘ VỚI EXPLORE.JS
       ========================================================================== */
    const toursData = window.toursData || [
        {
            id: 1,
            title: "Tour Thượng Lưu Bà Nà Hills, Cầu Vàng & Ngũ Hành Sơn 3 Ngày",
            description: "Trải nghiệm cáp treo đạt nhiều kỷ lục thế giới, check-in Cầu Vàng huyền thoại giữa mây ngàn, khám phá làng Pháp cổ kính và lưu trú tại resort 5 sao bên bờ biển Mỹ Khê tuyệt mỹ.",
            image: "assets/images/tour_danang.png",
            rating: 4.9,
            reviews: 142,
            priceVND: 4800000,
            duration: 3,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 8,
            seatsTotal: 20,
            guide: { name: "Nguyễn Văn Hùng", avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=80&q=80" },
            location: "Đà Nẵng"
        },
        {
            id: 2,
            title: "Thiên Đường Đảo Ngọc Phú Quốc - Lặn San Hô & Ngắm Hoàng Hôn 4 Ngày",
            description: "Khám phá các đảo hoang sơ phía Nam, lên du thuyền câu cá lặn ngắm san hô tại hòn Móng Tay, thưởng thức tiệc hải sản tươi sống và ngắm hoàng hôn Sunset Sanato rực rỡ.",
            image: "assets/images/tour_phuquoc.png",
            rating: 5.0,
            reviews: 98,
            priceVND: 6200000,
            duration: 4,
            difficulty: "easy",
            category: "beach",
            seatsLeft: 12,
            seatsTotal: 20,
            guide: { name: "Trần Minh Tâm", avatar: "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=80&q=80" },
            location: "Phú Quốc"
        },
        {
            id: 3,
            title: "Nghỉ Dưỡng Du Thuyền 5 Sao Vịnh Hạ Long & Chèo Thuyền Kayak 2 Ngày",
            description: "Thư giãn trên du thuyền sang trọng giữa kỳ quan thiên nhiên thế giới. Trải nghiệm chèo kayak qua Hang Luồn kỳ thú, chinh phục đỉnh đảo Ti Tốp và thưởng thức ẩm thực Á-Âu thượng hạng.",
            image: "assets/images/tour_halong.png",
            rating: 4.8,
            reviews: 215,
            priceVND: 3900000,
            duration: 2,
            difficulty: "easy",
            category: "luxury",
            seatsLeft: 4,
            seatsTotal: 10,
            guide: { name: "Lê Hoàng Nam", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
            location: "Hạ Long"
        },
        {
            id: 4,
            title: "Hành Trình Phố Cổ Hội An Hoài Cổ & Thả Đèn Hoa Đăng Sông Hoài 2 Ngày",
            description: "Tản bộ qua những bức tường vàng phủ rêu phong hàng trăm năm tuổi, tham gia làm đèn lồng truyền thống nghệ thuật, thưởng thức Cao Lầu đặc sản và đi thuyền gỗ thả đèn hoa đăng lung linh.",
            image: "assets/images/tour_hoian.png",
            rating: 4.7,
            reviews: 86,
            priceVND: 1850000,
            duration: 2,
            difficulty: "easy",
            category: "cultural",
            seatsLeft: 15,
            seatsTotal: 30,
            guide: { name: "Phạm Thùy Linh", avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80" },
            location: "Hội An"
        },
        {
            id: 5,
            title: "Săn Mây Đà Lạt, Chinh Phục Langbiang & Cắm Trại Rừng Thông 3 Ngày",
            description: "Săn mây bình minh tuyệt diệu tại Đồi Chè Cầu Đất, trekking chinh phục đỉnh núi Langbiang huyền thoại, cắm trại rừng thông thơ mộng và thưởng thức tiệc BBQ ấm cúng trong sương mờ.",
            image: "assets/images/tour_dalat.png",
            rating: 4.9,
            reviews: 110,
            priceVND: 2900000,
            duration: 3,
            difficulty: "medium",
            category: "hiking",
            seatsLeft: 6,
            seatsTotal: 8,
            guide: { name: "Lâm Quốc Bảo", avatar: "https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?auto=format&fit=crop&w=80&q=80" },
            location: "Đà Lạt"
        },
        {
            id: 6,
            title: "Trekking Ruộng Bậc Thang Sa Pa & Chinh Phục Fansipan Kỳ Vĩ 3 Ngày",
            description: "Hành trình trekking ngắm ruộng bậc thang thung lũng Mường Hoa kỳ vĩ, chinh phục đỉnh Fansipan - Nóc nhà Đông Dương bằng cáp treo hiện đại và trải nghiệm văn hóa bản địa độc đáo.",
            image: "assets/images/tour_sapa.png",
            rating: 4.9,
            reviews: 154,
            priceVND: 3500000,
            duration: 3,
            difficulty: "hard",
            category: "hiking",
            seatsLeft: 3,
            seatsTotal: 8,
            guide: { name: "Vàng A Tủa", avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=120&q=80" },
            location: "Sa Pa"
        },
        {
            id: 7,
            title: "Khám Phá Vịnh Nha Trang - Đi Bộ Dưới Đại Dương & VinWonders 4 Ngày",
            description: "Trải nghiệm đi bộ dưới đáy biển ngắm rạn san hô rực rỡ tại Hòn Mun, đi ca-nô cao tốc ngắm vịnh và thỏa sức vui chơi giải trí tại thiên đường VinWonders đẳng cấp thế giới.",
            image: "assets/images/tour_nhatrang.png",
            rating: 4.6,
            reviews: 73,
            priceVND: 4200000,
            duration: 4,
            difficulty: "medium",
            category: "beach",
            seatsLeft: 18,
            seatsTotal: 25,
            guide: { name: "Nguyễn Minh Triết", avatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=120&q=80" },
            location: "Nha Trang"
        },
        {
            id: 8,
            title: "Hành Trình Kỳ Vĩ Hà Giang - Mã Pí Lèng & Đi Thuyền Sông Nho Quế 4 Ngày",
            description: "Chinh phục đèo Mã Pí Lèng - một trong tứ đại đỉnh đèo Việt Nam, ngắm thung lũng hoa tam giác mạch rừng đá Đồng Văn và đi thuyền trên dòng sông Nho Quế xanh như ngọc bích.",
            image: "assets/images/tour_hagiang.png",
            rating: 5.0,
            reviews: 120,
            priceVND: 3200000,
            duration: 4,
            difficulty: "hard",
            category: "adventure",
            seatsLeft: 5,
            seatsTotal: 10,
            guide: { name: "Sùng Mí Phìn", avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=120&q=80" },
            location: "Hà Giang"
        }
    ];

    /* ==========================================================================
       DỮ LIỆU LỊCH TRÌNH CHI TIẾT TỪNG NGÀY (DAILY ITINERARIES)
       Lý do tại sao lại sử dụng window.itinerariesData:
       - Để nhận dữ liệu động được kết xuất từ cơ sở dữ liệu ở cuối trang detail.jsp.
       - Toán tử || (hoặc) giúp đảm bảo nếu biến window.itinerariesData trống (ví dụ chạy offline tĩnh)
         thì hệ thống sẽ tự động sử dụng mảng dữ liệu mặc định bên dưới làm dự phòng (fallback).
       ========================================================================== */
    const itinerariesData = window.itinerariesData || {
        1: [
            { day: 1, title: "Đón đoàn - Di chuyển đi Bà Nà Hills - Trải nghiệm Làng Pháp", desc: "Đón khách tại sân bay Đà Nẵng. Di chuyển lên đỉnh Bà Nà bằng hệ thống cáp treo đạt nhiều kỷ lục. Khám phá lâu đài cổ kính kiểu Pháp, lâu đài tâm linh và thưởng thức buffet trưa thịnh soạn.", icon: "cable-car" },
            { day: 2, title: "Check-in Cầu Vàng huyền ảo - Tham quan hầm rượu cổ Debay & Chùa Linh Ứng", desc: "Đón bình minh sớm trên Cầu Vàng (Golden Bridge) tuyệt đẹp không bóng người. Khám phá Vườn hoa Le Jardin D'Amour rực rỡ, hầm rượu cổ sâu trong lòng đất và chùa Linh Ứng uy nghiêm.", icon: "camera" },
            { day: 3, title: "Khám phá danh thắng Ngũ Hành Sơn - Mua sắm đặc sản - Tiễn đoàn", desc: "Xuống cáp treo, di chuyển tham quan quần thể Ngũ Hành Sơn kỳ bí, ghé thăm làng đá mỹ nghệ Non Nước. Tự do mua sắm quà lưu niệm và xe tiễn đoàn ra sân bay Đà Nẵng kết thúc chuyến đi.", icon: "plane" }
        ],
        2: [
            { day: 1, title: "Chào đón Phú Quốc - Khám phá Dinh Cậu & Chợ đêm ẩm thực", desc: "Đón du khách tại sân bay Phú Quốc, nhận phòng resort 5 sao sát biển. Chiều tham quan Dinh Cậu tâm linh và ngắm hoàng hôn đỏ lịm. Tối dạo chơi tự do và thưởng thức hải sản tại Chợ đêm Đảo Ngọc.", icon: "palmtree" },
            { day: 2, title: "Lên Du thuyền sang trọng - Câu cá & Lặn ngắm san hô Hòn Móng Tay", desc: "Lên tàu cao cấp du ngoạn 4 đảo phía Nam. Trải nghiệm câu cá giải trí, bơi lặn ngắm san hô tự nhiên tại Hòn Móng Tay, Hòn Gầm Ghì, Hòn Mây Rút. Thưởng thức bữa trưa hải sản thịnh soạn chế biến trực tiếp trên tàu.", icon: "ship" },
            { day: 3, title: "Tham quan Safari hoang dã - Khám phá siêu quần thể Grand World", desc: "Ghé thăm Công viên bảo tồn động vật bán hoang dã Vinpearl Safari lớn nhất Việt Nam. Chiều tối hòa mình vào không gian lễ hội Châu Âu thu nhỏ của siêu dự án Grand World không ngủ.", icon: "sparkles" },
            { day: 4, title: "Ghé thăm Nhà thùng Nước mắm truyền thống - Tiễn sân bay", desc: "Tìm hiểu quy trình ủ nước mắm cá cơm Phú Quốc nổi tiếng tại nhà thùng cổ truyền. Ghé mua sắm đặc sản tiêu sọ, ngọc trai Phú Quốc làm quà và xe đưa ra sân bay tiễn đoàn.", icon: "plane" }
        ],
        3: [
            { day: 1, title: "Đón Cảng Tuần Châu - Lên Du thuyền 5 sao - Khám phá Hang Sửng Sốt", desc: "Đoàn làm thủ tục lên tàu tại Cảng Tuần Châu. Thưởng thức đồ uống chào mừng, nghe phổ biến an toàn. Tàu nhổ neo xuyên vịnh, tham quan Hang Sửng Sốt - hang động lớn và đẹp nhất vịnh Hạ Long với thạch nhũ lấp lánh.", icon: "ship" },
            { day: 2, title: "Chèo kayak Hang Luồn - Chinh phục đảo Ti Tốp - Trở về cảng", desc: "Đón ngày mới với bài tập Thái Cực Quyền trên boong tàu. Chèo thuyền Kayak xuyên qua vách đá Hang Luồn kỳ bí. Chinh phục đỉnh núi đảo Ti Tốp ngắm toàn cảnh Vịnh Hạ Long từ trên cao trước khi tàu cập bến cảng Tuần Châu.", icon: "mountain" }
        ],
        4: [
            { day: 1, title: "Chào Hội An cổ kính - Khám phá thánh địa Mỹ Sơn kỳ bí", desc: "Đoàn di chuyển tham quan Thánh địa Mỹ Sơn - thủ đô đền tháp của vương triều Chăm Pa xưa cổ. Chiều tối nhận phòng khách sạn, tản bộ ngắm phố cổ Hội An lên đèn lung linh huyền ảo.", icon: "landmark" },
            { day: 2, title: "Trải nghiệm đi thuyền gỗ thả đèn hoa đăng sông Hoài - Học làm đèn lồng", desc: "Tự tay làm một chiếc đèn lồng Hội An nhỏ xinh dưới sự hướng dẫn của nghệ nhân. Chiều mát lên thuyền thả đèn hoa đăng lung linh dọc dòng sông Hoài thơ mộng cầu an lành.", icon: "heart" }
        ],
        5: [
            { day: 1, title: "Đón sân bay Liên Khương - Check-in Đà Lạt mộng mơ - Chợ đêm", desc: "Xe đón đoàn di chuyển lên cao nguyên Đà Lạt trong lành. Nhận phòng khách sạn, chiều tham quan ga xe lửa cổ Đà Lạt và check-in quảng trường Lâm Viên. Tối tự do ăn uống lẩu gà lá é và dạo chợ đêm.", icon: "map-pin" },
            { day: 2, title: "Săn mây bình minh Đồi chè Cầu Đất - Chinh phục Langbiang huyền thoại", desc: "Thức dậy sớm di chuyển săn mây bồng bềnh tại cầu gỗ đồi chè Cầu Đất. Chiều trekking/đi xe jeep chinh phục đỉnh Langbiang huyền thoại ngắm dòng sông Vàng từ đỉnh núi sương mù.", icon: "mountain" },
            { day: 3, title: "Thăm vườn dâu tây công nghệ cao - Thác Datanla - Trở về", desc: "Ghé thăm vườn dâu tây tươi hái tại vườn. Trải nghiệm máng trượt xuyên thác nước Datanla kỳ vĩ trước khi xe tiễn đoàn ra sân bay Liên Khương kết thúc tour.", icon: "plane" }
        ],
        6: [
            { day: 1, title: "Đón Sa Pa - Trekking Bản Cát Cát hoang sơ - Thung lũng Mường Hoa", desc: "Xe giường nằm đón du khách đến thị trấn Sa Pa mù sương. Buổi chiều trekking tản bộ dọc theo bản Cát Cát xinh đẹp của người đồng bào H'Mông, ngắm ruộng bậc thang trải dài và thác nước Cát Cát thơ mộng.", icon: "activity" },
            { day: 2, title: "Chinh phục Đỉnh núi Fansipan bằng Cáp treo - Cột mốc Nóc nhà Đông Dương", desc: "Di chuyển bằng tàu hỏa leo núi Mường Hoa, sau đó lên Cáp treo Fansipan vượt qua thung lũng mây kỳ vĩ. Chinh phục 600 bậc đá để chạm tay vào chóp inox 3.143m huyền thoại - Nóc nhà của Đông Dương.", icon: "mountain" },
            { day: 3, title: "Thăm Bản Tả Phìn yên bình - Trải nghiệm tắm lá thuốc Dao Đỏ - Trở về Hà Nội", desc: "Ghé thăm bản Tả Phìn nguyên sơ, tự do trải nghiệm tắm lá thuốc thảo mộc của người Dao Đỏ để xua tan mệt mỏi. Trưa mua sắm nông sản hạt dẻ, nấm hương trước khi lên xe về lại Hà Nội.", icon: "plane" }
        ],
        7: [
            { day: 1, title: "Chào Nha Trang nắng vàng - Khám phá Chùa Long Sơn & Tháp Bà Ponagar", desc: "Xe đón khách đưa đi tham quan di tích lịch sử vương triều Chăm cổ Tháp Bà Ponagar, chiêm ngưỡng tượng Phật trắng chùa Long Sơn. Nhận phòng khách sạn cao cấp sát biển Nha Trang.", icon: "landmark" },
            { day: 2, title: "Lên ca-nô cao tốc - Đi bộ dưới đại dương ngắm san hô Hòn Mun", desc: "Trải nghiệm lặn biển và đi bộ dưới đáy biển (Sea Walk) ngắm san hô, cá màu rực rỡ tại khu bảo tồn biển Hòn Mun bằng mũ dưỡng khí công nghệ cao. Trưa ăn trưa dã ngoại hải sản trên Bè nổi.", icon: "anchor" },
            { day: 3, title: "Vui chơi thả ga VinWonders đảo Hòn Tre", desc: "Dành trọn vẹn 1 ngày vui chơi tại thiên đường giải trí VinWonders Nha Trang với cáp treo vượt biển, công viên nước khổng lồ và các show diễn thực cảnh Tata Show triệu đô đầy choáng ngợp.", icon: "sparkles" },
            { day: 4, title: "Mua sắm hải sản Chợ Đầm - Xe tiễn sân bay Cam Ranh", desc: "Mua sắm đặc sản yến sào, mực khô, nem nướng tại Chợ Đầm lịch sử. Xe tiễn đoàn ra sân bay Cam Ranh kết thúc chuyến du lịch biển tuyệt vời.", icon: "plane" }
        ],
        8: [
            { day: 1, title: "Hành trình Hà Nội - Hà Giang - Cổng trời Quản Bạ - Rừng thông Yên Minh", desc: "Khởi hành từ Hà Nội đi Hà Giang. Dừng chân check-in Dốc Bắc Sum quanh co và Cổng trời Quản Bạ ngắm núi đôi Cô Tiên. Chiều đi qua rừng thông Yên Minh xanh mát, nhận phòng homestay người Tày.", icon: "activity" },
            { day: 2, title: "Cột cờ Lũng Cú địa đầu - Dinh thự Vua Mèo cổ kính - Phố cổ Đồng Văn", desc: "Check-in Cột cờ quốc gia Lũng Cú cực kỳ tự hào. Tham quan kiến trúc cổ kính giao thoa Pháp-Hoa của Dinh thự Vua Mèo Vương Chính Đức. Tối dạo chơi uống cafe Phố cổ Đồng Văn trong gió lạnh vùng cao.", icon: "landmark" },
            { day: 3, title: "Chinh phục Đệ nhất hùng đèo Mã Pí Lèng - Du thuyền hẻm vực sông Nho Quế", desc: "Vượt qua những khúc cua ngoạn mục đèo Mã Pí Lèng kỳ vĩ bậc nhất Việt Nam. Xuống bến thuyền tản bộ dọc hẻm Tu Sản sâu nhất Đông Nam Á và đi thuyền trên dòng sông Nho Quế xanh biếc thơ mộng.", icon: "mountain" },
            { day: 4, title: "Check-in Dốc Thẩm Mã huyền thoại - Mua sắm sản vật - Hà Nội", desc: "Chụp ảnh lưu niệm tại Dốc Thẩm Mã - con dốc nổi tiếng nhất Hà Giang với những em bé dân tộc đeo gùi hoa. Ghé mua mật ong bạc hà đặc sản trước khi xe chạy xuyên đêm tiễn về lại Hà Nội.", icon: "plane" }
        ]
    };

    /* ==========================================================================
       DỮ LIỆU ĐÁNH GIÁ MẪU CHO TỪNG TOUR (SAMPLE REVIEWS)
       Lý do tại sao lại sử dụng window.reviewsData:
       - Để nhận dữ liệu danh sách đánh giá của tour hiện tại được nạp động từ DB (qua detail.jsp).
       - Nếu DB chưa có đánh giá nào, sẽ sử dụng các đánh giá mẫu đã chuẩn bị sẵn để hiển thị cho đẹp mắt.
       ========================================================================== */
    const reviewsData = window.reviewsData || {
        6: [
            { name: "Phạm Minh Hoàng", rating: 5, date: "15/05/2026", text: "Chuyến trekking Fansipan thực sự là trải nghiệm để đời! Đường leo dốc tuy mệt nhưng phong cảnh ruộng bậc thang Sa Pa lộng gió quá đẹp. Đỉnh núi mây mù giăng lối sương lạnh buốt chạm tay vào chóp cảm giác tự hào vô cùng. Hướng dẫn viên Tủa rất chu đáo, nhiệt tình hỗ trợ đoàn.", isVerified: true, avatar: "https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&w=80&q=80", image: "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80" },
            { name: "Nguyễn Thùy Chi", rating: 5, date: "02/05/2026", text: "Du lịch Sa Pa dịch vụ của Mirai rất xuất sắc. Khách sạn 5 sao có bồn tắm nước nóng ngắm thung lũng, đồ ăn buffet ngon miệng phong phú. Trải nghiệm tắm lá thuốc Dao đỏ ở bản Tả Phìn vô cùng thư giãn, đỡ mỏi hẳn sau ngày trekking dốc núi.", isVerified: true, avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=80&q=80" },
            { name: "Lê Quốc Bảo", rating: 4, date: "24/04/2026", text: "Phong cảnh thung lũng Mường Hoa rất thơ mộng. Dịch vụ ăn uống ngon nhưng lịch trình ngày 2 leo Fansipan đi bộ hơi mỏi chân chút. Cáp treo rất hiện đại, cabin kính rộng lớn. Đáng tiền trải nghiệm!", isVerified: true, avatar: "https://images.unsplash.com/photo-1570295999919-56ceb5ecca61?auto=format&fit=crop&w=80&q=80" }
        ]
    };

    // Fallback reviews for tours that don't have specified review lists
    const defaultReviews = [
        { name: "Trần Anh Tuấn", rating: 5, date: "20/05/2026", text: "Dịch vụ đẳng cấp chuyên nghiệp! Đưa đón đúng giờ, hướng dẫn viên nhiệt tình vui tính. Các điểm tham quan cực đẹp, khách sạn resort ở siêu thích. Chắc chắn sẽ tiếp tục ủng hộ Mirai trong các hành trình du lịch tiếp theo.", isVerified: true, avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=80&q=80" },
        { name: "Lê Minh Thư", rating: 5, date: "14/05/2026", text: "Trải nghiệm du lịch 5 sao đáng tiền từng xu. Thức ăn siêu ngon đa dạng, lịch trình sắp xếp cực kỳ khoa học không gây cảm giác mệt mỏi. Gia đình tôi đều rất hài lòng.", isVerified: true, avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=80&q=80" }
    ];

    /* ==========================================================================
       DỮ LIỆU BỘ ẢNH SLIDESHOW CHI TIẾT TỪNG TOUR (GALLERY IMAGES SETS)
       ========================================================================== */
    const galleryImages = {
        1: [
            "https://images.unsplash.com/photo-1559592413-7cec4d0c8ab8?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80"
        ],
        2: [
            "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1439066615861-d1af74d74000?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1505118380757-91f5f5632de0?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1519046904884-53103b34b206?auto=format&fit=crop&w=1200&q=80"
        ],
        3: [
            "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1524230572899-a752b3835840?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1200&q=80"
        ],
        4: [
            "https://images.unsplash.com/photo-1528183429752-a97d0bf99f5c?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1528127269322-539801943592?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1537996194471-e657df975ab4?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1552674605-db6ffd4facb5?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=1200&q=80"
        ],
        5: [
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80"
        ],
        6: [
            "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1502602898657-3e91760cbb34?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1524230572899-a752b3835840?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1200&q=80"
        ],
        7: [
            "https://images.unsplash.com/photo-1528183429752-a97d0bf99f5c?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1540555700478-4be289fbecef?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1476514525535-07fb3b4ae5f1?auto=format&fit=crop&w=1200&q=80"
        ],
        8: [
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=1200&q=80",
            "https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=1200&q=80"
        ]
    };

    /* ==========================================================================
       DYNAMIC TARGET TOUR LOADING
       ========================================================================== */
    // Parse query params for ID
    const urlParams = new URLSearchParams(window.location.search);
    const tourId = parseInt(urlParams.get('id')) || 6; // Default to Sa Pa (id: 6) which matches "nui"

    // Load active tour data
    const activeTour = toursData.find(t => t.id === tourId) || toursData[5]; // Default to Sa Pa
    
    // Dynamic array of photos for lightbox
    const photosList = galleryImages[activeTour.id] || galleryImages[6];
    let currentPhotoIndex = 0;
    
    // Set dynamic HTML headers
    document.getElementById('breadcrumb-active').textContent = activeTour.title;
    document.getElementById('detail-title').textContent = activeTour.title;
    document.getElementById('detail-rating').textContent = activeTour.rating.toFixed(1);
    document.getElementById('detail-reviews-count').textContent = `(${activeTour.reviews} đánh giá)`;
    document.getElementById('detail-location-name').textContent = activeTour.location;
    document.getElementById('gallery-main-img').src = activeTour.image;
    document.getElementById('gallery-main-img').alt = activeTour.title;

    // Load category translation
    let categoryText = "Premium";
    if (activeTour.category === "luxury") categoryText = "Nghỉ dưỡng 5★";
    else if (activeTour.category === "beach") categoryText = "Khám phá Biển";
    else if (activeTour.category === "hiking") categoryText = "Trekking Thử thách";
    else if (activeTour.category === "cultural") categoryText = "Văn hóa Hoài cổ";
    else if (activeTour.category === "adventure") categoryText = "Thám hiểm Mạo hiểm";
    document.getElementById('detail-category-badge').textContent = categoryText;

    // Load Guide Details
    document.getElementById('guide-avatar-img').src = activeTour.guide.avatar;
    document.getElementById('guide-avatar-img').alt = activeTour.guide.name;
    document.getElementById('guide-name-txt').textContent = activeTour.guide.name;
    if (activeTour.guide.rating) {
        document.getElementById('guide-rating-txt').textContent = `${activeTour.guide.rating}★`;
    }
    if (activeTour.guide.toursLed) {
        document.getElementById('guide-tours-txt').textContent = activeTour.guide.toursLed;
    }
    if (activeTour.guide.bio) {
        document.getElementById('guide-bio-txt').textContent = `"${activeTour.guide.bio}"`;
    }

    // Load description
    document.getElementById('tour-detail-desc').textContent = activeTour.description;

    // Highlights translation
    let difficultyText = "Nhẹ nhàng";
    if (activeTour.difficulty === "medium") difficultyText = "Trung bình";
    else if (activeTour.difficulty === "hard") difficultyText = "Thử thách mạnh";
    
    document.getElementById('hl-difficulty').textContent = difficultyText;
    document.getElementById('hl-duration').textContent = `${activeTour.duration} Ngày`;
    document.getElementById('hl-group-size').textContent = `${activeTour.seatsTotal} Khách`;

    // Available seats progress sidebar
    const seatsPill = document.getElementById('booking-seats-left-pill');
    if (seatsPill) {
        if (activeTour.seatsLeft <= 5) {
            seatsPill.className = "price-side-right warning-pill";
            seatsPill.innerHTML = `<span>Chỉ còn ${activeTour.seatsLeft} chỗ!</span>`;
        } else {
            seatsPill.className = "price-side-right";
            seatsPill.innerHTML = `<span>Còn ${activeTour.seatsLeft} chỗ trống</span>`;
        }
    }

    // Load Thumbnails
    const subThumbnails = document.querySelectorAll('.gallery-thumb');
    subThumbnails.forEach((img, idx) => {
        if (photosList[idx + 1]) {
            img.src = photosList[idx + 1];
        }
    });

    /* ==========================================================================
       CURRENCY & FORMATTING UTIL FUNCTIONS
       ========================================================================== */
    const currSelect = document.getElementById('curr-select');

    function getActiveCurrency() {
        return currSelect ? currSelect.value : 'vnd';
    }

    function formatPrice(vndAmount) {
        const currency = getActiveCurrency();
        if (currency === 'vnd') {
            return `${vndAmount.toLocaleString('vi-VN')} ₫`;
        } else {
            const usdAmount = Math.round(vndAmount / EXCHANGE_RATE);
            return `$${usdAmount.toLocaleString('en-US')}`;
        }
    }

    // Update prices on page load
    function renderStaticPrices() {
        document.getElementById('booking-base-price').textContent = formatPrice(activeTour.priceVND);
    }
    renderStaticPrices();

    /* ==========================================================================
       STICKY SIDEBAR CALCULATIONS & PROMO CODE
       ========================================================================== */
    const bookDateInput = document.getElementById('book-date');
    const bookTravelersSelect = document.getElementById('book-travelers');
    const billCalculationsRow = document.getElementById('booking-bill-row');
    const billCalcLabel = document.getElementById('bill-calc-label');
    const billSubtotalVal = document.getElementById('bill-subtotal-val');
    const billTaxVal = document.getElementById('bill-tax-val');
    const billTotalVal = document.getElementById('bill-total-val');
    const promoCodeInput = document.getElementById('promo-code-input');
    const applyPromoBtn = document.getElementById('apply-promo-btn');
    const promoMessageTxt = document.getElementById('promo-message-txt');
    const promoDiscountLine = document.getElementById('promo-discount-line');
    const billDiscountVal = document.getElementById('bill-discount-val');
    const submitBookingBtn = document.getElementById('submit-booking-btn');

    // Default book date to tomorrow
    const tomorrow = new Date();
    tomorrow.setDate(tomorrow.getDate() + 1);
    if (bookDateInput) {
        bookDateInput.value = tomorrow.toISOString().split('T')[0];
    }

    let isPromoApplied = false;

    function runCalculations() {
        const travelers = parseInt(bookTravelersSelect.value);
        const basePriceVND = activeTour.priceVND;
        const subtotalVND = basePriceVND * travelers;

        // Discount calculation (20% off)
        let discountVND = 0;
        if (isPromoApplied) {
            discountVND = subtotalVND * 0.20;
        }

        // Tax calculation (8% VAT)
        const taxableAmountVND = subtotalVND - discountVND;
        const taxVND = taxableAmountVND * 0.08;

        // Total
        const totalVND = taxableAmountVND + taxVND;

        // Render calculations
        billCalcLabel.textContent = `${travelers} khách x ${formatPrice(basePriceVND)}`;
        billSubtotalVal.textContent = formatPrice(subtotalVND);
        billTaxVal.textContent = formatPrice(taxVND);
        billTotalVal.textContent = formatPrice(totalVND);

        if (isPromoApplied) {
            promoDiscountLine.style.display = 'flex';
            billDiscountVal.textContent = `-${formatPrice(discountVND)}`;
        } else {
            promoDiscountLine.style.display = 'none';
        }
    }

    runCalculations();

    if (bookTravelersSelect) {
        bookTravelersSelect.addEventListener('change', runCalculations);
    }

    if (applyPromoBtn) {
        applyPromoBtn.addEventListener('click', () => {
            const code = promoCodeInput.value.trim().toUpperCase();
            if (code === "MIRAI2026") {
                isPromoApplied = true;
                promoMessageTxt.style.color = "#16a34a";
                promoMessageTxt.textContent = "Áp dụng mã giảm giá 20% thành công!";
                runCalculations();
            } else if (code === "") {
                isPromoApplied = false;
                promoMessageTxt.textContent = "";
                runCalculations();
            } else {
                isPromoApplied = false;
                promoMessageTxt.style.color = "#dc2626";
                promoMessageTxt.textContent = "Mã giảm giá không hợp lệ.";
                runCalculations();
            }
        });
    }

    if (submitBookingBtn) {
        submitBookingBtn.addEventListener('click', () => {
            alert(`Đặt tour thành công!\nHành trình: ${activeTour.title}\nNgày khởi hành: ${bookDateInput.value}\nSố lượng khách: ${bookTravelersSelect.value} người.`);
        });
    }

    /* ==========================================================================
       VERTICAL ITINERARY TIMELINE accordion RENDER
       ========================================================================== */
    const timelineContainer = document.getElementById('itinerary-timeline-container');

    function renderItinerary() {
        if (!timelineContainer) return;
        timelineContainer.innerHTML = '';
        
        const itinerary = itinerariesData[activeTour.id] || itinerariesData[6];

        itinerary.forEach((item, idx) => {
            const step = document.createElement('div');
            step.className = `timeline-step ${idx === 0 ? 'active' : ''}`;
            
            // Map standard icons
            let iconName = "map-pin";
            if (item.icon === "cable-car") iconName = "cable-car";
            else if (item.icon === "camera") iconName = "camera";
            else if (item.icon === "plane") iconName = "plane";
            else if (item.icon === "ship") iconName = "ship";
            else if (item.icon === "palmtree") iconName = "palmtree";
            else if (item.icon === "sparkles") iconName = "sparkles";
            else if (item.icon === "mountain") iconName = "mountain";
            else if (item.icon === "activity") iconName = "activity";
            else if (item.icon === "landmark") iconName = "landmark";

            step.innerHTML = `
                <div class="timeline-badge">
                    <i data-lucide="${iconName}"></i>
                </div>
                <div class="timeline-panel">
                    <div class="timeline-heading">
                        <span class="timeline-day-label">Ngày ${item.day}</span>
                        <h4>${item.title}</h4>
                        <i data-lucide="chevron-down" class="timeline-arrow"></i>
                    </div>
                    <div class="timeline-body">
                        <p>${item.desc}</p>
                    </div>
                </div>
            `;

            // Toggle timeline body visibility (Accordion)
            const heading = step.querySelector('.timeline-heading');
            heading.addEventListener('click', () => {
                step.classList.toggle('active');
            });

            timelineContainer.appendChild(step);
        });

        lucide.createIcons();
    }
    renderItinerary();

    /* ==========================================================================
       FULLSCREEN LIGHTBOX SLIDESHOW
       ========================================================================== */
    const lightbox = document.getElementById('gallery-lightbox');
    const expandedImg = document.getElementById('lightbox-expanded-img');
    const captionTxt = document.getElementById('lightbox-caption-txt');
    const closeLightboxBtn = document.getElementById('lightbox-close-btn');
    const prevLightboxBtn = document.getElementById('lightbox-prev-btn');
    const nextLightboxBtn = document.getElementById('lightbox-next-btn');

    function openLightbox(index) {
        currentPhotoIndex = index;
        expandedImg.src = photosList[currentPhotoIndex];
        captionTxt.textContent = `Hình ảnh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
        lightbox.classList.add('active');
    }

    // Main photo click
    document.getElementById('gallery-main-img').addEventListener('click', () => openLightbox(0));

    // Thumbnails click
    subThumbnails.forEach((img, idx) => {
        img.addEventListener('click', () => openLightbox(idx + 1));
    });

    // View all button click
    const viewAllBtn = document.getElementById('view-all-photos-btn');
    if (viewAllBtn) {
        viewAllBtn.addEventListener('click', () => openLightbox(0));
    }

    // Close Lightbox
    if (closeLightboxBtn) {
        closeLightboxBtn.addEventListener('click', () => {
            lightbox.classList.remove('active');
        });
    }

    // Next Slide
    function nextSlide() {
        currentPhotoIndex = (currentPhotoIndex + 1) % photosList.length;
        expandedImg.src = photosList[currentPhotoIndex];
        captionTxt.textContent = `Hình ảnh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
    }

    // Prev Slide
    function prevSlide() {
        currentPhotoIndex = (currentPhotoIndex - 1 + photosList.length) % photosList.length;
        expandedImg.src = photosList[currentPhotoIndex];
        captionTxt.textContent = `Hình ảnh ${currentPhotoIndex + 1} / ${photosList.length} - ${activeTour.title}`;
    }

    if (nextLightboxBtn) nextLightboxBtn.addEventListener('click', nextSlide);
    if (prevLightboxBtn) prevLightboxBtn.addEventListener('click', prevSlide);

    // Keyboard support for Lightbox
    document.addEventListener('keydown', (e) => {
        if (!lightbox.classList.contains('active')) return;
        if (e.key === 'Escape') lightbox.classList.remove('active');
        if (e.key === 'ArrowRight') nextSlide();
        if (e.key === 'ArrowLeft') prevSlide();
    });

    // Play video simulated alert
    const playVideoBtn = document.getElementById('play-video-btn');
    if (playVideoBtn) {
        playVideoBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            alert("Đang tải video giới thiệu hành trình du lịch cao cấp của Mirai Travels...");
        });
    }

    /* ==========================================================================
       REVIEWS SECTION RENDER & ADD COMMENT FORM
       ========================================================================== */
    const reviewsListContainer = document.getElementById('reviews-list-container');
    const scorecardAvg = document.getElementById('scorecard-avg');
    const scorecardTotal = document.getElementById('scorecard-total');
    const newReviewForm = document.getElementById('new-review-form');
    const starsSelector = document.getElementById('stars-selector');
    
    // Reviews state
    let activeReviews = reviewsData[activeTour.id] || [...defaultReviews];
    let selectedRatingVal = 5; // Default 5 stars selected

    function renderReviews() {
        if (!reviewsListContainer) return;
        reviewsListContainer.innerHTML = '';
        
        let totalSum = 0;
        let starCounts = { 5: 0, 4: 0, 3: 0, 2: 0, 1: 0 };
        
        activeReviews.forEach(rev => {
            totalSum += rev.rating;
            const r = Math.round(rev.rating);
            if (starCounts[r] !== undefined) {
                starCounts[r]++;
            }
            
            const card = document.createElement('div');
            card.className = 'review-comment-card';

            let starsHtml = '';
            for (let i = 1; i <= 5; i++) {
                starsHtml += `<i data-lucide="star" class="${i <= rev.rating ? 'star-filled' : ''}"></i>`;
            }

            let verifiedHtml = rev.isVerified ? `
                <div class="verified-badge">
                    <i data-lucide="shield-check"></i>
                    <span>Đã trải nghiệm</span>
                </div>
            ` : '';

            let imgHtml = rev.image ? `
                <div class="review-comment-image-wrapper">
                    <img src="${rev.image}" alt="Ảnh hành khách chụp" class="review-comment-img" onclick="window.open('${rev.image}', '_blank')">
                </div>
            ` : '';

            card.innerHTML = `
                <div class="review-comment-header">
                    <div class="reviewer-info">
                        <img src="${rev.avatar}" alt="${rev.name}" class="reviewer-avatar">
                        <div class="reviewer-meta">
                            <span class="reviewer-name">${rev.name}</span>
                            <span class="reviewer-date">Đăng ngày: ${rev.date}</span>
                        </div>
                    </div>
                    <div class="reviewer-actions">
                        <div class="reviewer-stars-row">
                            ${starsHtml}
                        </div>
                        ${verifiedHtml}
                    </div>
                </div>
                <div class="review-comment-body">
                    <p>${rev.text}</p>
                    ${imgHtml}
                </div>
            `;

            reviewsListContainer.appendChild(card);
        });

        // Update Scorecard Avg
        const totalReviews = activeReviews.length;
        const avg = totalSum / (totalReviews || 1);
        scorecardAvg.textContent = avg.toFixed(1);
        scorecardTotal.textContent = `Dựa trên ${totalReviews} đánh giá khách hàng`;

        // Update Scorecard Distribution Bars
        for (let star = 1; star <= 5; star++) {
            const count = starCounts[star] || 0;
            const percent = totalReviews > 0 ? Math.round((count / totalReviews) * 100) : 0;
            
            const barItem = document.querySelector(`.rating-bar-item[data-star="${star}"]`);
            if (barItem) {
                const fillElement = barItem.querySelector('.rating-bar-fill');
                const percentText = barItem.querySelector('.rating-percent');
                
                if (fillElement) fillElement.style.width = `${percent}%`;
                if (percentText) percentText.textContent = `${percent}%`;
            }
        }

        lucide.createIcons();
    }
    renderReviews();

    // Star selector event using event delegation to support Lucide SVG replacement
    if (starsSelector) {
        starsSelector.addEventListener('click', (e) => {
            const star = e.target.closest('.star-select');
            if (!star) return;
            const rating = parseInt(star.getAttribute('data-rating'));
            selectedRatingVal = rating;
            
            const starIcons = starsSelector.querySelectorAll('.star-select');
            starIcons.forEach(s => {
                const r = parseInt(s.getAttribute('data-rating'));
                if (r <= rating) {
                    s.classList.add('active');
                } else {
                    s.classList.remove('active');
                }
            });
        });
        // Init 5 stars selected visually
        setTimeout(() => {
            const starIcons = starsSelector.querySelectorAll('.star-select');
            starIcons.forEach(s => s.classList.add('active'));
        }, 150);
    }

    // Simulator Upload image
    const uploadSimBtn = document.getElementById('upload-sim-btn');
    const uploadPreviewRow = document.getElementById('uploaded-images-preview-row');
    let simulatedUploadedImgUrl = '';

    if (uploadSimBtn) {
        uploadSimBtn.addEventListener('click', () => {
            // Simulated upload of a beautiful landscape image
            simulatedUploadedImgUrl = "https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?auto=format&fit=crop&w=400&q=80";
            if (uploadPreviewRow) {
                uploadPreviewRow.innerHTML = `
                    <div class="preview-img-wrapper">
                        <img src="${simulatedUploadedImgUrl}" alt="Ảnh xem trước">
                        <span class="remove-preview-btn" id="remove-preview-img-btn">&times;</span>
                    </div>
                `;
                document.getElementById('remove-preview-img-btn').addEventListener('click', () => {
                    uploadPreviewRow.innerHTML = '';
                    simulatedUploadedImgUrl = '';
                });
            }
        });
    }

    // LÝ DO VÀ CHỨC NĂNG CỦA ĐOẠN SUBMIT FORM ĐÁNH GIÁ (SUBMIT REVIEW FORM):
    // - Khi người dùng bấm nút gửi đánh giá, trình duyệt sẽ kích hoạt sự kiện submit này.
    // - Ta cần đọc biến `selectedRatingVal` (chứa số sao người dùng vừa chọn bằng cách click vào các ngôi sao trên giao diện).
    // - Gán giá trị sao này vào thẻ input ẩn `#review-rating-input` để nó được gửi đi cùng dữ liệu form POST.
    // - Chúng ta KHÔNG gọi `e.preventDefault()` để cho phép biểu mẫu tự động submit tự nhiên lên servlet
    //   DetailController (POST) lưu trữ vào cơ sở dữ liệu và tải lại trang chi tiết.
    if (newReviewForm) {
        newReviewForm.addEventListener('submit', (e) => {
            const ratingInput = document.getElementById('review-rating-input');
            if (ratingInput) {
                ratingInput.value = selectedRatingVal;
            }
            // Allow natural HTML form submission to backend DetailController doPost
        });
    }

    /* ==========================================================================
       FAQ INTERACTIVE ACCORDION
       ========================================================================== */
    const faqItems = document.querySelectorAll('.faq-item');
    faqItems.forEach(item => {
        const question = item.querySelector('.faq-question');
        question.addEventListener('click', () => {
            item.classList.toggle('active');
        });
    });

    /* ==========================================================================
       RELATED TOURS RENDER (3 other tours recommended)
       ========================================================================== */
    const relatedToursGrid = document.getElementById('related-tours-grid-container');

    function renderRelatedTours() {
        if (!relatedToursGrid) return;
        relatedToursGrid.innerHTML = '';
        
        // Pick three other tours
        const related = toursData.filter(t => t.id !== activeTour.id).slice(0, 3);

        related.forEach(tour => {
            const card = document.createElement('div');
            card.className = 'tour-card';
            card.setAttribute('data-id', tour.id);

            card.innerHTML = `
                <div class="tour-img-wrapper">
                    <img src="${tour.image}" alt="${tour.title}" class="tour-img">
                    <div class="tour-badge">
                        <span class="badge badge-featured">Tương Tự</span>
                    </div>
                </div>
                <div class="tour-details">
                    <div class="tour-location-badge">
                        <i data-lucide="map-pin"></i>
                        <span>${tour.location}</span>
                    </div>
                    <h3>${tour.title}</h3>
                    <div class="tour-footer">
                        <div class="tour-price">
                            <span class="price-label">Giá từ</span>
                            <span class="price-val">${formatPrice(tour.priceVND)}</span>
                        </div>
                        <button class="btn btn-primary btn-sm" onclick="window.location.href='detail?id=${tour.id}'">Xem Ngay</button>
                    </div>
                </div>
            `;
            relatedToursGrid.appendChild(card);
        });

        lucide.createIcons();
    }
    renderRelatedTours();

    /* ==========================================================================
       CURRENCY CHANGE LISTENER
       ========================================================================== */
    if (currSelect) {
        currSelect.addEventListener('change', () => {
            // Re-render prices, calculated items and related tours
            renderStaticPrices();
            runCalculations();
            renderRelatedTours();
            renderReviews(); // Stars/Prices formatting helper
        });
    }

    // Sharing button simulated
    const shareBtn = document.getElementById('share-btn');
    if (shareBtn) {
        shareBtn.addEventListener('click', () => {
            alert(`Đã sao chép liên kết chia sẻ hành trình:\n${window.location.href}`);
        });
    }

    // Wishlist detail button toggle
    const wishlistDetailBtn = document.getElementById('wishlist-detail-btn');
    if (wishlistDetailBtn) {
        wishlistDetailBtn.addEventListener('click', () => {
            wishlistDetailBtn.classList.toggle('active');
            const heartIcon = wishlistDetailBtn.querySelector('svg');
            if (wishlistDetailBtn.classList.contains('active')) {
                heartIcon.setAttribute('fill', 'currentColor');
                wishlistDetailBtn.innerHTML = `<i data-lucide="heart" fill="currentColor"></i> Đã lưu Yêu thích`;
            } else {
                heartIcon.setAttribute('fill', 'none');
                wishlistDetailBtn.innerHTML = `<i data-lucide="heart"></i> Lưu vào Yêu thích`;
            }
            lucide.createIcons();
        });
    }

    /* ==========================================================================
       MOBILE RESPONSIVE CONTROLS
       ========================================================================== */
    const mobileMenuToggle = document.getElementById('mobile-menu-toggle');
    const navMenu = document.getElementById('nav-menu');

    if (mobileMenuToggle && navMenu) {
        mobileMenuToggle.addEventListener('click', () => {
            if (navMenu.style.display === 'flex') {
                navMenu.style.display = 'none';
            } else {
                navMenu.style.display = 'flex';
                navMenu.style.flexDirection = 'column';
                navMenu.style.position = 'absolute';
                navMenu.style.top = '70px';
                navMenu.style.left = '0';
                navMenu.style.width = '100%';
                navMenu.style.backgroundColor = 'var(--bg-glass)';
                navMenu.style.backdropFilter = 'blur(12px)';
                navMenu.style.padding = '1.5rem var(--space-md)';
                navMenu.style.boxShadow = 'var(--shadow-lg)';
                navMenu.style.gap = '1rem';
                
                navMenu.querySelectorAll('.nav-link').forEach(link => {
                    link.style.color = 'var(--slate-800)';
                });
            }
        });
    }
});
