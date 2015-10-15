package stripes.smscrew.push;

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
import com.telkomsel.itvas.util.EnumUtil;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class ViewPublishActionBean extends WebStarterActionBean {
    private String idCrew;
    
    @Validate(required=true, mask="[0-9]{1,2}")
    private String month;
    
    @Validate(required=true, mask="[0-9]{4}")
    private String year;
    
    @Validate(required=true)
    private String periode;
    
    @Validate(required=true)
    private int delivered;
    
    @Validate(required=true)
    private int orderBy;
    
    @Validate(required=true)
    private String crewType;

    @Validate(required=true)
    private String fleet;
    
    @Validate(required=true)
    private String category;
    
    @DefaultHandler
    public Resolution action() {
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
			conn = MysqlFacade.getConnection();
			String q = null;
			q = "SELECT * FROM push_entry WHERE 1 ";
			if (idCrew != null && !idCrew.trim().equals("")) {
				q += " AND id_crew='" + idCrew + "' ";
			}
			q += " AND push_type='" + PushType.PUBLISH.ordinal() + "' ";
			
			if (delivered == 0) {
				q += " AND (nb_part>-1 AND nb_part<>nb_delivered) ";
			} else if (delivered == 1) {
				q += " AND (nb_part<>0 AND nb_part=nb_delivered) ";
			} else if (delivered == 2) {
				q += " AND (nb_part = -1) ";
			}
			
			if (month.length() == 1) {
				month = "0" + month;
			}
			String publishCode = month + year;
			if (!periode.equals("-1")) {
				publishCode += periode;
			} else {
				publishCode += "_";
			}
			
			if (!crewType.equals("-1")) {
				publishCode += crewType;
			} else {
				publishCode += "_";
			}
			
			if (!fleet.equals("-1")) {
				publishCode += fleet;
			} else {
				publishCode += "_";
			}
			
			if (!category.equals("-1")) {
				if (category.length() == 1) {
					category = "0" + category;
				}
				publishCode += category;
			} else {
				publishCode += "__";
			}
			
			q += " AND code_push LIKE '"+publishCode+"______%'";
			
			switch (orderBy) {
			case 1:
				q += " ORDER BY ts";
				break;
			case 2:
				q += " ORDER BY ts DESC";
				break;
			case 3:
				q += " ORDER BY id_crew";
				break;
			case 4:
				q += " ORDER BY id_crew DESC";
				break;
			}
			System.out.println("haiya : " + q);
			PreparedStatement ps = conn.prepareStatement(q);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> entry = new Hashtable<String, String>();
				entry.put("ts", rs.getString("ts"));
				entry.put("id_crew", rs.getString("id_crew"));
				entry.put("push_type", EnumUtil.getPushType(rs.getString("push_type")));
				entry.put("message", rs.getString("message"));
				entry.put("code_push", rs.getString("code_push"));
				entry.put("nb_part", rs.getString("nb_part"));
				entry.put("nb_delivered", rs.getString("nb_delivered"));
				String deliveryStatus = null;
				String deliveryCode = "";
				if (rs.getInt("nb_part") !=0 && (rs.getInt("nb_part") == rs.getInt("nb_delivered"))) {
					deliveryStatus = "Delivered";
					deliveryCode = "1";
				} else if (rs.getInt("nb_part") == -1) {
					deliveryStatus = "Incorrect Crew Data";
					deliveryCode = "2";
				} else {
					deliveryStatus = "Not Delivered Yet";
					deliveryCode = "0";
				}
				String notes = null;
				if (rs.getString("notes") == null) {
					notes = "";
				} else {
					notes = rs.getString("notes");
				}
				entry.put("delivered", deliveryStatus);
				entry.put("deliveryCode", deliveryCode);
				entry.put("id", rs.getString("id"));
				entry.put("notes", notes);
				result.add(entry);
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in ViewPushActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menampilkan data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
    	getContext().getServletContext().setAttribute("data", result);
    	getContext().getServletContext().setAttribute("nperiode", periode);
    	getContext().getServletContext().setAttribute("ndelivered", delivered);
    	getContext().getServletContext().setAttribute("norderBy", orderBy);
    	getContext().getServletContext().setAttribute("generateResult", 1);
		
    	return new ForwardResolution("/push/ViewPublish.jsp");
    }


	public String getIdCrew() {
		return idCrew;
	}


	public void setIdCrew(String idCrew) {
		this.idCrew = idCrew;
	}


	public String getStartDate() {
		return month;
	}


	public void setStartDate(String startDate) {
		this.month = startDate;
	}


	public String getEndDate() {
		return year;
	}


	public void setEndDate(String endDate) {
		this.year = endDate;
	}

	public int getDelivered() {
		return delivered;
	}


	public void setDelivered(int delivered) {
		this.delivered = delivered;
	}


	public int getOrderBy() {
		return orderBy;
	}


	public void setOrderBy(int orderBy) {
		this.orderBy = orderBy;
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


	public String getMonth() {
		return month;
	}


	public void setMonth(String month) {
		this.month = month;
	}


	public String getYear() {
		return year;
	}


	public void setYear(String year) {
		this.year = year;
	}


	public String getPeriode() {
		return periode;
	}


	public void setPeriode(String periode) {
		this.periode = periode;
	}
}
