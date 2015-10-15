package stripes.smscrew.push;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

import org.apache.commons.dbutils.BasicRowProcessor;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.RowProcessor;
import org.apache.commons.dbutils.handlers.MapHandler;
import org.apache.commons.dbutils.handlers.MapListHandler;

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
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

public class SelectCrewActionBean extends WebStarterActionBean {
    private String searchCrew;
    
    @DefaultHandler
    public Resolution action() {
    	String q = null;
    	List<Map<String,String>> result = null;
    	try {
	    	if (searchCrew!= null && !searchCrew.trim().equals("")) {
	    		q = "SELECT id, name FROM crew WHERE name like ? ORDER BY name";
				result = (List<Map<String,String>>) MysqlFacade.getObject(q, new Object[] {"%" + searchCrew + "%"}, new MapListHandler());
	    	} else {
	    		q = "SELECT id,name  FROM crew ORDER BY name";
				result = (List<Map<String,String>>) MysqlFacade.getObject(q, null, new MapListHandler());
	    	}
    	} catch (SQLException e) {
    		System.out.println("eek");
    		e.printStackTrace();
		}
    	getContext().getServletContext().setAttribute("results", result);
    	getContext().getServletContext().setAttribute("test", "hasil test");
    	return new ForwardResolution("/push/SelectCrewView.jsp");
    }

	public String getSearchCrew() {
		return searchCrew;
	}

	public void setSearchCrew(String searchCrew) {
		this.searchCrew = searchCrew;
	}
}
