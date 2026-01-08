-- Mall lost & Found

CREATE DATABASE IF NOT EXISTS mall_lost_found;
USE mall_lost_found;

-- persons table
CREATE TABLE IF NOT EXISTS Persons (
    person_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) NOT NULL,
    email VARCHAR(100),
    person_type VARCHAR(20) NOT NULL
);

-- locations table
CREATE TABLE IF NOT EXISTS Locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    floor_level INT NOT NULL,
    section VARCHAR(50)
);

-- staff table
CREATE TABLE IF NOT EXISTS Staff (
    staff_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    contact_number VARCHAR(15) NOT NULL UNIQUE
);

-- items table
CREATE TABLE IF NOT EXISTS Items (
    item_id INT PRIMARY KEY AUTO_INCREMENT,
    item_name VARCHAR(100) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(50) NOT NULL,
    color VARCHAR(30),
    status VARCHAR(20) DEFAULT 'Lost',
    date_reported DATE NOT NULL,
    person_id INT NOT NULL,
    location_id INT NOT NULL,
    staff_id INT,
    FOREIGN KEY (person_id) REFERENCES Persons(person_id),
    FOREIGN KEY (location_id) REFERENCES Locations(location_id),
    FOREIGN KEY (staff_id) REFERENCES Staff(staff_id)
);

-- claims table
CREATE TABLE IF NOT EXISTS Claims (
    claim_id INT PRIMARY KEY AUTO_INCREMENT,
    item_id INT NOT NULL,
    claimant_id INT NOT NULL,
    claim_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    notes TEXT,
    verified_by INT,
    FOREIGN KEY (item_id) REFERENCES Items(item_id),
    FOREIGN KEY (claimant_id) REFERENCES Persons(person_id),
    FOREIGN KEY (verified_by) REFERENCES Staff(staff_id)
);

-- persons data
INSERT INTO Persons (first_name, last_name, contact_number, email, person_type) VALUES
('CJ', 'Adriatico', '09171234567', 'cj@gmail.com', 'Reporter'),
('Maria', 'Santos', '09182345678', 'maria@gmail.com', 'Finder'),
('Pedro', 'Reyes', '09193456789', 'pedro@email.com', 'Claimant'),
('Ana', 'Garcia', '09204567890', 'ana@gmail.com', 'Reporter'),
('Carlos', 'Mendoza', '09226789012', 'carlos@gmail.com', 'Finder'),
('Miguel', 'Torres', '09237890123', 'miguel@email.com', 'Finder');

-- locations data
INSERT INTO Locations (location_name, floor_level, section) VALUES
('Food Court', 2, 'Dining'),
('Parking Area', 3, 'Parking'),
('Cinema', 2, 'Entertainment'),
('Department Store', 1, 'Shopping'),
('Restroom Area', 1, 'Facilities');

-- staff data 
INSERT INTO Staff (first_name, last_name, position, contact_number) VALUES
('David', 'Cruz', 'Security', '09221234567'),
('Mark', 'Torres', 'Security', '09232345678'),
('Lisa', 'Mendoza', 'Manager', '09243456789'),
('Sofia', 'Bautista', 'Staff', '09254567890'),
('Emma', 'Cruz', 'Staff', '09265678901');

-- items data 
INSERT INTO Items (item_name, description, category, color, status, date_reported, person_id, location_id, staff_id) VALUES
('Phone', 'iPhone 13', 'Electronics', 'Black', 'Found', '2025-12-25', 2, 1, 1),
('Laptop', 'MacBook', 'Electronics', 'Silver', 'Claimed', '2025-12-25', 1, 1, 2),
('Umbrella', 'Red umbrella', 'Personal', 'Red', 'Found', '2025-12-25', 5, 4, 3),
('Eyeglasses', 'Reading glasses', 'Accessories', 'Black', 'Lost', '2025-12-25', 4, 3, 1),
('Watch', 'Wristwatch', 'Jewelry', 'Gold', 'Found', '2025-12-25', 6, 5, 2),
('Keys', 'Car keys', 'Keys', 'Silver', 'Found', '2025-12-25', 6, 2, 4),
('Wallet', 'Leather wallet', 'Personal', 'Brown', 'Lost', '2025-12-25', 4, 5, 3);

-- claims data 
INSERT INTO Claims (item_id, claimant_id, claim_date, status, notes, verified_by) VALUES
(2, 3, '2025-12-25 10:30:00', 'Approved', 'ID verified', 2),
(1, 3, '2025-12-25 10:30:00', 'Approved', 'Verified successfully', 1),
(3, 3, '2025-12-25 11:00:00', 'Pending', 'Checking details', 3),
(5, 3, '2025-12-25 11:00:00', 'Pending', 'Checking details', 2),
(6, 3, '2025-12-25 11:30:00', 'Pending', 'Checking details', 4);

-- Query 1 - WHERE
SELECT item_name, description, color, status
FROM Items
WHERE status = 'Found';

-- Query 2 - ORDER BY
SELECT item_name, date_reported, status
FROM Items
ORDER BY date_reported DESC;

-- Query 3 - UP BY
SELECT category, COUNT(*) as total
FROM Items
GROUP BY category;

-- Query 4 - JOIN
SELECT 
    i.item_name,
    i.description,
    l.location_name,
    l.floor_level
FROM Items i
JOIN Locations l ON i.location_id = l.location_id;

-- Query 5 - Multiple JOIN
SELECT 
    i.item_name,
    CONCAT(p.first_name, ' ', p.last_name) as reporter,
    l.location_name,
    i.status
FROM Items i
JOIN Persons p ON i.person_id = p.person_id
JOIN Locations l ON i.location_id = l.location_id;


-- update item status
UPDATE Items 
SET status = 'Claimed' 
WHERE item_id = 1;

-- update claim status
UPDATE Claims 
SET status = 'Approved', notes = 'Verified successfully'
WHERE claim_id = 2;


-- delete a rejected claim
DELETE FROM Claims 
WHERE claim_id = 3 AND status = 'Rejected';

-- delete old unclaimed items
DELETE FROM Items 
WHERE status = 'Lost' AND date_reported < '2024-12-01';


-- count items by status
SELECT status, COUNT(*) as total
FROM Items
GROUP BY status;

-- find pending claims
SELECT 
    i.item_name,
    CONCAT(p.first_name, ' ', p.last_name) as claimant,
    c.claim_date
FROM Claims c
JOIN Items i ON c.item_id = i.item_id
JOIN Persons p ON c.claimant_id = p.person_id
WHERE c.status = 'Pending';

-- staff workload report
SELECT 
    CONCAT(s.first_name, ' ', s.last_name) as staff_name,
    s.position,
    COUNT(i.item_id) as items_handled
FROM Staff s
LEFT JOIN Items i ON s.staff_id = i.staff_id
GROUP BY s.staff_id;