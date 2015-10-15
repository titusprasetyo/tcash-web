package stripes.smscrew.pull;

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

public class ViewPullActionBean extends WebStarterActionBean {
    private String idCrew;
    
    @Validate(required=true, mask="[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}")
    private String startDate;
    
    @Validate(required=true, mask="[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}")
    private String endDate;
    
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
    
    private int pullType;
    
    @DefaultHandler
    public Resolution action() {
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
			conn = MysqlFacade.getConnection();
			String q = null;
			q = "SELECT * FROM push_entry a INNER JOIN pull_request b ON a.id=b.push_entry_id INNER JOIN crew c ON b.id_crew=c.id WHERE 1 ";
			if (idCrew != null && !idCrew.trim().equals("")) {
				q += " AND a.id_crew='" + idCrew + "' ";
			}
			if (delivered == 0) {
				q += " AND (nb_part>-1 AND nb_part<>nb_delivered) ";
			} else if (delivered == 1) {
				q += " AND (nb_part<>0 AND nb_part=nb_delivered) ";
			} else if (delivered == 2) {
				q += " AND (nb_part = -1) ";
			}
			
			q += " AND (b.ts BETWEEN '"+Util.formatMysqlDate(startDate)+" 00:00:00' AND '"+Util.formatMysqlDate(endDate)+" 23:59:59')";
			
			if (!crewType.equals("-1")) {
				q += " AND (c.crew_type='"+crewType+"') ";
			}
			
			if (!fleet.equals("-1")) {
				q += " AND (c.fleet='"+fleet+"') ";
			}
			
			if (!category.equals("-1")) {
				q += " AND (c.category='"+category+"') ";
			}
			
			if (pullType != -1) {
				q += " AND (push_type='"+pullType+"') ";
			}
			
			switch (orderBy) {
			case 1:
				q += " ORDER BY b.ts";
				break;
			case 2:
				q += " ORDER BY b.ts DESC";
				break;
			case 3:
				q += " ORDER BY a.id_crew";
				break;
			case 4:
				q += " ORDER BY a.id_crew DESC";
				break;
			}
			System.out.println("haiya : " + q);
			PreparedStatement ps = conn.prepareStatement(q);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> entry = new Hashtable<String, String>();
				entry.put("ts", rs.getString("ts"));
				entry.put("id_crew", rs.getString("id_crew"));
				entry.put("request_message", rs.getString("b.message"));
				entry.put("response_message", rs.getString("a.message"));
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
				entry.put("delivered", deliveryStatus);
				entry.put("deliveryCode", deliveryCode);
				entry.put("push_entry_id", rs.getString("push_entry_id"));
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
    	getContext().getServletContext().setAttribute("ndelivered", delivered);
    	getContext().getServletContext().setAttribute("norderBy", orderBy);
    	getContext().getServletContext().setAttribute("generateResult", 1);
		
    	return new ForwardResolution("/pull/ViewPull.jsp");
    }


	public String getIdCrew() {
		return idCrew;
	}


	public void setIdCrew(String idCrew) {
		this.idCrew = idCrew;
	}


	public String getStartDate() {
		return startDate;
	}


	public void setStartDate(String startDate) {
		this.startDate = startDate;
	}


	public String getEndDate() {
		return endDate;
	}


	public void setEndDate(String endDate) {
		this.endDate = endDate;
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


	public int getPullType() {
		return pullType;
	}


	public void setPullType(int pullType) {
		this.pullType = pullType;
	}
}
