# BÁO CÁO PHÂN TÍCH KHOẢNG TRỐNG DỮ LIỆU (GAP ANALYSIS REPORT)
**Dự án:** Hệ thống Quản lý Phòng khám Đa khoa HealthSync  
**Vai trò:** System Analyst & Database Administrator  

---

## 1. Tổng quan
Qua rà soát và đối chiếu giữa **UML Activity Diagram** (quy trình nghiệp vụ do BA thiết kế) và **Legacy SQL Script** (do Lập trình viên Backend thực hiện), chúng tôi phát hiện sự "vênh" nghiêm trọng giữa nghiệp vụ thực tế và cấu trúc CSDL hiện tại. Sự bất nhất này khiến hệ thống liên tục báo lỗi khi đưa vào thử nghiệm các tính năng như phạt tiền cọc và kê đơn thuốc.

---

## 2. 3 Điểm "vênh" nghiêm trọng nhất giữa Nghiệp vụ và Thiết kế CSDL cũ

### 🛑 Điểm 1: Sử dụng kiểu dữ liệu BOOLEAN (`is_active`) cho quy trình vòng đời đa trạng thái
* **Nghiệp vụ (UML):** Trạng thái lịch hẹn chuyển đổi qua 5 giai đoạn: `PENDING` -> `CONFIRMED` -> `CHECKED_IN` -> `COMPLETED` / `CANCELLED`.
* **CSDL cũ:** Chỉ dùng một cột `is_active BOOLEAN DEFAULT TRUE`.
* **Hậu quả:** Cột cờ (flag) 0/1 chỉ thể hiện được trạng thái Bật/Tắt, hoàn toàn thất bại trong việc ghi nhận bệnh nhân đã cọc tiền chưa, đã đến phòng khám chưa, hay đã hủy/hoàn thành khám.

### 🛑 Điểm 2: Thiếu hoàn toàn cơ chế ghi nhận Quản lý Tài chính và Lý do Hủy lịch
* **Nghiệp vụ (UML):** Bệnh nhân đặt lịch phải đóng cọc (`deposit_amount`). Khi hủy lịch từ trạng thái `CONFIRMED`, hệ thống phải lưu lý do hủy (`cancel_reason`) và tính toán phí phạt (`penalty_fee`) trừ vào tiền cọc.
* **CSDL cũ:** Bảng `Appointments` không hề có các cột `deposit_amount`, `penalty_fee`, và `cancel_reason`.
* **Hậu quả:** Không thể đối soát dòng tiền cọc/phạt, gây thất thoát tài chính phòng khám và không theo dõi được nguyên nhân hủy dịch vụ của bệnh nhân.

### 🛑 Điểm 3: Vắng mặt hoàn toàn thực thể Quản lý Đơn thuốc (`Prescriptions`)
* **Nghiệp vụ (UML):** Khi bác sĩ khám xong (`COMPLETED`), một đơn thuốc phải được lập và gán trực tiếp với lịch hẹn đó.
* **CSDL cũ:** Không có bảng `Prescriptions` và cũng không có khóa ngoại nối với `Appointments`.
* **Hậu quả:** Bác sĩ không thể kê đơn trên hệ thống; dữ liệu lịch sử khám và đơn thuốc bị đứt gãy hoàn toàn.

---

## 3. Kết luận
Cấu trúc CSDL cũ vi phạm tính toàn vẹn nghiệp vụ (Business Integrity). Cần tiến hành tái cấu trúc lại schema (DDL) và bổ sung các ràng buộc tài chính/khóa ngoại ngay lập tức.
