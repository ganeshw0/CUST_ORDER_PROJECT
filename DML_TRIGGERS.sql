CREATE OR REPLACE TRIGGER invoice_entry AFTER
    INSERT ON orders
    FOR EACH ROW
ENABLE DECLARE
  -- PRAGMA AUTONOMOUS_TRANSACTION;
    i   NUMBER;
BEGIN
    INSERT INTO invoices (
        order_id,
        total_amount,
        sgst,
        cgst
    ) VALUES (
        :new.order_id,
        :new.price *:new.product_qty,
        :new.price *:new.product_qty *0.01* ( 18 / 2 ),
        :new.price *:new.product_qty *0.01* ( 18 / 2 )
    );
EXCEPTION
 WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(sqlerrm);
  DBMS_OUTPUT.PUT_LINE(sqlcode);
END;
/
CREATE OR REPLACE TRIGGER check_ord_status BEFORE
    UPDATE ON orders
    FOR EACH ROW
ENABLE DECLARE
  -- PRAGMA AUTONOMOUS_TRANSACTION;
    i   NUMBER;
    cant_cancel EXCEPTION;
BEGIN
    IF
        :new.status = 'CAN'
    THEN
        IF
            :old.status = 'CON'
        THEN
            NULL;
        ELSE
            RAISE cant_cancel;
        END IF;
    END IF;
EXCEPTION
    WHEN cant_cancel THEN
        dbms_output.put_line('can not cancel when it is in '
        ||:new.status
        || ' state');
    WHEN OTHERS THEN
        dbms_output.put_line(sqlerrm);
        dbms_output.put_line(sqlcode);
END;
/