package Utils;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;

public class GoogleLoginUtil {

    // REPLACE WITH YOUR ACTUAL GOOGLE CLIENT ID AND SECRET
    public static final String CLIENT_ID = "125212965450-ksqfbqjnltlv8nqbc3ok0gtetc5551gr.apps.googleusercontent.com";
    public static final String CLIENT_SECRET = "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";
    public static final String REDIRECT_URI = "http://localhost:9999/TourBuddy/google-callback";

    public static String getToken(String code) throws Exception {
        String urlParameters = "code=" + code
                + "&client_id=" + CLIENT_ID
                + "&client_secret=" + CLIENT_SECRET
                + "&redirect_uri=" + REDIRECT_URI
                + "&grant_type=authorization_code";

        URL url = new URL("https://oauth2.googleapis.com/token");
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(urlParameters.getBytes(StandardCharsets.UTF_8));
        }

        try (InputStreamReader reader = new InputStreamReader(conn.getInputStream())) {
            JsonObject jsonObject = new Gson().fromJson(reader, JsonObject.class);
            return jsonObject.get("access_token").getAsString();
        }
    }

    public static JsonObject getUserInfo(String accessToken) throws Exception {
        String link = "https://www.googleapis.com/oauth2/v1/userinfo";
        URL url = new URL(link);
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        
        try (InputStreamReader reader = new InputStreamReader(conn.getInputStream())) {
            return new Gson().fromJson(reader, JsonObject.class);
        }
    }
}
