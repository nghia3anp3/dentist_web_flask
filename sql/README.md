# SQL

Bao gồm 2 file:
- database.sql: lưu cấu trúc database và dữ liệu thô.
- procedure.sql: lưu các procedure cho các chức năng.

#### Các procedure có trong procedure.sql:

- **sp_KiemTraSdtTonTai**: 
    - Tham số truyền vào: @SDT VARCHAR(20)
    - Kết quả trả về: giá trị 1 hoặc 0 (kiểu dữ liệu bit)
    - Chức năng: kiểm tra một số điện thoại đã tồn tại trong bảng NGUOIDUNG hay chưa.

- **sp_KiemTraTKTonTai**:
    - Tham số truyền vào *@SDT VARCHAR(20), @LoaiND varchar(10)*.
    - Kết quả trả về: giá trị 1 hoặc 0 (kiểu dữ liệu bit).
    - Chức năng: kiểm tra một số điện thoại đã được đăng ký với loại người dùng được truyền vào chưa.
    - Thường dùng trong việc đăng ký tài khoản.

- **sp_LayThongTinTuSDT**:
    - Tham số truyền vào: @SDT VARCHAR(20)
    - Kết quả trả về: 
        - 1 bảng thông tin của người dùng sử dụng @SDT (thứ tự: HoTen, NgaySinh, DiaChi).
        - Hoặc trả về bảng có 1 cột 1 dòng duy nhất (cột result, value = 0).
    - Chức năng: Xem thông tin người dùng, kiểm tra xem có người dùng nào mang @SDT chưa, nếu có thì autofill thông tin.


- **sp_LayHoaDonTuSDT**:
    - Tham số truyền vào: @SDT VARCHAR(20)
    - Kết quả trả về: 
        - 1 bảng chứa tất cả các hoá đơn của @SDT (thứ tự: *MaHoSo, MaHoaDon, NgayKham, MaNhaSi, TenNhaSi, MaThuoc, TenThuoc, SoLuongThuoc, DonGiaThuoc, MaDV, TenDV, SoLuongDV, DonGia, TongTien*). 
        - Hoặc trả về bảng có 1 cột 1 dòng duy nhất (cột result, value = 0). 
        - Lưu ý sẽ phát sinh duplicate dữ liệu. 
    - Chức năng: Lấy hoá đơn từ số điện thoại.

- **sp_TimNhaSiRanh**:
    - Tham số truyền vào: @Time varchar(15), @Date varchar(15).
    - Kết quả trả về:
        - 1 bảng gồm MaNhaSi và TenNhaSi
        - Nếu không có thì trả về 1 bảng rỗng.
    - Chức năng: Tìm nha sĩ rảnh trong thời gian đầu vào.
    - Sử dụng: Khi đăng ký khám.


- **sp_LayThongTinKhoThuoc**:
    - Tham số truyền vào: không có
    - Kết quả trả về: 
        - Bảng thông tin các thuốc có trong kho. Thứ tự: *MaThuoc,TenThuoc, DonGia, ChiDinh, SoLuongTon, NgayHetHan.*
    - Chức năng: Xem tất cả các thuốc trong kho.
    - Sử dụng: Chức năng xem danh sách thuốc của admin và QTV.

- **sp_TimThuocBangTen**:
    - Tham số truyền vào: @TenThuoc VARCHAR(20). (Có thể là 1 phần trong tên thuốc).
    - Kết quả trả về:
        - 1 bảng chứa thông tin thuốc (Thứ tự: *MaThuoc,TenThuoc, DonGia, ChiDinh, SoLuongTon, NgayHetHan.*)
        - 1 bảng rỗng nếu không có tên thuốc tương ứng.
    - Chức năng: Tìm kiếm thuốc

- **sp_DatLichKham**:
    - Tham số truyền vào: 
    *@SDT VARCHAR(20),	
				            @HoTen nvarchar(30),
				@NgaySinh varchar(15),
				@DiaChi nvarchar(50),
				@NgayHen varchar(15),
				@GioHen varchar(15),
				@MaBacSi VARCHAR(20)*
        **Lưu ý**: Với những trường không cần truyền (trong trường hợp có người dùng dùng SDT kia rồi) thì có thể truyền vào rỗng.
    - Kết quả trả về: Không có, procedure sẽ insert vào database (bảng LICHEN và NGUOIDDUNG (nếu chưa tồn tại SDT)).
    - Chức năng:
    - Sử dụng

- **sp_ThemNguoiDung**:
    - Tham số truyền vào: 
       *@SDT VARCHAR(20),	
				@HoTen nvarchar(30),
				@NgaySinh varchar(15),
				@DiaChi nvarchar(50)*
    - Kết quả trả về: 
        - 1 nếu đăng ký thành công.
        - 0 nếu đăng ký không thành công (trong trường hợp SDT đã tồn tại rồi)
    - Chức năng: Thêm người dùng vào database.
    - Sử dụng: đăng ký tài khoản, đăng ký lịch hẹn (chưa từng khám ở đây).
    


- **sp_DangKiTaiKhoan**:
    - Tham số truyền vào: 
       @SDT varchar(10),
				@HoTen nvarchar(30),
				@NgaySinh DATE,
				@DiaChi nvarchar (50),
				@MatKhau varchar(20),
				@LoaiND varchar(10)*
        **Lưu ý**: Với những trường không cần truyền (trong trường hợp có người dùng dùng SDT kia rồi) thì có thể truyền vào rỗng.
    - Kết quả trả về: 
        - 1 nếu đăng ký thành công.
        - 0 nếu đăng ký không thành công (trong trường hợp SDT đã tồn tại rồi)
    - Chức năng: Thêm người dùng vào database.
    - Sử dụng: đăng ký tài khoản, đăng ký lịch hẹn (chưa từng khám ở đây).


- **sp_DangKiTaiKhoan**:
    - Tham số truyền vào: 
       @SDT varchar(10),
				@HoTen nvarchar(30),
				@NgaySinh DATE,
				@DiaChi nvarchar (50),
				@MatKhau varchar(20),
				@LoaiND varchar(10)*
        **Lưu ý**: Với những trường không cần truyền (trong trường hợp có người dùng dùng SDT kia rồi) thì có thể truyền vào rỗng.
    - Kết quả trả về: 
        - 1 nếu đăng ký thành công.
        - 0 nếu đăng ký không thành công (trong trường hợp SDT đã tồn tại rồi)
    - Chức năng: Thêm người dùng vào database.
    - Sử dụng: đăng ký tài khoản, đăng ký lịch hẹn (chưa từng khám ở đây).



- **sp_XemLichKham**:
    - Tham số truyền vào: 
       @SDT varchar(10)*
    - Kết quả trả về: 
        - Bảng thông tin các lịch khám (thứ tự: *NgayKham, GioKham, MaNhaSi, TenNhaSi, HoTen, SDT*) 
        - Bảng 1 dòng 1 cột (result: 0)
    - Chức năng: Xem lịch hẹn khám của @SDT.