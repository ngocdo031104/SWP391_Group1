import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.regex.*;

public class CleanJsp {

    public static void main(String[] args) throws IOException {
        Path startPath = Paths.get("d:\\K8\\SWP391\\Group1\\TourBuddy\\src\\frontend");
        
        Files.walkFileTree(startPath, new SimpleFileVisitor<Path>() {
            @Override
            public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                if (file.getFileName().toString().endsWith(".jsp")) {
                    processFile(file);
                }
                return FileVisitResult.CONTINUE;
            }
        });
        System.out.println("CleanJsp completed.");
    }

    private static void processFile(Path file) {
        try {
            byte[] bytes = Files.readAllBytes(file);
            String content = new String(bytes, StandardCharsets.UTF_8);
            boolean modified = false;

            String injectedHeader = "<%@ page pageEncoding=\"UTF-8\" contentType=\"text/html; charset=UTF-8\" language=\"java\" %>\n";
            if (content.startsWith(injectedHeader)) {
                // Find and remove any other <%@ page ... contentType="..." ... %>
                String rest = content.substring(injectedHeader.length());
                
                // Regex to match <%@ page ... %> that contains contentType
                Pattern p = Pattern.compile("<%@\\s*page\\s+[^>]*contentType=[\"'][^\"']+[\"'][^>]*%>", Pattern.CASE_INSENSITIVE);
                Matcher m = p.matcher(rest);
                
                if (m.find()) {
                    rest = m.replaceAll("");
                    content = injectedHeader + rest;
                    modified = true;
                    System.out.println("Removed duplicate page directive in: " + file);
                }
            }

            if (modified) {
                Files.write(file, content.getBytes(StandardCharsets.UTF_8));
            }
        } catch (Exception e) {
            System.err.println("Error processing file: " + file + " - " + e.getMessage());
        }
    }
}
