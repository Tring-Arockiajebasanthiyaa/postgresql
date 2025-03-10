--Creating the category Table

CREATE TABLE categories (
    category_id SERIAL PRIMARY KEY,   
    category_name VARCHAR(50) NOT NULL UNIQUE 
);

--Creating the menu Table
CREATE TABLE menu (
    item_id SERIAL PRIMARY KEY,      
    item_name VARCHAR(100) UNIQUE NOT NULL,  -- Make item_name UNIQUE
    category_id INT REFERENCES categories(category_id) ON DELETE SET NULL,  
    price INT CHECK (price > 0)       
);

--Drop menu

DROP TABLE menu;

--Creating the orders Table

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,        
    total_amount INT DEFAULT 0,         
    order_date TIMESTAMP DEFAULT NOW()   
);
--Drop table

DROP table orders;

--Creating the order_items Table

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY, 
    order_id INT REFERENCES orders(order_id) ON DELETE SET NULL,
    item_name VARCHAR(100) REFERENCES menu(item_name) ON DELETE SET NULL,    
    quantity INT CHECK (quantity > 0), 
    price INT CHECK (price > 0)        
);

--Drop table

DROP table order_items;

--Creating a Function to Automatically Update Total Amount

CREATE OR REPLACE FUNCTION update_total_amount()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total amount for the order when a new item is added
    UPDATE orders
    SET total_amount = (
        SELECT SUM(price * quantity)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

--Functions 2:

CREATE OR REPLACE FUNCTION set_price_from_menu()
RETURNS TRIGGER AS $$
BEGIN
    NEW.price := (SELECT price FROM menu WHERE item_name = NEW.item_name);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


select * from menu;


CREATE OR REPLACE FUNCTION prevent_empty_order()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM order_items WHERE order_id = NEW.order_id) THEN
        RAISE EXCEPTION 'Order must have at least one item!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION validate_order_item()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM menu WHERE item_name = NEW.item_name) THEN
        RAISE EXCEPTION 'Item does not exist in menu!';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;




--Drop Function

DROP FUNCTION IF EXISTS update_total_amount();
DROP FUNCTION IF EXISTS set_price_from_menu();
--Create the Trigger

CREATE TRIGGER update_order_total
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_total_amount();

--Trigger 2:

CREATE TRIGGER before_insert_order_items
BEFORE INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION set_price_from_menu();

--Trigger
CREATE TRIGGER check_order_items
BEFORE INSERT ON orders
FOR EACH ROW
EXECUTE FUNCTION prevent_empty_order();

--Trigger

CREATE TRIGGER check_menu_item
BEFORE INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION validate_order_item();

--Drop trigger

DROP TRIGGER IF EXISTS update_order_total ON order_items;
DROP TRIGGER IF EXISTS before_insert_order_items ON order_items;
--INSERT TABLE 

--INSERT into categories
INSERT INTO categories (category_name) VALUES 
('Beverages'),
('Fast Food'),
('Desserts');

--Insert into menu
 
INSERT INTO menu (item_name, category_id, price) VALUES 
('Burger', 2, 150), 
('Coffee', 1, 100), 
('Ice Cream', 3, 80);

--Insert into orders

INSERT INTO orders DEFAULT VALUES;

--Insert into order_items

INSERT INTO order_items (order_id, item_name, quantity) 
VALUES (1, 'Burger', 2);

--Display orders

SELECT * FROM orders;
SELECT * FROM menu;
SELECT * FROM categories;
SELECT * FROM order_items;

--Delete items
DELETE FROM order_items;
