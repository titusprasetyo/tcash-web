package stripes.smscrew;

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

public class FtpFilesActionBean extends WebStarterActionBean {
    private String filename;
    
    @Validate(required=true, mask="[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}")
    private String startDate;
    
    @Validate(required=true, mask="[0-9]{1,2}-[0-9]{1,2}-[0-9]{4}")
    private String endDate;
    
    @Validate(required=true)
    private int orderBy;
    
    @DefaultHandler
    public Resolution action() {
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
			conn = MysqlFacade.getConnection();
			String q = null;
			q = "SELECT * FROM garuda_file WHERE 1 ";
			if (filename != null && !filename.trim().equals("")) {
				q += " AND id_crew like '%" + filename + "%' ";
			}
			q += " AND (ts BETWEEN '"+Util.formatMysqlDate(startDate)+" 00:00:00' AND '"+Util.formatMysqlDate(endDate)+" 23:59:59')";
			switch (orderBy) {
			case 1:
				q += " ORDER BY ts";
				break;
			case 2:
				q += " ORDER BY ts DESC";
				break;
			case 3:
				q += " ORDER BY filename";
				break;
			case 4:
				q += " ORDER BY filename DESC";
				break;
			}
			PreparedStatement ps = conn.prepareStatement(q);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> entry = new Hashtable<String, String>();
				entry.put("ts", rs.getString("ts"));
				entry.put("filename", rs.getString("filename"));
				result.add(entry);
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in FtpFilesActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menampilkan data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
    	getContext().getRequest().setAttribute("data", result);
    	getContext().getRequest().setAttribute("norderBy", orderBy);
    	getContext().getRequest().setAttribute("generateResult", 1);
		
    	return new ForwardResolution("/FtpFiles.jsp");
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

	public int getOrderBy() {
		return orderBy;
	}


	public void setOrderBy(int orderBy) {
		this.orderBy = orderBy;
	}

	public String getFilename() {
		return filename;
	}

	public void setFilename(String filename) {
		this.filename = filename;
	}
}
