# Design Document

By Romelus, Francy

Video overview: <https://youtu.be/5AcgcE8k52E>

## Scope
Access to books at an affordable price can become a problem for students, particularly students with budget constraints.
To make book access convenient for students, I developed a database for a book swap website in which books can be
exchanged for a points system and not for real cash. With such a system, students can obtain their required books with no
financial constraints. Overall, I created this database to support a book exchange platform where users can trade each
other's books using a points-based system. The database tracks things like books, points, user reputations, and people
who are the users of the platform. The database does not track deliveries since the platform has yet a need for deliveries
nor does it track real dollars making sure to only use points for transactions. I'm hoping to use this to help students
who don't have the funds to afford books.

## Functional Requirements

Using my database a user should be able to manage their account, list books, look for available books, exchange books for
points rate other users, and affiliate with schools. A user must also have the ability to see other users' reputations so
they can decide if they would like to exchange or not. A user should not be able to exchange books for real money, modify
other users' accounts, or trade books that are not listed in the system. In my vision, it would be possible for someone to
keep exchanging their books each semester until they graduate. I also believe that trading in the campus for colleges would
be for the best which is why I added the school-to-user affiliations relationship.

## Representation

### Entities

The database represents the following entities:
Users – Represents individuals using the book exchange platform.
Books – Represents books available for exchange.
User Points – Tracks the points each user has for trading books.
Book Point Cost – Stores the point value assigned to each book.
Transactions – Tracks book exchanges between users.
Reputations – Stores user ratings based on completed transactions.
User Inventories – Tracks books owned by each user and their condition.
Schools – Represents educational institutions users may be affiliated with.
School Affiliations – Links users to their respective schools.
Password Log – Stores previous password changes for security purposes.

Each entity has attributes relevant to its function:
Users: id, first_name, last_name, username, password, number, email_address, address, created_date, updated_date
Books: id, isbn, title, author, description, publisher, published_date
User Points: id, user_id, total_points
Book Point Cost: id, book_id, point_cost, date
Transactions: id, seller_user_id, book_id, buyer_user_id, points_exchanged, seller_rating, buyer_rating, transaction_status, start_date, finish_date
Reputations: id, user_id, avg_rating, avg_buy_rating, avg_selling_rating
User Inventories: id, user_id, book_id, date, amount, condition
Schools: id, name, address, type
School Affiliations: id, user_id, school_id, affiliated_date, role
Password Log: id, user_id, old_password, new_password, change_date

These are the types used:
IDs: INT PRIMARY KEY – Used for unique identification of each record.
Text Fields: TEXT – Used for attributes that require variable-length input (e.g., names, titles, addresses).
Numerical Fields: INT – Used for attributes requiring numerical values (e.g., points, ratings, amounts).
Dates: TEXT – Stored as TEXT for easy parsing and manipulation across different systems.

Chosen constraints:
Primary Keys (PRIMARY KEY) ensure each record is unique.
Foreign Keys (FOREIGN KEY) enforce relationships between related tables (e.g., users and their points, books and transactions).
Unique Constraints (UNIQUE) prevent duplicate data for attributes like usernames, email addresses, and ISBNs.
NOT NULL Constraints ensure critical fields (like usernames and book titles) must have values.
Triggers help maintain data consistency (e.g., transferring points upon transaction completion, logging password changes).

### Relationships

![Alt text](/workspaces/154463480/project/mermaid-diagram-2025-02-06-194528.png)

The database holds seven key entities, and each one of them interacts with one another mainly The ERD shows that the users
are the central part of the system, connecting to most of the entities. The books entity is significant, and it interfaces
with transactions, in which books move between users, and with inventories. The school entity ties schools and students
together, and school affiliations grant students ease in transactions with one another, finally, tracking entities,
such as a reputation entity, enable trust in the system with buyer and seller ratings stored in them. With triggers
updating user information, book availability, and transactions accurately and consistently it helps keep the information
stored concise.


Entities relationships:
Users → User Inventories, One-to-Many
Users → Transactions, One-to-Many
Transactions → User Inventory, Many-to-One
Books → User Inventory, One-to-Many
Books → Book Point Cost, One-to-One
Users → Reputations, One-to-One
Users ↔ Schools, Many-to-Many


## Optimizations

Active Listings View – A view that joins Books, User Inventories, and Book Point Cost to show currently available books with their point costs.

Transaction History View – A view combining Transactions, Users, and Books to present a summary of completed exchanges.

User Reputation Summary View – A view that aggregates user ratings from Reputations and Transactions for quick access to seller and buyer trust scores.

Top Users by Transactions – A materialized view that precomputes the most active users in terms of book exchanges. This reduces computation for leaderboards or user rankings.

Denormalized Some Data – The Reputations table stores precomputed averages (overall rating, buy rating, sell rating) to avoid recalculating them on every query.

I included some indexes on te users table since most of the query will involve the users table,
i also included indexes for most of the other tables except the log table since it will be most likely called by admins and not normal users so the amount of querying wont be as much.

I included some triggers making sure to deduct point from buyer after the transaction and add points to the seller once the transaction has been complete all to keep the information accurate.

## Limitations

My database does not have the ability to track deliveries, my conditions are stored as text instead of predefined
variables like new, used, or lightly used, no user communication and my database doesn't represent wishlists where
users can have a list of books which they can get notified when it's in stock we don't have a refund process so users
can't refund back if they're not satisfied with the exchange. later on, I will be optimizing and including features like
deliveries, communication, and more information to help the users.
