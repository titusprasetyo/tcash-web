package com.telkomsel.itvas.webstarter;

import net.sourceforge.stripes.action.ActionBean;
import net.sourceforge.stripes.action.ActionBeanContext;

import java.util.Date;

import org.apache.log4j.Logger;

public abstract class WebStarterActionBean implements ActionBean {
	protected Logger log = Logger.getLogger(this.getClass());
    private WebStarterActionBeanContext context;

    public void setContext(ActionBeanContext context) {
        this.context = (WebStarterActionBeanContext) context;
    }

    /** Gets the ActionBeanContext set by Stripes during initialization. */
    public WebStarterActionBeanContext getContext() {
        return this.context;
    }
}
