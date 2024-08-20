-- Create warden table
CREATE TABLE warden (
    P_id INT PRIMARY KEY,
    w_name VARCHAR(10),
    w_dob DATE,
    w_gender VARCHAR(5),
    w_city VARCHAR(30)
);

-- Insert data into warden table
INSERT INTO warden VALUES (101, 'Shama', '1993-12-1', 'F', 'Mumbai');
INSERT INTO warden VALUES (102, 'Faizal', '1995-10-15', 'M', 'Bangalore');
INSERT INTO warden VALUES (103, 'Sonali', '1995-1-12', 'F', 'Chandigarh');

-- Select from warden table
SELECT * FROM warden;

-- Create complaint table
CREATE TABLE complaint (
    c_id INT PRIMARY KEY,
    c_deadline DATE,
    c_status VARCHAR(5),
    c_date DATE
);

-- Insert data into complaint table
INSERT INTO complaint VALUES (1, '2024-02-27', 'PEND', '2024-02-11');
INSERT INTO complaint VALUES (2, '2024-02-29', 'PEND', '2024-02-15');
INSERT INTO complaint VALUES (3, '2024-01-23', 'PEND', '2024-01-09');

-- Select from complaint table
SELECT * FROM complaint;

-- Create feedback table
CREATE TABLE feedback (
    f_id INT PRIMARY KEY,
    sat_level VARCHAR(5),
    res_time INT
);

-- Insert data into feedback table
INSERT INTO feedback VALUES (1, 'good', 3);

-- Select from feedback table
SELECT * FROM feedback;

-- Create caretaker table
CREATE TABLE caretaker (
    c_id INT PRIMARY KEY,
    c_city VARCHAR(10),
    c_fname VARCHAR(10),
    c_lname VARCHAR(10),
    p_id INT,
    CONSTRAINT fk_p_id FOREIGN KEY (p_id) REFERENCES warden (P_id)
);

-- Insert data into caretaker table
INSERT INTO caretaker VALUES (200, 'Patiala', 'Sunita', 'Sharma', 101);
INSERT INTO caretaker VALUES (201, 'Mumbai', 'Anita', 'Sharma', 101);

-- Select from caretaker table
SELECT * FROM caretaker;

-- Create caretaker1 table
CREATE TABLE caretaker1 (
    c_phn VARCHAR(20),
    c_id INT,
    CONSTRAINT fk_c_id FOREIGN KEY (c_id) REFERENCES caretaker (c_id)
);

-- Insert data into caretaker1 table
INSERT INTO caretaker1 VALUES ('9173547286', 200);
INSERT INTO caretaker1 VALUES ('8892736473', 200);

-- Select from caretaker1 table
SELECT * FROM caretaker1;

-- Create complainant table
CREATE TABLE complainant (
    co_id INT PRIMARY KEY,
    co_name VARCHAR(10),
    co_phn VARCHAR(20),
    co_hostel VARCHAR(10),
    c_id INT,
    CONSTRAINT fk_cid FOREIGN KEY (c_id) REFERENCES caretaker (c_id)
);

-- Insert data into complainant table
INSERT INTO complainant VALUES (501, 'Ram', '38478574847', 'B', 201);

-- Select from complainant table
SELECT * FROM complainant;

-- Create register table
CREATE TABLE register (
    co_id INT,
    c_no INT,
    CONSTRAINT fk_co_id FOREIGN KEY (co_id) REFERENCES complainant (co_id),
    CONSTRAINT fk_c_no FOREIGN KEY (c_no) REFERENCES complaint (c_id)
);

-- Insert data into register table
INSERT INTO register VALUES (501, 2);

-- Select from register table
SELECT * FROM register;

-- Create gives table
CREATE TABLE gives (
    co_id INT,
    CONSTRAINT fk_co_id2 FOREIGN KEY (co_id) REFERENCES complainant (co_id),
    f_id INT,
    CONSTRAINT fk_fid FOREIGN KEY (f_id) REFERENCES feedback (f_id)
);

-- Insert data into gives table
INSERT INTO gives VALUES (501, 1);

-- Select from gives table
SELECT * FROM gives;

-- Show all tables
SHOW TABLES;

-- Sample SQL Queries

-- Query to Find Wardens without Any Caretaker Assigned
SELECT w.w_name
FROM warden w
LEFT JOIN caretaker ct ON w.p_id = ct.p_id
WHERE ct.c_id IS NULL;

-- Query to Get the Count of Pending Complaints for Each Warden
SELECT w.w_name, COUNT(c.c_id) AS pending_complaints_count
FROM warden w
LEFT JOIN caretaker ct ON w.p_id = ct.p_id
LEFT JOIN complainant co ON ct.c_id = co.c_id
LEFT JOIN register r ON co.co_id = r.co_id
LEFT JOIN complaint c ON r.c_no = c.c_id AND c.c_status = 'PEND'
GROUP BY w.w_name;

-- Procedure to Extend the Deadline Date
DELIMITER //
CREATE PROCEDURE Extend_Deadline (
    IN complaint_id INT,
    IN new_deadline_date DATE
)
BEGIN
    UPDATE complaint SET c_deadline = new_deadline_date WHERE c_id = complaint_id;
    SELECT 'Deadline extended successfully.' AS message;
END //
DELIMITER ;

-- Example usage of Extend_Deadline
CALL Extend_Deadline(2, '2024-08-02');
SELECT * FROM complaint;

-- Procedure to Get Next Nearest Deadline
DELIMITER //
CREATE PROCEDURE GetNextComplaintDeadline(OUT nextDeadline DATE)
BEGIN
    DECLARE minDeadline DATE;
    SELECT MIN(c_deadline) INTO minDeadline
    FROM complaint
    WHERE c_deadline > CURDATE();
    SET nextDeadline = IFNULL(minDeadline, NULL);
END //
DELIMITER ;

-- Example usage of GetNextComplaintDeadline
SET @nextDate := NULL;
CALL GetNextComplaintDeadline(@nextDate);
SELECT @nextDate AS NextComplaintDeadline;

-- Trigger to Ensure Deadline is Greater Than Entered Date
DELIMITER //
CREATE TRIGGER check_deadline
BEFORE INSERT ON complaint
FOR EACH ROW
BEGIN
    IF NEW.c_deadline < NEW.c_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deadline date cannot be earlier than entered date';
    END IF;
END //
DELIMITER ;
