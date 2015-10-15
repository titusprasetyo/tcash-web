package com.telkomsel.itvas.garudasmscrew.enumeration;

import java.util.ArrayList;
import java.util.Hashtable;
import java.util.List;
import java.util.Map;

public class PullType {
	private static List data;
	
	static {
		data = new ArrayList<Hashtable<String,String>>();
		
		Hashtable<String, String> d = new Hashtable<String, String>();
		d.put("value", "5");
		d.put("label", "Pull Publish");
		data.add(d);
		d = null;

		d = new Hashtable<String, String>();
		d.put("value", "6");
		d.put("label", "Pull Schedule");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("value", "7");
		d.put("label", "Pull Check In");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("value", "8");
		d.put("label", "Pull Crew Per PID");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("value", "9");
		d.put("label", "Pull Free Message");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("value", "10");
		d.put("label", "Pull FAT");
		data.add(d);
		d = null;
		
		d = new Hashtable<String, String>();
		d.put("value", "11");
		d.put("label", "Pull MISC");
		data.add(d);
		d = null;
	}
	
	public List getEnumeration() {
		return data;
	}
}
