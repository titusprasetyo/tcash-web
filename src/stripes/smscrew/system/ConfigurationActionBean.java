package stripes.smscrew.system;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;

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
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class ConfigurationActionBean extends WebStarterActionBean {
	private List<Map<String, String>> configs;
	
    public Resolution action() {
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> data = new ArrayList<Hashtable<String,String>>();
    	
    	try {
    		conn = MysqlFacade.getConnection();
    		
    		if (getContext().getRequest().getMethod().equals("POST") && configs != null) {
    			QueryRunner qr = new QueryRunner();
        		String q = "UPDATE configuration SET value=? WHERE config=?";
        		for (Map<String, String> m : configs) {
        			qr.update(conn, q, new Object[]{m.get("value"), m.get("config")});
        		}
        		getContext().getServletContext().setAttribute("msgResult", "Configuration updated!");
        	}
    		
			String q = "SELECT * FROM configuration ORDER BY config";
			PreparedStatement ps = conn.prepareStatement(q);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> d = new Hashtable<String, String>();
				d.put("config", rs.getString("config"));
				d.put("description", rs.getString("description"));
				d.put("value", rs.getString("value"));
				data.add(d);
			}
			rs.close();
			ps.close();
		} catch (SQLException e) {
			e.printStackTrace();
		} finally {
			DbUtils.closeQuietly(conn);
		}
		getContext().getServletContext().setAttribute("data", data);
    	
    	return new ForwardResolution("/system/Configuration.jsp");
    }

	public List<Map<String, String>> getConfigs() {
		return configs;
	}

	public void setConfigs(List<Map<String, String>> configs) {
		this.configs = configs;
	}
}
