import com.sun.org.apache.bcel.internal.classfile.SourceFile;

import java.sql.*;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.Scanner;
import java.util.concurrent.TimeUnit;


public class ConnectToDB {


    private static void compose(Scanner scanner, Connection con) throws SQLException, InterruptedException {

            System.out.println("\n please enter number of recipients and their username\n");

            int n1 = scanner.nextInt();
            ArrayList<String> recipientsUsername = new ArrayList<>();
            String res;

            for (int i = 1; i <= n1; i++) {
                res = scanner.next();
                recipientsUsername.add(res);
            }
            for(int i=1 ; i<=3-n1; i++){

                recipientsUsername.add(null);
            }

            System.out.println("\n please enter number of cc recipients and their username\n");
            int n2 = scanner.nextInt();
            ArrayList<String> ccRecipientsUsername = new ArrayList<>();
            String res2;
            for (int i = 1; i <= n2; i++) {
                res2 = scanner.next();
                ccRecipientsUsername.add(res2);
            }
             for(int i=1 ; i<=3-n2; i++){

                ccRecipientsUsername.add(null);
             }


            System.out.println("\nplease enter the subject\n");
            String ignore = scanner.nextLine();
            String subject = scanner.nextLine();
           // System.out.println(subject);

            System.out.println("\nplease enter content\n");
            String content = new String();
            String ignore2;
            String line;

            System.out.println("enter number of lines you need for content");
            int n = scanner.nextInt();

            ignore2 = scanner.nextLine();

            for (int i = 0; i < n; i++) {


                line = scanner.nextLine();
                content = content + " " + line;


            }


            composeMailToUsernames(con, recipientsUsername.get(0), recipientsUsername.get(1),  recipientsUsername.get(2), ccRecipientsUsername.get(0), ccRecipientsUsername.get(1), ccRecipientsUsername.get(2), subject, content);

    }

    private static void composeMailToUsernames(Connection con, String r1_username,String r2_username,String r3_username,String ccr1_username, String ccr2_username,String ccr3_username, String entered_subject, String entered_content) throws SQLException, InterruptedException {

        CallableStatement cs=con.prepareCall("{CALL compose_Email(?,?,?,?,?,?,?,?)}");


        cs.setString(1,entered_subject);
        cs.setString(2,entered_content);
        cs.setString(3,r1_username);
        cs.setString(4,r2_username);
        cs.setString(5,r3_username);
        cs.setString(6,ccr1_username);
        cs.setString(7,ccr2_username);
        cs.setString(8,ccr3_username);
        cs.executeQuery();

        cs.close();



    }

    private static void inbox(Scanner scanner, Connection con) throws SQLException {



        limitedView(0, scanner, con,"inbox");

        System.out.println("\nif you want to see next page enter next else enter something\n");
        String next=scanner.next();
        int count=0;

        while(next.equals("next")){

            count+=10;
            limitedView(count, scanner, con,"inbox");
            System.out.println("\nif you want to see next page enter next else enter something\n");
            next=scanner.next();


        }





    }

    private static void limitedView(int offset,Scanner scanner, Connection con,String box) throws SQLException {


            if(box.equals("inbox")) {
                CallableStatement cs = con.prepareCall("{CALL view_inbox(?)}");
                cs.setInt(1, offset);
                ResultSet resultSet = cs.executeQuery();
                System.out.println("ID  from        subject        not read                 time\n\n");

                while (resultSet.next()) {


                    System.out.printf("%s  %s    %s             %d             %s \n", resultSet.getString(1), resultSet.getString(2), resultSet.getString(3), resultSet.getInt(4), resultSet.getString(5));


                }
            }else if(box.equals("sent")){

                CallableStatement cs = con.prepareCall("{CALL view_sent_Emails(?)}");
                cs.setInt(1,offset);
                ResultSet resultSet = cs.executeQuery();
                System.out.println("ID         subject        time\n\n");

                while (resultSet.next()) {


                    System.out.printf("%s      %s             %s \n", resultSet.getString(1), resultSet.getString(2), resultSet.getString(3));


                }
            }

    }

