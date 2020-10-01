-- Bookshop Example Overview: 
	-- At this fake bookstore their inventory data is organized by Subject Category and given a unique ID related to that category 
	-- Each book title can be sold in multiple formats and each format also has a unique ID 

CREATE DATABASE BookShop;
USE BookShop;

-- CREATING DATA TABLES --

-- First, I will create a reference table for the format IDs 
CREATE TABLE Format_Ref (
Format_Id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
Format_Name VARCHAR(20) NOT NULL,
PRIMARY KEY (Format_Id));		
/* setting a primary key calls out an unique identifier for each row of data 
(very often it is an index that you set with AUTO_INCREMENT to ensure a unique number) */

INSERT INTO Format_Ref
VALUES 
(1,'Hard Cover'),
(2,'Paperback'),
(3,'Audio'),
(4,'Electronic'),
(5,'Pocket'),
(6,'Workbook'),
(7,'Other');

 -- Next, I will create a table of category overview information, including a column that will reference the 'Top Format' for each category 
CREATE TABLE Category (
Cat_Id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
Cat_Name VARCHAR(45) NOT NULL, 
Inventory SMALLINT UNSIGNED NOT NULL,
Top_Format_Id TINYINT UNSIGNED NOT NULL,
DateEntered DATETIME NOT NULL,
DateUpdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
PRIMARY KEY (Cat_Id),
CONSTRAINT fkCategoryFormat FOREIGN KEY (Top_Format_Id) REFERENCES Format_Ref (Format_Id)	
ON DELETE RESTRICT ON UPDATE CASCADE); 
/* a foriegn key allows me to easily reference similiar data between two tables within the same DATABASE, 
also when implementing a foriegn key it is best to indicate to your tables how to maintain data integrity 
just incase the parent table is changed with either "on delete" and/or "on update" */
	
INSERT INTO Category 
VALUES
(1,'Classics',10,1,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(2,'Romance',5,2,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(3,'SciFi',20,2,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(4,'Travel',10,5,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(5,'Youth',15,4,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(6,'Education',12,6,'2015-02-15 10:30:00','2015-02-15 10:30:00'),
(7,'Biography',7,1,'2015-02-15 10:30:00','2015-02-15 10:30:00');

-- MODIFYING DATA TO AN EXISTING TABLE --

-- I think the DateEntered column is redunant and I want to drop it from my table so it runs faster
ALTER TABLE Category
DROP COLUMN DateEntered;

-- Looks like someone else in my company was using that data so I better add it back in
ALTER TABLE Category
ADD COLUMN DateEntered DATETIME
AFTER Top_Format_ID;
/* I want to add the column back to the same place I dropped it from so I add 'after top_format_ID' */

/* I have a couple of options here on how to add the data back into the column
1. I can create a new data table with the column data and then do an INSERT INTO function 
2. I can update each row with the update statement 
(and since I am adding the same date to all I am going to quickly do this)*/

UPDATE category
SET DateEntered='2015-02-15 10:30:00'
WHERE Cat_Id>='1';

/* data can also be uploaded to your server in different ways based on the management system 
and most commonly in the format of a .txt, .cvs, or .tab */

-- SELECT QUERY --

-- let's take a look at our reference list 
SELECT Format_Name, Format_id
FROM Format_Ref; 
/* or all (*) */

-- I might need to know which categories have a top format of paperback books (ID 2)
SELECT * FROM Category
WHERE Top_Format_ID = 2;

-- What if I didn't know the Product ID for paperbacks was a 2 but I needed to look for categories where the top seller is paperback?
SELECT * FROM Category 	/* selecting all records from the Category Table */
WHERE Top_Format_ID = 	/* where the row's indicated top format ID ... */ 
	(SELECT Format_ID 	/* matches the format ID */
    FROM Format_Ref 	/* from the reference table */
    WHERE Format_Name = 'paperback'); /* where the row has a format name of paperback */
-- Since Top_Format_ID is my foreign key in the Category table I can pull data between the two tables 

-- JOINS --

/* another way to do the same thing as above is with an INNER JOIN which will pull all category info 
with a top format of paperback as well as include the data you want from the reference table */ 

SELECT Category.*, Format_Ref.Format_Name FROM Category
INNER JOIN Format_Ref
ON Category.Top_Format_ID = Format_Ref.Format_ID
WHERE Format_Ref.Format_Name= 'paperback';

-- Again same thing but with a LEFT JOIN and using aliases for the tables 
SELECT c.*, r.Format_Name 
FROM Category c
LEFT JOIN Format_Ref r
ON c.Top_Format_ID = r.Format_ID;

-- For example purposes let's see what happens if I join the data from Category to the Format_Ref table with a RIGHT JOIN 
-- What will happen is that my pull will return a format name and id for every category on the category table (even duplicate formats) 
SELECT r.*, c.cat_name, c.inventory 
FROM Format_Ref r 
RIGHT JOIN Category c
ON c.Top_Format_ID = r.Format_ID;

-- If I tried to left join it then instead of having one line of info for each category, 
-- the query prioritizes format names and I get rows of data for formats I currently dont have on my category table
SELECT r.*, c.cat_name, c.inventory 
FROM Format_Ref r
LEFT JOIN Category c
ON c.Top_Format_ID = r.Format_ID; /* 	:( 		*/

-- But if I had to left join I could then easily fix having Audio and Other with NULL values
-- Even better I can continue to clean the data grid by organizing it by largest inventory... 

-- REMOVING THE NULL VALUES and CHANGE THE ORDER  -- 
SELECT r.*, c.cat_name, c.inventory 
FROM Format_Ref r
LEFT JOIN Category c
ON c.Top_Format_ID = r.Format_ID
WHERE c.cat_name IS NOT NULL
ORDER BY c.inventory DESC;

-- Aggerate functions can help to analyze certain data  

-- How much inventory does each top format of book have in the store? 

SELECT Format_Ref.Format_Name, SUM(Inventory)
FROM Format_Ref, Category
WHERE Category.Top_Format_ID = Format_Ref.Format_ID
GROUP BY Category.Top_Format_Id;
/* produces a grid of the total inventory for each Format Name */


-- VIEWS --
-- creating a view lets me have a saved option for a certain query within my schema that I can easily pull forward

CREATE VIEW vBigInventory AS
SELECT r.*, c.cat_name, c.inventory 
FROM Format_Ref r
LEFT JOIN Category c
ON c.Top_Format_ID = r.Format_ID
WHERE c.cat_name IS NOT NULL
ORDER BY c.inventory DESC
LIMIT 5;

-- Now if I wanted to see the top 5 categories and their formats with the biggest inventory I can run ... 
SELECT * FROM BookShop.vbiginventory;

-- FUNCTIONS -- 
