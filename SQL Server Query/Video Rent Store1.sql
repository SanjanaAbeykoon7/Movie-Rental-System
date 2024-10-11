CREATE DATABASE video_rent__store;
USE video_rent__store;

CREATE TABLE movie(
movieNo INT PRIMARY KEY NOT NULL,
title VARCHAR(255) NOT NULL,
genre VARCHAR(100) NOT NULL,
format VARCHAR(10) CHECK (format in ('VHS', 'VCD', 'DVD')) NOT NULL,
);

CREATE TABLE member(
memberID INT PRIMARY KEY NOT NULL,
phoneNo VARCHAR(15) UNIQUE NOT NULL,
memberType VARCHAR(10) CHECK (memberType in ('golden', 'bronze')) NOT NULL,
creditCardInfo VARCHAR(16) NULL,
CONSTRAINT CHK_creditCardInfo CHECK (memberType = 'golden' OR creditCardInfo IS NULL)
-- Ensuring creditCardInfo is provided only for golden members
);

CREATE TABLE rental(
rentalID INT PRIMARY KEY NOT NULL,
rentDate DATE NOT NULL,
returnDate DATE,
memberID INT NULL,
dependentID INT NULL,
movieNo INT NOT NULL,
FOREIGN KEY (memberID) REFERENCES member(memberID),
FOREIGN KEY (movieNo) REFERENCES movie(movieNo),
FOREIGN KEY (dependentID) REFERENCES dependent(dependentID),
CONSTRAINT CHK_renterType CHECK (
(memberID IS NOT NULL AND dependentID IS NULL) OR
(memberID IS NULL AND dependentID IS NOT NULL)
)
);

CREATE TABLE dependent(
dependentID INT PRIMARY KEY NOT NULL,
name VARCHAR(255) NOT NULL,
memberID INT NOT NULL,
FOREIGN KEY (memberID) REFERENCES member(memberID)
);

INSERT INTO movie
(movieNo, title, genre, format)
VALUES
(101, 'Dark', 'Adventure', 'DVD'),
(102, 'Mr Bean', 'Comedy', 'VHS'),
(103, 'Dictator', 'Comedy', 'VCD'),
(104, 'Babylon', 'Comedy', 'DVD'),
(105, 'Avengers', 'Action', 'DVD'),
(106, 'Arrow', 'Adventure', 'VCD'),
(107, 'Bad Boys', 'Action', 'VHS'),
(108, 'Transformers', 'Adventure', 'VCD'),
(109, 'Troy', 'Adventure', 'VCD'),
(110, 'Affair', 'Comedy', 'DVD'),
(111, 'Dark Knight', 'Adventure', 'DVD'),
(112, 'Who Am I', 'Action', 'DVD'),
(113, 'Malena', 'Action', 'VHS'),
(114, 'BayWatch', 'Adventure', 'VCD'),
(115, 'My Spy', 'Comedy', 'DVD');

INSERT INTO member
(memberID, phoneNo, memberType, creditCardInfo)
VALUES
(1, '0762147408', 'golden', '0123456789012345'),
(2, '0771234567', 'golden', '0123456789012346'),
(3, '0771234568', 'bronze', NULL),
(4, '0771234569', 'bronze', NULL),
(5, '0771234561', 'bronze', NULL),
(6, '0771234562', 'golden', '0123456789012347'),
(7, '0771234563', 'bronze', NULL),
(8, '0771234564', 'golden', '0123456789012348'),
(9, '0771234565', 'bronze', NULL),
(10, '0771234566', 'bronze', NULL),
(11, '0761234561', 'golden', '0123456789012349'),
(12, '0761234562', 'bronze', NULL),
(13, '0761234563', 'bronze', NULL),
(14, '0761234564', 'bronze', NULL),
(15, '0761234565', 'golden', '0123456789012350');

INSERT INTO rental
(rentalID, rentDate, returnDate, memberID, dependentID, movieNo)
VALUES
(1, '2024-1-2', '2024-1-3', 1, NULL, 101),
(2, '2024-1-4', '2024-1-5', 2, NULL, 102),
(3, '2024-1-6', '2024-1-7', 3, NULL, 103),
(4, '2024-1-8', NULL, 4, NULL, 104),
(5, '2024-1-10', '2024-1-11', NULL, 5, 105),
(6, '2024-1-12', '2024-1-13', NULL, 6, 106),
(7, '2024-1-14', '2024-1-15', NULL, 7, 107),
(8, '2024-1-16', '2024-1-17', 8, NULL, 108),
(9, '2024-1-18', '2024-1-19', 9, NULL, 109),
(10, '2024-1-20', '2024-1-21', 10, NULL, 110),
(11, '2024-1-22', '2024-1-23', 11, NULL, 111),
(12, '2024-1-24', '2024-1-25', 12, NULL, 112),
(13, '2024-1-26', NULL, NULL, 13, 113),
(14, '2024-1-28', '2024-1-29', NULL, 14, 114),
(15, '2024-1-29', '2024-1-30', NULL, 15, 115);

INSERT INTO dependent
(dependentID, name, memberID)
VALUES
(1, 'Ranil', 2),
(2, 'Sanjana', 1),
(3, 'Pasan', 3),
(4, 'John', 6),
(5, 'Himash', 5),
(6, 'Adam', 4),
(7, 'Harry', 7),
(8, 'Potter', 9),
(9, 'Chamath', 8),
(10, 'Hirusha', 15),
(11, 'Sakun', 10),
(12, 'Anura', 14),
(13, 'Smith', 13),
(14, 'Sadew', 11),
(15, 'Arosh', 12);

SELECT * FROM movie;

SELECT
m.title,
m.genre,
m.format,
r.rentDate,
r.returnDate
FROM rental r
JOIN movie m ON r.movieNo = m.movieNo
WHERE r.memberID = NULL OR r.dependentID = 5;
-- Replace @memberID with actual memberID/@dependentID with actual dependentID

SELECT
memberID,
phoneNo,
memberType,
creditCardInfo
FROM member WHERE memberType = 'golden';

SELECT
movieNo,
COUNT(rentalID) AS totalRentals
FROM rental GROUP BY movieNo;

--Step 1: bronze members who reached rental limit (1 active rental)
SELECT
m.memberID AS renterID,
'bronze' AS memberType,
COUNT(r.rentalID) AS activeRentals
FROM member m
JOIN rental r ON m.memberID = r.memberID
WHERE 
m.memberType = 'bronze' AND r.returnDate IS NULL
GROUP BY m.memberID
HAVING COUNT(r.rentalID) >= 1

UNION

--Step 2: dependents who reached rental limit (1 active rental)
SELECT
d.dependentID AS renterID,
'dependent' AS memberType,
COUNT(r.rentalID) AS activeRentals
FROM dependent d
JOIN rental r ON d.dependentID = r.dependentID
WHERE 
r.returnDate IS NULL
GROUP BY d.dependentID
HAVING COUNT(r.rentalID) >= 1;