-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 21, 2020 at 03:53 PM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `foofle`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `checkLength` (IN `given_string` VARCHAR(20), IN `g_start` INT, IN `g_end` INT, OUT `res` SMALLINT)  SELECT EXISTS(SELECT CHARACTER_LENGTH(given_string) 
           		WHERE CHARACTER_LENGTH(given_string)>=g_start and 		CHARACTER_LENGTH(given_string)<= g_end )
INTO  res$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `checkUserNameIsTaken` (IN `wanted_username` VARCHAR(20), OUT `res` SMALLINT)  SELECT EXISTS(SELECT username
FROM user
WHERE username= wanted_username)
INTO res$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `compose_Email` (IN `entered_subject` VARCHAR(50), IN `entered_content` TEXT, IN `r1_username` VARCHAR(20), IN `r2_username` VARCHAR(20), IN `r3_username` VARCHAR(20), IN `ccr1_username` VARCHAR(20), IN `ccr2_username` VARCHAR(20), IN `ccr3_username` VARCHAR(20))  BEGIN
DECLARE exit handler for sqlexception
  BEGIN
   ROLLBACK;
END;
 
DECLARE exit handler for sqlwarning
 BEGIN
ROLLBACK;
END;
START TRANSACTION;
BEGIN
	DECLARE IndexID int;
    DECLARE s_username VARCHAR(20);
    CALL Current_username(s_username);
INSERT INTO sents(sender_username,deliver_time, subject, content) VALUES (s_username,CURRENT_TIMESTAMP,entered_subject,entered_content);
    SET IndexID=LAST_INSERT_ID();
    IF(r1_username IS NOT NULL)
    THEN
    INSERT INTO recipient_table(email_ID, recipient_username,type) VALUES (IndexID,r1_username,"recipient"); 
	END IF;
    IF(r2_username IS NOT NULL)
    THEN
    INSERT INTO recipient_table(email_ID, recipient_username,type) VALUES (IndexID,r2_username,"recipient"); 
	END IF;
    IF(r3_username IS NOT NULL)
    THEN
    INSERT INTO recipient_table(email_ID, recipient_username,type) VALUES (IndexID,r3_username,"recipient"); 
	END IF;
    IF(ccr1_username IS NOT NULL)
    THEN
    INSERT INTO recipient_table(email_ID, recipient_username,type) VALUES (IndexID,ccr1_username,"cc"); 
	END IF;
    IF(ccr2_username IS NOT NULL)
    THEN
    INSERT INTO recipient_table(email_ID, recipient_username,type) VALUES (IndexID,ccr2_username,"cc"); 
	END IF;
    IF(ccr3_username IS NOT NULL)
    THEN
    INSERT INTO recipient_table(email_ID, recipient_username,type) VALUES (IndexID,ccr3_username,"cc"); 
	END IF;
  
END;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `confirmPassword` (IN `entered_username` VARCHAR(20), IN `entered_password` VARCHAR(20), OUT `res` SMALLINT)  SELECT 1
INTO res 
WHERE EXISTS(SELECT * 
			FROM user
			WHERE password=MD5(entered_password) and 								username=entered_username)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Current_username` (OUT `c_user` VARCHAR(20))  BEGIN
SELECT username
FROM list_of_users_entered
WHERE entered_time=(SELECT MAX(entered_time)
                    FROM list_of_users_entered)
INTO c_user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_account` ()  BEGIN 
DECLARE user_in VARCHAR(20);
CALL Current_username(user_in);
DELETE FROM user
WHERE username=user_in ;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_Email` (IN `e_ID` INT, IN `box` VARCHAR(6), OUT `output` TEXT)  BEGIN 
DECLARE username VARCHAR(20);
DECLARE checkExist SMALLINT;
CALL email_exist(e_ID,box,checkExist);
CALL Current_username(username);
if(box='inbox')
THEN
	IF(checkExist=1)
    THEN
	UPDATE recipient_table
	SET active_for_recipient=0 
	WHERE email_ID=e_ID and recipient_username=username and active_for_recipient=1;
     SET output="deleted";
     ELSE
  	 CALL get_exception(7,output);
  	 END IF;

ELSEIF(box='sent')
THEN
	IF(checkExist=1)
    THEN
	UPDATE sents
	SET active_for_sender=0 , deliver_time=deliver_time
	WHERE e_ID=sents.ID and sender_username=username and active_for_sender=1;
    SET output="deleted";
    ELSE
     	CALL get_exception(7,output);
     	END IF;
    
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `edit_user_information` (IN `entered_password` VARCHAR(200), IN `entered_security_mobile_number` CHAR(110), IN `entered_address` TEXT, IN `entered_first_name` VARCHAR(200), IN `entered_last_name` VARCHAR(200), IN `entered_nickname` VARCHAR(200), IN `entered_birth_date` DATE, IN `entered_mobile_number` CHAR(110), IN `entered_national_ID` VARCHAR(100), OUT `out_message` TEXT)  BEGIN
DECLARE exit handler for sqlexception
  BEGIN
  CALL get_exception(6,out_message);
  ROLLBACK;
END;
 
DECLARE exit handler for sqlwarning
 BEGIN
 CALL get_exception(6,out_message);
 ROLLBACK;
END;
START TRANSACTION;
BEGIN
DECLARE entered_username VARCHAR(20);
DECLARE res1 SMALLINT;
CALL Current_username(entered_username);
CALL checkLength(entered_password,6,20,res1);
IF(res1=1)
THEN
UPDATE user
SET password=MD5(entered_password),security_mobile_number=entered_security_mobile_number,address=entered_address
,first_name=entered_first_name,last_name=entered_last_name,nickname=entered_nickname,birth_date=entered_birth_date
,mobile_number=entered_mobile_number
,national_ID=entered_national_ID,creation_date=creation_date
WHERE username=entered_username;
SET out_message="edited successful";
ELSE
CALL get_exception(1,out_message);
END IF;
END;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `email_exist` (IN `e_ID` INT, IN `box` VARCHAR(10), OUT `output` INT)  NO SQL
BEGIN
DECLARE userIn VARCHAR(20);
CALL Current_username(userIn);
IF (box="inbox")
THEN
SELECT EXISTS(SELECT *
              FROM recipient_table
              WHERE active_for_recipient=1 and e_ID=email_ID and userIn=recipient_username
)
INTO output;

ELSEIF(box="sent")
THEN
SELECT EXISTS(SELECT *
              FROM sents
              WHERE active_for_sender=1 and e_ID=ID and userIn=sender_username
)
INTO output;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_exception` (IN `e_ID` INT, OUT `output` TEXT)  SELECT content
FROM exception
WHERE e_ID=ID
INTO output$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `grant_access_to_user` (IN `given_username` VARCHAR(20), OUT `output` TEXT)  BEGIN 
DECLARE exit handler for sqlexception
  BEGIN
  CALL get_exception(3,output);
  ROLLBACK;
