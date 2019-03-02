create or replace PACKAGE order_management AS
    PROCEDURE confirm_order (
        p_cust_id    VARCHAR2,
        p_prod_id    VARCHAR2,
        p_prod_qty   NUMBER
    );

    PROCEDURE order_shipment (
        p_order_id NUMBER
    );

    PROCEDURE cancel_order (
        p_order_id NUMBER
    );

    PROCEDURE order_delivered (
        p_order_id NUMBER
    );

    PROCEDURE return_order (
        p_order_id NUMBER
    );

    PROCEDURE generate_invoice (
        p_order_id NUMBER
    );

    PROCEDURE get_revenue_in_inr (
        p_from_date DATE,
        p_to_date DATE
    );

    PROCEDURE get_orders_delivered (
        p_location_id   VARCHAR2,
        p_from_date     DATE,
        p_to_date       DATE
    );

    PROCEDURE cust_area_ord_details_csv (
        p_cust_id VARCHAR2
    );

    FUNCTION euro_to_rupees (
        p_amount NUMBER
    ) RETURN NUMBER;

END order_management;
/