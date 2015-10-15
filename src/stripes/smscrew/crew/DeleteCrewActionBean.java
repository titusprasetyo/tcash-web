package stripes.smscrew.crew;

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
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class DeleteCrewActionBean extends WebStarterActionBean {
    private String idCrew;
    
    private String name;
    
    private int orderBy;
    
    private String crewType;

    private String fleet;
    
    private String category;
    
    private String delIdCrew;
    
    @DefaultHandler
    public Resolution action() {
    	if (getContext().getRequest().getParameter("id") != null) {
    		idCrew = getContext().getRequest().getParameter("id");
    		name = "";
    		orderBy = 1;
    		category = crewType = fleet = "-1";
    	}
    	
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
			conn = MysqlFacade.getConnection();
			String q = null;
			q = "SELECT * FROM crew WHERE 1 ";
			if (idCrew != null && !idCrew.trim().equals("")) {
				q += " AND id='" + idCrew + "' ";
			}
			if (name != null && !name.trim().equals("")) {
				q += " AND name like '%" + name + "%' ";
			}
			
			if (!crewType.equals("-1")) {
				q += " AND (crew_type='"+crewType+"') ";
			}
			if (!fleet.equals("-1")) {
				q += " AND (fleet='"+fleet+"') ";
			}
			if (!category.equals("-1")) {
				q += " AND (category='"+category+"') ";
			}
			
			switch (orderBy) {
			case 1:
				q += " ORDER BY name";
				break;
			case 2:
				q += " ORDER BY name DESC";
				break;
			case 3:
				q += " ORDER BY id";
				break;
			case 4:
				q += " ORDER BY id DESC";
				break;
			}
			PreparedStatement ps = conn.prepareStatement(q);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> entry = new Hashtable<String, String>();
				entry.put("name", rs.getString("name"));
				entry.put("id", rs.getString("id"));
				entry.put("crew_type", rs.getString("crew_type"));
				entry.put("msisdn", rs.getString("msisdn"));
				result.add(entry);
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in ViewCrewActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menampilkan data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
    	getContext().getRequest().setAttribute("data", result);
    	getContext().getRequest().setAttribute("norderBy", orderBy);
    	getContext().getRequest().setAttribute("generateResult", 1);
		
    	return new ForwardResolution("/crew/ViewCrew.jsp");
    }


	public String getIdCrew() {
		return idCrew;
	}


	public void setIdCrew(String idCrew) {
		this.idCrew = idCrew;
	}


	public int getOrderBy() {
		return orderBy;
	}


	public void setOrderBy(int orderBy) {
		this.orderBy = orderBy;
	}


	public String getName() {
		return name;
	}


	public void setName(String name) {
		this.name = name;
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


	public String getDelIdCrew() {
		return delIdCrew;
	}


	public void setDelIdCrew(String delIdCrew) {
		this.delIdCrew = delIdCrew;
	}
}
