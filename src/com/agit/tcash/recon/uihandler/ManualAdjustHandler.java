package com.agit.tcash.recon.uihandler;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.sql.DataSource;

import com.telkomsel.itvas.webstarter.User;

public class ManualAdjustHandler extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private DataSource dataSource = null;
	private Connection connection = null;
	private PreparedStatement pstmt = null;
	private PreparedStatement pstmt2 = null;
	private String query = "";

	private void initDb() throws SQLException, NamingException {
		Context ctx = new InitialContext();
		dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/tsel_tunai");
		// dataSource = (DataSource) ctx.lookup("java:comp/env/jdbc/local");
		connection = dataSource.getConnection();
	}

	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		System.out.println("doGet()");

	}

	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		try {
			User userModel = (User) request.getSession(false).getAttribute("user");
			String user = userModel.getUsername();
			String cashid = request.getParameter("cashid");
			String comment = request.getParameter("comment");
			String batch = request.getParameter("batch");
			String bank = request.getParameter("bank");
			String journal = request.getParameter("journal");
			String dbcr = request.getParameter("dbcr");
			String amount = request.getParameter("amount");
			String description = request.getParameter("description");
			System.out.println("cashid : " + cashid);
			System.out.println("comment : " + comment);
			System.out.println("batch : " + batch);
			System.out.println("bank : " + bank);
			System.out.println("journal : " + journal);
			System.out.println("dbcr : " + dbcr);
			System.out.println("amount : " + amount);
			System.out.println("description : " + description);
			initDb();
			query = "update AG_T_BANK_STATEMENT set REFID=?, ADJ_COMMENT=?, ADJ_USER=?, reconstatus=1, DTSTMP=sysdate where BATCHID=? and AMOUNT=? and JOURNALID=? and BANKID=? and TXTYPE=? and trim(DESCRIPTION)=?";
			pstmt = connection.prepareStatement(query);
			pstmt.setString(1, cashid);
			pstmt.setString(2, comment);
			pstmt.setString(3, user);
			pstmt.setString(4, batch);
			pstmt.setBigDecimal(5, new BigDecimal(Double.valueOf(amount)));
			pstmt.setString(6, journal);
			pstmt.setString(7, bank);
			pstmt.setString(8, dbcr);
			pstmt.setString(9, description.trim());
			pstmt.execute();
			if ("d".equalsIgnoreCase(dbcr))
				query = "UPDATE merchant_cashout SET is_executed = '2', completion_date=sysdate where cashout_id=?";
			else
				query = "UPDATE merchant_deposit SET is_executed = '2', completion_date=sysdate where deposit_id=?";
			pstmt2 = connection.prepareStatement(query);
			pstmt2.setString(1, cashid);
			pstmt2.execute();
			request.setAttribute("message", "Manual Adjustment Success");
			request.getRequestDispatcher("./agit/recon_manual_adj_result.jsp").forward(request, response);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			request.setAttribute("message", "Manual Adjustment Fail due this Error : " + e.getMessage());
			e.printStackTrace();
		} finally {
			try {
				pstmt.close();
				pstmt2.close();
				connection.close();
			} catch (SQLException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}

		}

	}

}
