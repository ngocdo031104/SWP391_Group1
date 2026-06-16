package Utils;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

public class PasswordUtil {

    /**
     * Hash SHA-256
     */
    public static String hashPassword(String plainPassword) {

        try {

            MessageDigest md =
                    MessageDigest.getInstance("SHA-256");

            byte[] bytes =
                    md.digest(
                            plainPassword.getBytes(
                                    StandardCharsets.UTF_8));

            StringBuilder sb =
                    new StringBuilder();

            for (byte b : bytes) {
                sb.append(
                        String.format("%02x", b)
                );
            }

            return sb.toString();

        } catch (NoSuchAlgorithmException e) {

            throw new RuntimeException(e);
        }
    }

    /**
     * Verify password
     */
    public static boolean verifyPassword(
            String plainPassword,
            String storedHash) {

        return hashPassword(plainPassword)
                .equals(storedHash);
    }

    /**
     * Validate password
     */
    public static String validatePassword(String password) {

        if (password == null || password.trim().isEmpty()) {
            return "Mật khẩu không được để trống";
        }

        if (password.length() < 6) {
            return "Mật khẩu phải có ít nhất 6 ký tự";
        }

        return null;
    }
}