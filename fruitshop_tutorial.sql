CREATE DATABASE FruitShop;
USE FruitShop;

CREATE TABLE Units (
UnitId TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
UnitName VARCHAR(10) NOT NULL,
DateEntered DATETIME NOT NULL,
DateUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (UnitId));		/* setting a primary key calls out an unique identifier for each row of data 
(a lot of times it is an index that you set with AUTO_INCREMENT to ensure a unique number */


DROP TABLE IF EXISTS Fruit;
CREATE TABLE Fruit (
FruitId SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
FruitName VARCHAR(45) NOT NULL, 
Inventory SMALLINT UNSIGNED NOT NULL,
UnitId TINYINT UNSIGNED NOT NULL,
DateEntered DATETIME NOT NULL,
DateUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (FruitId),
CONSTRAINT fkFruitUnits FOREIGN KEY (UnitId) REFERENCES Units (UnitId) 
ON DELETE RESTRICT ON UPDATE CASCADE); 
/* a foriegn key allows us to easily reference similiar data between two 
	tables within the same DATABASE */

INSERT INTO Units 
VALUES 
(1,'Piece','2015-02-15 10:30:00','2015-02-15 10:30:00'),
(2,'Kilogram','2015-02-15 10:30:00','2015-02-15 10:30:00'),
(3,'Gram','2015-02-15 10:30:00','2015-02-15 10:30:00'),
(4,'Pound','2015-02-15 10:30:00','2015-02-15 10:30:00'),
(5,'Ounce','2015-02-15 10:30:00','2015-02-15 10:30:00'),
(6,'Bunch','2015-02-15 10:30:00','2015-02-15 10:30:00'),
(7,'Container','2015-02-15 10:30:00','2015-02-15 10:30:00');
	
INSERT INTO Fruit 
VALUES 
(1,'Apple',10,1,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(2,'Orange',5,2,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(3,'Banana',20,6,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(4,'Watermelon',10,1,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(5,'Grapes',15,6,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(6,'Strawberry',12,7,'2015-02-15 10:30:00','2015-02-15 10:30:00');

-- Selecting Data 

SELECT FruitId, FruitName 
FROM Fruit;

SELECT * FROM Fruit
WHERE UnitId = 1;

-- What if we didn't know the UnitId? 
-- What if we only knew to look for those records with a unit name of Piece?

SELECT * FROM Fruit  			/* selecting all records from the Fruit table */
WHERE UnitId = 					/* where the Fruit table's unit id ... */ 
	(SELECT UnitId 				/* matches the unit id */
    FROM Units 					/* in the other table called units */
    WHERE UnitName = 'Piece'); 	/* when that row had a unit name Piece */

-- since on the units table the unit id associated with a 'Piece' of fruit is 1, 
		-- then any fruit in the Fruit table with an unit id of 1 should be returned in our pull
-- also when we created the Fruit table UnitId was called out as a FORIEGN KEY 
		-- that allows us to use it as a reference between tables

/* Ref code that set that Foriegn Key and ties changes to the data together through CASCADE:
CONSTRAINT fkFruitUnits FOREIGN KEY (UnitId) REFERENCES Units (UnitId) 
ON DELETE RESTRICT ON UPDATE CASCADE */ 

-- Doing the same thing but with an INNER JOIN for efficiency -- 
-- INNER JOIN will return only the selected data that meets all criteria

SELECT Fruit.* FROM Fruit
INNER JOIN Units
ON Fruit.UnitId = Units.UnitId
WHERE Units.UnitName = 'Piece';

-- OUTER JOINS: unmatched rows in one or both tables can be returned
-- Types of OUTER JOINS 
	-- LEFT JOIN: all rows from the left or first table, data from the other table will only be displayed if it intersects with the first table
    -- RIGHT JOIN: all rows from the right or second table, data from the other table will only be displayed if it intersects with that second table
    -- FULL JOIN: all rows from both tables will appear in your pull but some may not match so then you must insert NULLS
	-- CROSS JOIN: each row from both tables that were combined in the join 
-- UNIONS are when you place one set of data directly on top of another and the columns must match to be incorporated 

-- EXAMPLE OF LEFT OUTER JOIN -- 
-- add the Unit Name from the Units Table to the data on the Fruit Table 
SELECT f.*, u.UnitName FROM Fruit f
LEFT JOIN Units u
ON f.UnitId = u.UnitId;

-- EXAMPLE OF RIGHT OUTER JOIN -- 
-- add the Fruit Name from the Fruits Table to the data on the Unit Table 
SELECT f.FruitName, u.* FROM Fruit f
RIGHT JOIN Units u
ON f.UnitId = u.UnitId;
/* this will result in a table with NULL values because there isnt a FruitName to coorespond with every UnitID within the Units Table */

-- REMOVING THE NULL VALUES and CHANGE THE ORDER  -- 
SELECT f.FruitName, u.* FROM Fruit f
RIGHT JOIN Units u
ON f.UnitId = u.UnitId 
WHERE f.fruitname IS NOT NULL
ORDER BY f.unitid;

-- MySQL for some reason does not allow for CROSS and FULL OUTER JOINS? so I can't verify my code --
-- but it would return all data indicated and the overlapping would be NULL because it would return duplicate -- 

-- EXAMPLE OF FULL OUTER JOIN -- 
-- add the Fruit Name from the Fruits Table to the data on the Unit Table 

-- SELECT f.*, u.* FROM Fruit f
-- FULL JOIN Units u
-- ON f.UnitId = u.UnitId;

-- SELF JOINS:  used to join a table to itself when using a join
-- so if we wanted to see all the fruit data where a Fruit ID matched any Unit ID within the same 

SELECT DISTINCT f1.* FROM Fruit f1 		/* used select distinct so that we only got the info for one row vs multiple */
INNER JOIN Fruit f2
ON f1.fruitid = f2.unitid;

-- VIEWS --
-- creating a view lets you have a saved option for a certain query -- 

CREATE VIEW vFruitInventory AS
SELECT 
    Fruit.FruitName,
    Fruit.Inventory,
    Units.UnitName
FROM
	Fruit INNER JOIN Units ON
    Fruit.UnitId = Units.UnitId;

-- after the view is created you can simply call it forward -- 
SELECT * FROM vFruitInventory; 
-- views are saved within the schema package of a SQL package (along with your tables and other stored functions --


