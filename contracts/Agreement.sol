pragma solidity ^0.4.18;

contract Agreement {

    address public owner;
    address public buyerAddress;

    // The Buyer struct
    struct Buyer {
        address addr;
        string name;

        bool init;
    }

    // The Shipment struct
    struct Shipment {
        address courier;
        uint price;
        uint safePay;
        address payer;
        uint date;
        uint deliveryDate;

        bool init;
    }

    // The Order struct
    struct Order {
        string product;
        uint quantity;
        string location;
        uint number;
        uint phoneNumber;
        uint price;
        uint safePay;
        string comment;
        Shipment shipment;

        bool init;
    }

    // The Invoice struct
    struct Invoice {
        uint orderNo;
        uint number;

        bool init;
    }

    // The mapping to store orders
    mapping (uint => Order) orders;

    // The mapping to store invoices
    mapping (uint => Invoice) invoices;

    // Events for actions
    uint orderSeq;
    uint invoiceSeq;
    event OrderSent(address buyer, string product, uint quantity, string location, uint orderNo);
    event PriceSent(address buyer, uint orderNo, uint priceForProduct, uint priceForDelivery, uint deliveryDate);
    event SafePaySent(address buyer, uint orderNo, uint value, uint phoneNumber, uint now);
    event InvoiceSent(address buyer, uint invoiceNo, uint orderNo, uint deliveryDate, address courier);
    event OrderDelivered(address buyer, uint invoiceNo, uint orderNo, uint realDeliveredDate, address courier);
    event CommentSend(address buyer, uint orderNo, uint date, string comment);

    // Constructor
    function Agreement(address _buyerAddress) public payable {
        owner = msg.sender;
        buyerAddress = _buyerAddress;
    }

    //  Buyer send order to seller
    function sendOrder(string product, uint quantity, string location) payable public {
        require(msg.sender == buyerAddress);
        orderSeq++;

        // Create the order
        orders[orderSeq] = Order(product, quantity, location, orderSeq, 0, 0, 0, "",Shipment(0, 0, 0, 0, 0, 0, false), true);

        // Call an event
        OrderSent(msg.sender, product, quantity, location, orderSeq);
    }

    //   The function to query orders by number
    function queryOrder(uint number) constant public returns (address, string, uint, string, uint, uint, uint, string) {
        require(orders[number].init);

        Order memory orderStruct;
        orderStruct = orders[number];

        // Return the order data
        return(buyerAddress, orderStruct.product, orderStruct.quantity, orderStruct.location, orderStruct.price, orderStruct.shipment.price, orderStruct.safePay, orderStruct.comment);
    }

    //  Owner send the price for product/delivery to pay for order
    function sendPrice(uint orderNo, uint priceForProduct, uint priceForDelivery, uint deliveryDate) payable public {
        require(msg.sender == owner);
        require(orders[orderNo].init);

        orders[orderNo].price = priceForProduct;
        orders[orderNo].shipment.price = priceForDelivery;
        orders[orderNo].shipment.init = true;
        orders[orderNo].shipment.date  = deliveryDate;

        // Call an event
        PriceSent(buyerAddress, orderNo, priceForProduct, priceForDelivery, deliveryDate);
    }

    //  Buyer send the value of order's price and it will be blocked until the delivery of order
    function sendSafePay(uint orderNo, uint phoneNumber) payable public {
        require(orders[orderNo].init);
        require(buyerAddress == msg.sender);
        require((orders[orderNo].price + orders[orderNo].shipment.price) == msg.value);

        orders[orderNo].safePay = msg.value;
        orders[orderNo].phoneNumber = phoneNumber;

        // Call an event
        SafePaySent(msg.sender, orderNo, msg.value, phoneNumber, now);
    }

    // The function to send the invoice data
    function sendInvoice(uint orderNo, address courier) payable public {
        require(orders[orderNo].init);
        require(owner == msg.sender);

        invoiceSeq++;

        // Create then Invoice instance and store it
        invoices[invoiceSeq] = Invoice(orderNo, invoiceSeq, true);

        // Update the shipment data
        orders[orderNo].shipment.courier = courier;

        // Call an event
        InvoiceSent(buyerAddress, invoiceSeq, orderNo, orders[orderNo].shipment.date, courier);
    }

    // The function to get the sent invoice
    function getInvoice(uint invoiceNo) constant public returns (address buyer, uint orderNo, uint deliveryDate, address courier){
        require(invoices[invoiceNo].init);

        Invoice storage _invoice = invoices[invoiceNo];
        Order storage _order     = orders[_invoice.orderNo];

        return (buyerAddress, _order.number, _order.shipment.date, _order.shipment.courier);
    }

    // The function to mark an order as delivered
    function delivery(uint invoiceNo, uint timestamp) payable public {
        require(invoices[invoiceNo].init);

        Invoice storage _invoice = invoices[invoiceNo];
        Order storage _order     = orders[_invoice.orderNo];

        // Just the courier can call this function
        require(_order.shipment.courier == msg.sender);

        // Call an event
        OrderDelivered(buyerAddress, invoiceNo, _order.number, timestamp, _order.shipment.courier);

        // Seller payout money for product
        owner.transfer(_order.safePay);

        // Courier payout money for delivery
        _order.shipment.courier.transfer(_order.shipment.safePay);

        _order.safePay = 0;
    }

    // Buyer send comment/feedback
    function sendComment(uint orderNo, string comment) public {
        require(orders[orderNo].init);
        require(buyerAddress == msg.sender);

        orders[orderNo].comment = comment;
        CommentSend(buyerAddress, orders[orderNo].number, now, comment);
    }
}
