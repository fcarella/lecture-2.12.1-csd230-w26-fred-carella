package csd230.bookstore.pojos;

public class CashTill {
    private double runningTotal;

    public CashTill() {
        this.runningTotal = 0.0;
    }

    public void showTotal() {
        System.out.println("Current Cash Till Total: $" + runningTotal);
    }

    public void sellItem(SaleableItem item) {
        item.sellItem();
        runningTotal += item.getPrice();
        System.out.println("Added $" + item.getPrice() + " to till.");
    }

    public double getRunningTotal() {
        return runningTotal;
    }
}