END;
 
DECLARE exit handler for sqlwarning
 BEGIN
 CALL get_exception(3,output);
 ROLLBACK;
END;
START TRANSACTION;
BEGIN
DECLARE owner_username VARCHAR(20);
DECLARE checkExist SMALLINT;
CALL Current_username(owner_username);
CALL checkUserNameIsTaken(given_username,checkExist);
IF(checkExist=1)
THEN
INSERT INTO `privileges_table`(`owner_username`, `receiver_username`) VALUES (owner_username,given_username);
SET output="granted";
ELSE
CALL get_exception(3,output);
END IF;
END;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Login` (IN `entered_username` VARCHAR(20), IN `pass` VARCHAR(20), OUT `out_message` TEXT)  BEGIN
DECLARE res SMALLINT;
DECLARE answer SMALLINT;
CALL checkUserNameIsTaken(entered_username,answer);
IF (answer=1)
THEN
CALL confirmPassword(entered_username,pass,res);
IF(res=1)
THEN
INSERT INTO list_of_users_entered(username,entered_time)VALUES (entered_username,CURRENT_TIMESTAMP);
SET out_message="Login successful";
ELSE 
CALL get_exception(2,out_message);
END IF;
ELSE 
CALL get_exception(3,out_message);
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `read_Email` (IN `e_ID` INT, IN `box` VARCHAR(6), OUT `output` TEXT)  BEGIN 
DECLARE username VARCHAR(20);
DECLARE checkExist SMALLINT;
CALL email_exist(e_ID,box,checkExist);
CALL Current_username(username);
IF(box='inbox')
THEN
	IF(checkExist=1)
    THEN
		SELECT 	sents.ID,sender_username,subject,deliver_time,content
		FROM sents INNER JOIN recipient_table
		WHERE sents.ID=email_ID and sents.ID=e_ID and active_for_recipient=1 and recipient_username=username for update;
       		 UPDATE recipient_table
			SET not_read_by_recipient=0 
			WHERE  e_ID=email_ID and username=recipient_username;
   ELSE
  	 CALL get_exception(7,output);
  	 END IF;

ELSEIF(box='sent')
THEN
	IF(checkExist=1)
    THEN
		SELECT ID,subject,deliver_time,content
		FROM sents 
		WHERE  active_for_sender=1 and ID=e_ID and username=sender_username;
     ELSE
     	CALL get_exception(7,output);
     	END IF;
END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registerUser` (IN `user_name` VARCHAR(200), IN `entered_password` VARCHAR(200), IN `e_security_mobile_number` CHAR(110), IN `e_address` TEXT, IN `e_first_name` VARCHAR(200), IN `e_last_name` VARCHAR(200), IN `e_nickname` VARCHAR(200), IN `e_birth_date` DATE, IN `e_mobile_number` CHAR(110), IN `e_national_ID` VARCHAR(100), OUT `output` TEXT)  BEGIN
DECLARE exit handler for sqlexception
  BEGIN
  CALL get_exception(6,output);
  ROLLBACK;
END;
 
DECLARE exit handler for sqlwarning
 BEGIN
 CALL get_exception(6,output);
 ROLLBACK;
