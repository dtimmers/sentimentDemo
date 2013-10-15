/* Create a new user such that R can access the database with tweets 
   User only has access to the database sentiment_db */
GRANT ALL PRIVILEGES ON sentiment_db.* To 'Ruser'@'localhost' IDENTIFIED BY 'ouRs3cret!';