package com.telkomsel.itvas.webstarter;

import java.util.ArrayList;

public class Menu {
	private String title;
	private String link;
	private String eligibleRole;
	private boolean isVisible;
	private ArrayList<Menu> childs = new ArrayList<Menu>();
	
	private int id;
	
	public int getId() {
		return id;
	}
	public void setId(int id) {
		this.id = id;
	}
	public boolean isVisible() {
		return isVisible;
	}
	public void setVisible(boolean isVisible) {
		this.isVisible = isVisible;
	}
	public String getTitle() {
		return title;
	}
	public void setTitle(String title) {
		this.title = title;
	}
	public String getEligibleRole() {
		return eligibleRole;
	}
	public void setEligibleRole(String eligibleRole) {
		this.eligibleRole = eligibleRole;
	}
	public boolean isEligible(int roleID) {
		return (eligibleRole.indexOf(String.valueOf(roleID) + "|") != -1);
	}
	public String getLink() {
		return link;
	}
	public void setLink(String link) {
		this.link = link;
	}
	public void addChild(Menu m) {
		childs.add(m);
	}
	public int getChildCount() {
		return childs.size();
	}
	public ArrayList<Menu> getChilds() {
		return childs;
	}
	public void setChilds(ArrayList<Menu> childs) {
		this.childs = childs;
	}
}