    private static void sent(Scanner scanner, Connection con) throws SQLException {


        limitedView(0, scanner, con,"sent");

        System.out.println("\nif you want to see next page enter next else enter something \n");
        String next=scanner.next();
        int count=0;

        while(next.equals("next")){

            count+=10;
            limitedView(count, scanner, con,"sent");
            System.out.println("\nif you want to see next page enter next else enter something\n");
            next=scanner.next();


        }



    }

    private static void readEmail(Scanner scanner, Connection con) throws SQLException{



            System.out.println("\n please enter the box inbox or sent\n\n");
            String box = scanner.next();

                CallableStatement cs = con.prepareCall("{CALL read_Email(?,?,?)}");
                System.out.println("\nenter ID of wanted email\n");
                String ID = scanner.next();
                cs.setString(1, ID);
                cs.setString(2,box);
                cs.registerOutParameter(3,Types.VARCHAR);
                ResultSet resultSet = cs.executeQuery();
                String res=cs.getString(3);

            if(res==null) {
                if (resultSet.next()) {


                    if (box.equals("inbox")) {
                        System.out.println("ID | sender_username | subject | deliver_time | content");
                        System.out.println(resultSet.getString(1) + " | " + resultSet.getString(2) + " | " + resultSet.getString(3) + " | " + resultSet.getString(4) + " | " + resultSet.getString(5));
                    } else if (box.equals("sent")) {

                        System.out.println("ID | subject | deliver_time | content");
                        System.out.println(resultSet.getString(1) + " | " + resultSet.getString(2) + " | " + resultSet.getString(3) + " | " + resultSet.getString(4));
                    }

                }
            }
             else{

                System.out.println(res);

             }

                cs.close();


    }

    private static void deleteAccount(Scanner scanner, Connection con) throws SQLException {

            CallableStatement cs = con.prepareCall("{CALL delete_account()}");
            cs.executeQuery();
    }

    private static void editInformation(Scanner scanner, Connection con) throws SQLException {


            CallableStatement callableStatement = con.prepareCall("{CALL edit_user_information(?,?,?,?,?,?,?,?,?,?)}");

            System.out.println("\npassword (must has at least 6 character of numbers and letters) (max 20)\n");
            String wantedPassword = scanner.next();

                System.out.println("\nsecurity mobile number (11 chars)\n");
                String securityMobileNumber = scanner.next();

                System.out.println("\nAddress (Max 512 chars)\n");
                String ignore = scanner.nextLine();
                String address = scanner.nextLine();


                System.out.println("\nfirst name (max 20)\n");
                String firstName = scanner.next();


                System.out.println("\nlast name (max 20)\n");
                String lastName = scanner.next();

                System.out.println("\nnickname (max 20)\n");
                String nickName = scanner.next();

                System.out.println("\ndate of birth (format year-month-date)  \n");
                String birthDate = scanner.next();

                System.out.println("\nmobile number  (11 chars)\n");
                String mobileNumber = scanner.next();

                System.out.println("\nnational ID (max 10)");
                String nationalID = scanner.next();


                    callableStatement.setString(1, wantedPassword);
                    callableStatement.setString(2, securityMobileNumber);
                    callableStatement.setString(3, address);
                    callableStatement.setString(4, firstName);
                    callableStatement.setString(5, lastName);
                    callableStatement.setString(6, nickName);
                    callableStatement.setString(7, birthDate);
                    callableStatement.setString(8, mobileNumber);
                    callableStatement.setString(9, nationalID);
                    callableStatement.registerOutParameter(10,Types.VARCHAR);
                    callableStatement.executeUpdate();
                    String output=callableStatement.getString(10);


                        System.out.println(output);



    }

    private static void grantAccessToUser(Connection con ,Scanner scanner) throws SQLException {

        System.out.println("\n enter username you want to give access");
        String accessedUsername = scanner.next();

            CallableStatement cs = con.prepareCall("{CALL grant_access_to_user (?,?)}");
            cs.setString(1, accessedUsername);
            cs.registerOutParameter(2,Types.VARCHAR);
            cs.executeUpdate();
            String output=cs.getString(2);
            cs.close();

            System.out.println(output);

        }

