<%@ page language = "java" import = "java.io.*, java.util.*, java.text.*" %>

<%
		String strMonthNames[] = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"};

		int checkRowSpan = 0;

		String strYear = request.getParameter("year");
		String strMonth = request.getParameter("month");
		String strDay = request.getParameter("day");
		String strStartHour = request.getParameter("start");
		String strTotalHours = request.getParameter("total");
		Locale _locale=Locale.getDefault();

		java.util.Calendar gc = java.util.Calendar.getInstance(_locale);
		gc.setTime(new java.util.Date());

		if(strYear == null)
		{
			strYear = Integer.toString(gc.get(gc.YEAR));
		}

		if(strMonth == null)
		{
			strMonth = Integer.toString(gc.get(gc.MONTH)+1);
		}

		if(strDay == null)
		{
			strDay = Integer.toString(gc.get(gc.DATE));
		}

		if(strMonth.length() == 1)
		{
			strMonth = "0" + strMonth;
		}

		if(strDay.length() == 1)
		{
			strDay = "0" + strDay;
		}

		if(strStartHour  == null)
		{
			strStartHour = "0";
		}

		if(strTotalHours  == null)
		{
			strTotalHours = "24";
		}
%>

<html>
<head>
<title>Calendar</title>
<link rel=stylesheet type=text/css href="application.css">
<link rel=stylesheet type=text/css href="standard.css">
</head>
<body >
<TABLE border=0 cellpadding=0 cellspacing=0>
              <TR>
                <TD align=center vAlign=top width=120px >
