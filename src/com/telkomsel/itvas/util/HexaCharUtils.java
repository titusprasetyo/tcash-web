/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package com.telkomsel.itvas.util;
/**
 *
 * @author ITDEV03
 */
public class HexaCharUtils {

    public static String CharToHexa(String chr) {
        String hasilHexa = "";
        if (chr != null) {
            for (char ch : chr.toCharArray()) {
                hasilHexa += Integer.toHexString(ch);
            }
        }
        return hasilHexa;

    }
    
    public static String HexaToChar(String hex){
       String hexa="";
       if(hex != null && !"".equals(hex)){
           for(int b=0;b<hex.length()/2;b++){
               int i=Integer.parseInt(hex.substring(b*2, b*2+2),16);
               char ch=(char)i;
               hexa+=ch;
           }
       }
       return hexa;
    }
}