END;
START TRANSACTION;
BEGIN
DECLARE Validate SMALLINT;
DECLARE res1 SMALLINT;
DECLARE res2 SMALLINT;
CALL checkUserNameIsTaken(user_name,Validate);
IF(Validate=0)
THEN
CALL checkLength(user_name,6,20,res1);
CALL checkLength(entered_password,6,20,res2);
IF(res1=1 and res2=1 )
THEN
INSERT INTO user(username, password, creation_date, security_mobile_number, address,first_name, last_name, nickname, birth_date, mobile_number, national_ID)
VALUES(user_name,MD5(entered_password),CURRENT_TIMESTAMP,e_security_mobile_number,e_address,e_first_name,e_last_name,e_nickname,e_birth_date,e_mobile_number,e_national_ID);
SET output="register successful";
ELSE
CALL get_exception(1,output);
END IF;
ELSE 
CALL get_exception(5,output);
END IF;
END;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `revoke_access_from_user` (IN `receiver` VARCHAR(20), OUT `output` TEXT)  BEGIN 
DECLARE exit handler for sqlexception
  BEGIN
  CALL get_exception(3,output);
  ROLLBACK;
END;
 
DECLARE exit handler for sqlwarning
 BEGIN
 CALL get_exception(3,output);
 ROLLBACK;
END;
START TRANSACTION;
BEGIN
DECLARE owner VARCHAR(20);
DECLARE checkExist SMALLINT;
CALL Current_username(owner);
CALL checkUserNameIsTaken(receiver,checkExist);
IF(checkExist=1)
THEN
DELETE FROM `privileges_table`
WHERE receiver_username=receiver AND owner_username=owner;
SET output="revoked";
ELSE
CALL get_exception(3,output);
END IF;
END;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_inbox` (IN `e_offset` INT)  BEGIN 
DECLARE given_username VARCHAR(20);
CALL Current_username(given_username);
SELECT sents.ID,sender_username,subject,not_read_by_recipient,deliver_time
FROM sents INNER JOIN recipient_table
WHERE  sents.ID=email_ID and recipient_username=given_username and active_for_recipient=1
ORDER by  deliver_time DESC
LIMIT 10 OFFSET e_offset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_notification` ()  BEGIN 
DECLARE e_username VARCHAR(20);
CALL Current_username(e_username);
SELECT `ID`, `username`, `content`, `Receipt_time` FROM `notification` WHERE e_username=username
ORDER BY Receipt_time DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_profile_of_other_user` (IN `owner` VARCHAR(20), OUT `output` TEXT)  BEGIN 
DECLARE exit handler for sqlexception
  BEGIN
  CALL get_exception(3,output);
  ROLLBACK;
END;
 
DECLARE exit handler for sqlwarning
 BEGIN
 CALL get_exception(3,output);
 ROLLBACK;
END;
START TRANSACTION;
BEGIN
DECLARE receiver VARCHAR(20);
CALL Current_username(receiver);

IF (SELECT EXISTS(SELECT *
              FROM privileges_table
              WHERE owner_username=owner and receiver_username=receiver
             )=1)
		THEN          
SELECT  `first_name`, `last_name`, `nickname`, `birth_date`, `mobile_number`, `address`, `national_ID`
FROM personal_information 
WHERE username=owner ;

INSERT INTO `notification`( `username`, `content`) VALUES (owner,CONCAT( CONVERT(receiver, VARCHAR(20)) , " wants to see your personal information and access is: true"));
ELSE

INSERT INTO `notification`( `username`, `content`) VALUES (owner,CONCAT( CONVERT(receiver, VARCHAR(20)) , " wants to see your personal information and access is: false"));

CALL get_exception(4,output);


END IF;
END;
COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_sent_Emails` (IN `e_offset` INT)  BEGIN 
DECLARE given_username VARCHAR(20);
CALL Current_username(given_username);
SELECT ID,subject,deliver_time
FROM sents 
WHERE sender_username=given_username and active_for_sender=1 
ORDER by  deliver_time DESC
LIMIT 10 OFFSET e_offset;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `view_user_information` ()  BEGIN 
DECLARE e_username VARCHAR(20);
CALL Current_username(e_username);
SELECT *
FROM user
WHERE username=e_username;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `exception`
--

