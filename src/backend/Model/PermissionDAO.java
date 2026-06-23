package Model;

import Entities.Permission;
import Utils.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class PermissionDAO extends DBContext {
    public List<Permission> getAllPermissions() {
        List<Permission> list = new ArrayList<>();
        String sql = "SELECT * FROM Permission";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Permission p = new Permission();
                p.setPermissionId(rs.getInt("PermissionID"));
                p.setModuleName(rs.getString("ModuleName"));
                p.setAction(rs.getString("Action"));
                p.setDescription(rs.getString("Description"));
                p.setIsCritical(rs.getBoolean("IsCritical"));
                list.add(p);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
