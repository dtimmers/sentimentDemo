CREATE TABLE state (
state_id INT NOT NULL AUTO_INCREMENT,
name  CHAR(20) UNIQUE,
abr CHAR(2),
PRIMARY KEY (state_id)
);

CREATE TABLE city (
city_id INT NOT NULL AUTO_INCREMENT,
state_id INT,
city CHAR(20),
population INT,
area FLOAT(5,1),
radius FLOAT(6,4),
lat DOUBLE(8,5),
lng DOUBLE(8,5),
PRIMARY KEY (city_id),
FOREIGN KEY (state_id) REFERENCES state(state_id)
);

ALTER TABLE city 
ADD CONSTRAINT uc_city UNIQUE (state_id,city)

/* Add a foreign key to the Cities table */
CREATE TABLE tweet (
tweet_id BIGINT NOT NULL,
city_id INT NOT NULL,
datetime DATETIME NOT NULL,
txt CHAR(150) CHARACTER SET utf8,
cleanTxt CHAR(150) CHARACTER SET utf8,
score FLOAT(5,2),
screenName CHAR(20),
searchTerm CHAR(20),
PRIMARY KEY (tweet_id),
FOREIGN KEY (city_id) REFERENCES city(city_id)
);

/* Create index on datetime, city_id and searchTerm for fast searches*/
CREATE INDEX dateCityIndex 
ON tweet (datetime, city_id);

/* Creat index on state for fast searches*/
CREATE INDEX cityIndex 
ON tweet (city_id);
