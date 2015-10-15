package tsel_tunai;

import java.sql.*;

public class Ticket {
  private String msisdn;
  private String card_num;
  private String problem;
  private String priority;
  private String name;
  private String reporter;

  public void setMsisdn(String msisdn) {
    this.msisdn = msisdn;
  }

  public void setCard_num(String card_num) {
    this.card_num = card_num;
  }

  public void setProblem(String problem) {
    this.problem = problem;
  }

  public void setPriority(String priority) {
    this.priority = priority;
  }

  public void setName(String name) {
    this.name = name;
  }

  public void setReporter(String reporter) {
    this.reporter = reporter;
  }

  public String [] submit(){
    String ret[] = {"03", "internal_problem"};
    Connection con = null;
    try {

      con = DbCon.getConnection();
      String sql = "insert into problem_ticket(msisdn, card_no,  problem, priority, status, create_time, report_by)"
                  +" values(?, ?, ?, ?, ?, sysdate, ?)";
     PreparedStatement ps = con.prepareStatement(sql);
     ps.setString(1, this.msisdn);
     ps.setString(2, this.card_num);
     ps.setString(3, this.problem);
     ps.setString(4, this.priority);
     ps.setString(5, "0");
     ps.setString(6, this.reporter);
     ps.executeUpdate();
     ps.close();
     ret[0] = "00";
     ret[1] = "success";

    }catch(Exception e){
      e.printStackTrace(System.out);
    } finally {
      try { con.close(); } catch(Exception e2){}
    }


    return ret;
  }
  public Ticket() {
  }
  public static void main(String[] args) {
    Ticket ticket1 = new Ticket();
  }

}
