package csd230.bookstore.pojos;

import java.util.Date;

public class DiscMag extends Magazine {
    private boolean hasDisc;

    public DiscMag() {
    }

    public DiscMag(boolean hasDisc, int orderQty, Date currentIssue, String title, double price, int copies) {
        super(orderQty, currentIssue, title, price, copies);
        this.hasDisc = hasDisc;
    }

    @Override
    public void initialize() {
        super.initialize(); // Title, Qty, Date, Copies, Price

        System.out.println("Has Disc? (true/false):");
        this.hasDisc = getInput(false);
    }

    @Override
    public void edit() {
        super.edit(); // Title, Price, Copies, OrderQty, Date

        System.out.println("Edit Has Disc [" + this.hasDisc + "]:");
        this.hasDisc = getInput(this.hasDisc);
    }

    @Override
    public void sellItem() {
        System.out.println("Selling Disc Magazine (Disc: " + hasDisc + ")");
        setCopies(getCopies() - 1);
    }

    public boolean isHasDisc() { return hasDisc; }
    public void setHasDisc(boolean h) { this.hasDisc = h; }

    @Override
    public String toString() {
        return "DiscMag{hasDisc=" + hasDisc + ", " + super.toString() + "}";
    }
}
