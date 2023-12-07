use master
go
create database HQT_CSDL
go
use HQT_CSDL
go

CREATE TABLE NGUOIDUNG
(
	SDT VARCHAR(20) PRIMARY KEY,
	HoTen NVARCHAR(30) NOT NULL,
	NgaySinh DATE,
	DiaChi NVARCHAR(50)
);

CREATE TABLE TAIKHOAN
(
	SDT VARCHAR(20),
	LoaiND varchar(10) default 'Khach',
	MatKhau varchar(20) NOT NULL,
	TrangThai bit DEFAULT 1
	PRIMARY KEY (SDT, LoaiND)
	FOREIGN KEY (SDT) REFERENCES NGUOIDUNG(SDT)
)

CREATE TABLE HOSOBENHAN
(
	MaHoSo int,
	SDT VARCHAR(20) NOT NULL,
	NgayKham datetime NOT NULL DEFAULT CURRENT_TIMESTAMP, 
	MaNhaSi VARCHAR(20) NOT NULL,
	TongTien bigint DEFAULT 0

	PRIMARY KEY (MaHoSo)
	FOREIGN KEY (MaNhaSi) REFERENCES NGUOIDUNG(SDT),
	FOREIGN KEY (SDT) REFERENCES NGUOIDUNG(SDT),

)

CREATE TABLE THUOC
(
	MaThuoc char(10),
	TenThuoc char(30) NOT NULL,
	DonGia int NOT NULL,
	ChiDinh nvarchar(100),
	SoLuongTon int NOT NULL,
	NgayHetHan date NOT NULL

	PRIMARY KEY (MaThuoc)
)

CREATE TABLE DONTHUOC
(
	MaDonThuoc int,
	MaThuoc char(10),
	SoLuong int NOT NULL DEFAULT 1,
	DonGia int NOT NULL

	PRIMARY KEY (MaDonThuoc, MaThuoc),
	FOREIGN KEY (MaThuoc) REFERENCES THUOC(MaThuoc),
	FOREIGN KEY (MaDonThuoc) REFERENCES HOSOBENHAN(MaHoSo)

)


CREATE TABLE DICHVU
(
	MaDV char(10),
	TenDV nvarchar(50),
	DonGia int NOT NULL,

	PRIMARY KEY (MaDV)
)

CREATE TABLE DONDICHVU
(
	MaDonDV int,
	MaDV char(10),
	PRIMARY KEY (MaDonDV, MaDV),
	DonGia int NOT NULL,


	FOREIGN KEY (MaDV) REFERENCES DICHVU(MaDV),
	FOREIGN KEY (MaDonDV) REFERENCES HOSOBENHAN(MaHoSo)

)	



CREATE TABLE LICHHEN
(
	MaLH int,
	ThoiGianHen datetime NOT NULL,
	SDT VARCHAR(20) NOT NULL,
	MaNhaSi VARCHAR(20) NOT NULL,
	DaXong bit DEFAULT 0

	PRIMARY KEY (MaLH)
	FOREIGN KEY (MaNhaSi) REFERENCES NGUOIDUNG(SDT)
)

CREATE TABLE LICHBAN
(
	MALB int,
	MaNhaSi VARCHAR(20) NOT NULL, 
	NgayGioBatDau datetime NOT NULL,
	NgayGioKetThuc datetime NOT NULL,
	PRIMARY KEY(MALB),
	FOREIGN KEY (MaNhaSi) REFERENCES NGUOIDUNG(SDT)
)




--INSERT DATA
INSERT INTO NGUOIDUNG(SDT, HoTen, NgaySinh, DiaChi)
VALUES
    ('397',N'Phan Nguyên Phương','2003-03-02', N'Thăng Bình, Quảng Nam'),
	('020',N'Vũ Minh Thư','2003-02-12', N'Phú Riềng, Bình Phước'),
	('237',N'Nguyễn Tạ Bảo','2003-01-01', N'Quy Nhơn, Bình Định'),
	('630',N'Võ Thu Trang','2003-01-02', N'Bảo Lộc, Lâm Đồng'),
	('564',N'Lê Nguyễn Trọng Nghĩa','2003-12-12', N'Duy Xuyên, Quảng Nam'),
	('123',N'Nguyễn Văn A','2003-11-02', N'Bảo Lộc, Lâm Đồng'),
	('234',N'Võ Nguyễn Văn B','2003-10-02', N'Quế Sơn, Lâm Đồng'),
	('345',N'Võ Thị D','2003-12-20', N'Núi Thành, Lâm Đồng'),
	('456',N'Phan Thị E','2003-01-02', N'Bảo Lộc, Lâm Đồng'),
	('567',N'Nguyễn Thị F','2003-12-20', N'Núi Thành, Lâm Đồng'),
	('678',N'Lê Văn G','2003-12-20', N'Núi Thành, Lâm Đồng');
	