    private static void revokeAccessFromUser(Connection con ,Scanner scanner) throws SQLException {

        System.out.println("\n enter username you want to revoke access ");
        String revokedUsername = scanner.next();


            String output;
            CallableStatement cs = con.prepareCall("{CALL revoke_access_from_user (?,?)}");

            cs.setString(1, revokedUsername);
            cs.registerOutParameter(2,Types.VARCHAR);
            cs.executeUpdate();
            output=cs.getString(2);
            cs.close();

            System.out.println(output);


    }

    private  static void viewProfileOfOtherUser(Connection con ,Scanner scanner) throws SQLException {  ///////////check


        System.out.println("\nenter the username that you want to see\n");
        String userProfile=scanner.next();



            CallableStatement cs = con.prepareCall("{CALL view_profile_of_other_user(?,?)}");
            cs.setString(1, userProfile);
            cs.registerOutParameter(2,Types.VARCHAR);
            ResultSet resultSet=cs.executeQuery();
            String output=cs.getString(2);

            if (output==null) {
                if (resultSet.next()) {

                    System.out.printf("\n%s  %s  %s  %s  %s  %s  %s \n", resultSet.getString("first_name"), resultSet.getString("last_name"), resultSet.getString("nickname"), resultSet.getString("birth_date"), resultSet.getString("mobile_number"), resultSet.getString("address"), resultSet.getString("national_ID"));

                }
            }
            else{

                System.out.println(output);
            }


        }

    private static void deleteEmail(Scanner scanner, Connection con) throws SQLException{

            System.out.println("\nplease enter the box inbox or sent\n");
            String box=scanner.next();

                CallableStatement cs = con.prepareCall("{CALL delete_Email(?,?,?)}");
                System.out.println("enter ID of wanted email\n");
                String ID = scanner.next();

                cs.setString(1, ID);
                cs.setString(2, box);
                cs.registerOutParameter(3,Types.VARCHAR);
                cs.executeUpdate();
                String res=cs.getString(3);


                    System.out.println(res);


        }

    private static void notification(Scanner scanner, Connection con) throws SQLException {

        CallableStatement cs=con.prepareCall("{CALL view_notification()}");
        ResultSet r=cs.executeQuery();

        System.out.println("\nID         username             content                          receipt time\n");

        while (r.next()){

            System.out.println(r.getString(1)+"         "+r.getString(2)+"             "+r.getString(3)+"                          "+r.getString(4));


        }



    }

    private static void myInformation(Connection con) throws SQLException {


        CallableStatement cs=con.prepareCall("{CALL view_user_information()}");
        ResultSet r=cs.executeQuery();

        while (r.next()){


            System.out.println("username:"+r.getString(1)+" password: "+r.getString(2)+" creation_date "+r.getString(3)+" security mobile number: "+r.getString(4)+" address: "+r.getString(5)+" first name: "+r.getString(6)+" last name: "+r.getString(7)+" nickname"+r.getString(8)+" birth date: "+r.getString(9)+" mobile number: "+r.getString(10)+" national ID: "+r.getString(11));


        }



    }

    private static void actions(Scanner scanner, Connection con) throws SQLException, ParseException, InterruptedException {


        CallableStatement cs=con.prepareCall("{CALL Current_username(?)}");
        cs.registerOutParameter(1,Types.VARCHAR);
        cs.executeUpdate();
        String currentUser=cs.getString(1);
        cs.close();;

        System.out.println("Loged in as: "+currentUser);


        System.out.println("\n1.compose\n"+"2.inbox\n"+"3.sent\n"+"4.read\n"+"5.delete_account\n"+"6.edit_information\n"+"7.delete\n"+"8.grant_access_to_user\n"+"9.revoke_access_from_user\n"+"10.view_profile_of_Other_User\n"+"11.notification\n"+"12.my_information\n");
        System.out.println("\n Enter Operation if you want to exit enter exit\n");

        String input=scanner.next();

        while (!input.equals("exit")){

            switch (input){

                case "1":
                    compose(scanner,con);
                    break;

                case "2":
                    inbox(scanner,con);
                    break;

                case "3":
                    sent(scanner,con);
                    break;

                case "4":
                    readEmail(scanner,con);
                    break;

                case "5":
                    deleteAccount(scanner,con);
                    System.out.println("account deleted: "+currentUser);
                    return ;

                case "6":
                    editInformation(scanner,con);
                    break;
                case "7":
                        deleteEmail(scanner,con);
                        break;
                case "8":
                    grantAccessToUser(con,scanner);
                    break;
                case "9":
                    revokeAccessFromUser(con,scanner);
                    break;

                 case "10":
                     viewProfileOfOtherUser(con,scanner);
                     break;
                case "11":
                    notification(scanner,con);
                    break;
                case "12":
                    myInformation(con);
                    break;

            }

            System.out.println("\nEnter number of operation?\n");
            input=scanner.next();

        }



    }

