package stripes.smscrew;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Properties;

import org.apache.log4j.Logger;

import net.sourceforge.stripes.action.FileBean;
import net.sourceforge.stripes.action.LocalizableMessage;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.validation.Validate;

import com.telkomsel.itvas.garudasmscrew.OutgoingSMS;
import com.telkomsel.itvas.garudasmscrew.PublishDataFile;
import com.telkomsel.itvas.garudasmscrew.PushEntry;
import com.telkomsel.itvas.garudasmscrew.PushType;
import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import com.telkomsel.itvas.webstarter.WebStarterProperties;

public class PublishActionBean extends WebStarterActionBean {
    @Validate(required=true)
    private FileBean publishFile;
    
    private String info;
    
    private Logger log = Logger.getLogger(PublishActionBean.class);

    public Resolution doRefund() {
    	Properties prop = WebStarterProperties.getInstance();
    	User user = getContext().getUser();
    	String destinationPath = prop.getProperty("publishFileDest");
    	SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
    	String fileName = formatter.format(new Date(System.currentTimeMillis())) + "-" + user.getUsername() + ".csv";
    	URI uri = null;
		try {
			uri = new URI(destinationPath + fileName);
		} catch (URISyntaxException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
    	File destFile = new File(uri);
		BufferedReader reader = null;
		boolean success = false;
    	try {
			publishFile.save(destFile);
			
			// Validasi isi batch file
			reader = new BufferedReader(new FileReader(destFile));
			String line = null;
			while ((line = reader.readLine()) != null) {
				if (!line.trim().equals("")) {
					String[] p = line.trim().split("\\|");
					if (p.length != 2) {
						throw new Exception("Invalid entry in data file : " + line);
					} else {
						PushEntry pe = new PushEntry();
						pe.setType(PushType.PUBLISH);
						pe.setMsisdn(p[0]);
						pe.setMessage(p[1]);
//						long createdId = pe.create();
						long createdId = 10;
						
						OutgoingSMS outSMS = new OutgoingSMS();
						outSMS.setTrxID(createdId);
						outSMS.setMsisdn(p[0]);
						outSMS.setMessage(p[1]);
						outSMS.create();
						
						String strLog = createdId + "|"
									+ p[0] + "|"
									+ p[1];
						log.info("Successfully process, resulting log : "
									+ strLog);
					}
				}
			}
			// TODO entry ke DB
			success = true;
			PublishDataFile pdf = new PublishDataFile();
			pdf.setOperator(user.getUsername());
			pdf.setOriginalFilename(publishFile.getFileName());
			pdf.setFilename(destFile.getAbsolutePath());
			pdf.setInfo(info);
			pdf.create();
			
			UserLogWriter.writeLog(user.getUsername(), "Execute Publish Schedule : " + publishFile.getFileName() + ",  successful");
			getContext().getMessages().add(
	                  new LocalizableMessage("/push/Publish.action.success", destFile.getName()));
				return new RedirectResolution("/push/Publish.jsp");
		} catch (IOException e) {
			e.printStackTrace();
			getContext().getMessages().add(
                  new LocalizableMessage("/push/Publish.action.failed", "I/O Exception"));
			destFile.delete();
			UserLogWriter.writeLog(user.getUsername(), "Execute Publish Schedule : " + publishFile.getFileName() + ",  failed");
			return new RedirectResolution("/push/Publish.jsp");
		} catch (Exception e) {
			e.printStackTrace();
			getContext().getMessages().add(
	                  new LocalizableMessage("/push/Publish.action.failed", e.getMessage()));
				destFile.delete();
			UserLogWriter.writeLog(user.getUsername(), "Execute Publish Schedule: " + publishFile.getFileName() + ",  failed");
			return new RedirectResolution("/push/Publish.jsp");
		} finally {
			if (reader != null) {
				try {
					reader.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			if (!success) {
				destFile.delete();
			}
		}
    }

	public FileBean getPublishFile() {
		return publishFile;
	}

	public void setPublishFile(FileBean batchFile) {
		this.publishFile = batchFile;
	}

	public String getInfo() {
		return info;
	}

	public void setInfo(String reason) {
		this.info = reason;
	}
}
