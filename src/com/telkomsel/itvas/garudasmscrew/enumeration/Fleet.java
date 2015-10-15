package com.telkomsel.itvas.garudasmscrew.enumeration;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

public class Fleet {
	private static List data;
	
	static {
		data = new ArrayList<Hashtable<String,String>>();
		
		Hashtable<String, String> d = new Hashtable<String, String>();
		d.put("label", "F1");
		d.put("value", "1");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("label", "F2");
		d.put("value", "2");
		data.add(d);
		d = null;
	}
	
	public List getEnumeration() {
		return data;
	}
}
