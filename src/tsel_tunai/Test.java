package tsel_tunai;

import java.net.*;

public class Test {
  public Test() throws Exception {

    String xml_msg = "%3Cwap-push%3E%3Curl%3Ehttp%3A%2F%2F10.1.89.197%2Fkoinapp%2Fdownload%2Fget.php%3Fid%3D2650341%3C%2Furl%3E%3Cmsisdn_sender%3E62811917695%3C%2Fmsisdn_sender%3E%3Cmsisdn_receipient%3E62811917695%3C%2Fmsisdn_receipient%3E%3Csid%3Epushmail1%3C%2Fsid%3E%3Ctext%3ESilakan+download.Utk+setting+gprs%2Cketik+%3A+GPRS+%2Ckrm+ke+6616%3C%2Ftext%3E%3Ctrx_id%3E2005071051088792426919%3C%2Ftrx_id%3E%3Ctrx_date%3E20070520000011%3C%2Ftrx_date%3E%3Ccontentid%3Epushmail_wappush%3C%2Fcontentid%3E%3C%2Fwap-push%3E";
    System.out.println(URLDecoder.decode(xml_msg, "UTF-8"));
  }

  public static void main(String[] args) throws Exception {
    Test test1 = new Test();

    String s = "2|pembayaran 1|pembayaran2";
    //String s = "1|pembayaran 1";
    //String s = "0|";
    //String s = "5|pemb_1|pemb_2|pemb_3|pemb_4|pemb_5";
    String tmp[] = s.split("\\|");
    System.out.println("len :" + tmp[0]);
    int len = Integer.parseInt(tmp[0]);
    int len_new = len+1;

    String tx = "pembayaran Rp.1000";
    String s_new="";
    String s_old="";
    String s2 [] = new String[len];
    if(len == 5) len = 4;
    for(int i=1; i<=len; i++){
      s_old = s_old+"|"+tmp[i];
    }

    if(len_new > 5) len_new = 5;

    s_new = len_new+"|"+tx+s_old;

    System.out.println("s_new :"+s_new+"end");


  }

}
