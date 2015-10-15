package stripes.smscrew.system;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Hashtable;

import org.apache.commons.dbutils.DbUtils;

import sun.util.logging.resources.logging;

import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.SimpleMessage;
import net.sourceforge.stripes.validation.SimpleError;
import net.sourceforge.stripes.validation.Validate;
import net.sourceforge.stripes.validation.ValidationError;
import net.sourceforge.stripes.validation.ValidationErrors;

import com.telkomsel.itvas.database.MysqlFacade;
import com.telkomsel.itvas.garudasmscrew.PushEntry;
import com.telkomsel.itvas.garudasmscrew.PushType;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.RoleType;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class ViewUserActionBean extends WebStarterActionBean {
    private String username;
    
    private String fullname;
    
    private int orderBy;
    
    private String role;
    
    @DefaultHandler
    public Resolution action() {
    	if (getContext().getRequest().getParameter("id") != null) {
    		username = getContext().getRequest().getParameter("id");
    		fullname = "";
    		orderBy = 1;
    		role = "-1";
    	}
    	
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
			conn = MysqlFacade.getConnection();
			String q = null;
			q = "SELECT * FROM tsel_webstarter_user WHERE 1 ";
			if (username != null && !username.trim().equals("")) {
				q += " AND username like '%" + username + "%' ";
			}
			if (fullname != null && !fullname.trim().equals("")) {
				q += " AND fullname like '%" + fullname + "%' ";
			}
			
			if (!role.equals("-1")) {
				q += " AND (id_role='"+role+"') ";
			}
			
			switch (orderBy) {
			case 1:
				q += " ORDER BY fullname";
				break;
			case 2:
				q += " ORDER BY fullname DESC";
				break;
			case 3:
				q += " ORDER BY username";
				break;
			case 4:
				q += " ORDER BY username DESC";
				break;
			}
			PreparedStatement ps = conn.prepareStatement(q);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> entry = new Hashtable<String, String>();
				entry.put("fullname", Util.nullSafeString(rs.getString("fullname")));
				entry.put("username", Util.nullSafeString(rs.getString("username")));
				entry.put("email", Util.nullSafeString(rs.getString("email")));
				entry.put("account_expiry", Util.nullSafeString(rs.getString("account_expiry")));
				entry.put("last_login_attempt", Util.nullSafeString(rs.getString("last_login_attempt")));
				RoleType r = RoleType.getRoleType(rs.getInt("id_role"));
				entry.put("role", r.getLabel());
				result.add(entry);
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in ViewUserActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menampilkan data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
    	getContext().getServletContext().setAttribute("data", result);
    	getContext().getServletContext().setAttribute("norderBy", orderBy);
    	getContext().getServletContext().setAttribute("generateResult", 1);
		
    	return new ForwardResolution("/system/ViewUser.jsp");
    }


	public int getOrderBy() {
		return orderBy;
	}


	public void setOrderBy(int orderBy) {
		this.orderBy = orderBy;
	}


	public String getFullname() {
		return fullname;
	}


	public void setFullname(String name) {
		this.fullname = name;
	}


	public String getUsername() {
		return username;
	}


	public void setUsername(String username) {
		this.username = username;
	}


	public String getRole() {
		return role;
	}


	public void setRole(String role) {
		this.role = role;
	}
}
