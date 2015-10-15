package stripes.smscrew.crew;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.Hashtable;

import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.handlers.ScalarHandler;

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

public class AddCrewActionBean extends WebStarterActionBean {
    private String id;
    
    private String name;
    
    private String msisdn;
    
    private String msisdnOld;
    
    private String crewType;
    
    private String fleet;
    
    private String category;
    
    public Resolution add() {
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
    		conn = MysqlFacade.getConnection();
    		
    		if (getContext().getRequest().getMethod().equals("POST")) {
    			String id = getContext().getRequest().getParameter("id");
    			QueryRunner qr = new QueryRunner();
    			
    			// Cek apakah sudah ada di database ato belum
        		String q = "SELECT id FROM crew WHERE id=?";
        		Object res = qr.query(conn, q, id, new ScalarHandler("id"));
        		if (res != null) { // ID udah ada
        			getContext().getValidationErrors().addGlobalError(new SimpleError("ID sudah sudah ada di database"));
        		} else {
        			q = "INSERT INTO crew(id, name, msisdn, msisdn_old, category, fleet_type, crew_type) VALUES(?,?,?,?,?,?,?)";
        			qr.update(conn, q, new Object[] {id, name, msisdn, msisdnOld, category, fleet, crewType});
        			getContext().getRequest().setAttribute("msgResponse", "Crew inserted");
        		}
        	}
    		
		} catch (Exception e) {
			log.error("Err in EditCrewActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal memproses data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
		
    	return new RedirectResolution("/crew/AddCrew.jsp");
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