    private static void register(Connection con, Scanner scanner) throws SQLException {

            System.out.println("\nPlease enter your information\n");

            System.out.println("username (must has at least 6 character of numbers and letters)(max 20)\n");

            String wantedUsername=scanner.next();

            System.out.println("\npassword (must has at least 6 character of numbers and letters(max 20)\n");
            String wantedPassword=scanner.next();


            System.out.println("\nsecurity mobile number (11 chars)\n");
            String securityMobileNumber=scanner.next();


            System.out.println("\nAddress (Max 512 chars)\n");
            String ignore=scanner.nextLine();
            String address=scanner.nextLine();

            System.out.println("\nfirst name (max 20)\n");
            String firstName=scanner.next();

            System.out.println("\nlast name (max 20)\n");
            String lastName=scanner.next();

            System.out.println("\nnickname (max 20)\n");
            String nickName=scanner.next();

            System.out.println("\ndate of birth (format year-month-date)  \n");
            String birthDate=scanner.next();

            System.out.println("\nmobile number  (11 chars)\n");
            String mobileNumber=scanner.next();

            System.out.println("\nnational ID (max 10)");
            String nationalID=scanner.next();

                    CallableStatement callableStatement = con.prepareCall("{CALL registerUser(?,?,?,?,?,?,?,?,?,?,?)}");
                    callableStatement.setString(1, wantedUsername);
                    callableStatement.setString(2, wantedPassword);
                    callableStatement.setString(3, securityMobileNumber);
                    callableStatement.setString(4, address);
                    callableStatement.setString(5, firstName);
                    callableStatement.setString(6, lastName);
                    callableStatement.setString(7, nickName);
                    callableStatement.setString(8, birthDate);
                    callableStatement.setString(9, mobileNumber);
                    callableStatement.setString(10, nationalID);
                    callableStatement.registerOutParameter(11,Types.VARCHAR);
                    callableStatement.executeUpdate();
                    String res=callableStatement.getString(11);
                    System.out.println(res);

    }

    private static int Login(Connection con, Scanner scanner) throws SQLException, ParseException, InterruptedException {

        System.out.println("\nPlease enter your username:\n");

        String enteredUsername=scanner.next();

            System.out.println("\nPlease enter your password\n");
            String enteredPassword=scanner.next();
            CallableStatement callableStatement=con.prepareCall("{CALL Login(?,?,?)}");
            callableStatement.setString(2,enteredPassword);
            callableStatement.setString(1,enteredUsername);
            callableStatement.registerOutParameter(3,Types.VARCHAR);
            callableStatement.executeUpdate();
            String res=callableStatement.getString(3);
            System.out.println(res);

            if (res.equals("Login successful")){

                actions(scanner,con);


            return 0;
            }else {

                return -1;
            }

    }

    public static void main(String[] args) throws ClassNotFoundException, SQLException, ParseException, InterruptedException {


        Class.forName("com.mysql.cj.jdbc.Driver");
        String url="jdbc:mysql://localhost:3306/foofle";
        Connection con= DriverManager.getConnection(url,"root","");

        if (con!=null){
            System.out.println("Welcome to Foofle\n");
            System.out.println("Please choose one of these actions\n\n");
            System.out.println("Register       Login \n");

            Scanner scanner=new Scanner(System.in);
            String input=scanner.next();

            if (input.equals("Register")){

                   register(con,scanner);

                    return;

            }

            else if (input.equals("Login")){

                //check in data base

               int res= Login(con,scanner);

               if(res!=0){

                   System.out.println("java: login completed successfully");

                   return;

               }



            }else{


                System.out.println("java: incorrect input");
            }



        }

    }


}
