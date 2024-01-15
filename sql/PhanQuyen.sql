USE HQT_CSDL
GO

/* TẠO ROLE - CẤP QUYỀN */

----------0. Dùng chung----------
--Tạo role
sp_addrole 'Users' --sp_droprole 'Users'
GO

--Cấp quyền
GRANT SELECT, UPDATE ON TAIKHOAN(SDT, MatKhau) TO Users
GRANT INSERT ON TAIKHOAN TO Users

GRANT SELECT, INSERT, UPDATE ON NGUOIDUNG TO Users
GO

----------1. Quản trị viên----------
--Tạo role
sp_addrole 'Admin' --sp_droprole 'Admin'
GO

--Cấp quyền
GRANT SELECT ON TAIKHOAN(LoaiND, TrangThai) TO Users
GRANT UPDATE ON TAIKHOAN(TrangThai) TO Admin

GRANT SELECT, INSERT ON THUOC TO Admin
GRANT UPDATE ON THUOC(TenThuoc, DonGia, ChiDinh, SoLuongTon, NgayHetHan, TrangThai) TO Admin
GO

----------2. Nha sĩ----------
--Tạo role
sp_addrole 'Dentist' --sp_droprole 'Dentist'
GO

--Cấp quyền
GRANT SELECT, INSERT ON HOSOBENHAN(MaHoSo, SDT, NgayKham, NhaSi) TO Dentist

GRANT SELECT, INSERT, DELETE, UPDATE ON DONTHUOC TO Dentist

GRANT SELECT, INSERT, DELETE, UPDATE ON DONDICHVU TO Dentist

GRANT SELECT ON LICHHEN TO Dentist

GRANT SELECT, INSERT, DELETE, UPDATE ON LICHBAN TO Dentist
GO

----------3. Nhân viên----------
--Tạo role
sp_addrole 'Staff' --sp_droprole 'Staff'
GO 

--Cấp quyền
GRANT SELECT, INSERT ON LICHHEN TO Staff

GRANT SELECT ON HOSOBENHAN TO Staff
GRANT UPDATE ON HOSOBENHAN(TongTien) TO Staff

GRANT SELECT ON DONTHUOC TO Staff

GRANT SELECT ON DONDICHVU TO Staff

GRANT SELECT ON THUOC TO Staff
GO

----------4. Khách hàng----------
--Tạo role
sp_addrole 'Customer' --sp_droprole 'Customer'
GO

--Cấp quyền
GRANT SELECT, INSERT ON LICHHEN TO Customer

GRANT SELECT ON HOSOBENHAN TO Customer

GRANT SELECT ON DONTHUOC TO Customer

GRANT SELECT ON DONDICHVU TO Customer
GO


/* TẠO ACCOUNT */

----------1. Quản trị viên----------
sp_addLogin 'ad564', 'Nghia'
GO
CREATE USER ad01 FOR LOGIN ad564
GO
sp_addrolemember 'Users', 'ad01'
GO
sp_addrolemember 'Admin', 'ad01'
GO

----------2. Nha sĩ----------
sp_addLogin 'den237', 'bao'
GO
CREATE USER den01 FOR LOGIN den237
GO
sp_addrolemember 'Users', 'den01'
GO
sp_addrolemember 'Dentist', 'den01'
GO

sp_addLogin 'den397', 'phuong'
GO
CREATE USER den02 FOR LOGIN den397
GO
sp_addrolemember 'Users', 'den02'
GO
sp_addrolemember 'Dentist', 'den02'
GO

----------3. Nhân viên----------
sp_addLogin 'sta020', 'thu'
GO
CREATE USER st01 FOR LOGIN sta020
GO
sp_addrolemember 'Users', 'st01'
GO
sp_addrolemember 'Staff', 'st01'
GO

sp_addLogin 'sta630', 'Trang'
GO
CREATE USER st02 FOR LOGIN sta630
GO
sp_addrolemember 'Users', 'st02'
GO
sp_addrolemember 'Staff', 'st02'
GO

----------4. Khách hàng----------
sp_addLogin 'cus123', 'a'
GO
CREATE USER cus01 FOR LOGIN cus123
GO
sp_addrolemember 'Users', 'cus01'
GO
sp_addrolemember 'Customer', 'cus01'
GO

sp_addLogin 'cus234', 'b'
GO
CREATE USER cus02 FOR LOGIN cus234
GO
sp_addrolemember 'Users', 'cus02'
GO
sp_addrolemember 'Customer', 'cus02'
GO

sp_addLogin 'cus345', 'c'
GO
CREATE USER cus03 FOR LOGIN cus345
GO
sp_addrolemember 'Users', 'cus03'
GO
sp_addrolemember 'Customer', 'cus03'
GO