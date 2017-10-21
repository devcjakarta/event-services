

DROP TABLE IF EXISTS `participants`;
CREATE TABLE `participants` (
	pid BIGINT NOT NULL AUTO_INCREMENT,
	email varchar(120) NOT NULL,
	post_date DATETIME,
	name varchar(120) NOT NULL DEFAULT '',
	phone varchar(15) NOT NULL DEFAULT '',
	institution varchar(120) NOT NULL DEFAULT '',
	occupation varchar(120) NOT NULL DEFAULT '',
	note TEXT,
	reg_counter TINYINT DEFAULT 1,
	post_by BIGINT DEFAULT 0,
	status_id TINYINT DEFAULT 1,
	PRIMARY KEY (pid, email),
	UNIQUE KEY email (email),
	KEY email_ie1 (email)
);
#  INSERT INTO participants (email,name,phone) VALUES ('me@me.com','name','email')
#  ON DUPLICATE KEY UPDATE reg_counter=reg_counter+1;


DROP TABLE IF EXISTS event_participants;
CREATE TABLE `event_participants` (
	epid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	post_date DATETIME,
	event_id BIGINT DEFAULT 0,
	participant_id BIGINT DEFAULT 0,
	note TEXT,
	post_by BIGINT DEFAULT 0,
	status_id TINYINT DEFAULT 1
);

DROP TABLE IF EXISTS `participant_blacklists`;
CREATE TABLE `participant_blacklists` (
	pid BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	post_date DATETIME,
	email varchar(120) NOT NULL,
	note TEXT,
	duration TINYINT DEFAULT 1,
	post_by BIGINT DEFAULT 0,
	status_id TINYINT DEFAULT 1
);

