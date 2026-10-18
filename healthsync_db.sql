-- =============================================================================
-- DỰ ÁN HEALTHSYNC - SCRIPT TÁI CẤU TRÚC VÀ VẬN HÀNH BẢNG DỮ LIỆU
-- Tác giả: System Analyst & Database Administrator
-- =============================================================================

CREATE DATABASE IF NOT EXISTS healthsync_db;
USE healthsync_db;

-- -----------------------------------------------------------------------------
-- 1. BẢNG DỮ LIỆU NỀN TẢNG (PATIENTS & DOCTORS)
-- -----------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS Patients (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15) NOT NULL
);

CREATE TABLE IF NOT EXISTS Doctors (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    specialty VARCHAR(50)
);

-- -----------------------------------------------------------------------------
-- 2. TÁI CẤU TRÚC BẢNG APPOINTMENTS
-- -----------------------------------------------------------------------------
DROP TABLE IF EXISTS Prescriptions;
DROP TABLE IF EXISTS Appointments;

CREATE TABLE Appointments (
    appointment_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATETIME NOT NULL,
    
    -- Thay thế is_active bằng ENUM chuẩn hóa 5 trạng thái vòng đời
    status ENUM('PENDING', 'CONFIRMED', 'CHECKED_IN', 'COMPLETED', 'CANCELLED') 
        NOT NULL DEFAULT 'PENDING',
    
    -- Xử lý tài chính chính xác tuyệt đối với DECIMAL(10,2)
    deposit_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    penalty_fee DECIMAL(10,2) DEFAULT 0.00,
    cancel_reason VARCHAR(255) DEFAULT NULL,
    
    FOREIGN KEY (patient_id) REFERENCES Patients(patient_id) ON DELETE RESTRICT,
    FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id) ON DELETE RESTRICT
);

-- -----------------------------------------------------------------------------
-- 3. TẠO BẢNG MỚI PRESCRIPTIONS (ĐƠN THUỐC)
-- -----------------------------------------------------------------------------
CREATE TABLE Prescriptions (
    prescription_id INT AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT NOT NULL UNIQUE, -- Quan hệ 1-1 với Appointments
    medication_details TEXT NOT NULL,
    issued_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (appointment_id) REFERENCES Appointments(appointment_id) ON DELETE CASCADE
);

-- -----------------------------------------------------------------------------
-- 4. BỔ SUNG TRIGGER ĐẢM BẢO TOÀN VẸN NGHIỆP VỤ
-- Ngăn chặn việc kê đơn thuốc cho lịch hẹn chưa 'COMPLETED'
-- -----------------------------------------------------------------------------
DELIMITER //
CREATE TRIGGER chk_prescription_completed_status
BEFORE INSERT ON Prescriptions
FOR EACH ROW
BEGIN
    DECLARE current_status VARCHAR(20);
    
    SELECT status INTO current_status
    FROM Appointments
    WHERE appointment_id = NEW.appointment_id;
    
    IF current_status != 'COMPLETED' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Lỗi Nghiệp Vụ: Chỉ có thể tạo Đơn thuốc cho Lịch hẹn đã ở trạng thái COMPLETED!';
    END IF;
END//
DELIMITER ;

-- =============================================================================
-- 5. KỊCH BẢN CHÉP LIỆU THỰC TẾ (DML - DEMO SCENARIOS)
-- =============================================================================

INSERT INTO Patients (full_name, phone) VALUES 
('Nguyễn Văn A', '0901234567'),
('Trần Thị B', '0987654321');

INSERT INTO Doctors (full_name, specialty) VALUES 
('BS. Lê Văn C', 'Nội khoa'),
('BS. Phạm Thị D', 'Tim mạch');

-- KỊCH BẢN 1: Luồng thành công (PENDING -> CHECKED_IN -> COMPLETED -> Kê đơn)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (1, 1, '2026-10-20 09:00:00', 'PENDING', 500000.00);

UPDATE Appointments SET status = 'CHECKED_IN' WHERE appointment_id = 1;
UPDATE Appointments SET status = 'COMPLETED' WHERE appointment_id = 1;

INSERT INTO Prescriptions (appointment_id, medication_details)
VALUES (1, 'Paracetamol 500mg (20 viên), Amoxicillin 500mg (14 viên). Uống ngày 2 lần.');

-- KỊCH BẢN 2: Luồng Hủy & Phạt cọc (CONFIRMED -> CANCELLED + Penalty)
INSERT INTO Appointments (patient_id, doctor_id, appointment_date, status, deposit_amount)
VALUES (2, 2, '2026-10-21 14:00:00', 'CONFIRMED', 300000.00);

UPDATE Appointments 
SET status = 'CANCELLED',
    cancel_reason = 'Bận việc đột xuất',
    penalty_fee = 150000.00
WHERE appointment_id = 2;

-- -----------------------------------------------------------------------------
-- 6. TRUY VẤN KIỂM TRA VÀ ĐỐI SOÁT
-- -----------------------------------------------------------------------------
SELECT 
    a.appointment_id,
    p.full_name AS patient_name,
    d.full_name AS doctor_name,
    a.status,
    a.deposit_amount,
    pr.medication_details,
    pr.issued_date
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
JOIN Doctors d ON a.doctor_id = d.doctor_id
JOIN Prescriptions pr ON a.appointment_id = pr.appointment_id
WHERE a.status = 'COMPLETED';
