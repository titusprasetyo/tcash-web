package stripes.smscrew;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.util.Locale;
import java.util.Properties;

import javax.servlet.http.HttpServletResponse;

import net.sourceforge.stripes.action.DefaultHandler;
import net.sourceforge.stripes.action.ForwardResolution;
import net.sourceforge.stripes.action.Message;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.action.StreamingResolution;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class FileStreamerActionBean extends WebStarterActionBean {
	@DefaultHandler
	public Resolution stream() {
		User user = getContext().getUser();
		String type = (String) getContext().getRequest().getParameter("type");
		String filename = (String) getContext().getRequest().getParameter(
				"filename");
		Properties prop = WebStarterProperties.getInstance();
		File fileData = null;
		try {
			if (type.equals("in")) {
				fileData = new File(new URI(prop.getProperty("batchFileDest")
						+ filename));
			} else {
				fileData = new File(new URI(prop
						.getProperty("batchFileOutputDest")
						+ filename));
			}
			if (!fileData.exists()) {
				getContext().getMessages().add(new Message() {
					public String getMessage(Locale arg0) {
						return "File not found";
					}
				});
				UserLogWriter.writeLog(user.getUsername(), "Download file : "
						+ fileData.getName() + ", failed");
				return new ForwardResolution("/refund/BatchView.jsp");
			}
		} catch (URISyntaxException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		BufferedReader reader = null;
		try {
			reader = new BufferedReader(new FileReader(fileData));
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		StreamingResolution retval = new StreamingResolution("text/csv", reader)
				.setFilename(filename);
		UserLogWriter.writeLog(user.getUsername(), "Download file : "
				+ fileData.getName() + ", successful");
		return retval;
	}
}
