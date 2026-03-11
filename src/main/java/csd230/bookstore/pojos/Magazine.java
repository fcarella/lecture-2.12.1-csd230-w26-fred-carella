package csd230.bookstore.pojos;

import java.util.Date;

public class Magazine extends Publication {
    private int orderQty = 0;
    private Date currentIssue = new Date();

    public Magazine() {
    }

    public Magazine(int orderQty, Date currentIssue, String title, double price, int copies) {
        super(title, price, copies);
        this.orderQty = orderQty;
        this.currentIssue = currentIssue;
    }

    @Override
    public void initialize() {
        super.initialize(); // Title

        System.out.println("Enter Order Qty:");
        this.orderQty = getInput(0);

        System.out.println("Enter Current Issue Date (dd-MMM-yyyy):");
        this.currentIssue = getInput(new Date());

        super.initPriceCopies(); // Copies, Price
    }

    @Override
    public void edit() {
        super.edit(); // Title, Price, Copies

        System.out.println("Edit Order Qty [" + this.orderQty + "]:");
        this.orderQty = getInput(this.orderQty);

        System.out.println("Edit Issue Date [" + this.currentIssue + "]:");
        this.currentIssue = getInput(this.currentIssue);
    }

    @Override
    public void sellItem() {
        System.out.println("Selling Magazine: " + getTitle());
        setCopies(getCopies() - 1);
    }

    public int getOrderQty() { return orderQty; }
    public void setOrderQty(int o) { this.orderQty = o; }
    public Date getCurrentIssue() { return currentIssue; }
    public void setCurrentIssue(Date d) { this.currentIssue = d; }

    @Override
    public String toString() {
        return "Magazine{orderQty=" + orderQty + ", issue=" + currentIssue + ", " + super.toString() + "}";
    }
}
