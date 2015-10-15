package stripes.smscrew.push;

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
import com.telkomsel.itvas.garudasmscrew.SmsGatewayConnector;
import com.telkomsel.itvas.util.EnumUtil;
import com.telkomsel.itvas.util.Util;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class ViewDetailedActionBean extends WebStarterActionBean {
    @DefaultHandler
    public Resolution action() {
    	String resend_id = getContext().getRequest().getParameter("resend_id");
    	if (resend_id != null) {
    		resendSingleSMS(resend_id);
    		String message = "SMS Resent!";
    		getContext().getServletContext().setAttribute("message", message);
    	}
    	
    	String id = getContext().getRequest().getParameter("id");
    	if (id == null) {
    		id = "";
    	}
    	Connection conn = null;
    	ArrayList<Hashtable<String, String>> result = new ArrayList<Hashtable<String,String>>();
    	try {
			conn = MysqlFacade.getConnection();
			String q = "SELECT * FROM single_sms_entry WHERE trx_id=? ORDER BY part_id";
			System.out.println("haiya : " + q);
			PreparedStatement ps = conn.prepareStatement(q);
			ps.setString(1, id);
			ResultSet rs = ps.executeQuery();
			while (rs.next()) {
				Hashtable<String, String> entry = new Hashtable<String, String>();
				entry.put("part_id", rs.getString("part_id"));
				entry.put("msisdn", rs.getString("msisdn"));
				entry.put("message", rs.getString("message"));
				String delivered = rs.getString("delivered");
				if (delivered == null) {
					delivered = "-";
				}
				String delivery_code = rs.getString("delivery_code");
				if (delivery_code == null) {
					delivery_code = "-";
				}
				String delivery_time = rs.getString("delivery_time");
				if (delivery_time == null) {
					delivery_time = "-";
				}
				String retry_count = rs.getString("retry_count");
				if (retry_count == null) {
					retry_count = "-";
				}
				String sent_time = rs.getString("sent_time");
				if (sent_time == null) {
					sent_time = "-";
				}
				entry.put("delivered", delivered);
				entry.put("delivery_code", EnumUtil.getDeliveryReport(delivery_code));
				entry.put("delivery_time", delivery_time);
				entry.put("retry_count", retry_count);
				entry.put("sent_time", sent_time);
				entry.put("id", rs.getString("id"));
				entry.put("single_sms_id", id);
				result.add(entry);
			}
			rs.close();
			ps.close();
		} catch (Exception e) {
			log.error("Err in ViewDetailedPushActionBean : " + e.getMessage(), e);
			getContext().getValidationErrors().addGlobalError(new SimpleError("Gagal menampilkan data, coba ulangi beberapa saat lagi"));
		} finally {
			DbUtils.closeQuietly(conn);
		}
    	getContext().getServletContext().setAttribute("data", result);
    	getContext().getServletContext().setAttribute("generateResult", 1);
		
    	return new ForwardResolution("/push/ViewDetailedPush.jsp");
    }

	private void resendSingleSMS(String resend_id) {
		SmsGatewayConnector sms = new SmsGatewayConnector();
		try {
			Long val = Long.parseLong(resend_id);
			sms.resendSingleSmsEntry(val);
		} catch (RuntimeException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
	}
}
