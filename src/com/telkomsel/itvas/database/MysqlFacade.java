package com.telkomsel.itvas.database;

import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import org.apache.commons.dbcp.ConnectionFactory;
import org.apache.commons.dbcp.DriverManagerConnectionFactory;
import org.apache.commons.dbcp.PoolableConnectionFactory;
import org.apache.commons.dbcp.PoolingDataSource;
import org.apache.commons.dbutils.DbUtils;
import org.apache.commons.dbutils.QueryRunner;
import org.apache.commons.dbutils.ResultSetHandler;
import org.apache.commons.dbutils.handlers.ScalarHandler;
import org.apache.log4j.Logger;
import org.apache.commons.pool.impl.GenericObjectPool;

import com.telkomsel.itvas.webstarter.WebStarterProperties;

/*
 * - A connection facade to MySQL Database
 * - Utilize apache tomcat datasource connection, or it also can be used as standalone
 * - Use dbutil package (from apache commons) to simplify query execution
 */
public class MysqlFacade {
	private InitialContext ctx;
	private DataSource ds;
	private GenericObjectPool connectionPool;
	private ConnectionFactory connectionFactory;
	private static MysqlFacade instance = null;

	private MysqlFacade() {
		try {
			ctx = new InitialContext();
			String dsName = WebStarterProperties.getInstance().getProperty(
					"jndi.datasource");
			ds = (DataSource) ctx.lookup(dsName);
		} catch (Exception e) {
			Logger
					.getLogger(MysqlFacade.class)
					.error(
							"Cannot initalize Context, try to using standalone DBCP",
							e);
		}
	}

	private MysqlFacade(String url, String username, String password) {
		connectionPool = new GenericObjectPool(null);
		try {
			Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}
		connectionPool.setMinIdle(2);
		connectionPool.setMaxActive(10);

		connectionFactory = new DriverManagerConnectionFactory(
				url, username, password);

		PoolableConnectionFactory poolableConnectionFactory = new PoolableConnectionFactory(
				connectionFactory, connectionPool, null, null, false, true);
		this.ds = new PoolingDataSource(connectionPool);
	}

	public static void initStandalone(String url, String username,
			String password) {
		if (instance == null) {
			instance = new MysqlFacade(url, username, password);
		}
	}

	public static Connection getConnection() throws SQLException {
		if (instance == null) {
			instance = new MysqlFacade();
		}
		if (instance.ds == null) {
			return null;
		}
		return instance.ds.getConnection();
	}
	
	public static void terminateFacade() {
		if (instance.connectionPool !=  null) {
			instance.connectionPool.clear();
		}
	}

	public static QueryRunner getQueryRunner() {
		if (instance == null) {
			instance = new MysqlFacade();
		}
		return new QueryRunner(instance.ds);
	}

	public static Object getScalar(String q, Object[] params, String columnName)
			throws SQLException {
		QueryRunner qr = getQueryRunner();
		Connection conn = null;
		Object result = null;
		try {
			conn = getConnection();
			result = qr.query(conn, q, params, new ScalarHandler(columnName));
		} catch (SQLException e) {
			throw e;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return result;
	}

	public static Object getObject(String q, Object[] params, ResultSetHandler handler)
			throws SQLException {
		QueryRunner qr = getQueryRunner();
		Connection conn = null;
		Object result = null;
		try {
			conn = getConnection();
			result = qr.query(q, params, handler);
		} catch (SQLException e) {
			throw e;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return result;
	}

	public static Object getScalar(String q, Object param, String columnName)
			throws SQLException {
		QueryRunner qr = getQueryRunner();
		Connection conn = null;
		Object result = null;
		try {
			conn = getConnection();
			result = qr.query(q, param, new ScalarHandler(columnName));
		} catch (SQLException e) {
			throw e;
		} finally {
			DbUtils.closeQuietly(conn);
		}
		return result;
	}

	public static int update(String q, Object[] params) throws SQLException {
		QueryRunner qr = getQueryRunner();
		Connection conn = null;
		try {
			conn = getConnection();
			return qr.update(conn, q, params);
		} catch (SQLException e) {
			throw e;
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}

	public static int update(String q, Object param) throws SQLException {
		QueryRunner qr = getQueryRunner();
		Connection conn = null;
		try {
			conn = getConnection();
			return qr.update(conn, q, param);
		} catch (SQLException e) {
			throw e;
		} finally {
			DbUtils.closeQuietly(conn);
		}
	}
}
