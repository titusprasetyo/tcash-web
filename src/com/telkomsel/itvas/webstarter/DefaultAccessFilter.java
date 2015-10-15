package com.telkomsel.itvas.webstarter;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.net.URLEncoder;
import java.util.HashSet;
import java.util.Hashtable;
//import java.util.Set;

public class DefaultAccessFilter implements Filter {
    private static java.util.Set<String> publicUrls = new HashSet<String>();

    static {
        publicUrls.add("/web-starter/Login.jsp");
        publicUrls.add("/web-starter/Exit.jsp");
        publicUrls.add("/Login.action");
        publicUrls.add("/Logout.action");
    }

    /** Does nothing. */
    public void init(FilterConfig filterConfig) throws ServletException { }

    public void doFilter(ServletRequest servletRequest,
                         ServletResponse servletResponse,
                         FilterChain filterChain) throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) servletRequest;
        HttpServletResponse response = (HttpServletResponse) servletResponse;
        if (request.getSession().getAttribute("user") != null) {
        	User user = (User) request.getSession().getAttribute("user");
        	user.updateSession(request.getRemoteAddr());
        	if (MenuManager.isEligible(request.getServletPath(), (User)request.getSession().getAttribute("user"))) {
        		filterChain.doFilter(request, response);
        	} else {
                String targetUrl = URLEncoder.encode(request.getServletPath(), "UTF-8");
                response.sendRedirect(
                        request.getContextPath() + "/web-starter/Login.jsp?targetUrl=" + targetUrl);
        	}
        }
        else if ( isPublicResource(request) ) {
            filterChain.doFilter(request, response);
        }
        else {
            // Redirect the user to the login page, noting where they were coming from
            String targetUrl = URLEncoder.encode(request.getServletPath(), "UTF-8");
            if (!request.getServletPath().startsWith("/Dashboard.jsp")) {
            	System.out.println(request.getServletPath());
	            response.sendRedirect(
	                    request.getContextPath() + "/Dashboard.jsp?targetUrl=" + targetUrl);
            } else {
            	response.sendRedirect(
	                    request.getContextPath() + "/web-starter/Login.jsp?targetUrl=" + targetUrl);
            }
        }
    }

    /**
     * Method that checks the request to see if it is for a publicly accessible resource
     */
    protected boolean isPublicResource(HttpServletRequest request) {
        String resource = request.getServletPath();

        return publicUrls.contains(request.getServletPath())
                || (!resource.endsWith(".jsp") && !resource.endsWith(".action"));
    }

    /** Does nothing. */
    public void destroy() { }
}
