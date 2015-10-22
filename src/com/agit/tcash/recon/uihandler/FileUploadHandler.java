package com.agit.tcash.recon.uihandler;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.Calendar;
import java.util.List;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.commons.io.FilenameUtils;

import com.agit.tcash.recon.dao.ParseDao;
import com.agit.tcash.recon.dao.ReconDao;
import com.agit.tcash.recon.model.UploadLog;
import com.agit.tcash.recon.parseworker.Parser;
import com.agit.tcash.recon.util.UploadUtils;
import com.telkomsel.itvas.webstarter.User;

/**
 * Servlet to handle File upload request from Client
 * 
 * @author Titus Adi Prasetyo - Agit ESD Telkomsel
 */
public class FileUploadHandler extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String UPLOAD_DIRECTORY;
	private String message = "";

	// @Override
	protected void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		System.out.println("doGet()");

	}

	// @Override
	protected void doPost(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {
		ServletContext servletContext = getServletContext();
		UPLOAD_DIRECTORY = servletContext.getRealPath(File.separator) + "uploadedFiles";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHms");
		String name = null;
		User userModel = (User) request.getSession(false).getAttribute("user");
		String user = userModel.getUsername();
		String datePart = sdf.format(Calendar.getInstance().getTime());
		System.out.println("doPost");
		System.out.println("User : " + user);
		String fileCOntent = "";
		// process only if its multipart content
		if (ServletFileUpload.isMultipartContent(request)) {
			System.out.println("isMultipartContent");
			try {
				List<FileItem> multiparts = new ServletFileUpload(new DiskFileItemFactory()).parseRequest(request);
				System.out.println("multiparts size : " + multiparts.size());
				for (FileItem item : multiparts) {
					System.out.println("isFormField: " + item.isFormField());
					if (!item.isFormField()) {
						name = new File(item.getName()).getName() + datePart;
						System.out.println("filename : " + name);
						System.out.println("UPLOAD DIRECTORY : " + UPLOAD_DIRECTORY);
						try {
							fileCOntent = item.getString();
							File f = new File(UPLOAD_DIRECTORY + File.separator + name);
							FileOutputStream fos = new FileOutputStream(f);
							byte[] contentInBytes = fileCOntent.getBytes();
							fos.write(contentInBytes);
							fos.flush();
							fos.close();
							// item.write(new File(UPLOAD_DIRECTORY +
							// File.separator + name));
						} catch (Exception e) {
							e.printStackTrace();
						}
						System.out.println("Succes write file to : " + UPLOAD_DIRECTORY + File.separator + name);
					}
				}
				// start import to DB
				save(UPLOAD_DIRECTORY + File.separator + name, user);
				//message = "File uploaded Successfuly";
				// File uploaded successfully
				request.setAttribute("message", message.trim());
			} catch (Exception ex) {
				request.setAttribute("message", "File Upload Failed due to " + ex.getMessage());
			}

		} else {
			request.setAttribute("message", "Sorry this Servlet only handles file upload request");
		}

		request.getRequestDispatcher("./agit/bank_statement_upload_result.jsp").forward(request, response);
		// response.sendRedirect("./agit/bank_statement_upload_result.jsp");

	}


	private void save(String filename, String uploadedBy) {
		// message += "Start reading file from " +
		// FilenameUtils.getName(filename) + "\n";
		SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddhhmmss");
		// String uuid = UploadUtils.generateUUID();
		String uuid = sdf.format(Calendar.getInstance().getTime());
		Parser parser = null;
		UploadLog log = null;
		ParseDao dao = null;
		ReconDao rdao = null;
		boolean reconResult = false;
		// save upload log table
		try {

			dao = new ParseDao();
			rdao = new ReconDao();
			if (dao.isParsed(UploadUtils.getChecksumString(filename))) {
				message = "File already processed before";
				return;
			}
			log = new UploadLog();
			log.setBatchID(uuid);
			log.setFilename(FilenameUtils.getName(filename));
			log.setChecksum(UploadUtils.getChecksumString(filename));
			log.setUploadedBy(uploadedBy);
			log.setDtStamp();
			dao.saveUploadLog(log);
			// message += "Saved to upload log table\n";
			try {
				// message += "Start parsing file\n";
				parser = new Parser();
				// message +=
				parser.doParse(filename, uuid);
				// Begin compare data
				reconResult = rdao.doRecon(uuid);
				if (!reconResult)
					message = "File uploaded and imported to DB succesfully but, Data comparison fail";
				else
					message = "File processed Successfuly";
			} catch (Exception e) {
				message = "Error Parsing file " + e.getMessage();
			}
		} catch (Exception e) {
			message = "Error saving to log table " + e.getMessage();
		}
	}

}