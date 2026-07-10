import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;

public class FixEncoding {

    public static void main(String[] args) throws IOException {
        Path startPath = Paths.get("d:\\K8\\SWP391\\Group1\\TourBuddy\\src");
        
        Files.walkFileTree(startPath, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                String fileName = file.getFileName().toString();
                if (fileName.endsWith(".java") || fileName.endsWith(".jsp") || 
                    fileName.endsWith(".js") || fileName.endsWith(".html") || 
                    fileName.endsWith(".css") || fileName.endsWith(".properties")) {
                    
                    processFile(file);
                }
                return FileVisitResult.CONTINUE;
            }
        });
        
        System.out.println("Processing complete.");
    }

    private static void processFile(Path file) {
        try {
            byte[] bytes = Files.readAllBytes(file);
            String content = new String(bytes, StandardCharsets.UTF_8);
            boolean modified = false;

            // 1. Fix Mojibake
            String fixedContent = fixMojibake(content);
            if (!fixedContent.equals(content)) {
                content = fixedContent;
                modified = true;
                System.out.println("Fixed mojibake in: " + file);
            }

            // 2. JSP Configuration
            if (file.toString().endsWith(".jsp")) {
                if (!content.contains("pageEncoding=\"UTF-8\"")) {
                    String jspHeader = "<%@ page pageEncoding=\"UTF-8\" contentType=\"text/html; charset=UTF-8\" language=\"java\" %>\n";
                    content = jspHeader + content;
                    modified = true;
                    System.out.println("Added JSP UTF-8 header to: " + file);
                }
            }

            // 3. HTML Configuration
            if (file.toString().endsWith(".html")) {
                if (!content.contains("charset=\"UTF-8\"") && !content.contains("charset=UTF-8")) {
                    content = content.replaceFirst("<head>", "<head>\n    <meta charset=\"UTF-8\">");
                    modified = true;
                    System.out.println("Added HTML charset to: " + file);
                }
            }

            // 4. Servlet Configuration
            if (file.toString().endsWith(".java") && content.contains("@WebServlet")) {
                if (content.contains("protected void doGet(") && !content.contains("response.setCharacterEncoding(\"UTF-8\")")) {
                    content = content.replaceFirst("protected void doGet\\([^)]+\\)\\s*(throws [^{]+)?\\s*\\{", 
                        "$0\n        response.setContentType(\"text/html;charset=UTF-8\");\n        request.setCharacterEncoding(\"UTF-8\");\n        response.setCharacterEncoding(\"UTF-8\");");
                    modified = true;
                    System.out.println("Added Servlet doGet charset to: " + file);
                }
                if (content.contains("protected void doPost(") && !content.contains("request.setCharacterEncoding(\"UTF-8\")")) {
                    content = content.replaceFirst("protected void doPost\\([^)]+\\)\\s*(throws [^{]+)?\\s*\\{", 
                        "$0\n        response.setContentType(\"text/html;charset=UTF-8\");\n        request.setCharacterEncoding(\"UTF-8\");\n        response.setCharacterEncoding(\"UTF-8\");");
                    modified = true;
                    System.out.println("Added Servlet doPost charset to: " + file);
                }
            }

            if (modified) {
                Files.write(file, content.getBytes(StandardCharsets.UTF_8));
            }
        } catch (Exception e) {
            System.err.println("Error processing file: " + file + " - " + e.getMessage());
        }
    }

    private static String fixMojibake(String text) {
        // Known mojibake artifacts mapped back to UTF-8
        String[][] replacements = {
            {"LĂªn", "Lên"},
            {"lá»‹ch", "lịch"},
            {"gá»i", "gọi"},
            {"Sá»a", "Sửa"},
            {"Há»§y", "Hủy"},
            {"thĂ nh", "thành"},
            {"cĂ´ng", "công"},
            {"Ä‘", "đ"},
            {"Ă¡", "á"},
            {"Ă", "à"},
            {"Ă£", "ã"},
            {"áº£", "ả"},
            {"áº¡", "ạ"},
            {"Ăª", "ê"},
            {"áº¿", "ế"},
            {"á»", "ọ"},
            {"Ă´", "ô"},
            {"Ăº", "ú"},
            {"Ă¹", "ù"},
            {"á»§", "ủ"},
            {"Ă½", "ý"},
            {"Ă²", "ò"}
        };
        
        String result = text;
        
        // General programmatic double-encoding fix attempt
        try {
            byte[] encoded = text.getBytes("windows-1252");
            String decoded = new String(encoded, StandardCharsets.UTF_8);
            
            // If the decoded string contains valid Vietnamese characters and no replacement characters, it might be a clean fix.
            // But replacing specific known strings is safer.
        } catch (Exception e) {
            // fallback
        }
        
        // Manual replacements for the specific things we know are broken
        for (String[] rep : replacements) {
            result = result.replace(rep[0], rep[1]);
        }
        
        return result;
    }
}
