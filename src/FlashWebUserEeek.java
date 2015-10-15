import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;

import tsel_tunai.Util;


public class FlashWebUserEeek {
	public static void main (String[] args) {
		BufferedReader r = null;
		PrintWriter pw = null;
		
		try {
			r = new BufferedReader(new InputStreamReader(new FileInputStream("d:\\input.csv")));
			pw = new PrintWriter(new FileWriter("d:\\output.csv"));
			
			String line = null;
			while ((line = r.readLine()) != null) {
				String[] p = line.split(";");
				if (p.length>=5) {
					String out = "" + ";" +
						p[2] + ";" +
						Util.getMd5Digest(p[2]) + ";" +
						"1" + ";" +
						"PR" + ";" +
						"0000-00-00" + ";" +
						"0" + ";" +
						p[2] + ";" +
						p[1] + ";" +
						"" + ";" +
						"" + ";" +
						p[3] + ";" +
						p[4] + ";" +
						"0000-00-00";
					pw.println(out);
				}
			}
			
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		} finally {
			if (r != null) {
				try {
					r.close();
				} catch (IOException e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
			if (pw != null) {
				try {
					pw.close();
				} catch (Exception e) {
					// TODO Auto-generated catch block
					e.printStackTrace();
				}
			}
		}
	}
}
