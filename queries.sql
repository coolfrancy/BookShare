-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database
--Common queries which will be run

-- This query is used to find a book based off its id
SELECT id
FROM books
WHERE id=?;

--This query is used to search for users based off their id
SELECT *
FROM users
WHERE id=?;

--This query is to show a user totoal points
SELECT total_points
FROM user_points
WHERE id=?;

--This shows the top 10 sellers on the platform
SELECT *
FROM top_seller_transactions
LIMIT 10;

--Thi query shows he top 10 buyers on the platform
SELECT *
FROM top_buyer_transactions
LIMIT 10;


--This query shows a books cost in point based off its title
SELECT point_cost
FROM book_point_cost
WHERE book_id=
    (SELECT id
    FROM books
    WHERE title=?);

