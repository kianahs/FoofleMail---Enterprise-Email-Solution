# Foofle - Email Management System

## Overview

Foofle is a comprehensive email management system designed to simulate the functionalities of a modern email service. This project showcases advanced database design and development skills, along with a robust Java-based user interface. The system allows users to register, log in, compose emails, manage their inbox and sent items, view notifications, and edit their personal information. It also includes features like granting and revoking access to other users, viewing profiles, and deleting emails.

## Database Concepts Used

### 1. **Relational Database Design**
   - **Tables**: The database is structured using multiple tables such as `user`, `sents`, `recipient_table`, `notification`, `privileges_table`, and `exception`. Each table is designed to store specific data related to users, emails, notifications, and access privileges.
   - **Primary and Foreign Keys**: Relationships between tables are established using primary and foreign keys. For example, the `recipient_table` references the `sents` table via `email_ID` and the `user` table via `recipient_username`.
   - **Normalization**: The database is normalized to reduce redundancy and improve data integrity. For instance, user information is stored in the `user` table, while email-related data is stored in the `sents` and `recipient_table`.

### 2. **Stored Procedures and Triggers**
   - **Stored Procedures**: The database uses stored procedures to encapsulate complex SQL logic. Procedures like `compose_Email`, `view_inbox`, `edit_user_information`, and `delete_Email` handle various operations, ensuring that business logic is maintained within the database.
   - **Triggers**: Triggers are used to automate actions such as sending notifications when a new email is received (`email_trigger`) or when a user logs in (`login_trigger`).

### 3. **Transactions and Error Handling**
   - **Transactions**: Critical operations like composing an email or editing user information are wrapped in transactions to ensure atomicity. If any part of the transaction fails, the entire operation is rolled back to maintain data consistency.
   - **Error Handling**: The system uses a custom `exception` table to handle and log errors. Stored procedures like `get_exception` are used to retrieve error messages based on error codes.

### 4. **Views**
   - **Views**: The `personal_information` view is created to simplify the retrieval of user profile data. It combines relevant columns from the `user` table, providing a streamlined way to access user details.

### 5. **Indexing**
   - **Indexes**: Indexes are used on frequently queried columns like `username` and `email_ID` to improve query performance. For example, the `username` column in the `user` table is indexed to speed up login and profile retrieval operations.

## Tech Stack

### 1. **Backend**
   - **Database**: MySQL is used as the relational database management system. It handles all data storage, retrieval, and manipulation.
   - **Stored Procedures**: MySQL stored procedures are used to encapsulate business logic and ensure data integrity.
   - **Triggers**: MySQL triggers automate actions like sending notifications and logging user activities.

### 2. **Frontend**
   - **Java**: The user interface is built using Java, providing a command-line interface (CLI) for interacting with the system. The Java application connects to the MySQL database using JDBC (Java Database Connectivity).
   - **JDBC**: JDBC is used to establish a connection between the Java application and the MySQL database, allowing for seamless data exchange.

### 3. **Security**
   - **Password Hashing**: User passwords are hashed using MD5 before being stored in the database, ensuring that plaintext passwords are never stored.
   - **Access Control**: The system includes a `privileges_table` that controls which users can view the personal information of other users. This ensures that sensitive data is only accessible to authorized users.

## Features

### 1. **User Registration and Login**
   - Users can register by providing a username, password, and other personal details. The system checks for username availability and password strength.
   - Registered users can log in using their credentials. The system validates the username and password before granting access.

### 2. **Email Composition**
   - Users can compose emails by specifying recipients, CC recipients, a subject, and content. The system supports up to three recipients and three CC recipients per email.
   - Emails are stored in the `sents` table, and recipient information is stored in the `recipient_table`.

### 3. **Inbox and Sent Items**
   - Users can view their inbox and sent items. The system paginates the results, allowing users to view emails in batches of 10.
   - Emails in the inbox are marked as read or unread, and users can delete emails from both the inbox and sent items.

### 4. **Notifications**
   - The system sends notifications for various events, such as receiving a new email, logging in, or editing personal information. Notifications are stored in the `notification` table and displayed to the user.

### 5. **Profile Management**
   - Users can edit their personal information, including their password, security mobile number, address, and more. The system validates the input before updating the database.
   - Users can view their own information and, if granted access, the information of other users.

### 6. **Access Control**
   - Users can grant or revoke access to their personal information for other users. This is managed through the `privileges_table`.
   - If a user tries to view another user's profile without access, the system denies the request and logs the attempt.

### 7. **Email Deletion**
   - Users can delete emails from their inbox or sent items. The system marks the email as inactive in the `recipient_table` or `sents` table, ensuring that it is no longer visible to the user.

## Java UI

The Java-based user interface provides a command-line interface for interacting with the system. Users can perform various actions by entering commands, such as:

- **Compose Email**: Users can compose and send emails by entering recipient details, subject, and content.
- **View Inbox/Sent Items**: Users can view their inbox or sent items, with pagination support.
- **Read Email**: Users can read the content of a specific email by entering its ID.
- **Edit Information**: Users can update their personal information, including password, address, and more.
- **Delete Email**: Users can delete emails from their inbox or sent items.
- **Grant/Revoke Access**: Users can grant or revoke access to their personal information for other users.
- **View Profile**: Users can view their own profile or, if granted access, the profile of another user.
- **Notifications**: Users can view their notifications, which include alerts for new emails, login events, and profile updates.

## How to Run the Project

1. **Database Setup**:
   - Import the provided SQL file (`foofle.sql`) into your MySQL database. This will create all the necessary tables, stored procedures, and triggers.
   - Ensure that the MySQL server is running and accessible.

2. **Java Application**:
   - Open the `ConnectToDB.java` file in your preferred Java IDE.
   - Update the database connection URL, username, and password in the `main` method to match your MySQL configuration.
   - Compile and run the `ConnectToDB` class.

3. **Using the System**:
   - Upon running the Java application, you will be prompted to either register or log in.
   - Follow the on-screen instructions to perform various actions like composing emails, viewing your inbox, editing your profile, and more.

## Showcase of Database Skills

This project demonstrates a deep understanding of database design and development, including:

- **Database Normalization**: The database is designed to minimize redundancy and ensure data integrity.
- **Stored Procedures and Triggers**: Complex business logic is encapsulated within the database, ensuring that the application layer remains lightweight.
- **Transactions**: Critical operations are wrapped in transactions to maintain data consistency.
- **Error Handling**: Custom error handling ensures that the system can gracefully handle unexpected situations.
- **Access Control**: The system includes a robust access control mechanism, allowing users to manage who can view their personal information.

## Conclusion

Foofle is a sophisticated email management system that showcases advanced database design and development skills. The use of stored procedures, triggers, transactions, and error handling demonstrates a strong understanding of database concepts. The Java-based user interface provides a seamless way to interact with the system, making it an excellent addition to any CV as a showcase of database and backend development expertise.