INSERT INTO TAIKHOAN(SDT, MatKhau, LoaiND, TrangThai)
VALUES
    ('123','a','Khach', 1),
    ('234','b','Khach', 1),
    ('345','c','Khach', 1),
    ('397','phuong','BacSi', 1),
	('020','thu','NhanVien', 1),
	('237','bao','BacSi', 1),
	('630','Trang','NhanVien', 1),
	('564','Nghia','Admin', 1);

INSERT INTO LICHHEN(MaLH, SDT, MaNhaSi, ThoiGianHen, DaXong)
VALUES
	(1, '123', '397', '2023-12-02 15:00:00', 0),
	(2, '234', '397', '2023-12-03 08:00:00', 0), 	
	(3, '456', '397', '2023-12-02 10:00:00', 0), 
	(4, '345', '237', '2023-12-02 11:00:00', 0), 
	(5, '567', '237', '2023-12-03 20:00:00', 0), 
	(6, '678', '237', '2023-12-03 07:00:00', 0);



INSERT INTO LICHBAN(MALB, MaNhaSi, NgayGioBatDau, NgayGioKetThuc)
VALUES
	(1, '397', '2023-12-02 05:00:00', '2023-12-02 07:00:00'),
	(2, '397', '2023-12-03 05:00:00', '2023-12-03 07:00:00'), 	
	(3, '397', '2023-12-02 21:00:00', '2023-12-03 04:00:00'), 
	(4, '237', '2023-12-01 11:00:00', '2023-12-02 04:00:00'), 
	(5, '237', '2023-12-04 05:00:00', '2023-12-05 05:00:00');


INSERT INTO THUOC(MaThuoc, TenThuoc, SoLuongTon, DonGia, NgayHetHan, ChiDinh)
VALUES
	('T001', 'Paracetamol', 100, 10000, '2025-12-30', N'Thuốc không dùng cho người da đen'),
	('T002', 'Panadol', 100, 2000, '2025-12-30', N'Thuốc không dùng cho dân Thanh Hóa'),
	('T003', 'Celpha', 100, 5000, '2025-12-30', N'Thuốc không dùng cho người tên Trang'),
	('T004', 'Delta', 100, 8000, '2025-12-30', N'Thuốc không dùng cho người không phát âm được chữ a'),
	('T005', 'Gamma', 100, 3000, '2025-12-30', N'Thuốc không dùng cho thằng tên Nghĩa');


INSERT INTO DICHVU(MaDV, TenDV, DonGia)
VALUES
	('D001', N'Cạo vôi răng', 100000),
	('D002', N'Nhổ răng', 2000000),
	('D003', N'Tẩy trắng răng', 100000),
	('D004', N'Trồng răng', 3000000),
	('D005', N'Niềng răng', 40000000);


INSERT INTO HOSOBENHAN(MaHoSo, SDT, MaNhaSi, NgayKham, TongTien)
VALUES
	(1, '123', '397', '2023-12-02 15:00:00', 2170000),
	(2, '234', '397', '2023-12-03 08:00:00', 2010000), 	
	(3, '456', '397', '2023-12-02 10:00:00', 150000), 
	(4, '345', '237', '2023-12-02 11:00:00', 3190000), 
	(5, '567', '237', '2023-12-03 20:00:00', 40015000);


INSERT INTO DONDICHVU(MaDonDV, MaDV, DonGia)
VALUES
	(1, 'D001', 100000),
	(1, 'D002', 2000000),
	(2, 'D002', 2000000),
	(3, 'D003', 100000),
	(4, 'D004', 3000000),	
	(4, 'D003', 100000),
	(5, 'D005', 40000000);

INSERT INTO DONTHUOC(MaDonThuoc, MaThuoc,SoLuong, DonGia)
VALUES
	(1, 'T001', 5, 10000),
	(1, 'T002', 10, 2000),
	(2, 'T002', 5, 2000),
	(3, 'T003', 10, 5000),
	(4, 'T004', 5, 8000),	
	(4, 'T003', 10,5000 ),
	(5, 'T005', 5, 3000);