DROP TABLE IF EXISTS events;
CREATE TABLE `events` (
	eid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	post_date DATETIME,
	type_id TINYINT DEFAULT 0,
	name varchar(120) NOT NULL,
	sub_title varchar(120) NOT NULL,
	description TEXT NOT NULL,
	date_start DATETIME NOT NULL,
	date_finish DATETIME NOT NULL,
	location TEXT NOT NULL,
	location_map varchar(120) NOT NULL,
	url TEXT NOT NULL,
	image_url TEXT NOT NULL,
	quota TINYINT DEFAULT 0,
	post_by TINYINT DEFAULT 0,
	status_id TINYINT DEFAULT 1
)
