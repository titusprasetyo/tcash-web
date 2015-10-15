package stripes;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.UserManager;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;

import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;
import net.sourceforge.stripes.validation.LocalizableError;
import net.sourceforge.stripes.validation.Validate;
import net.sourceforge.stripes.validation.ValidationError;

public class LoginActionBean extends WebStarterActionBean {
    @Validate(required=true)
    private String username;

    @Validate(required=true)
    private String password;

    private String targetUrl;

    /** The username of the user trying to log in. */
    public void setUsername(String username) { this.username = username; }

    /** The username of the user trying to log in. */
    public String getUsername() { return username; }

    /** The password of the user trying to log in. */
    public void setPassword(String password) { this.password = password; }

    /** The password of the user trying to log in. */
    public String getPassword() { return password; }

    /** The URL the user was trying to access (null if the login page was accessed directly). */
    public String getTargetUrl() { return targetUrl; }

    /** The URL the user was trying to access (null if the login page was accessed directly). */
    public void setTargetUrl(String targetUrl) { this.targetUrl = targetUrl; }
    
    public Resolution login() {
        UserManager pm = new UserManager();
        User person = pm.getUser(this.username, password);
        
        if (person == null) {
        	int loginAttempt = pm.incLoginAttempt(this.username);
            ValidationError error = (loginAttempt <= 3) ? new LocalizableError("usernameDoesNotExist") : new LocalizableError("userBlock");
            getContext().getValidationErrors().add("username", error);
            UserLogWriter.writeLog(username, "Login failed");
            return getContext().getSourcePageResolution();
        }
        else {
            if (person.getLoginAttempt() > 3) {
            	ValidationError error = new LocalizableError("userBlock");
            	getContext().getValidationErrors().add("username", error);
            	UserLogWriter.writeLog(username, "Login failed, because the user is blocked");
                return getContext().getSourcePageResolution();
            } else if (person.getAccountExpiry() != null && person.isAccountExpired()) {
            	ValidationError error = new LocalizableError("userExpired");
            	getContext().getValidationErrors().add("username", error);
            	UserLogWriter.writeLog(username, "Login failed, because the user is expired");
                return getContext().getSourcePageResolution();
            } else if (person.isPasswordExpired()) {
            	person.updateLoginAttempt();
            	getContext().setUser(person);
            	UserLogWriter.writeLog(username, "Login successful");
            	return new RedirectResolution("/web-starter/ChangePassword.jsp");
            } else if (this.targetUrl != null) {
            	person.updateLoginAttempt();
            	getContext().setUser(person);
            	UserLogWriter.writeLog(username, "Login successful");
                return new RedirectResolution(this.targetUrl);
            } else {
            	person.updateLoginAttempt();
            	long nbSession = person.getNbSession();
            	if (nbSession <= 2) { 
	            	getContext().setUser(person);
	            	UserLogWriter.writeLog(username, "Login successful");
	                return new RedirectResolution("/Dashboard.jsp");
            	} else {
            		ValidationError error = new LocalizableError("userMaxSession");
                	getContext().getValidationErrors().add("username", error);
                	UserLogWriter.writeLog(username, "Login failed, maximum number of sessions (2) has been reached");
                    return getContext().getSourcePageResolution();
            	}
            }
    	}
    }
}
