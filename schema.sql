-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

CREATE TABLE users(
    id INT PRIMARY KEY,
    first_name TEXT,
    last_name TEXT,
    username TEXT UNIQUE,
    "password" TEXT,
    "number" INT UNIQUE,
    email_address TEXT UNIQUE,
    "address" TEXT,
    created_date TEXT,
    updated_date TEXT
);

CREATE TABLE books(
    id INT PRIMARY KEY,
    isbn TEXT UNIQUE,
    title TEXT,
    author TEXT,
    "description" TEXT,
    publisher TEXT,
    published_date TEXT
);

CREATE TABLE user_points(
    id INT PRIMARY KEY,
    user_id INT UNIQUE,
    total_points INT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE book_point_cost(
    id INT PRIMARY KEY,
    book_id INT UNIQUE,
    point_cost INT,
    "date" TEXT,
    FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE transactions(
    id INT PRIMARY KEY,
    seller_user_id INT,
    book_id INT,
    buyer_user_id INT,
    points_exchanged INT,
    seller_rating INT,
    buyer_rating INT,
    transaction_status TEXT,
    "start_date" TEXT,
    finish_date TEXT,
    FOREIGN KEY (seller_user_id) REFERENCES users(id),
    FOREIGN KEY (buyer_user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE reputations(
    id INT PRIMARY KEY,
    user_id INT UNIQUE,
    avg_rating INT,
    avg_buy_rating INT,
    avg_selling_rating INT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE user_inventories(
    id INT PRIMARY KEY,
    user_id INT,
    book_id INT,
    "date" TEXT,
    amount INT,
    condition TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (book_id) REFERENCES books(id)
);

CREATE TABLE schools(
    id INT PRIMARY KEY,
    "name" TEXT,
    "address" TEXT,
    "type" TEXT
);

CREATE TABLE school_affiliations(
    id INT PRIMARY KEY,
    user_id INT,
    school_id INT,
    affeliated_date TEXT,
    "role" TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (school_id) REFERENCES schools(id)
);

CREATE TABLE password_log(
    id INT PRIMARY KEY,
    user_id INT,
    old_password TEXT,
    new_password TEXT,
    change_date TEXT,
    FOREIGN KEY (user_id) REFERENCES users(id)
);

--Indexes to help speed up commonly querried collumns
CREATE INDEX book_search
ON books(isbn, title, author, "description", publisher, published_date);

CREATE INDEX user_search
ON users(first_name, last_name, "number", email_address, "address", username, "password");

CREATE INDEX total_points_search
ON user_points(user_id, total_points);

CREATE INDEX book_point_search
ON book_point_cost(book_id, point_cost, "date");

CREATE INDEX transaction_search
ON transactions(seller_user_id, book_id, buyer_user_id, points_exchanged, seller_rating, buyer_rating, transaction_status, "start_date", finish_date);

CREATE INDEX reputation_search
ON reputations(user_id, avg_rating, avg_buy_rating, avg_selling_rating);

create INDEX user_inventory_search
ON user_inventories(user_id, book_id, "date", amount, condition);

CREATE INDEX school_search
ON schools("name");

CREATE INDEX school_affiliation_search
ON school_affiliations(user_id, school_id, affeliated_date, "role");

--A view to get books title and cost in one table
CREATE VIEW book_title_cost AS
SELECT books.title, book_point_cost.point_cost
FROM books
JOIN book_point_cost
ON book_point_cost.book_id=books.id;


--A view to show user names and the transaction information could be shown to users
CREATE VIEW transaction_for_user AS
SELECT
    transactions.seller_user_id AS seller,
    books.title,
    transactions.buyer_user_id AS buyer,
    transactions.points_exchanged,
    transactions.transaction_status
FROM transactions
JOIN books
ON books.id=transactions.book_id
JOIN users AS seller
ON seller.id=transactions.seller_user_id
JOIN users AS buyer
ON buyer.id=transactions.buyer_user_id;

--A view to show user names and the reputation information could be shown to users
CREATE VIEW reputaion_for_user AS
SELECT
    users.username,
    reputations.avg_rating,
    reputations.avg_buy_rating,
    reputations.avg_selling_rating
FROM reputations
JOIN users
ON users.id=reputations.user_id;

--A view to show user inventories
CREATE VIEW inventories_for_user AS
SELECT
    users.username,
    books.title,
    SUM(ui.amount) AS total_amount,
    ui.condition
FROM users
JOIN user_inventories AS ui ON ui.user_id = users.id
JOIN books ON ui.book_id = books.id
GROUP BY username, title, condition;

--a view to show who is connected to which schools
CREATE VIEW school_affiliaions_view AS
SELECT
    users.username,
    users.first_name,
    users.last_name,
    schools.name,
    sa.affeliated_date,
    sa.role
FROM users
JOIN school_affiliations AS sa
ON sa.user_id=users.id
JOIN schools
ON schools.id=sa.school_id;

--a view to show the top book buyers
CREATE VIEW top_buyer_transactions AS
SELECT buyer_user_id, COUNT(*) AS total_purchases
FROM transactions
GROUP BY buyer_user_id
ORDER BY total_purchases DESC;

--a view to show the top book sellers
CREATE VIEW top_seller_transactions AS
SELECT seller_user_id, COUNT(*) AS total_sold
FROM transactions
GROUP BY seller_user_id
ORDER BY total_sold DESC;

--A trigger that transfer points based off the transactions
CREATE TRIGGER point_transfer
AFTER UPDATE ON transactions
FOR EACH ROW
WHEN NEW.transaction_status = 'complete' AND OLD.transaction_status != 'complete'
BEGIN
    UPDATE user_points
    SET total_points = total_points - NEW.points_exchanged
    WHERE user_id = NEW.buyer_user_id;

    UPDATE user_points
    SET total_points = total_points + NEW.points_exchanged
    WHERE user_id = NEW.seller_user_id;
END;

--A trigger that adds changed passwords to the password_logs
CREATE TRIGGER password_logs
AFTER UPDATE ON users
FOR EACH ROW
WHEN old.password!=new.password

BEGIN
    INSERT INTO password_log(user_id, old_password, new_password, change_date)
    VALUES (old.id, old.password, new.password, CURRENT_TIMESTAMP);
END;
