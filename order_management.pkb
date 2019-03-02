CREATE OR REPLACE PACKAGE BODY order_management AS

    PROCEDURE confirm_order (
        p_cust_id    VARCHAR2,
        p_prod_id    VARCHAR2,
        p_prod_qty   NUMBER,
        p_payment    CHAR
    ) IS
        lv_price        NUMBER;
        lv_last_order   NUMBER;
        integrety_constraint EXCEPTION;
        PRAGMA exception_init ( integrety_constraint,-02291 );
    BEGIN
        IF
            p_payment = 'Y'
        THEN
            SELECT
                product_price
            INTO
                lv_price
            FROM
                products
            WHERE
                product_id = p_prod_id;

            BEGIN
                SELECT
                    MAX(order_id)
                INTO
                    lv_last_order
                FROM
                    orders;

                INSERT INTO orders (
                    order_id,
                    cust_id,
                    product_id,
                    order_date,
                    product_qty,
                    price,
                    status
                ) VALUES (
                    lv_last_order + 1,
                    p_cust_id,
                    p_prod_id,
                    SYSDATE,
                    p_prod_qty,
                    lv_price,
                    'CON'
                );

                COMMIT;
                dbms_output.put_line('Order confirmed with order id :'
                || lv_last_order + 1);
            EXCEPTION
                WHEN integrety_constraint THEN
                    dbms_output.put_line('please provide proper customer id');
            END;

        ELSE
            dbms_output.put_line('Order can not be confirmed until payment getway process done');
        END IF;
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Please provide proper product id');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END confirm_order;
/*----------------------procedure to ship the order---------------------------------------------*/

    PROCEDURE order_shipment (
        p_order_id NUMBER
    ) IS
        lv_order_status   VARCHAR2(10);
    BEGIN
        SELECT
            status
        INTO
            lv_order_status
        FROM
            orders
        WHERE
            order_id = p_order_id;

        IF
            lv_order_status = 'CON'
        THEN
            UPDATE orders
                SET
                    status = 'SHP'
            WHERE
                order_id = p_order_id;

            COMMIT;
        ELSE
            dbms_output.put_line('order can not be shiped when order status is:'
            || lv_order_status);
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('please provide proper order id');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END order_shipment;
/*-------------PROCEDURE FOR CANCELLING THE ORDER-------------------------*/

    PROCEDURE cancel_order (
        p_order_id NUMBER
    ) IS
        lv_order_status   VARCHAR2(10);
    BEGIN
        SELECT
            status
        INTO
            lv_order_status
        FROM
            orders
        WHERE
            order_id = p_order_id;

        COMMIT;
        IF
            lv_order_status = 'CON'
        THEN
            UPDATE orders
                SET
                    status = 'CAN'
            WHERE
                order_id = p_order_id;

        ELSE
            dbms_output.put_line('order can not be cancelled when order status is:'
            || lv_order_status);
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('please provide proper order id');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END cancel_order;
/*---------------------------------Procedure order delivered------------------*/

    PROCEDURE order_delivered (
        p_order_id NUMBER
    ) IS
        lv_order_status   VARCHAR2(10);
    BEGIN
        SELECT
            status
        INTO
            lv_order_status
        FROM
            orders
        WHERE
            order_id = p_order_id;

        IF
            lv_order_status = 'SHP'
        THEN
            UPDATE orders
                SET
                    status = 'DEL'
            WHERE
                order_id = p_order_id;

            COMMIT;
        ELSE
            dbms_output.put_line('order can not be delivered when order status is:'
            || lv_order_status);
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('please provide proper order id');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END order_delivered;
/*-----------------------------------Procedure for order delivery--------------------------------*/

    PROCEDURE return_order (
        p_order_id NUMBER
    ) IS
        lv_order_status   VARCHAR2(10);
        lv_order_date     DATE;
    BEGIN
        SELECT
            status,
            order_date
        INTO
            lv_order_status,lv_order_date
        FROM
            orders
        WHERE
            order_id = p_order_id;

        IF
            lv_order_status = 'DEL'
        THEN
            IF
                ( SYSDATE - lv_order_date ) < 5
            THEN
                UPDATE orders
                    SET
                        status = 'RET'
                WHERE
                    order_id = p_order_id;

                COMMIT;
            ELSE
                dbms_output.put_line('Order can not be returned after 5 days');
            END IF;

        ELSE
            dbms_output.put_line('order can not be shiped when order status is:'
            || lv_order_status);
        END IF;

    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('please provide proper order id');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END return_order;
