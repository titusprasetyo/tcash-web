package stripes.smscrew.crew;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Hashtable;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;

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
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class EditCrewActionBean extends WebStarterActionBean {
    private String id;
    
    private String name;
    
    private String msisdn;
    
    private String msisdnOld;
    
    private String crewType;
    
    private String fleet;
    
    private String category;
    
    
    @DefaultHandler
    public Resolution action() {
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
    		conn = MysqlFacade.getConnection();
    		
    		String id = getContext().getRequest().getParameter("id");
    		
    		if (getContext().getRequest().getMethod().equals("POST")) {
    			String q = "UPDATE crew SET name=?, msisdn=?, msisdn_old=?, category=?, fleet=?, crew_type=? WHERE id=?";
    			QueryRunner qr = new QueryRunner();
    			qr.update(conn, q, new Object[]{name, msisdn, msisdnOld, category, fleet, crewType, id});
    			getContext().getRequest().setAttribute("msgResponse", "Crew updated");
        	}
    		
			String q = null;
			q = "SELECT * FROM crew WHERE id=?";
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, id);
			ResultSet rs = ps.executeQuery();
			name = msisdn = msisdnOld = category = crewType = fleet = "";
			if (rs.next()) {
				name = rs.getString("name");
				msisdn = rs.getString("msisdn");
				msisdnOld = rs.getString("msisdn_old");
				category = rs.getString("category");
				crewType = rs.getString("crew_type");
				fleet = rs.getString("fleet");
			}
			rs.close();
			ps.close();
			
			getContext().getRequest().setAttribute("id", id);
			getContext().getRequest().setAttribute("name", name);
			getContext().getRequest().setAttribute("msisdn", msisdn);
			getContext().getRequest().setAttribute("msisdnOld", msisdnOld);
			getContext().getRequest().setAttribute("category", category);
			getContext().getRequest().setAttribute("crewType", crewType);
			getContext().getRequest().setAttribute("fleet", fleet);
			
		} catch (Exception e) {
			log.error("Err in EditCrewActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal memproses data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
		
    	return new ForwardResolution("/crew/EditCrew.jsp");
    }


	public String getId() {
		return id;
	}


	public void setId(String idCrew) {
		this.id = idCrew;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
	}


	public String getMsisdn() {
		return msisdn;
	}


	public void setMsisdn(String msisdn) {
		this.msisdn = msisdn;
	}


	public String getMsisdnOld() {
		return msisdnOld;
	}


	public void setMsisdnOld(String msisdnOld) {
		this.msisdnOld = msisdnOld;
	}


	public String getCrewType() {
		return crewType;
	}


	public void setCrewType(String crewType) {
		this.crewType = crewType;
	}


	public String getFleet() {
		return fleet;
	}


	public void setFleet(String fleet) {
		this.fleet = fleet;
	}


	public String getCategory() {
		return category;
	}


	public void setCategory(String category) {
		this.category = category;
	}
}
