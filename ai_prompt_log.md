# NHẬT KÝ TƯƠNG TÁC AI (AI PROMPT LOG)

**Học viên:** System Analyst & Database Administrator  
**Mục tiêu:** Thảo luận giải pháp tối ưu thiết kế CSDL MySQL cho Hệ thống HealthSync.

---

## Prompt 1: Tìm hiểu về Anti-pattern trong Quản lý Trạng thái Vòng đời
* **User Input:**  
  > "Trong thiết kế cơ sở dữ liệu quan hệ, tại sao việc dùng một cột `is_active` (kiểu TINYINT/BOOLEAN) để theo dõi vòng đời của một Đơn hàng/Lịch hẹn lại là một thiết kế tồi (Anti-pattern)? Tôi nên thay thế bằng cấu trúc nào?"
* **AI Output Summary:**  
  - Cột Boolean chỉ phản ánh trạng thái nhị phân, mất khả năng thể hiện các bước chuyển đổi tuần tự (State Transitions) của quy trình.
  - Giải pháp khuyến nghị: Sử dụng kiểu dữ liệu `ENUM` với các giá trị (`PENDING`, `CONFIRMED`, `CHECKED_IN`, `COMPLETED`, `CANCELLED`).

---

## Prompt 2: Lựa chọn Kiểu Dữ Liệu Tài Chính (Financial Precision)
* **User Input:**  
  > "Khi thiết kế cột `deposit_amount` và `penalty_fee` trong MySQL phục vụ tính toán tài chính, tôi nên dùng kiểu dữ liệu `FLOAT`, `DOUBLE` hay `DECIMAL`? Tại sao?"
* **AI Output Summary:**  
  - Không được dùng `FLOAT`/`DOUBLE` do nguy cơ sai số làm tròn số thực phẩy động.
  - Sử dụng `DECIMAL(10,2)` giúp lưu trữ định dạng số cố định (Fixed-point), đảm bảo độ chính xác tuyệt đối cho dữ liệu kế toán.

---

## Prompt 3: Đảm bảo Toàn vẹn Ràng buộc Nghiệp vụ ở tầng Database (Triggers)
* **User Input:**  
  > "Làm thế nào để viết một Database Trigger trong MySQL nhằm ngăn chặn việc INSERT một bản ghi vào bảng `Prescriptions` nếu `appointment_id` tương ứng trong bảng `Appointments` chưa ở trạng thái 'COMPLETED'?"
* **AI Output Summary:**  
  - Sử dụng `BEFORE INSERT TRIGGER` kết hợp với `SIGNAL SQLSTATE '45000'` để quăng ngoại lệ ngăn chặn câu lệnh chèn nếu không thỏa mãn điều kiện.
