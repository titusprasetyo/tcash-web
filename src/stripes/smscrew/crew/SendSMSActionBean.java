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

public class SendSMSActionBean extends WebStarterActionBean {
    private String idCrew;
    
    private String message;
    
    @DefaultHandler
    public Resolution action() {
    	Connection conn = null;
    	String result = "";
    	try {
			conn = MysqlFacade.getConnection();
			String q = "INSERT INTO push_entry (ts, id_crew, push_type, message) VALUES (NOW(), ?, ?, ?)";
			QueryRunner qr = new QueryRunner();
			qr.update(conn, q, new Object[]{idCrew, PushType.FREE_MESSAGE.ordinal(), message});
			result = "Pesan sukses dikirimkan";
		} catch (Exception e) {
			log.error("Err in ViewCrewActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menampilkan data, coba ulangi beberapa saat lagi"));
			result = "Pesan gagal dikirimkan";
		} finally {
			DbUtils.closeQuietly(conn);
		}
    	getContext().getRequest().setAttribute("result", result);
		message = "";
    	return new ForwardResolution("/crew/SendSMS.jsp");
    }


	public String getIdCrew() {
		return idCrew;
	}


	public void setIdCrew(String idCrew) {
		this.idCrew = idCrew;
	}

	public String getMessage() {
		return message;
	}


	public void setMessage(String message) {
		this.message = message;
	}
}
