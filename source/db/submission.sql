DROP TABLE submissions;
CREATE TABLE `submissions` (
	sid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	date_post DATETIME,
	name TEXT NOT NULL,
	email TEXT NOT NULL,
	phone TEXT NOT NULL,
	title TEXT NOT NULL,
	description TEXT NOT NULL,
	tech TEXT NOT NULL,
	url TEXT NOT NULL,
	filename TEXT NOT NULL,
	status_id TINYINT DEFAULT 1
)
