package com.telkomsel.itvas.util;

import com.telkomsel.itvas.garudasmscrew.PushType;

public class EnumUtil {
	public static String getDeliveryReport(String code) {
		if (code.equals("1")) {
			return "Delivered";
		} else if (code.equals("2")) {
			return "Delivery Failed";
		} else if (code.equals("4")) {
			return "SMS buffered";
		} else if (code.equals("8")) {
			return "SMSC accepted for delivery";
		} else if (code.equals("16")) {
			return "SMSC Rejected";
		} else {
			return "Undefined";
		}
	}
	
	public static String getPushType(String code) {
		int i = -1;
		try {
			i = Integer.parseInt(code);
		} catch (NumberFormatException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		if (i == -1) {
			return code;
		} else {
			PushType p = PushType.values()[i];
			return p.toString();
		}
	}
}
