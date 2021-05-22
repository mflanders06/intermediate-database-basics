--Practice Joins
--1
SELECT *
FROM invoice
inner join invoice_line
on invoice.invoice_id = invoice_line.invoice_id
WHERE unit_price > .99;

--2
SELECT invoice_date, first_name, last_name, total
FROM invoice
FULL OUTER JOIN customer
on invoice.customer_id = customer.customer_id;

--3
SELECT  customer.first_name as CustFirstName,
		customer.last_name as CustLastName,
        employee.first_name as EmpFirstName,
        employee.last_name as EmpLastName
FROM customer
LEFT JOIN employee
ON customer.support_rep_id = employee.employee_id;

--4
SELECT title, name
FROM album
LEFT JOIN artist
ON album.artist_id = artist.artist_id;

--5
SELECT track_id
FROM playlist_track
INNER JOIN playlist
ON playlist_track.playlist_id = playlist.playlist_id
WHERE name = 'Music';

--6
SELECT name
FROM track
INNER JOIN playlist_track
ON track.track_id = playlist_track.track_id
WHERE playlist_id = 5;

--7
SELECT track.name as TrackName, playlist.name as PlaylistName
FROM track
INNER JOIN playlist_track
ON track.track_id = playlist_track.track_id
INNER JOIN playlist
ON playlist_track.playlist_id = playlist.playlist_id;

--8
SELECT track.name, album.title
FROM track
JOIN genre
ON track.genre_id = genre.genre_id
JOIN album
ON track.album_id = album.album_id
WHERE genre.name = 'Alternative & Punk';

--BlackDiamond
SELECT  track.name as TrackName,
        genre.name as Genre,
        album.title as Album,
        artist.name as Artist
FROM track
JOIN genre
ON track.genre_id = genre.genre_id
JOIN playlist_track
ON track.track_id = playlist_track.track_id
JOIN playlist
ON playlist_track.playlist_id = playlist.playlist_id
JOIN album
ON track.album_id = album.album_id
JOIN artist
on album.artist_id = artist.artist_id;


/*Practice nested queries*/
--1
SELECT *
FROM invoice
WHERE invoice_id in (SELECT invoice_id
                     FROM invoice_line
                     WHERE unit_price > 0.99);

--2
SELECT *
FROM playlist_track
WHERE playlist_id in (SELECT playlist_id
                      FROM playlist
                      WHERE name = 'Music');

--3
SELECT name
FROM track
WHERE track_id IN (SELECT track_id
                   FROM playlist_track
                   WHERE playlist_id = 5);

--4
SELECT *
FROM track
WHERE genre_id IN (SELECT genre_id
                   FROM genre
                   WHERE name = 'Comedy');

--5
SELECT *
FROM track
WHERE album_id IN (SELECT album_id
                   FROM album
                   WHERE title = 'Fireball');

--6
SELECT *
FROM track
WHERE album_id IN (SELECT album_id
                   FROM album
                   WHERE artist_id IN (SELECT artist_id
                                       FROM artist
                                       WHERE name = 'Queen'));


/*Practice Updating Rows*/
--1
UPDATE customer
SET fax = NULL
WHERE fax IS NOT NULL;

--2
UPDATE customer
SET company = 'Self'
WHERE company is NULL;

--3
UPDATE customer
SET last_name = 'Thompson'
WHERE first_name = 'Julia' and last_name = 'Barnett';

--4
UPDATE customer
SET support_rep_id = 4
WHERE email = 'luisrojas@yahoo.cl';

--5
UPDATE track
SET composer = 'The darkness around us'
WHERE composer IS NULL;

--6
--Done


/*Group by*/
--1
SELECT genre.name, count(track_id)
FROM track
JOIN genre
ON track.genre_id = genre.genre_id
GROUP BY genre.name;

--2
SELECT genre.name, count(track_id)
FROM track
JOIN genre
ON track.genre_id = genre.genre_id
WHERE genre.name IN ('Pop', 'Rock')
GROUP BY genre.name;

--3
SELECT name, count(*)
FROM artist
JOIN album
on artist.artist_id = album.artist_id
GROUP BY name;


/*Use Distinct*/
--1
SELECT DISTINCT composer
FROM track;

--2
SELECT DISTINCT billing_postal_code
FROM invoice;

--3
SELECT DISTINCT company
FROM customer;


/*Delete Rows*/
--1
/*   This is the dummy table
CREATE TABLE practice_delete ( name TEXT, type TEXT, value INTEGER );
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'bronze', 50);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'bronze', 50);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'bronze', 50);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'silver', 100);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'silver', 100);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'gold', 150);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'gold', 150);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'gold', 150);
INSERT INTO practice_delete ( name, type, value ) VALUES ('delete', 'gold', 150);

SELECT * FROM practice_delete;
*/

--2
DELETE FROM practice_delete
WHERE type = 'bronze';

--3
DELETE FROM practice_delete
WHERE type = 'silver';

--4
DELETE FROM practice_delete
WHERE value = 150;


/*eCommerce Simulation - No Hints*/


CREATE TABLE users (user_KEY SERIAL PRIMARY KEY,
                    name TEXT,
                    email varchar(100));
                    
INSERT INTO users (name, email)
VALUES  ('Mike', 'mike@gmail.com'),
		('Ralph', 'ralph@gmail.com'),
        ('Lauren', 'lauren@juno.com');

CREATE TABLE products (product_key SERIAL PRIMARY KEY,
                       name TEXT,
                       price DECIMAL);
                       
INSERT INTO products (name, price)
VALUES  ('Apple', 0.89),
		('Orange', 1.32),
        ('Avocado', 0.95);
                       
CREATE TABLE orders (order_KEY SERIAL PRIMARY KEY,
										product_key INT
                     		REFERENCES products (product_key)
);

INSERT INTO orders (product_key)
VALUES  (1),
		(2),
        (3);

--Get all products for the first order:
SELECT name
FROM products
WHERE product_KEY IN (SELECT product_KEY
                      FROM orders
                      WHERE order_key = 1);

--Get all orders
SELECT *
FROM orders;

--Get the total cost of an order
SELECT order_key, sum(price)
FROM orders
JOIN products
ON orders.product_key = products.product_key
GROUP BY order_key;
WHERE order_key = 1

--Add a foreign key reference from orders to users
ALTER TABLE orders
ADD COLUMN user_key INT
						REFERENCES users (user_key);

--Update the orders table to link a user to each order
UPDATE orders
SET user_key = 1
WHERE order_key in (1, 2);

UPDATE orders
SET user_key = 2
WHERE order_key =3;

--Get all orders for a user
SELECT *
FROM orders
WHERE user_key = 1

--Get how many orders each user has
SELECT name, count(order_key)
FROM users
LEFT JOIN orders
ON users.user_key = orders.user_key
GROUP BY name;

--Black Diamond
SELECT users.name, sum(price)
FROM users
LEFT JOIN orders
on users.user_key = orders.user_key
INNER JOIN products
ON orders.product_key = products.product_key
GROUP BY users.name;


--(I'm adding a quantity to the orders table)
ALTER TABLE orders
ADD COLUMN quantity INT;


UPDATE orders
SET quantity = 3
WHERE order_key IN (2, 3);

UPDATE orders
SET quantity = 11
WHERE order_key = 1;

--Get the total amount on all orders for each user
SELECT users.name, sum(quantity * price)
FROM users
LEFT JOIN orders
on users.user_key = orders.user_key
INNER JOIN products
ON orders.product_key = products.product_key
GROUP BY users.name;