/*------------------------------------------------procedure to generate invoice-------------------------*/

    PROCEDURE generate_invoice (
        p_order_id NUMBER
    ) IS

        lv_file                utl_file.file_type;
        lv_invoice_id          invoices.invoice_id%TYPE;
        lv_order_id            invoices.order_id%TYPE;
        lv_product_name        products.product_name%TYPE;
        lv_product_qty         orders.product_qty%TYPE;
        lv_total_amount        invoices.total_amount%TYPE;
        lv_cgst                invoices.cgst%TYPE;
        lv_sgst                invoices.sgst%TYPE;
        lv_total_amount_paid   NUMBER;
    BEGIN
        lv_file := utl_file.fopen('DIR_FILE',p_order_id
        || '_Invoice.txt','w');
        SELECT
            i.invoice_id,
            i.order_id,
            p.product_name,
            o.product_qty,
            i.total_amount,
            i.sgst,
            i.cgst,
            i.total_amount + i.sgst + i.cgst
        INTO
            lv_invoice_id,lv_order_id,lv_product_name,lv_product_qty,lv_total_amount,lv_cgst,lv_sgst,lv_total_amount_paid
        FROM
            orders o,
            products p,
            invoices i
        WHERE
            i.order_id = p_order_id
            AND   i.order_id = o.order_id
            AND   o.product_id = p.product_id;

        utl_file.put_line(lv_file,'--------------INVOICE FOR ORDER NO:'
        || p_order_id
        || ' -------------------------');
        utl_file.put_line(lv_file,'Invoice Number:                         '
        || lv_invoice_id);
        utl_file.put_line(lv_file,'Order Number:                           '
        || lv_order_id);
        utl_file.put_line(lv_file,'Product Name:                           '
        || lv_product_name);
        utl_file.put_line(lv_file,'Product quanty:                         '
        || lv_product_qty);
        utl_file.put_line(lv_file,'Total price excluding tax:              '
        || lv_total_amount
        || 'EUROS');
        utl_file.put_line(lv_file,'central tax CGST:                       '
        || lv_cgst
        || 'EUROS');
        utl_file.put_line(lv_file,'STATE TAX SGST:                         '
        || lv_sgst
        || 'EUROS');
        utl_file.put_line(lv_file,'----------------------------------------------------------- ');
        utl_file.put_line(lv_file,'GROSS TOTAL AMOUNT:                     '
        || lv_total_amount_paid
        || 'EUROS');
        utl_file.fclose(lv_file);
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('Please provide proper order id');
            utl_file.fclose(lv_file);
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
            utl_file.fclose(lv_file);
    END generate_invoice;
/*-----------------------------------GET REVENUE FOR PERTICULAR DURATION FOR CONFIRMED ORDERS-----*/

    PROCEDURE get_revenue_in_inr (
        p_from_date DATE,
        p_to_date DATE
    ) IS
        lv_sum_revenue   NUMBER;
        lv_sum_rupees    NUMBER;
    BEGIN
        SELECT
            SUM(o.price * o.product_qty)
        INTO
            lv_sum_revenue
        FROM
            orders o
        WHERE
            o.status = 'DEL'
            AND   trunc(o.order_date) BETWEEN trunc(p_from_date) AND trunc(p_to_date);

        lv_sum_rupees := euro_to_rupees(lv_sum_revenue);
        dbms_output.put_line('revenue generated for all products between '
        || p_from_date
        || ' and '
        || p_to_date
        || ' is INR '
        || lv_sum_rupees);

    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('There are no orders placed during provided dates');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END get_revenue_in_inr;
/*--------------------------------Number of orders delivered in given location for duration-------------*/

    PROCEDURE get_orders_delivered (
        p_location_id   VARCHAR2,
        p_from_date     DATE,
        p_to_date       DATE
    ) IS
        lv_sum_orders   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO
            lv_sum_orders
        FROM
            orders o,
            customers c
        WHERE
            o.cust_id = c.cust_id
            AND   c.loc_id = p_location_id
            AND   trunc(o.order_date) BETWEEN trunc(p_from_date) AND trunc(p_to_date);

        dbms_output.put_line('total number of orders in location :'
        || p_location_id
        || ' are '
        || lv_sum_orders);
    EXCEPTION
        WHEN no_data_found THEN
            dbms_output.put_line('There are no orders for given location during provided deates');
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
    END get_orders_delivered;
/*-----------------Generate CSV FILE FOR tracking orders of perticular customer-------------------*/

    PROCEDURE cust_area_ord_details_csv (
        p_cust_id VARCHAR2
    ) IS

        lv_file       utl_file.file_type;
        CURSOR lv_cur_data IS SELECT
            c.cust_name,
            c.address,
            l.location_name,
            p.product_name,
            ost.status_desc
                              FROM
            customers c,
            orders o,
            products p,
            locations l,
            order_status_desc ost
                              WHERE
            c.cust_id = p_cust_id
            AND   c.cust_id = o.cust_id
            AND   o.product_id = p.product_id
            AND   o.status = ost.status
            AND   c.loc_id = l.location_id;

        TYPE lv_data_collect IS
            TABLE OF lv_cur_data%rowtype;
        lv_tab_data   lv_data_collect := lv_data_collect ();
    BEGIN
        OPEN lv_cur_data;
        FETCH lv_cur_data BULK COLLECT INTO lv_tab_data;
        CLOSE lv_cur_data;
        lv_file := utl_file.fopen('DIR_FILE',p_cust_id
        || '_file.csv','w');
        utl_file.put_line(lv_file,'Customer Name '
        || chr(9)
        || 'Customer address '
        || chr(9)
        || 'Location area name '
        || chr(9)
        || 'product name '
        || chr(9)
        || 'order status');

        FOR tab IN lv_tab_data.first..lv_tab_data.last LOOP
            utl_file.put_line(lv_file,lv_tab_data(tab).cust_name
            || chr(9)
            || lv_tab_data(tab).address
            || chr(9)
            || lv_tab_data(tab).location_name
            || chr(9)
            || lv_tab_data(tab).product_name
            || chr(9)
            || lv_tab_data(tab).status_desc);
        END LOOP;

        utl_file.fclose(lv_file);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line(sqlcode);
            dbms_output.put_line(sqlerrm);
            utl_file.fclose(lv_file);
    END cust_area_ord_details_csv;
/*-----------------------------------currency conversion from euro to rupees----------------------*/

    FUNCTION euro_to_rupees (
        p_amount NUMBER
    ) RETURN NUMBER IS
        lv_conv_factor     NUMBER := 83.3;
        lv_amount_rupees   NUMBER;
    BEGIN
        lv_amount_rupees := p_amount * lv_conv_factor;
        RETURN lv_amount_rupees;
    END euro_to_rupees;
/*--------------------------------------------------------------------------------------------*/

END order_management;
/