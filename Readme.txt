-----------Read me ---------
Project About managing orders after order has been successfully placed
Here handled from order confirmation to order delivered or returned 
Order terminology used to show order status 
CAN-->Cancel order 
CON-->Confirm order
DEL-->Delivered order
SHP-->Shipped order 
RET-->returned order 
------------------------------------------------------------------------
DDL Objects and their use 
CUSTOMERS--> Have customer details with address and location 
Locations--> Mapped location names with location id 
PRODUCTS-->  cotaines product details with price and stock 
ORDERS--> it is to handle the orders and maintain its status along with trigger for auto generate invoices
INVOICES--> it is auto filled in trigger by orders table when order is confirmed invoice entry is generated
ORDER_STATUS_DESC--> to describe the status of order 
-------------------------------------------------------------------------------
TRIGGERS
TRIGGER invoice_entry-->this trigger is on orders table on INSERT,It will enter the data in Invoices table automatically when order is confirmed.

TRIGGER check_ord_status-->this trigger is on orders table on Update, to manage cancelled order as it should not be cancelled once it is shipped, order can be cancelled only if it is in confirmed status. 


---------------------------------------------------------------------------------
Package ORDER MANAGEMENT 
PROCEDURE CONFIRM ORDER--> IT is used to confirm the order once the payment done order can be confirmed using this procedure need to pass customer id, product id and quantity to confirm the order.

PROCEDURE ORDER_SHIPMENT-->This procedure used to change order status if order is shipped, it will change status to order shipped only if order is in confirm status else it cannot be updated, need to pass order id

PROCEDURE CANCEL_ORDER-->This procedure used to cancel the order and update status in orders table,it will change the status only if order is in confirm state else it will not update status as once order is shipped it cannot be cancelled, need to pass order id.


PROCEDURE ORDER_DELIVERED-->This procedure is used to update status in orders table once the order is delivered to customer, it will update status ony if the old status is order shipped else it will not update status, need to pass order id

PROCEDURE RETURN_ORDER-->This procedure used to update returned products by customer it can be called within 5 days of order date or can be returned only if it is delivered and number of days not exceed 5 days.


PROCEDURE GENERATE_INVOICE-->This procedure is used to generate invoice file in given directory C:/FILES in txt format , need to provide order id to genrate invoice

PROCEDURE GET_REVENUE_IN_INR-->It will generate total revenue in INR for given from date and to date need to provide dates 


PROCEDURE GET_ORDERS_DELIVERED--> It will give Number of orders provided in given areat for given time duartion all orders should be in delivered state 

PROCEDURE CUST_AREA_ORD_DETAILS_CSV-->This procedure will generate csv file in C:\FILES directory for given customer id it will have all customer details and his orders 

FUNCTION EURO_TO_RUPEES-->this function used to convert currency from euro to rupees 
------------------------------------------------------------------------------------------