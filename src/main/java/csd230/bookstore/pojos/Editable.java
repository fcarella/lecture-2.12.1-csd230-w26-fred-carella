package csd230.bookstore.pojos;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.PrintStream;
import java.io.Serializable;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;
import java.util.Date;
import java.util.Locale;
import java.util.Scanner;

/**
 * @author fcarella
 */


public abstract class Editable implements Serializable, SaleableItem {
//    private Long id;


    public Scanner input = new Scanner(System.in);

    public abstract void edit();
    public abstract void initialize();
    // setInput, setOutput are used when unit testing
    // see https://stackoverflow.com/questions/1647907/junit-how-to-simulate-system-in-testing
    public void setSystemInput(ByteArrayInputStream testIn){
        System.setIn(testIn);
        input=new Scanner(System.in);
    }
    public void setSystemOutput(ByteArrayOutputStream testOut){
        System.setOut(new PrintStream(testOut));
    }

//    public Long getId() {
//        return id;
//    }
//
//    public void setId(Long id) {
//        this.id = id;
//    }


    public String getInput(String s) {
        String ss = input.nextLine();
        if (ss.trim().isEmpty()) {
            return s;
        }
        Scanner in2 = new Scanner(ss);
        return in2.nextLine();
    }

    public int getInput(int i) {
        String s = input.nextLine();
        if (s.trim().isEmpty()) {
            return i;
        }
        Scanner in2 = new Scanner(s);
        return in2.nextInt();
    }

    public double getInput(double i) {
        String s = input.nextLine();
        if (s.trim().isEmpty()) {
            return i;
        }
        Scanner in2 = new Scanner(s);
        return in2.nextDouble();
    }
    public boolean getInput(boolean b) {
        String s = input.nextLine();
        if (s.trim().isEmpty()) {
            return b;
        }
        Scanner in2 = new Scanner(s);
        return in2.nextBoolean();
    }

    public Date getInput(Date date) {
        String s = input.nextLine();
        if (s.trim().isEmpty()) {
            return date;
        }
        Scanner in2 = new Scanner(s);
//        String dateInString = "7-Jun-2013";
        String dateInString = in2.nextLine();
        // see https://www.baeldung.com/java-string-to-date
        SimpleDateFormat formatter = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
        Date d;
        try {
            d = formatter.parse(dateInString);
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
        return d;
    }
    public LocalDate getInput(LocalDate date) {
        String s = input.nextLine();
        if (s.trim().isEmpty()) {
            return date;
        }
        Scanner in2 = new Scanner(s);
//        String dateInString = "7-Jun-2013";
        String dateInString = in2.nextLine();
        // see https://www.baeldung.com/java-string-to-date
//        SimpleDateFormat formatter = new SimpleDateFormat("dd-MMM-yyyy", Locale.ENGLISH);
        LocalDate d;
        try {
            d = LocalDate.parse(s, DateTimeFormatter.ofPattern("dd-MMM-yyyy"));
        } catch (DateTimeParseException e) {
            throw e;
        }
        return d;
    }

    @Override
    public String toString() {
        return "Editable{" +
//                "id=" + id +
               '}';
    }
}