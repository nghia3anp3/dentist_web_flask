# SQL

Bao gồm 2 file:
- database.sql: lưu cấu trúc database và dữ liệu thô.
- procedure.sql: lưu các procedure cho các chức năng.

#### Các procedure có trong procedure.sql:

- **sp_KiemTraSdtTonTai**: 
    - Tham số truyền vào: *@SDT VARCHAR(20)*
    - Kết quả trả về: giá trị 1 hoặc 0 (kiểu dữ liệu bit)
    - Chức năng: kiểm tra một số điện thoại đã tồn tại trong bảng NGUOIDUNG hay chưa.

- **sp_KiemTraTKTonTai**:
    - Tham số truyền vào *@SDT VARCHAR(20), @LoaiND VARCHAR(10)*.
    - Kết quả trả về: giá trị 1 hoặc 0 (kiểu dữ liệu bit).
    - Chức năng: kiểm tra một số điện thoại đã được đăng ký với loại người dùng được truyền vào chưa.
    - Thường dùng trong việc đăng ký tài khoản.

- **sp_LayThongTinTuSDT**:
    - Tham số truyền vào: *@SDT VARCHAR(20)*
    - Kết quả trả về: 
        - 1 bảng thông tin của người dùng sử dụng @SDT (thứ tự: HoTen, NgaySinh, DiaChi).
        - Hoặc trả về bảng có 1 cột 1 dòng duy nhất (cột result, value = 0).
    - Chức năng: Xem thông tin người dùng, kiểm tra xem có người dùng nào mang @SDT chưa, nếu có thì autofill thông tin.

- **sp_LayHoaDonTuSDT**:
    - Tham số truyền vào: *@SDT VARCHAR(20)*
    - Kết quả trả về: 
        - 1 bảng chứa tất cả các hoá đơn của @SDT (thứ tự: *MaHoSo, MaHoaDon, NgayKham, MaNhaSi, TenNhaSi, MaThuoc, TenThuoc, SoLuongThuoc, DonGiaThuoc, MaDV, TenDV, SoLuongDV, DonGia, TongTien*). 
        - Hoặc trả về bảng có 1 cột 1 dòng duy nhất (cột result, value = 0). 
        - Lưu ý sẽ phát sinh duplicate dữ liệu. 
    - Chức năng: Lấy hoá đơn từ số điện thoại.

- **sp_TimNhaSiRanh**:
    - Tham số truyền vào: *@Time VARCHAR(15), @Date VARCHAR(15)*.
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
    - Tham số truyền vào: *@TenThuoc VARCHAR(20)*. (Có thể là 1 phần trong tên thuốc).
    - Kết quả trả về:
        - 1 bảng chứa thông tin thuốc (Thứ tự: *MaThuoc,TenThuoc, DonGia, ChiDinh, SoLuongTon, NgayHetHan.*)
        - 1 bảng rỗng nếu không có tên thuốc tương ứng.
    - Chức năng: Tìm kiếm thuốc

- **sp_DatLichKham**:
    - Tham số truyền vào: 
                *@SDT VARCHAR(20),	
				@HoTen NVARCHAR(30),
				@NgaySinh VARCHAR(15),
				@DiaChi NVARCHAR(50),
				@NgayHen VARCHAR(15),
				@GioHen VARCHAR(15),
				@MaBacSi VARCHAR(20)*
    
    **Lưu ý**: Với những trường không cần truyền (trong trường hợp có người dùng dùng SDT kia rồi) thì có thể truyền vào rỗng.
    - Kết quả trả về: Không có, procedure sẽ insert vào database (bảng LICHEN và NGUOIDDUNG (nếu chưa tồn tại SDT)).
    - Chức năng:
    - Sử dụng

- **sp_ThemNguoiDung**:
    - Tham số truyền vào: 
                *@SDT VARCHAR(20),	
				@HoTen NVARCHAR(30),
				@NgaySinh VARCHAR(15),
				@DiaChi NVARCHAR(50)*
    - Kết quả trả về: 
        - 1 nếu đăng ký thành công.
        - 0 nếu đăng ký không thành công (trong trường hợp SDT đã tồn tại rồi)
    - Chức năng: Thêm người dùng vào database.
    - Sử dụng: đăng ký tài khoản, đăng ký lịch hẹn (chưa từng khám ở đây).

- **sp_DangKiTaiKhoan**:
    - Tham số truyền vào: 
                *@SDT VARCHAR(10),
				@HoTen NVARCHAR(30),
				@NgaySinh DATE,
				@DiaChi NVARCHAR (50),
				@MatKhau VARCHAR(20),
				@LoaiND VARCHAR(10)*
    **Lưu ý**: Với những trường không cần truyền (trong trường hợp có người dùng dùng SDT kia rồi) thì có thể truyền vào rỗng.
    - Kết quả trả về: 
        - 1: đăng ký thành công.
        - 0: đăng ký không thành công (trong trường hợp SDT đã tồn tại rồi)
    - Chức năng: Thêm người dùng vào database.
    - Sử dụng: đăng ký tài khoản, đăng ký lịch hẹn (chưa từng khám ở đây).

- **sp_XemLichKham**:
    - Tham số truyền vào: *@SDT VARCHAR(10)*
    - Kết quả trả về: 
        - Bảng thông tin các lịch khám (thứ tự: *NgayKham, GioKham, MaNhaSi, TenNhaSi, HoTen, SDT*) 
        - Bảng 1 dòng 1 cột (result: 0)
    - Chức năng: Xem lịch hẹn khám của @SDT.

