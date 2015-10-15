package tsel_tunai;

public class HexUtils{

    /**
     * Convert string with hexadecimal digits into int array.
     * Each two character in the string gives one byte value,
     * and four byte values gives one int value
     */
    public static int [] convertToInt(String s){
            // Length of string must be a multiplum of 8.
            if(s.length()%8 != 0)
                throw new RuntimeException("Error in HexUtils: size of string must be a multiplum of 8.");

        // Convert string to byte array
            byte b[] = convertToByte(s);

        int a[] = new int[s.length()/8];

            // Convert every four byte into one int.
            for(int i = 0; i < a.length; i++)
           a[i] = ( (convertToInt(b[i*4]) << 24) | (convertToInt(b[i*4+1]) << 16) |
                    (convertToInt(b[i*4+2]) << 8) | convertToInt(b[i*4 +3])) ;
        return a;
    }


    /**
     * Convert string with hexadecimal digits into byte array.
     * Each two character in the string gives one byte value:
     * "00" ->  0
     * "FF" -> 255
     */
    public static byte [] convertToByte(String s){
            // Length of string must be of even size.
            if(s.length()%2 == 1)
                throw new RuntimeException("Error in HexUtils: string "+ s +" must have even size");

            byte b[] = new byte[s.length()/2];

            for(int i = 0; i < b.length; i++)
           b[i] = stringToHex(s.substring(2*i, 2*i+2));
        return b;
    }

    /**
     * Converts two character string into byte values.
     * If one off the characters is not a hexadecimal digit a runtime
     * exception will be thrown.
     */
    public static byte stringToHex(String s){
            char c1 = s.charAt(0);
            char c2 = s.charAt(1);
            int i1 = Character.digit(c1,16);
            int i2 = Character.digit(c2,16);
            if(i1 < 0)
                throw new RuntimeException("Error in HexUtils: " + c1 + " is not a hexadimal digit");
            if(i2 < 0)
                throw new RuntimeException("Error in HexUtils: " + c2 + " is not a hexadimal digit");

            return (byte)(16*i1+i2);
    }


    /**
     * Convert byte array to string with hexdecimal values.
     */
    public static String convertToString(byte b[]){
            String s="";
            for(int i=0;i<b.length;i++)
                s+=hexToString(b[i]);
            return s.toUpperCase();
    }


    /**
     * Take one byte and convert into string with two hexadecimal digits.
     */
    public static String hexToString(byte b){

       int i = convertToInt(b);
       String s = Integer.toHexString(i);

       // If string length is only one we insert "0" at beginning.
       if(s.length()<2)
           return ("0"+s);
       else
           return s;
    }

    /**
     * Take one integer and convert into string with 8 hexadecimal digits.
     */
    public static String hexToString(int i){
            String s="";
        byte b1 = (byte)(i>>>24);
        s+= hexToString(b1);
        byte b2 = (byte)(i>>>16);
        s+= hexToString(b2);
        byte b3 = (byte)(i>>>8);
        s+= hexToString(b3);
        byte b4 = (byte)i;
        s+= hexToString(b4);
        return s;
    }

    /**
     *
     * Bytes in java are interpreted as values from -128 to 127.
     * We would like to interpret a byte as ranging from 0 to 255.
     *
     * The convertToInt method will take a byte and convert it to an
     * integer with values ranging from 0 to 255.
     *
     * Ex:
     * byte 11000000 will be promoted to int as 11111111 11111111 11111111 11000000
     * shifting 24 to left gives 11000000 00000000 00000000 00000000
     * and shifting unsigned 24 to right gives the desired value:
     * 00000000 00000000 00000000 11000000
     */
    public static int convertToInt(byte b){
            int i = b;
            i = i << 24;
            i = i >>> 24;
            return i;
    }

            public static String htoS(String in) {
                byte b[] = convertToByte(in);

                String res = "";
                for(int i=0; i<b.length;i++) {
                        //System.out.print((char)b[i]+":"+convertToInt(b[i])+" ");
                        res = res+((char)b[i]);
                }
                return res;
        }


        public static String stoH(String mess) {
      String r = "";
      String s = "";
      for(int i=0; i<mess.length(); i++) {
        s = hexToString((byte)mess.charAt(i));
        r += s;
      }
      return r.toUpperCase();
    }

        /**
     * Small testprogram to see if methods is working.
     */
    public static void main(String args[]){
            //String s ="C34C052CC0DA8D73451AFE5F03BE297F";
            String s ="303132";

            System.out.println("Original hexadecimal string:\n" + s+"\n");

            //byte b[] = convertToByte("C34C052CC0DA8D73451AFE5F03BE297F");
        byte b[] = convertToByte("3031322b");

        System.out.println("my hex to string :");
        String res = "";
        for(int i=0; i<b.length;i++) {
                System.out.print((char)b[i]+":"+convertToInt(b[i])+" ");
                res = res+((char)b[i]);
        }
        System.out.println();
        System.out.println("res: "+res);

        /*
        System.out.println("Converted into byte array ranging from 0 to 255:");

        for(int i =0;i<b.length;i++)
               System.out.print(convertToInt(b[i])+" ");

            */

        System.out.println("\n");

        System.out.println("The byte array converted back to string with hexidecimal digits:");
            System.out.println(convertToString(b));

            // Test that convertToInt method is working.
            //s = "2b7e1516";
            s = "28aed2a6";
           int a[] = convertToInt(s);
            System.out.println("Hexadeximal string "+s+" converted to int is: "+a[0] );

            // Test that hexToString works.
            System.out.println("The integer "+a[0] + " converted to hex string is: "+hexToString(a[0]));

        String dlr = "4D65737361676520666F72203038313332353639343839312C2077697468206964656"
                        +"E74696669636174696F6E2030343031333130313036313420686173206265656E2064656C6976657"
                        +"26564206F6E20323030342D30312D33312061742030313A30363A33312E";
        System.out.println("dlr: "+htoS(dlr));
        System.out.println(HexUtils.convertToInt("7FFFFFFF")[0]);

    }

}
