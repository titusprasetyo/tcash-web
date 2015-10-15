package com.telkomsel.itvas.garudasmscrew.enumeration;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

public class Category {
	private static List data;
	
	static {
		data = new ArrayList<Hashtable<String,String>>();
		
		Hashtable<String, String> d = new Hashtable<String, String>();
		d.put("label", "01");
		d.put("value", "01");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("label", "02");
		d.put("value", "02");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("label", "03");
		d.put("value", "03");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("label", "04");
		d.put("value", "04");
		data.add(d);
		d = null;
	}
	
	public List getEnumeration() {
		return data;
	}
}
