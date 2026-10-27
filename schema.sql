DROP DATABASE IF EXISTS guardian; 
CREATE DATABASE guardian CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; 
USE guardian; -- 01 AUTHENTICATION & ACCOUNTS 
CREATE TABLE user_account ( 
user_id        
INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
account_type   ENUM('passenger','moderator','route_manager','admin') NOT NULL, 
email          
phone          
VARCHAR(255) NOT NULL UNIQUE, 
VARCHAR(20), 
password_hash  VARCHAR(255) NOT NULL 
) ENGINE=InnoDB; 
CREATE TABLE passenger_profile ( 
passenger_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
user_id        
name          
phone          
status         
INT UNSIGNED NOT NULL UNIQUE, 
 VARCHAR(100) NOT NULL, 
VARCHAR(20), 
VARCHAR(20) NOT NULL DEFAULT 'active', 
CONSTRAINT fk_passenger_user FOREIGN KEY (user_id) 
REFERENCES user_account(user_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE moderator_profile ( 
moderator_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
user_id        
staff_id      
status         
INT UNSIGNED NOT NULL UNIQUE, 
 VARCHAR(30) NOT NULL UNIQUE, 
VARCHAR(20) NOT NULL DEFAULT 'active', 
CONSTRAINT fk_moderator_user FOREIGN KEY (user_id) 
REFERENCES user_account(user_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE route_manager_profile ( 
route_manager_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
user_id          
staff_id        
status           
INT UNSIGNED NOT NULL UNIQUE, 
 VARCHAR(30) NOT NULL UNIQUE, 
VARCHAR(20) NOT NULL DEFAULT 'active', 
CONSTRAINT fk_rm_user FOREIGN KEY (user_id) 
REFERENCES user_account(user_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE admin_profile ( 
admin_id      
user_id        
staff_id      
 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
INT UNSIGNED NOT NULL UNIQUE, 
 VARCHAR(30) NOT NULL UNIQUE, 
admin_level    TINYINT UNSIGNED NOT NULL DEFAULT 1, 
status         
VARCHAR(20) NOT NULL DEFAULT 'active', 
CONSTRAINT fk_admin_user FOREIGN KEY (user_id) 
REFERENCES user_account(user_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE audit_log ( 
log_id        
user_id        
action        
 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
INT UNSIGNED NOT NULL, 
 VARCHAR(100) NOT NULL, 
entity_type    VARCHAR(50), 
`timestamp`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
CONSTRAINT fk_audit_user FOREIGN KEY (user_id) 
REFERENCES user_account(user_id) 
) ENGINE=InnoDB; -- 02 TRANSPORT 
CREATE TABLE driver ( 
driver_id     
name          
phone          
 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
 VARCHAR(100) NOT NULL, 
VARCHAR(20), 
image_url      VARCHAR(500) 
) ENGINE=InnoDB; 
CREATE TABLE driver_private ( 
driver_private_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
driver_id        
nid               
 INT UNSIGNED NOT NULL UNIQUE, 
VARCHAR(30), 
sensitive_details TEXT, 
CONSTRAINT fk_dpriv_driver FOREIGN KEY (driver_id) 
REFERENCES driver(driver_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE bus ( 
bus_id          
 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
registration_no  VARCHAR(30) NOT NULL UNIQUE, 
bus_number       
seat_count      
) ENGINE=InnoDB; 
VARCHAR(20) NOT NULL, 
 SMALLINT UNSIGNED NOT NULL 
CREATE TABLE bus_seat ( 
seat_id        
INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
bus_id        
 INT UNSIGNED NOT NULL, 
seat_number    VARCHAR(10) NOT NULL, 
seat_type      
VARCHAR(30), 
UNIQUE KEY uq_bus_seat (bus_id, seat_number), 
CONSTRAINT fk_seat_bus FOREIGN KEY (bus_id) 
REFERENCES bus(bus_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE conductor ( 
conductor_id   INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
name          
phone          
status         
 VARCHAR(100) NOT NULL, 
VARCHAR(20), 
VARCHAR(20) NOT NULL DEFAULT 'active' 
) ENGINE=InnoDB; 
CREATE TABLE route ( 
route_id       
INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
route_name     VARCHAR(100) NOT NULL, 
origin         
VARCHAR(100) NOT NULL, 
destination    VARCHAR(100) NOT NULL, 
status         
VARCHAR(20) NOT NULL DEFAULT 'active' 
) ENGINE=InnoDB; 
CREATE TABLE road_segment ( 
segment_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
route_id       
INT UNSIGNED NOT NULL, 
segment_name   VARCHAR(100) NOT NULL, 
sequence_no    SMALLINT UNSIGNED NOT NULL, 
UNIQUE KEY uq_route_seq (route_id, sequence_no), 
CONSTRAINT fk_segment_route FOREIGN KEY (route_id) 
REFERENCES route(route_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE speed_limit ( 
speed_limit_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
segment_id     INT UNSIGNED NOT NULL, 
max_speed      SMALLINT UNSIGNED NOT NULL,   -- km/h 
effective_from DATE NOT NULL, 
CONSTRAINT fk_limit_segment FOREIGN KEY (segment_id) 
REFERENCES road_segment(segment_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE trip_schedule ( 
schedule_id    INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
route_id       
INT UNSIGNED NOT NULL, 
departure_time TIME NOT NULL, 
arrival_time   TIME NOT NULL, 
status         
VARCHAR(20) NOT NULL DEFAULT 'active', 
CONSTRAINT fk_schedule_route FOREIGN KEY (route_id) 
REFERENCES route(route_id) 
) ENGINE=InnoDB; -- 03 CENTRAL: DRIVER_TRIP 
CREATE TABLE driver_trip ( 
trip_id       
driver_id     
 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
 INT UNSIGNED NOT NULL, 
bus_id        
 INT UNSIGNED NOT NULL, 
route_id       
INT UNSIGNED NOT NULL, 
start_time     DATETIME NOT NULL, 
end_time       
DATETIME, 
trip_status    VARCHAR(20) NOT NULL DEFAULT 'scheduled', 
CONSTRAINT fk_trip_driver FOREIGN KEY (driver_id) REFERENCES driver(driver_id), 
CONSTRAINT fk_trip_bus    FOREIGN KEY (bus_id)    REFERENCES bus(bus_id), 
CONSTRAINT fk_trip_route  FOREIGN KEY (route_id)  REFERENCES route(route_id) 
) ENGINE=InnoDB; -- 04 AI MONITORING 
CREATE TABLE gps_telemetry ( 
telemetry_id   BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
trip_id       
 INT UNSIGNED NOT NULL, 
`timestamp`    DATETIME(3) NOT NULL, 
latitude      
longitude      
speed          
 DECIMAL(9,6) NOT NULL, 
DECIMAL(9,6) NOT NULL, 
DECIMAL(6,2), 
acceleration   DECIMAL(6,2), 
KEY idx_gps_trip_time (trip_id, `timestamp`), 
CONSTRAINT fk_gps_trip FOREIGN KEY (trip_id) 
REFERENCES driver_trip(trip_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE live_session ( 
session_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
trip_id       
 INT UNSIGNED NOT NULL, 
started_at     DATETIME NOT NULL, 
ended_at       
DATETIME, 
stream_status  VARCHAR(20) NOT NULL DEFAULT 'active', 
CONSTRAINT fk_session_trip FOREIGN KEY (trip_id) 
REFERENCES driver_trip(trip_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE score_record ( 
score_id      
trip_id       
 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
 INT UNSIGNED NOT NULL, 
emotion_score  DECIMAL(5,2), 
behavior_score DECIMAL(5,2), 
driving_score  DECIMAL(5,2), 
overall_risk   DECIMAL(5,2), 
CONSTRAINT fk_score_trip FOREIGN KEY (trip_id) 
REFERENCES driver_trip(trip_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE face_emotion_event ( 
event_id      
 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
session_id     INT UNSIGNED NOT NULL, 
`timestamp`    DATETIME(3) NOT NULL, 
emotion        
VARCHAR(30) NOT NULL, 
confidence     DECIMAL(4,3), 
CONSTRAINT fk_face_session FOREIGN KEY (session_id) 
REFERENCES live_session(session_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE body_motion_event ( 
event_id      
 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
session_id     INT UNSIGNED NOT NULL, 
body_angle     DECIMAL(6,2), 
movement_type  VARCHAR(50), 
confidence     DECIMAL(4,3), 
CONSTRAINT fk_body_session FOREIGN KEY (session_id) 
REFERENCES live_session(session_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE steering_event ( 
event_id      
 BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
session_id     INT UNSIGNED NOT NULL, 
turn_severity  DECIMAL(5,2), 
left_hand      
BOOLEAN, 
right_hand     BOOLEAN, 
CONSTRAINT fk_steer_session FOREIGN KEY (session_id) 
REFERENCES live_session(session_id) ON DELETE CASCADE 
) ENGINE=InnoDB; -- 05 ALERTING & RESPONSE 
CREATE TABLE alert ( 
alert_id       
INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
session_id     INT UNSIGNED NOT NULL, 
alert_type     VARCHAR(50) NOT NULL, 
severity       
status         
VARCHAR(20) NOT NULL, 
VARCHAR(20) NOT NULL DEFAULT 'open', 
CONSTRAINT fk_alert_session FOREIGN KEY (session_id) 
REFERENCES live_session(session_id) ON DELETE CASCADE 
) ENGINE=InnoDB; 
CREATE TABLE alert_action ( 
    action_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    alert_id       INT UNSIGNED NOT NULL, 
    actor_id       INT UNSIGNED NOT NULL,        -- user who acted 
    action         VARCHAR(100) NOT NULL, 
    `timestamp`    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    CONSTRAINT fk_aa_alert FOREIGN KEY (alert_id) 
        REFERENCES alert(alert_id) ON DELETE CASCADE, 
    CONSTRAINT fk_aa_actor FOREIGN KEY (actor_id) 
        REFERENCES user_account(user_id) 
) ENGINE=InnoDB; 
 
CREATE TABLE notification ( 
    notification_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    alert_id        INT UNSIGNED NOT NULL, 
    recipient_id    INT UNSIGNED NOT NULL,       -- user receiving it 
    sound_enabled   BOOLEAN NOT NULL DEFAULT TRUE, 
    read_status     BOOLEAN NOT NULL DEFAULT FALSE, 
    CONSTRAINT fk_notif_alert FOREIGN KEY (alert_id) 
        REFERENCES alert(alert_id) ON DELETE CASCADE, 
    CONSTRAINT fk_notif_recipient FOREIGN KEY (recipient_id) 
        REFERENCES user_account(user_id) 
) ENGINE=InnoDB; 
 
CREATE TABLE escalation_rule ( 
    rule_id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    alert_type       VARCHAR(50) NOT NULL, 
    timeout          INT UNSIGNED NOT NULL,      -- seconds 
    escalation_level TINYINT UNSIGNED NOT NULL, 
    system_action    VARCHAR(100) 
) ENGINE=InnoDB; -- 06 VIDEO 
CREATE TABLE video_recording ( 
video_id      
trip_id       
 INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
 INT UNSIGNED NOT NULL, 
start_time     DATETIME NOT NULL, 
end_time       
DATETIME, 
storage_path   VARCHAR(500) NOT NULL, 
retention_until DATE, 
CONSTRAINT fk_video_trip FOREIGN KEY (trip_id) 
REFERENCES driver_trip(trip_id) 
) ENGINE=InnoDB; 
CREATE TABLE video_archive ( 
archive_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
video_id      
 INT UNSIGNED NOT NULL UNIQUE,  -- 1:1 with video_recording 
archived_at    DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
archive_path   VARCHAR(500) NOT NULL, 
archived_by    INT UNSIGNED,                  -- user who archived 
CONSTRAINT fk_archive_video FOREIGN KEY (video_id) 
REFERENCES video_recording(video_id) ON DELETE CASCADE, 
CONSTRAINT fk_archive_user FOREIGN KEY (archived_by) 
REFERENCES user_account(user_id) 
) ENGINE=InnoDB; -- 07 PASSENGER BOOKING & FEEDBACK 
CREATE TABLE booking ( 
    booking_id     INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    passenger_id   INT UNSIGNED NOT NULL, 
    trip_id        INT UNSIGNED NOT NULL, 
    booking_time   DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    status         VARCHAR(20) NOT NULL DEFAULT 'pending', 
    CONSTRAINT fk_booking_passenger FOREIGN KEY (passenger_id) 
        REFERENCES passenger_profile(passenger_id), 
    CONSTRAINT fk_booking_trip FOREIGN KEY (trip_id) 
        REFERENCES driver_trip(trip_id) 
) ENGINE=InnoDB; 
 
CREATE TABLE booking_seat ( 
    booking_seat_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    booking_id      INT UNSIGNED NOT NULL, 
    seat_id         INT UNSIGNED NOT NULL, 
    price           DECIMAL(10,2) NOT NULL, 
    status          VARCHAR(20) NOT NULL DEFAULT 'reserved', 
    UNIQUE KEY uq_booking_seat (booking_id, seat_id), 
    CONSTRAINT fk_bs_booking FOREIGN KEY (booking_id) 
        REFERENCES booking(booking_id) ON DELETE CASCADE, 
    CONSTRAINT fk_bs_seat FOREIGN KEY (seat_id) 
        REFERENCES bus_seat(seat_id) 
) ENGINE=InnoDB; 
 
CREATE TABLE payment ( 
    payment_id      INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
    booking_id      INT UNSIGNED NOT NULL, 
    method          VARCHAR(30) NOT NULL, 
status         
 VARCHAR(20) NOT NULL DEFAULT 'pending', 
transaction_ref VARCHAR(100) UNIQUE, 
CONSTRAINT fk_payment_booking FOREIGN KEY (booking_id) 
REFERENCES booking(booking_id) 
) ENGINE=InnoDB; 
CREATE TABLE rating ( 
rating_id      
INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, 
passenger_id   INT UNSIGNED NOT NULL, 
trip_id       
driver_id     
rating        
`comment`      
 INT UNSIGNED NOT NULL, 
 INT UNSIGNED NOT NULL, 
 TINYINT UNSIGNED NOT NULL, 
TEXT, 
CONSTRAINT chk_rating CHECK (rating BETWEEN 1 AND 5), 
CONSTRAINT fk_rating_passenger FOREIGN KEY (passenger_id) 
REFERENCES passenger_profile(passenger_id), 
CONSTRAINT fk_rating_trip FOREIGN KEY (trip_id) 
REFERENCES driver_trip(trip_id), 
CONSTRAINT fk_rating_driver FOREIGN KEY (driver_id) 
REFERENCES driver(driver_id) 
) ENGINE=InnoDB; 