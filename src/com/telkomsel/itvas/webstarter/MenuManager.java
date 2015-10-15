package com.telkomsel.itvas.webstarter;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Iterator;
import java.util.TreeMap;

import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.TransformerFactoryConfigurationError;
import javax.xml.transform.dom.DOMResult;
import javax.xml.transform.stream.StreamSource;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;

public class MenuManager {
	private static ArrayList<Menu> menus;
	
	private static Hashtable<String, String> roleHash = new Hashtable<String, String>();
	
	private static Logger log = Logger.getLogger(MenuManager.class);
	
	static {
		BufferedReader reader = new BufferedReader(new InputStreamReader(MenuManager.class.getResourceAsStream("/ACL.properties")));
		String line = null;
		TreeMap<String, Menu> hashMenu = new TreeMap<String, Menu>();
		try {
			while ((line = reader.readLine()) != null) {
				String[] p = line.split(";");
				if (p.length == 5) {
					if (p[0].equals("root")) { // ROOT element
						Menu menu = new Menu();
						menu.setId(Integer.parseInt(p[1]));
						menu.setLink(p[2]);
						menu.setTitle(p[3]);
						menu.setEligibleRole(p[4]);
						hashMenu.put(p[1], menu);
					} else if (p[0].equals("none")) {
						roleHash.put(p[2], p[4]);
					} else {
						Menu menu = hashMenu.get(p[0]);
						if (menu != null) {
							Menu child = new Menu();
							child.setId(Integer.parseInt(p[1]));
							child.setLink(p[2]);
							child.setTitle(p[3]);
							child.setEligibleRole(p[4]);
							roleHash.put(p[2], p[4]);
							menu.addChild(child);
							hashMenu.put(p[0], menu);
						}
					}
				}
			}
			reader.close();
			menus = new ArrayList<Menu>();
			Collection<Menu> enumeration = hashMenu.values();
			Iterator<Menu >iteratorMenus = enumeration.iterator();
			while (iteratorMenus.hasNext()) {
				Menu m = iteratorMenus.next();
				menus.add(m);
			}
		} catch (IOException e) {
			log.fatal("Cannot read ACL properties", e);
		}
	}
	
	public static ArrayList<Menu> getEligibleMenus(int roleId, boolean isPasswordExpired) {
		ArrayList<Menu> eligibleMenus = new ArrayList<Menu>();
		for (Menu m : menus) {
			if (m.isEligible(roleId) && !isPasswordExpired) {
				eligibleMenus.add(m);
			}
		}
		Menu menu = new Menu();
		menu.setId(3);
		menu.setLink("/Logout.action");
		menu.setEligibleRole("1|2|3|4|");
		menu.setTitle("Logout");
		eligibleMenus.add(menu);

		return eligibleMenus;
	}

	public static Hashtable<String, String> getRoleHash() {
		return roleHash;
	}

	public static void setRoleHash(Hashtable<String, String> roleHash) {
		MenuManager.roleHash = roleHash;
	}

	public static boolean isEligible(String url, User user) {
		String strRole = roleHash.get(url);
		if (strRole == null) {
			return true;
		} else {
			return (strRole.indexOf(String.valueOf(user.getRole()) + "|") != -1);
		}
	}
}