- **sp_XemHoSoBenhAn**:
    - Tham số truyền vào: *@SDT VARCHAR(20)*.
    - Kết quả trả về: Tất cả các *nhóm 3 bảng* thông tin theo thứ sau:
        - Thông tin Hồ sơ bệnh án (*MaHoSo, NgayKham, MaNhaSi, TongTien*);
        - Thông tin Đơn thuốc (*MaThuoc, SoLuong, DonGia*);
        - Thông tin Đơn dịch vụ (*MaDV, SoLuong, DonGia*).
    - Chức năng: Xem chi tiết hồ sơ bệnh án của @SDT.

- **sp_CapNhatThongTin**
    - Tham số truyền vào: *@SDT VARCHAR(20), @HoTen NVARCHAR(30), @NgaySinh DATE, @DiaChi NVARCHAR(50), @MatKhau VARCHAR(20)*.

    **Lưu ý**: Không cho cập nhật *@SDT*, *@SDT, @HoTen* phải khác rỗng.

    - Kết quả trả về: Tất cả các *nhóm 3 bảng* theo thứ tự:
        - 1: cập nhật thông tin thành công;
        - 0: thất bại (*@MatKhau* không đúng định dạng)
    - Chức năng: Xem chi tiết hồ sơ bệnh án của @SDT.

- **f_KTLichTrungNhau**
    - Tham số truyền vào: *@NgayGioBD1 DATETIME, @NgayGioKT1 DATETIME, @NgayGioBD2 DATETIME, @NgayGioKT2 DATETIME*
    - Kết quả trả về:
        - 1: trùng
        - 0: không trùng
    - Chức năng: Kiểm tra xem 2 lịch có trùng (giao) nhau không

- **f_KTLichHopLe**
    - Tham số truyền vào: *@MaNhaSi VARCHAR(20), @NgayGioBD DATETIME, @NgayGioKT DATETIME*
    - Kết quả trả về:
        - 1: hợp lệ
        - 0: không hợp lệ (có lịch trùng nhau)
    - Chức năng: Kiểm tra lịch bận thêm vào có hợp lệ không

- **sp_CapNhatLichBan**:
    - Tham số truyền vào: *@MaNhaSi VARCHAR(20), @MALB INT, @NgayBDMoi VARCHAR(20), @GioBDMoi VARCHAR(20), @NgayKTMoi VARCHAR(20), @GioKTMoi VARCHAR(20)*
    - Kết quả trả về: 
        - 1: cập nhật thành công
        - 0: cập nhật không thành công (f_KTLichHopLe = FALSE)
    - Chức năng: Cập nhật (Sửa) lịch bận của @MaNhaSi

- **sp_ThemLichBan**:
    - Tham số truyền vào: *@MaNhaSi VARCHAR(20), @NgayBD VARCHAR(20), @GioBD VARCHAR(20), @NgayKT VARCHAR(20), @GioKT VARCHAR(20)*
    - Kết quả trả về:
        - 1: thêm thành công
        - 0: thêm không thành công (f_KTLichHopLe = FALSE)
    - Chức năng: Thêm lịch bận mới vào lịch của @MaNhaSi

- **sp_ThanhToan**:
    - Tham số truyền vào: *@SDT VARCHAR(20)*
    - Kết quả trả về:
        - 1: thanh toán thành công (không còn hồ sơ nào chưa thanh toán cũng trả về thành công)
        - 0: thanh toán không thành công (@SDT không tồn tại)
    - Chức năng: Thực hiện thanh toán hóa đơn chưa thanh toán của @SDT

- **sp_TaoHoSoBenhAn**:
    - Tham số truyền vào: *@SDT VARCHAR(20), @MaNhaSi VARCHAR(20)*
    - Kết quả trả về: 
        - 1: tạo thành công
        - 0: không thành công (@SDT không tồn tại)
    - Chức năng: Tạo hồ sơ bệnh án mới cho @SDT

- **sp_TaoDonThuoc**:
    - Tham số truyền vào: *@MaHoSo INT, @TenThuoc CHAR(30), @SoLuong INT*
    - Kết quả trả về:
        - 1: tạo thành công
        - 0: không thành công (@SoLuong vượt quá số lượng tồn)
    - Chức năng: Thêm thuốc vào @MaHoSo

- **sp_TaoDonDV**:
    - Tham số truyền vào: *@MaHoSo INT, @TenDV NVARCHAR(50)*
    - Kết quả trả về: 
    - Kết quả trả về:
        - 1: tạo thành công
        - 0: không thành công
    - Chức năng: Thêm dịch vụ vào @MaHoSo

- **sp_KhoaTaiKhoan**:
    - Tham số truyền vào: *@SDT VARCHAR(20), @LoaiND VARCHAR(10)*
    - Kết quả trả về:
        - 1: khóa thành công
        - 0: không thành công (khi @SDT không có tài khoản)
    - Chức năng: Khóa tài khoản @SDT gặp vấn đề 

- **sp_ThemThuoc**:
    - Tham số truyền vào: *@MaThuoc CHAR(10), @TenThuoc CHAR(30),	@DonGia INT, @ChiDinh NVARCHAR(100), @SoLuongTon INT, @NgayHetHan DATE*
    - Kết quả trả về: 
        - 1: thêm thành công
        - 0: không thành công (@MaThuoc đã tồn tại, @NgayHetHan trước ngày thêm)
    - Chức năng: Thêm thuốc mới.

- **sp_SuaThongTinThuoc**:
    - Tham số truyền vào: *@MaThuoc CHAR(10), @TenThuoc CHAR(30),	@DonGia INT, @ChiDinh NVARCHAR(100), @SoLuongTon INT, @NgayHetHan DATE*
    - Kết quả trả về:
        - 1: sửa thành công
        - 0: không thành công (@MaThuoc chưa tồn tại, @NgayHetHan trước ngày sửa)
    - Chức năng: Sửa thông tin thuốc.