<%
		String DATETIME_REQ_FORMAT = "yyyyMMdd";
		SimpleDateFormat sdf = new SimpleDateFormat(DATETIME_REQ_FORMAT);
		String fromdate=null;
		int nNoOfMonths=1;
		int nCurrentMonth;

		fromdate = strYear + strMonth + "01";
		java.util.Date from = new java.util.Date();
		java.util.Date to = new java.util.Date();

		nNoOfMonths = 1;

		if(fromdate!=null)
		{
			try
			{
				from = sdf.parse(fromdate);
			}
			catch(ParseException pe)
			{
			}
		}

		java.util.Calendar c_start = java.util.Calendar.getInstance(_locale);
		java.util.Calendar c_end = java.util.Calendar.getInstance(_locale);
		java.util.Calendar c_temp = java.util.Calendar.getInstance(_locale);

		c_start.setTime(from);

		c_temp.setTime(from);
		c_end.setTime(from);
		c_end.add(c_end.MONTH,nNoOfMonths);

		String strHol = null;

		while(nNoOfMonths > 0)
		{
			out.print("<table border=0 cellspacing=0 cellpadding=0>");
			out.print("<tr><td colspan=7 bgcolor=#000000 height=1><img src='image/space.jpg' height=1 border=0 ></td></tr>");
			out.print("<tr><td colspan='7' align='center' valign='top' bgcolor='#333333'><b>");

			c_start.add(c_start.YEAR,-1);
			out.print("<a href='cal2.jsp?day=" + c_start.get(c_start.DATE) + "&month="+ (c_start.get(c_start.MONTH) + 1) +"&year="+c_start.get(c_start.YEAR)+"' style='text-decoration: none'><font face=arial size=2 color=#FFFFFF><b><<</b></font></a>&nbsp;");
			c_start.add(c_start.YEAR,1);

			c_start.add(c_start.MONTH,-1);
			out.print("<a href='cal2.jsp?day=" + c_start.get(c_start.DATE) + "&month="+ (c_start.get(c_start.MONTH) + 1) +"&year="+c_start.get(c_start.YEAR)+"' style='text-decoration: none'><font face=arial size=2 color=#FFFFFF><b><</b></font></a>&nbsp;<font face=arial size=2 color='#ffffff'>"+strMonthNames[c_temp.get(c_temp.MONTH)]);
			out.print("&nbsp;"+c_temp.get(c_temp.YEAR) + "</font>&nbsp;");
			c_start.add(c_start.MONTH,1);

			c_start.add(c_start.MONTH,1);
			out.print("<a href='cal2.jsp?day=" + c_start.get(c_start.DATE) + "&month="+ (c_start.get(c_start.MONTH) + 1) +"&year="+c_start.get(c_start.YEAR)+"' style='text-decoration: none'><font face=arial size=2 color=#FFFFFF><b>></b></font></a>&nbsp;");
			c_start.add(c_start.MONTH,-1);

			c_start.add(c_start.YEAR,1);
			out.print("<a href='cal2.jsp?day=" + c_start.get(c_start.DATE) + "&month="+ (c_start.get(c_start.MONTH) + 1) +"&year="+c_start.get(c_start.YEAR)+"' style='text-decoration: none'><font face=arial size=2 color=#FFFFFF><b>>></b></font></a>");
			c_start.add(c_start.YEAR,-1);

			out.print("</b></td></tr>");
			out.print("<tr><td colspan=7 bgcolor=#000000 height=1><img src='image/space.jpg' height=1 border=0 ></td></tr>");
			out.print("<tr valign='bottom'><td align='center' style='font-size: 8pt'>S</td><td align='center' style='font-size: 8pt'>M</td><td align='center' style='font-size: 8pt'>T</td><td align='center' style='font-size: 8pt'>W</td><td align='center' style='font-size: 8pt'>T</td><td align='center' style='font-size: 8pt'>F</td><td align='center' style='font-size: 8pt'>S</td></tr>");
			out.print("<tr>");
			out.print("<tr><td colspan=7 bgcolor=#000000 height=1><img src='image/space.jpg' height=1 border=0 ></td></tr>");

			while(!c_temp.after(c_end))
			{
				if(c_temp.get(c_temp.DAY_OF_WEEK)  == c_temp.getFirstDayOfWeek())
				{
					out.print("</tr><tr>");
				}
				else
				{
					if(c_temp.get(c_temp.DAY_OF_MONTH) == 1)
					{
						out.print("</tr><tr>");
						for(int iDay = 1; iDay <= 7; iDay++)
						{
							if(c_temp.get(c_temp.DAY_OF_WEEK) > iDay)
							{
								out.print("<td></td>");
							}
						}
					}
				}

				out.print("<td align=center class=arialText");
				out.print("><a href='javascript:window.close();' style='text-decoration: none; color: #000000; font-size: 8pt' onClick='opener.document.formini.to.value=\""+c_temp.get(c_temp.DAY_OF_MONTH)+"-"+(c_temp.get(c_temp.MONTH)+1)+"-"+c_temp.get(c_temp.YEAR)+"\"'>");

				java.util.Calendar gcTemp = java.util.Calendar.getInstance(_locale);
				gcTemp.setTime(new java.util.Date());

				if(strHol != null)
				{
						out.print("<font color='#E20A17'>");
				}
				else
				{
					if(c_temp.get(c_temp.DAY_OF_WEEK) == 1)
					{
						out.print("<font color='#ff0000'>");
					}
					else
					{
						out.print("<font color='#000000'>");
					}
				}

				if(c_temp.get(c_temp.DAY_OF_MONTH) == Integer.parseInt(strDay) && (c_temp.get(c_temp.MONTH) + 1) == Integer.parseInt(strMonth))
				{
					out.print("<b>");
				}
				else
				{
					if(strHol != null)
					{
							out.print("<b>");
					}
				}
				if(c_temp.get(c_temp.DAY_OF_MONTH) == gcTemp.get(gcTemp.DAY_OF_MONTH) && c_temp.get(c_temp.MONTH) == gcTemp.get(gcTemp.MONTH) && c_temp.get(c_temp.YEAR) == gcTemp.get(gcTemp.YEAR))
					out.print("(");

				out.print(c_temp.get(c_temp.DAY_OF_MONTH));

				if(c_temp.get(c_temp.DAY_OF_MONTH) == gcTemp.get(gcTemp.DAY_OF_MONTH) && c_temp.get(c_temp.MONTH) == gcTemp.get(gcTemp.MONTH) && c_temp.get(c_temp.YEAR) == gcTemp.get(gcTemp.YEAR))
					out.print(")");

				if(c_temp.get(c_temp.DAY_OF_MONTH) == Integer.parseInt(strDay) && (c_temp.get(c_temp.MONTH) + 1) == Integer.parseInt(strMonth))
				{
					out.print("</b>");
				}
				else
				{
					if(strHol != null)
					{
						out.print("</b>");
					}
				}

				out.print("</font></a></td>");

				nCurrentMonth = c_temp.get(c_temp.MONTH);

				c_temp.add(c_temp.DATE,1);

				if(nCurrentMonth != c_temp.get(c_temp.MONTH))
				{
					break;
				}
			}

			out.print("<tr><td colspan=7 bgcolor=#000000 height=1><img src='image/space.jpg' height=1 border=0 ></td></tr>");
			out.print("</table>");
			nNoOfMonths--;
		}
%>
		</TD>
	</TR>
</TABLE>
</body>
</html>
