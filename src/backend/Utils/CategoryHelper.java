package Utils;

import java.text.Normalizer;
import java.util.regex.Pattern;

public class CategoryHelper {

    /**
     * Chuyển đổi tên danh mục tiếng Việt có dấu thành slug không dấu, chữ thường và gạch nối.
     * Ví dụ: "Du lịch Mạo Hiểm" -> "du-lich-mao-hiem"
     */
    public static String toSlug(String input) {
        if (input == null || input.trim().isEmpty()) {
            return "all";
        }
        String temp = Normalizer.normalize(input, Normalizer.Form.NFD);
        Pattern pattern = Pattern.compile("\\p{InCombiningDiacriticalMarks}+");
        String slug = pattern.matcher(temp).replaceAll("")
                             .toLowerCase()
                             .replaceAll("[đđ]", "d")
                             .replaceAll("[^a-z0-9\\s-]", "")
                             .replaceAll("\\s+", "-")
                             .replaceAll("-+", "-")
                             .trim();
        return slug.isEmpty() ? "all" : slug;
    }

    /**
     * Tự động chọn icon Lucide phù hợp nhất dựa trên tên danh mục tiếng Việt/tiếng Anh.
     */
    public static String getIcon(String categoryName) {
        if (categoryName == null) {
            return "compass";
        }
        String lower = categoryName.toLowerCase();
        if (lower.contains("biển") || lower.contains("beach") || lower.contains("đảo") || lower.contains("vịnh")) {
            return "palmtree";
        } else if (lower.contains("núi") || lower.contains("trekking") || lower.contains("hiking") || lower.contains("leo núi")) {
            return "mountain";
        } else if (lower.contains("văn hóa") || lower.contains("di sản") || lower.contains("cultural") || lower.contains("lịch sử")) {
            return "landmark";
        } else if (lower.contains("mạo hiểm") || lower.contains("adventure") || lower.contains("khám phá")) {
            return "map";
        } else if (lower.contains("gia đình") || lower.contains("family") || lower.contains("mice") || lower.contains("đoàn")) {
            return "briefcase";
        } else if (lower.contains("cao cấp") || lower.contains("luxury") || lower.contains("nghỉ dưỡng")) {
            return "gem";
        } else if (lower.contains("ẩm thực") || lower.contains("food") || lower.contains("ăn uống")) {
            return "utensils";
        }
        return "compass"; // Fallback mặc định
    }
}
