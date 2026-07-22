import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.stream.Stream;

public class FixAllEncoding {
    public static void main(String[] args) throws IOException {
        Path root = Paths.get("d:/K8/SWP391/Group1/TourBuddy/src");
        
        try (Stream<Path> paths = Files.walk(root)) {
            paths.filter(Files::isRegularFile)
                 .filter(p -> p.toString().endsWith(".jsp") || p.toString().endsWith(".java"))
                 .forEach(FixAllEncoding::processFile);
        }
        System.out.println("Hoan thanh convert encoding!");
    }
    
    private static void processFile(Path path) {
        try {
            // Đọc file bằng UTF-8
            String content = Files.readString(path, StandardCharsets.UTF_8);
            
            // Chỉ xử lý các file của Ngọc
            if (!content.contains("Minh Ngọc") && !content.contains("Minh Ng&#7885;c")) {
                return;
            }
            
            boolean isJsp = path.toString().endsWith(".jsp");
            
            StringBuilder sb = new StringBuilder();
            boolean changed = false;
            
            for (int i = 0; i < content.length(); i++) {
                char c = content.charAt(i);
                if (c > 127) {
                    changed = true;
                    if (isJsp) {
                        sb.append("&#").append((int) c).append(";");
                    } else {
                        sb.append(String.format("\\u%04x", (int) c));
                    }
                } else {
                    sb.append(c);
                }
            }
            
            if (changed) {
                Files.writeString(path, sb.toString(), StandardCharsets.UTF_8);
                System.out.println("Converted: " + path.toString());
            }
            
        } catch (Exception e) {
            // Bỏ qua các file lỗi hoặc không phải text
        }
    }
}
