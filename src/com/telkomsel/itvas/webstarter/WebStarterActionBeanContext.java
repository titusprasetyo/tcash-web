package com.telkomsel.itvas.webstarter;

import net.sourceforge.stripes.action.ActionBeanContext;

/**
 * ActionBeanContext subclass for the Bugzooky application that manages where values
 * like the logged in user are stored.
 *
 * @author Tim Fennell
 */
public class WebStarterActionBeanContext extends ActionBeanContext {

    /** Gets the currently logged in user, or null if no-one is logged in. */
    public User getUser() {
        return (User) getRequest().getSession().getAttribute("user");
    }

    /** Sets the currently logged in user. */
    public void setUser(User currentUser) {
        getRequest().getSession().setAttribute("user", currentUser);
    }

    /** Logs the user out by invalidating the session. */
    public void logout() {
        getRequest().getSession().invalidate();
    }
}
