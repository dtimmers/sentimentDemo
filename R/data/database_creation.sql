CREATE TABLE Sentiment (
	id INT NOT NULL AUTO_INCREMENT,
	datetime DATETIME NOT NULL,
	txt CHAR(200),
	cleanTxt CHAR(200),
	lat FLOAT(7,4),
	lng FLOAT(7,4),
	state CHAR(100),
    primary key (id)
);

/* Create index on datetime and state for faster searches*/
CREATE INDEX DSIndex
ON Sentiment (datetime, state);

/* Creat index on state for faster searches*/
CREATE INDEX SIndex
ON Sentiment (state);

/* Create a new user such that R can access the database with tweets 
   User only has access to the table Sentiment */
GRANT ALL PRIVILEGES ON sentiment_db.* To 'Ruser'@'localhost' IDENTIFIED BY 'ouRs3cret!';