CREATE TABLE `exception` (
  `content` text NOT NULL,
  `ID` int(225) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `exception`
--

INSERT INTO `exception` (`content`, `ID`) VALUES
('Length is not in declared span - operation unsuccessful', 1),
('password is incorrect - Login failed', 2),
('username is not exist - failed', 3),
('you dont have access to this object - process failed\r\n\r\n*  *  *  *  *  *  *  *  *', 4),
('User name is taken - register unsuccessful', 5),
('Transaction rolled back - incorrect input type or length out of declared span', 6),
('email does not exist -  process failed', 7);

-- --------------------------------------------------------

--
-- Table structure for table `list_of_users_entered`
--

CREATE TABLE `list_of_users_entered` (
  `username` varchar(20) NOT NULL,
  `entered_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `list_of_users_entered`
--

INSERT INTO `list_of_users_entered` (`username`, `entered_time`) VALUES
('kianahs', '2020-05-24 19:01:42'),
('kianahs', '2020-05-24 19:07:57'),
('kianahs', '2020-05-25 08:49:05'),
('kianahs', '2020-05-25 09:23:05'),
('kianahs', '2020-05-26 22:27:06'),
('kianahs', '2020-05-27 08:47:50'),
('kianahs', '2020-05-27 09:04:55'),
('kianahs', '2020-05-28 17:47:37'),
('kianahs', '2020-05-28 21:50:55'),
('kianahs', '2020-05-28 21:53:03'),
('kianahs', '2020-05-28 21:55:48'),
('kianahs', '2020-05-28 22:05:41'),
('kianahs', '2020-05-29 12:50:07'),
('kianahs', '2020-06-09 20:33:10'),
('kianahs', '2020-06-09 20:47:01'),
('kianahs', '2020-06-10 14:39:21'),
('kianahs', '2020-06-10 14:40:35'),
('kianahs', '2020-06-10 14:45:57'),
('kianahs', '2020-06-10 16:17:25'),
('kianahs', '2020-06-10 16:17:58'),
('kianahs', '2020-06-21 10:32:55'),
('kianahs', '2020-06-21 13:10:02'),
('kianahs', '2020-06-21 13:25:57'),
('kianahs', '2020-06-21 13:28:15'),
('kianahs', '2020-06-21 13:42:08'),
('parsahds', '2020-05-21 14:45:20'),
('parsaHDS', '2020-05-21 15:27:08'),
('parsahds', '2020-05-21 15:30:58'),
('parsaHDS', '2020-05-22 14:12:51'),
('parsahds', '2020-05-24 16:48:22'),
('parsahds', '2020-05-24 16:52:20'),
('parsahds', '2020-05-24 16:55:05'),
('parsahds', '2020-05-24 16:57:30'),
('parsahds', '2020-05-24 18:10:08'),
('parsahds', '2020-05-29 13:37:07'),
('parsahds', '2020-05-29 13:41:22'),
('parsahds', '2020-05-29 13:46:30'),
('parsahds', '2020-05-29 13:48:07'),
('parsahds', '2020-05-29 13:51:00'),
('parsahds', '2020-05-29 13:54:23'),
('parsahds', '2020-05-29 14:03:47'),
('parsahds', '2020-06-10 15:58:37'),
('saharshahedi', '2020-05-22 14:17:50'),
('saharshahedi', '2020-05-24 18:23:39'),
('saharshahedi', '2020-05-24 18:55:53'),
('saharshahedi', '2020-05-24 19:06:40'),
('salarhds', '2020-05-21 14:14:31'),
('salarHDS', '2020-05-21 14:18:20'),
('salarHDS', '2020-05-21 14:21:57'),
('salarhds', '2020-05-21 14:25:37'),
('salarhds', '2020-05-21 14:30:34'),
('salarhds', '2020-05-21 14:42:18'),
('salarhds', '2020-05-21 14:48:45'),
('salarhds', '2020-05-21 15:32:55'),
('salarhds', '2020-05-24 17:00:59'),
('salarhds', '2020-05-24 18:12:17'),
('salarhds', '2020-05-24 18:15:58'),
('salarhds', '2020-05-28 16:14:24');

--
-- Triggers `list_of_users_entered`
--
DELIMITER $$
CREATE TRIGGER `login_trigger` AFTER INSERT ON `list_of_users_entered` FOR EACH ROW INSERT INTO `notification` (`username`, `content`) VALUES (NEW.username,"you Loged in ")
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `notification`
--

CREATE TABLE `notification` (
  `ID` int(225) NOT NULL,
  `username` varchar(20) NOT NULL,
  `content` text NOT NULL,
  `Receipt_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `notification`
--

INSERT INTO `notification` (`ID`, `username`, `content`, `Receipt_time`) VALUES
(1, 'katiFTH', 'register successful! welcome to foofle', '2020-05-26 15:48:35'),
(3, 'parsahds', 'kianahs wants to see your personal information and access is: 1', '2020-05-26 18:03:39'),
(4, 'kianahs', 'your information has been edited successfuly', '2020-05-26 18:10:23'),
(5, 'kianahs', 'you receive new email', '2020-05-26 18:20:02'),
(6, 'kianahs', 'you delete email from inbox', '2020-05-26 20:45:10'),
(7, 'kianahs', 'you delete email from inbox', '2020-05-26 21:07:41'),
(8, 'saharshahedi', 'you delete email from sent', '2020-05-26 21:16:45'),
(9, 'kianahs', 'you delete email from inbox', '2020-05-26 21:17:30'),
(10, 'saharshahedi', 'you have got new email', '2020-05-27 08:49:21'),
(11, 'salarhds', 'you have got new email', '2020-05-27 08:49:21'),
(12, 'parsahds', 'you have got new email', '2020-05-27 08:49:21'),
(13, 'katifth', 'you have got new email', '2020-05-27 08:49:21'),
(14, 'parsahds', 'kianahs wants to see your personal information and access is: 1', '2020-05-27 09:17:44'),
(15, 'salarhds', 'you Loged in ', '2020-05-28 16:14:24'),
(16, 'minaahmadi', 'register successful! welcome to foofle', '2020-05-28 16:19:12'),
(17, 'kianahs', 'you Loged in ', '2020-05-28 17:47:37'),
(18, 'kianahs', 'you Loged in ', '2020-05-28 21:50:55'),
(19, 'kianahs', 'you Loged in ', '2020-05-28 21:53:03'),
(20, 'kianahs', 'you Loged in ', '2020-05-28 21:55:48'),
(21, 'minaahmadi', 'kianahs wants to see your personal information and access is: 1', '2020-05-28 21:55:56'),
(22, 'salarhds', 'kianahs wants to see your personal information and access is: 0', '2020-05-28 21:56:18'),
(23, 'kianahs', 'you Loged in ', '2020-05-28 22:05:41'),
(24, 'kianahs', 'you Loged in ', '2020-05-29 12:50:07'),
(25, 'parsahds', 'you Loged in ', '2020-05-29 13:37:07'),
(26, 'parsahds', 'you delete email from inbox', '2020-05-29 13:37:59'),
(27, 'minaahmadi', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:39:08'),
(28, 'kianahs', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:40:50'),
(29, 'parsahds', 'you Loged in ', '2020-05-29 13:41:22'),
(30, 'minaahmadi', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:41:29'),
(31, 'parsahds', 'you Loged in ', '2020-05-29 13:46:30'),
(32, 'minaahmadi', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:46:44'),
(33, 'parsahds', 'you Loged in ', '2020-05-29 13:48:07'),
(34, 'minaahmadi', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:48:20'),
(35, 'parsahds', 'you Loged in ', '2020-05-29 13:51:00'),
(36, 'minaahmadi', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:51:17'),
(37, 'parsahds', 'you Loged in ', '2020-05-29 13:54:23'),
(38, 'minaahmadi', 'parsahds wants to see your personal information and access is: 0', '2020-05-29 13:54:31'),
(39, 'parsahds', 'you Loged in ', '2020-05-29 14:03:47'),
(40, 'faribamc', 'register successful! welcome to foofle', '2020-05-30 05:24:35'),
(41, 'kianahs', 'you have got new email', '2020-06-08 18:26:31'),
(42, 'salarhds', 'you have got new email', '2020-06-08 22:14:56'),
(43, 'parsahds', 'you have got new email', '2020-06-08 22:14:56'),
(44, 'katifth', 'you have got new email', '2020-06-08 22:14:57'),
(45, 'katifth', 'you have got new email', '2020-06-08 22:19:24'),
(46, 'faribamc', 'you have got new email', '2020-06-08 22:19:24'),
(47, 'salarhds', 'you have got new email', '2020-06-08 22:19:24'),
(48, 'parsahds', 'you have got new email', '2020-06-08 22:19:24'),
(49, 'saharshahedi', 'you have got new email', '2020-06-08 22:19:24'),
(50, 'minaahmadi', 'you have got new email', '2020-06-08 22:19:24'),
(51, 'salarhds', 'you have got new email', '2020-06-08 22:32:36'),
(52, 'salarhds', 'you have got new email', '2020-06-08 22:33:17'),
(53, 'salarhds', 'you have got new email', '2020-06-08 22:33:38'),
(54, 'salarhds', 'you have got new email', '2020-06-08 22:34:04'),
(55, 'salarhds', 'you have got new email', '2020-06-08 22:34:08'),
(56, 'salarhds', 'you have got new email', '2020-06-08 22:35:48'),
(57, 'salarhds', 'you have got new email', '2020-06-08 22:37:15'),
(58, 'salarhds', 'you have got new email', '2020-06-08 22:44:31'),
(59, 'parsahds', 'you have got new email', '2020-06-08 22:44:31'),
(60, 'katifth', 'you have got new email', '2020-06-08 22:53:14'),
(61, 'parsahds', 'you have got new email', '2020-06-08 22:53:14'),
(62, 'salarhds', 'you have got new email', '2020-06-08 22:53:14'),
(63, 'faribamc', 'you have got new email', '2020-06-08 22:53:14'),
(64, 'minaahmadi', 'you have got new email', '2020-06-08 22:53:14'),
(65, 'kianahs', 'you have got new email', '2020-06-08 22:53:14'),
(67, 'kianahs', 'you have got new email', '2020-06-09 07:47:19'),
(68, 'parsahds', 'you have got new email', '2020-06-09 07:47:19'),
(69, 'salarhds', 'you have got new email', '2020-06-09 07:47:19'),
(70, 'faribamc', 'you have got new email', '2020-06-09 07:47:19'),
(71, 'minaahmadi', 'you have got new email', '2020-06-09 07:47:19'),
(72, 'saharshahedi', 'you have got new email', '2020-06-09 07:47:19'),
(73, 'salarHDS', 'faribamc wants to see your personal information and access is: true', '2020-06-09 08:34:49'),
(74, 'faribamc', 'katifth wants to see your personal information and access is: false', '2020-06-09 08:36:01'),
(78, 'shakibaamirshahi', 'register successful! welcome to foofle', '2020-06-09 09:40:07'),
(82, 'faezenaemi', 'register successful! welcome to foofle', '2020-06-09 09:50:22'),
(85, 'salarhds', 'you have got new email', '2020-06-09 12:28:08'),
(86, 'faribamc', 'you have got new email', '2020-06-09 12:28:08'),
(87, 'salarhds', 'you have got new email', '2020-06-09 12:28:34'),
(88, 'faribamc', 'you have got new email', '2020-06-09 12:28:34'),
(89, 'katifth', 'you have got new email', '2020-06-09 12:28:34'),
(90, 'parsahds', 'you have got new email', '2020-06-09 12:28:34'),
(91, 'minaahmadi', 'you have got new email', '2020-06-09 12:28:34'),
(92, 'saharshahedi', 'you have got new email', '2020-06-09 12:28:34'),
(93, 'salarhds', 'you have got new email', '2020-06-09 12:40:06'),
(94, 'salarhds', 'you have got new email', '2020-06-09 12:40:45'),
(95, 'salarhds', 'you have got new email', '2020-06-09 12:47:57'),
(96, 'parsahds', 'you have got new email', '2020-06-09 12:47:57'),
(97, 'salarhds', 'you have got new email', '2020-06-09 12:51:06'),
(98, 'salarhds', 'you have got new email', '2020-06-09 12:54:48'),
(99, 'salarhds', 'you have got new email', '2020-06-09 13:50:40'),
(100, 'salarHDS', 'you have got new email', '2020-06-09 17:26:54'),
(102, 'kianahs', 'you Loged in ', '2020-06-09 20:33:10'),
(103, 'kianahs', 'you Loged in ', '2020-06-09 20:47:01'),
(104, 'kianahs', 'your information has been edited successfuly', '2020-06-09 21:08:29'),
(109, 'kianahs', 'you Loged in ', '2020-06-10 14:39:21'),
(110, 'kianahs', 'you Loged in ', '2020-06-10 14:40:35'),
(111, 'kianahs', 'you Loged in ', '2020-06-10 14:45:57'),
(112, 'parsaHDS', 'you have got new email', '2020-06-10 14:46:40'),
(113, 'kianahs', 'you have got new email', '2020-06-10 14:55:12'),
(114, 'parsaHDS', 'kianahs wants to see your personal information and access is: true', '2020-06-10 14:59:19'),
(115, 'shakibaamirshahi', 'kianahs wants to see your personal information and access is: false', '2020-06-10 14:59:39'),
(116, 'parsahds', 'you Loged in ', '2020-06-10 15:58:37'),
(117, 'kianahs', 'you Loged in ', '2020-06-10 16:17:25'),
(118, 'kianahs', 'you Loged in ', '2020-06-10 16:17:58'),
(120, 'kianahs', 'you Loged in ', '2020-06-21 10:32:55'),
(137, 'faribamc', 'kianahs wants to see your personal information and access is: true', '2020-06-21 13:08:14'),
(140, 'faribamc', 'kianahs wants to see your personal information and access is: true', '2020-06-21 13:09:28'),
(141, 'kianahs', 'you Loged in ', '2020-06-21 13:10:02'),
(142, 'faribamc', 'kianahs wants to see your personal information and access is: true', '2020-06-21 13:10:15'),
(143, 'salarhds', 'kianahs wants to see your personal information and access is: false', '2020-06-21 13:10:35'),
(146, 'salarHDS', 'kianahs wants to see your personal information and access is: false', '2020-06-21 13:17:17'),
(147, 'kianahs', 'you Loged in ', '2020-06-21 13:25:57'),
(148, 'salarhds', 'you have got new email', '2020-06-21 13:26:35'),
(149, 'kianahs', 'you Loged in ', '2020-06-21 13:28:15'),
(150, 'salarhds', 'you have got new email', '2020-06-21 13:30:38'),
(151, 'faribamc', 'you have got new email', '2020-06-21 13:30:38'),
(152, 'saharshahedi', 'your information has been edited successfuly', '2020-06-21 13:32:20'),
(153, 'kianahs', 'you Loged in ', '2020-06-21 13:42:08'),
(154, 'kianahs', 'you have got new email', '2020-06-21 13:43:04');

-- --------------------------------------------------------

--
-- Stand-in structure for view `personal_information`
-- (See below for the actual view)
--
CREATE TABLE `personal_information` (
`username` varchar(20)
,`first_name` varchar(20)
,`last_name` varchar(20)
,`nickname` varchar(20)
,`birth_date` date
,`mobile_number` char(11)
,`address` text
,`national_ID` varchar(10)
);

-- --------------------------------------------------------

--
-- Table structure for table `privileges_table`
--

CREATE TABLE `privileges_table` (
  `owner_username` varchar(20) NOT NULL,
  `receiver_username` varchar(20) NOT NULL,
  `grant_time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `privileges_table`
--

INSERT INTO `privileges_table` (`owner_username`, `receiver_username`, `grant_time`) VALUES
('faribamc', 'kianahs', '2020-05-30 05:24:35'),
('faribamc', 'minaahmadi', '2020-05-30 05:24:35'),
('faribamc', 'parsaHDS', '2020-05-30 05:24:35'),
('faribamc', 'saharshahedi', '2020-05-30 05:24:36'),
('faribamc', 'salarHDS', '2020-05-30 05:24:36'),
('katiFTH', 'faribamc', '2020-05-30 05:24:35'),
('katiFTH', 'minaahmadi', '2020-05-28 16:24:39'),
('kianahs', 'faribamc', '2020-05-30 05:24:35'),
('kianahs', 'minaahmadi', '2020-05-28 16:24:39'),
('kianahs', 'parsahds', '2020-05-30 05:03:43'),
('minaahmadi', 'faribamc', '2020-05-30 05:24:35'),
('minaahmadi', 'katiFTH', '2020-05-28 16:24:39'),
('minaahmadi', 'kianahs', '2020-05-28 16:24:39'),
('minaahmadi', 'parsaHDS', '2020-05-28 16:24:39'),
('minaahmadi', 'saharshahedi', '2020-05-28 16:24:39'),
('minaahmadi', 'salarHDS', '2020-05-28 16:24:39'),
('parsaHDS', 'faribamc', '2020-05-30 05:24:35'),
('parsaHDS', 'kianahs', '2020-05-28 16:24:39'),
('parsaHDS', 'minaahmadi', '2020-05-28 16:24:39'),
('parsaHDS', 'salarHDS', '2020-05-28 16:24:39'),
('saharshahedi', 'faribamc', '2020-05-30 05:24:36'),
('saharshahedi', 'kianahs', '2020-05-28 16:24:39'),
('saharshahedi', 'minaahmadi', '2020-05-28 16:24:39'),
('saharshahedi', 'parsaHDS', '2020-05-28 16:24:39'),
('saharshahedi', 'salarHDS', '2020-05-28 16:24:39'),
('salarHDS', 'faribamc', '2020-05-30 05:24:36'),
('salarHDS', 'minaahmadi', '2020-05-28 16:24:39');

-- --------------------------------------------------------

--
-- Table structure for table `recipient_table`
--

CREATE TABLE `recipient_table` (
  `ID` int(225) NOT NULL,
  `email_ID` int(225) NOT NULL,
  `recipient_username` varchar(20) NOT NULL,
  `active_for_recipient` tinyint(4) NOT NULL DEFAULT 1,
  `not_read_by_recipient` tinyint(4) NOT NULL DEFAULT 1,
  `type` varchar(10) NOT NULL DEFAULT 'recipient'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `recipient_table`
--

INSERT INTO `recipient_table` (`ID`, `email_ID`, `recipient_username`, `active_for_recipient`, `not_read_by_recipient`, `type`) VALUES
(56, 67, 'salarhds', 1, 1, 'recipient'),
(57, 67, 'faribamc', 1, 1, 'recipient'),
(59, 68, 'salarhds', 1, 1, 'recipient'),
(60, 68, 'faribamc', 1, 1, 'recipient'),
(61, 68, 'katifth', 1, 1, 'recipient'),
(62, 68, 'parsahds', 1, 1, 'cc'),
(63, 68, 'minaahmadi', 1, 1, 'cc'),
(64, 68, 'saharshahedi', 1, 1, 'cc'),
(65, 69, 'salarhds', 1, 1, 'recipient'),
(67, 70, 'salarhds', 1, 1, 'recipient'),
(73, 73, 'salarhds', 1, 1, 'recipient'),
(84, 81, 'salarhds', 1, 1, 'recipient'),
(85, 81, 'faribamc', 1, 1, 'recipient'),
(86, 82, 'kianahs', 1, 0, 'recipient');

--
-- Triggers `recipient_table`
--
DELIMITER $$
CREATE TRIGGER `email_trigger` AFTER INSERT ON `recipient_table` FOR EACH ROW INSERT INTO `notification`( `username`, `content`) VALUES (NEW.recipient_username,"you have got new email")
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `sents`
--

CREATE TABLE `sents` (
  `ID` int(225) NOT NULL,
  `sender_username` varchar(20) NOT NULL,
  `deliver_time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `subject` varchar(50) NOT NULL,
  `content` text NOT NULL,
  `active_for_sender` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `sents`
--

INSERT INTO `sents` (`ID`, `sender_username`, `deliver_time`, `subject`, `content`, `active_for_sender`) VALUES
(66, 'kianahs', '2020-06-09 11:52:21', 'foofle2', 'note', 1),
(67, 'kianahs', '2020-06-09 12:28:08', 'RESULT', 'CHECK FUCTION', 1),
(68, 'kianahs', '2020-06-09 12:28:34', 'RESULT', 'CHECK FUCTION', 1),
(69, 'kianahs', '2020-06-09 12:40:06', 'salam', 'hi check your inbox', 1),
(70, 'kianahs', '2020-06-09 12:40:45', 'salam', 'hi check your inbox', 1),
(73, 'kianahs', '2020-06-09 12:54:48', 'check ', 'note', 1),
(74, 'kianahs', '2020-06-09 13:24:18', 'check', 'check function compose', 1),
(81, 'kianahs', '2020-06-21 13:30:38', 'new', '', 1),
(82, 'kianahs', '2020-06-21 13:43:04', 'retry', '', 1);

-- --------------------------------------------------------

--
-- Table structure for table `user`
--

CREATE TABLE `user` (
  `username` varchar(20) NOT NULL,
  `password` varchar(100) NOT NULL,
  `creation_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `security_mobile_number` char(11) NOT NULL,
  `address` text NOT NULL,
  `first_name` varchar(20) NOT NULL,
  `last_name` varchar(20) NOT NULL,
  `nickname` varchar(20) NOT NULL,
  `birth_date` date NOT NULL,
  `mobile_number` char(11) NOT NULL,
  `national_ID` varchar(10) NOT NULL,
  `default_access` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `user`
--

INSERT INTO `user` (`username`, `password`, `creation_date`, `security_mobile_number`, `address`, `first_name`, `last_name`, `nickname`, `birth_date`, `mobile_number`, `national_ID`, `default_access`) VALUES
('faezenaemi', '80c0c6b7f1d427af61b6a021b67aeb80', '2020-06-09 09:50:22', '09120213684', 'none', 'faeze', 'naemi', 'faaaze', '2001-08-02', '09120213684', '54465', 0),
('faribamc', '3b3e093c39544be5a1ed51e0fad0e236', '2020-05-30 05:24:35', '023564', '1', 'fari', 'ba', 'far', '2021-03-01', '78564', '45678', 0),
('katiFTH', '*E6A34F6BA97757174F86AA08E3CACAA9D3B9655A', '2020-05-26 15:48:35', '09120541236', 'tehran heravi', 'katayoon', 'fathollahi', 'kati', '2000-05-03', '09120874563', '22565', 0),
('kianahs', '25b75fbff37116f8abd3e63079adc6b9', '2020-05-18 10:18:38', '09120213684', 'germany cologne', 'kiana', 'hadysadegh', 'kiana', '1999-11-21', '09120213684', '78954', 0),
('minaahmadi', 'eebca1dd6abfca82aeae54ecd60d13be', '2020-05-28 16:19:12', '09120456585', 'tehran taleghani', 'mina', 'ahmadi', 'mina', '1998-03-01', '09120365478', '88965', 0),
('parsaHDS', '6ddc2da1ecb8e0f561e405c5e30f7159', '2020-05-21 14:12:40', '09120213684', ' tehran iran', 'parsa', 'hadi', 'pars', '2001-03-06', '09120326598', '22548', 0),
('saharshahedi', '6881557a54767050d89eef644a8dfdee', '2020-05-22 13:49:13', '09120547896', 'tehran', 'sahar', 'shahedi', 'sahar', '2001-03-09', '09120325698', '44589', 0),
('salarHDS', '0596200c5cc9dfefa31ffbdd9fe20688', '2020-05-21 14:13:58', '09120326598', ' tehran iran', 'salar', 'sadegh', 'salar', '1964-02-06', '09120549874', '55698', 0),
('shakibaamirshahi', '45e011441bdd667b7a8ff2400b408a78', '2020-06-09 09:40:07', '09120213684', 'tehranpars', 'shakiba', 'amirshahi', 'shakib', '2003-02-09', '09120213684', '789546', 0);

--
-- Triggers `user`
--
DELIMITER $$
CREATE TRIGGER `edit_information_trigger` AFTER UPDATE ON `user` FOR EACH ROW INSERT INTO `notification`( `username`, `content`) VALUES (NEW.username,"your information has been edited successfuly")
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `register_trigger` AFTER INSERT ON `user` FOR EACH ROW INSERT INTO `notification`( `username`, `content`) VALUES (NEW.username,"register successful! welcome to foofle")
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure for view `personal_information`
--
DROP TABLE IF EXISTS `personal_information`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `personal_information`  AS  select `user`.`username` AS `username`,`user`.`first_name` AS `first_name`,`user`.`last_name` AS `last_name`,`user`.`nickname` AS `nickname`,`user`.`birth_date` AS `birth_date`,`user`.`mobile_number` AS `mobile_number`,`user`.`address` AS `address`,`user`.`national_ID` AS `national_ID` from `user` ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `exception`
--
ALTER TABLE `exception`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `list_of_users_entered`
--
ALTER TABLE `list_of_users_entered`
  ADD PRIMARY KEY (`entered_time`),
  ADD KEY `foreign key from userlist to user` (`username`);

--
-- Indexes for table `notification`
--
ALTER TABLE `notification`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `foreign key form notification to user` (`username`);

--
-- Indexes for table `privileges_table`
--
ALTER TABLE `privileges_table`
  ADD PRIMARY KEY (`owner_username`,`receiver_username`),
  ADD KEY `foreign key receiver username` (`receiver_username`);

--
-- Indexes for table `recipient_table`
--
ALTER TABLE `recipient_table`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `foreign key email ID` (`email_ID`),
  ADD KEY `foreign key recipient username` (`recipient_username`);

--
-- Indexes for table `sents`
--
ALTER TABLE `sents`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `foreign key sender` (`sender_username`);

--
-- Indexes for table `user`
--
ALTER TABLE `user`
  ADD PRIMARY KEY (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `exception`
--
ALTER TABLE `exception`
  MODIFY `ID` int(225) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `notification`
--
ALTER TABLE `notification`
  MODIFY `ID` int(225) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=155;

--
-- AUTO_INCREMENT for table `recipient_table`
--
ALTER TABLE `recipient_table`
  MODIFY `ID` int(225) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=87;

--
-- AUTO_INCREMENT for table `sents`
--
ALTER TABLE `sents`
  MODIFY `ID` int(225) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=83;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `list_of_users_entered`
--
ALTER TABLE `list_of_users_entered`
  ADD CONSTRAINT `foreign key from userlist to user` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `notification`
--
ALTER TABLE `notification`
  ADD CONSTRAINT `foreign key form notification to user` FOREIGN KEY (`username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `privileges_table`
--
ALTER TABLE `privileges_table`
  ADD CONSTRAINT `foreign key owner username` FOREIGN KEY (`owner_username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `foreign key receiver username` FOREIGN KEY (`receiver_username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `recipient_table`
--
ALTER TABLE `recipient_table`
  ADD CONSTRAINT `foreign key email ID` FOREIGN KEY (`email_ID`) REFERENCES `sents` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `foreign key recipient username` FOREIGN KEY (`recipient_username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Constraints for table `sents`
--
ALTER TABLE `sents`
  ADD CONSTRAINT `foreign key sender` FOREIGN KEY (`sender_username`) REFERENCES `user` (`username`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
