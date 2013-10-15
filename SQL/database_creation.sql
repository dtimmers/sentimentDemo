CREATE TABLE States (
state_id INT NOT NULL AUTO_INCREMENT,
name  CHAR(20),
abr CHAR(2),
PRIMARY KEY (state_id)
);

CREATE TABLE Cities (
city_id INT NOT NULL AUTO_INCREMENT,
state_id INT,
city CHAR(20),
population INT,
area FLOAT(5,1),
radius FLOAT(5,4),
PRIMARY KEY (city_id),
FOREIGN KEY States(state_id) REFERENCES States(state_id)
);

/* Add a foreign key to the Cities table */
CREATE TABLE Tweets (
tweet_id INT NOT NULL AUTO_INCREMENT,
city_id INT,
datetime DATETIME NOT NULL,
txt CHAR(200),
cleanTxt CHAR(200),
PRIMARY KEY (tweet_id),
FOREIGN KEY (city_id) REFERENCES Cities(city_id)
);

/* Create index on datetime and city_id for fast searches*/
CREATE INDEX dateCityIndex
ON Tweets (datetime, city_id);

/* Creat index on state for fast searches*/
CREATE INDEX cityIndex
ON Tweets (city_id);
