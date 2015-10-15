package com.telkomsel.itvas.webstarter;

public class WebStarterUtil {
	public static boolean isPasswordValid(String password) {
		return (
			(password != null) &&
			password.matches("^(?=.*\\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[!@#$%^&*])(?!.*\\s).*$") &&
			(password.length() >= 8)
		);
	}
}
