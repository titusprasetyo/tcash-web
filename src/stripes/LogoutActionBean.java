package stripes;

import com.telkomsel.itvas.webstarter.User;
import com.telkomsel.itvas.webstarter.UserLogWriter;
import com.telkomsel.itvas.webstarter.WebStarterActionBean;
import net.sourceforge.stripes.action.RedirectResolution;
import net.sourceforge.stripes.action.Resolution;

/**
 * Straightforward logout action that logs the user out and then sends to an exit page.
 * @author Tim Fennell
 */
public class LogoutActionBean extends WebStarterActionBean {
    public Resolution logout() throws Exception {
        User user = getContext().getUser();
        if (user != null && user.getUsername() != null) {
        	UserLogWriter.writeLog(user.getUsername(), "Logout successful");
        	user.killSession(getContext().getRequest().getRemoteAddr());
        }
        getContext().logout();
        return new RedirectResolution("/web-starter/Exit.jsp");
    }
}
