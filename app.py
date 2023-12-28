from flask import Flask, render_template, redirect, url_for, request, jsonify,session, make_response
import pandas as pd
import pypyodbc as obdc

from datetime import datetime
##NGHIA NGU
# DRIVER_NAME = 'SQL SERVER'
# SERVER_NAME = 'TRONG-NGHIA\MSSQLSERVER01'
# DATABASE_NAME ='HQT_CSDL'
# connection_string = f'DRIVER={DRIVER_NAME};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME}'
# conn = obdc.connect(connection_string)

#BAO2MAI
DRIVER_NAME = 'SQL SERVER'
SERVER_NAME = 'DESKTOP-S3ESUI2\BAOSERVER'
DATABASE_NAME = 'HQT_CSDL'

connection_string = (   
    r'DRIVER={SQL Server};'
    r'SERVER=DESKTOP-S3ESUI2\BAOSERVER;'
    r'DATABASE=HQT_CSDL;'
    r'Trusted_Connection=yes;'
)
conn = obdc.connect (connection_string)


app = Flask(__name__)
app.secret_key = 'nghia1804'

@app.route('/')
def base():
    return redirect(url_for('home'))

@app.route('/home')
def home():
    return render_template("home.html")

@app.route('/login', methods=['POST'])
def login():
    #connect
    print(conn)
    cursor = conn.cursor()

    #get fetch
    sdt = request.form['username']
    password = request.form['password']
    print (sdt,password)
    #run query
    cursor.execute("{CALL Dang_nhap(?, ?)}", (sdt, password))
    rows = cursor.fetchall()
    print(rows[0][0])
    cursor.close()
   # Store 'sdt' and 'password' in session
    session['sdt'] = sdt
    session['password'] = password
    
    if rows[0][0]=='Admin':
        # print("after:" ,session)
        return jsonify({'redirect': '/admin'})
    elif rows[0][0] == 'BacSi':
        # print("after:" ,session)
        return jsonify({'redirect': '/dentist'})       
    elif rows[0][0] == 'NhanVien':
        # print("after:" ,session)
        print ("vo nhan vien roi ne")
        return jsonify({'redirect': '/staff'})
    elif rows[0][0] == 'Khach':
        print("after:" ,session)
        return jsonify({'redirect': '/user'})
    return jsonify({'message': 'Tên người dùng hoặc mật khẩu không đúng'})

@app.route('/alert')
def alert():
    return render_template("alert.html")

@app.route('/admin')
def admin():
    # if 'sdt' in session:
    return render_template("admin.html")
    # else:
    #     return redirect(url_for('alert'))
    
@app.route('/dentist')
def dentist():
    # if 'sdt' in session:
    return render_template("dentist.html")
    # else:
    #     return redirect(url_for('alert'))
    
@app.route('/logout', methods = ['GET'])
def logout():
    # session['sdt'] = False
    # session.clear()
    return redirect(url_for('home'))

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/submit_form', methods=['POST'])
def submit_form():
    if request.method == 'POST':
        phone = request.form['phone']
        password = request.form['password']
        full_name = request.form['full_name']
        appointment_date = request.form['date']
        address = request.form['address']
        
        cursor = conn.cursor()

        cursor.execute("SELECT * FROM TAIKHOAN WHERE SDT = ? AND LoaiND = 'Khach'", (phone,))
        existing_entry = cursor.fetchone()

        if existing_entry:
            cursor.close()
            return jsonify({'status': 'error', 'message': 'Số điện thoại này đã được đăng ký!'})

        cursor.execute("INSERT INTO NGUOIDUNG (SDT, HoTen, NgaySinh, DiaChi) VALUES (?, ?, ?, ?)",
                       (phone, full_name, appointment_date, address))   
        cursor.execute("INSERT INTO TAIKHOAN (SDT, LoaiND, MatKhau, TrangThai) VALUES (?, 'Khach', ?, 'True')",
                       (phone, password))
        conn.commit()
        cursor.close()
        return jsonify({'status': 'success', 'message': 'Đăng ký thành công'})
# Nhan vien
@app.route('/staff' , methods=['GET', 'POST'])
def dat_lich_hen():
  return render_template('./nhanvien/dat_lich_hen.html' )

@app.route('/xuat_hoa_don', methods=['GET', 'POST'])
def xuat_hoa_don():
    return render_template('./nhanvien/xuat_hoa_don.html')

@app.route('/query-database-xuat_hoa_don', methods=['GET'])
def query_database_xuathoadon():
    try :   
        user_input = request.args.get('userInput')
        print (user_input)
        # Perform your database query here using the provided user_input

        # Replace the following line with the actual result from your database query
        cursor = conn.cursor ()
        cursor.execute("{CALL Get_bill_info_from_SDT(?)}", (user_input,))
#         query = """DECLARE @TEST BIT
# EXEC @TEST = sp_KiemTraSdtTonTai '{}'
# SELECT @TEST AS COLU
#         """.format (user_input)
#         cursor.execute(query)
        
        thongtin = cursor.fetchall()
        print ("hehehe" , thongtin)
        cursor.nextset()
        thuoc = cursor.fetchall()
        cursor.nextset()
        dichvu = cursor.fetchall()
        
        print (thongtin , thuoc, dichvu)
        # Commit the transaction
        conn.commit()
        # Close the connection
        cursor.close()
        if len (thongtin) == 0 :
            return jsonify (0)
        else :
            thongtin = [{"mahoadon" : thongtin[i][0],
                        "ngaykham":thongtin[i][1],
                        "manhasi": thongtin[i][2],
                        "tennhasi": thongtin[i][3],
                        "tongtien":thongtin[i][4]
                        } for i in range (len(thongtin))]
            thuoc = [{"mahoadonthuoc" : thuoc[i][0],
                "Mã thuốc" : thuoc[i][1],
                        "Tên Thuốc":thuoc[i][2],
                        "Số Lượng": thuoc[i][3],
                        "Đơn giá": thuoc[i][4],
                        } for i in range (len(thuoc))]

            dichvu = [{"mahoadondichvu": dichvu[i][0],
                "Mã Dịch Vụ" : dichvu[i][1],
                        "Tên Dịch Vụ":dichvu[i][2],
                        "Đơn giá": dichvu[i][3],
                        "Số Lượng Dịch Vụ": 1,
                        } for i in range (len(dichvu))]
            
            # thuoctheohd_list = []
            # dichvutheohd_list = []
            # thongtin_list = []
            # for i in range (len (thongtin) ) :
            thuoctheohd = []
            dichvutheohd = []
            mahd = thongtin[0]["mahoadon"]
            for th in thuoc :
                if th["mahoadonthuoc"] == mahd :
                    thuoctheohd.append (th)
            for dv in dichvu :
                if dv["mahoadondichvu"] == mahd :
                    dichvutheohd.append (dv)
                    
                
            print ("sdsadsa" , thongtin[0] , thuoctheohd , dichvutheohd)
            
            return jsonify({"thongtin" : [thongtin[0]] ,
                            "thuoc": thuoctheohd ,
                            "dichvu":dichvutheohd
                            })
    except Exception as e:
        # Catch any exceptions and return an error message
        print(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500  # 500 is the HTTP status code for Internal Server Error

@app.route('/query-database-ho-so-kb', methods=['GET'])
def query_database_ho_so_kb():
    try :   
        user_input = request.args.get('userInput')
        if user_input == "khachhang" :
            user_input = session.get ('sdt')
        print (user_input)
        # Perform your database query here using the provided user_input

        # Replace the following line with the actual result from your database query
        cursor = conn.cursor ()
        cursor.execute("{CALL Get_bill_info_from_SDT(?)}", (user_input,))
        
        thongtin = cursor.fetchall()
        cursor.nextset()
        thuoc = cursor.fetchall()
        cursor.nextset()
        dichvu = cursor.fetchall()
        
        print (thongtin , thuoc, dichvu)
        # Commit the transaction
        conn.commit()
        # Close the connection
        cursor.close()
        if len (thongtin) == 0 :
            return jsonify (0)
        else :
            thongtin = [{"mahoadon" : thongtin[i][0],
                        "ngaykham":thongtin[i][1],
                        "manhasi": thongtin[i][2],
                        "tennhasi": thongtin[i][3],
                        "tongtien":thongtin[i][4]
                        } for i in range (len(thongtin))]
            thuoc = [{  "mahoadonthuoc" : thuoc[i][0],                        
                      "Mã thuốc" : thuoc[i][1].strip (),
                        "Tên Thuốc":thuoc[i][2].strip (),
                        "Số Lượng": thuoc[i][3],
                        "Đơn giá": thuoc[i][4],
                        } for i in range (len(thuoc))]
                    
            dichvu = [{ "mahoadondichvu" : dichvu[i][0],
                        "Mã Dịch Vụ" : dichvu[i][1].strip (),
                        "Tên Dịch Vụ":dichvu[i][2],
                        "Đơn giá": dichvu[i][3],
                        "Số Lượng Dịch Vụ": 1,
                        } for i in range (len(dichvu))]
            
            thuoctheohd_list = []
            dichvutheohd_list = []
            thongtin_list = []
            for i in range (len (thongtin) ) :
                thuoctheohd = []
                dichvutheohd = []
                mahd = thongtin[i]["mahoadon"]
                for th in thuoc :
                    if th["mahoadonthuoc"] == mahd :
                        thuoctheohd.append (th)
                for dv in dichvu :
                    if dv["mahoadondichvu"] == mahd :
                        dichvutheohd.append (dv)
                        
                thuoctheohd_list.append (thuoctheohd)
                dichvutheohd_list.append (dichvutheohd)
                
            print ("sdsadsa" , thuoctheohd_list , dichvutheohd_list)
            thongtinlist = [[thongtindic] for thongtindic in thongtin]
            print ("hihdishdis" ,thongtinlist) 
            return jsonify({"thongtin" : thongtinlist ,
                            "thuoc": thuoctheohd_list ,
                            "dichvu":dichvutheohd_list
                            })
    except Exception as e:
        # Catch any exceptions and return an error message
        print(f"Error: {str(e)}")
        return jsonify({"error": str(e)}), 500
    
    
    

    
@app.route('/query-database-dat-lich-hen', methods=['GET'])
def query_database_datlichhen():
    user_input = request.args.get('userInput')
    print (user_input)
    # Perform your database query here using the provided user_input

    # Replace the following line with the actual result from your database query
    cursor = conn.cursor ()
    cursor.execute("{CALL sp_LayThongTinTuSDT(?)}", (user_input,))
    rows = cursor.fetchall()
     # Commit the transaction
    conn.commit()

    # Close the connection
    cursor.close()
    print ("rows: " , len (rows[0]))
    if len (rows[0]) == 1 :
        return jsonify (0)  
    else :
        result_from_database = {"hoten" : rows[0][0],
                                "ngaysinh" : rows[0][1],
                                "diachi" : rows[0][2]
                                }
        # print (result_from_database)
        return jsonify(result_from_database)
    
@app.route('/get_available_doctors', methods=['GET'])
def get_available_doctors():
    # Retrieve the selected time and date from the request
    selected_time = request.args.get('selected_time')
    selected_date = request.args.get('selected_date')
    cursor = conn.cursor ()
    cursor.execute("{CALL sp_TimNhaSiRanh(? , ?)}", (selected_time,selected_date))
    rows = cursor.fetchall()
    print ("rows: " , rows)
    # Perform your logic to query the database and get available doctors
    # Replace the following line with your database query
     # Commit the transaction
    conn.commit()

    # Close the connection
    cursor.close()
    if len (rows) == 0 :
        return jsonify (0)  
    else :
        doctors_id =  [row[0] for row in rows]
        available_doctors = [row[1] for row in rows]
        print (available_doctors)
        return jsonify(available_doctors=available_doctors , doctor_ids = doctors_id)
    
@app.route('/register_no_info', methods=[ 'GET' , 'POST'])
def register():
    # Get form data from the request
    print ("cscs")
    sdt = request.args.get('sdt')
    name = request.args.get('name')
    birth = request.args.get('birth')
    address = request.args.get('address')
    print (type (sdt) ,type (name),type ( birth ) , type (address) )
    print (sdt , name ,birth , address)
    
    cursor = conn.cursor()
    query = """
    SET NOCOUNT ON;
    DECLARE @SUS INT 
    EXEC @SUS = sp_ThemNguoiDung '{}', N'{}','{}', N'{}' 
    SELECT @SUS AS RESULT""".format (sdt, name, birth, address).strip ()

    cursor.execute(query)
    # Call the stored procedure
    # cursor.execute("{CALL sp_ThemNguoiDung (?, ?, ?, ?)}", (sdt, name, birth, address))
    # Fetch the result
    result_value = cursor.fetchone()[0]
    # Close the connection
    conn.commit()
    cursor.close()
    print ("sdsad" , result_value)
    if result_value == 1 :
        return jsonify (1)  
    elif result_value == 0:
        return jsonify (0)

@app.route('/register_have_info', methods=['GET'])
def register_info():
    # Get form data from the request
    print ("Dsds")
    sdt = request.args.get('sdt')
    print ("sdt new" , sdt)
    if sdt == "khachhang" :
        sdt = session.get('sdt')
        
    giokham = request.args.get('giokham')
    ngaykham = request.args.get('ngaykham')
    bacsi = request.args.get('bacsi').split (" - ")[-1]
    hoten = ""
    ngaysinh = ""
    diachi = ""
    print ("hehehe" ,sdt, giokham, ngaykham, bacsi, ngaykham)
    cursor = conn.cursor ()
    query = """
    SET NOCOUNT ON;
    DECLARE @RESULT INT
 EXEC @RESULT = sp_DatLichKham '{}', N'{}','{}', N'{}', '{}', '{}', '{}'
 SELECT @RESULT AS COL
    """.format (sdt , hoten , ngaysinh , diachi , ngaykham , giokham , bacsi)
    # cursor.execute("{CALL sp_DatLichKham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    cursor.execute (query)
    result_value = cursor.fetchone()[0]
     # Commit the transaction
    conn.commit()
    cursor.close()
    # Close the connection
    print ("ds" , result_value)
    if result_value == 1 :
        print ("thanh cong")
        return jsonify (1)  
    elif result_value == 0:
        print ("that bai")
        return jsonify (0)
    # Return a response (you can customize this based on your needs)

@app.route('/query-database-thongtinthuoc', methods=['GET'])
def get_tt_thuoc():
    # Retrieve the selected time and date from the request
    ten_thuoc = request.args.get('userInput')
    cursor = conn.cursor ()
    cursor.execute("{CALL sp_TimThuocBangTen(? )}", (ten_thuoc,))
    rows = cursor.fetchall()
     # Commit the transaction
    conn.commit()

    # Close the connection
    cursor.close()
    print ("rows: " , rows)
    # Perform your logic to query the database and get available doctors
    # Replace the following line with your database query
    
    if len (rows) == 0 :
        return jsonify (0)  
    else :
        result_from_database = [{"a_mathuoc": rows[i][0],
                                "b_tenthuoc": rows[i][1],
                                "c_dongia": rows[i][2],
                                "d_chidinh": rows[i][3],
                                "e_soluongton": rows[i][4],
                                "f_ngayhethan": rows[i][5],
                                } for i in range (len (rows)) ]
        print (result_from_database)
        return jsonify ({"thongtinthuoc" : result_from_database})
    
@app.route('/query-database-lichkham', methods=['GET'])
def get_tt_lichkham():
    # Retrieve the selected time and date from the request
    sdt = request.args.get('userInput')
    if (sdt == "khachang") :
        sdt = session.get ("sdt")
    cursor = conn.cursor ()
    cursor.execute("{CALL sp_XemLichKham(? )}", (sdt,))
    rows = cursor.fetchall()
     # Commit the transaction
    conn.commit()
    # Close the connection
    cursor.close()
    print ("rows: " , rows[0])
    # Perform your logic to query the database and get available doctors
    # Replace the following line with your database query
    
    if rows[0][0] == 0 :
        return jsonify (0)  
    else :
        result_from_database = [{"a_ngaykham": rows[i][0],
                                "b_giokham": rows[i][1].split (".")[0],
                                "c_manhasi": rows[i][2],
                                "d_tennhasi": rows[i][3],
                                "e_hoten": rows[i][4],
                                "f_sdt": rows[i][5],
                                } for i in range (len (rows)) ]
        print (result_from_database)
        return jsonify ({"ttlichkham" : result_from_database})
    
    
@app.route('/tao_tk_daydu', methods=['GET'])
def tao_tk_daydu():
    print("SDsds")
    sdt = request.args.get('sdt')
    name = request.args.get('name')
    birth = request.args.get('birth')
    address = request.args.get('address')
    password = request.args.get('password')
    print("dsdasds", sdt, "dsdasds", name, "dsdasds", birth, "dsdasds", address, "dsdasds", password)
    
    # Connect to the database
    
    cursor = conn.cursor()

    # Call the stored procedure to register the user
    # cursor.execute("{CALL sp_DangKiTaiKhoan(?,?,?,?,?,? , ?)}", (sdt, name, birth, address, password, "Khach", result))
    query = """
    SET NOCOUNT ON;
    DECLARE @RESULT INT
 EXEC @RESULT = sp_DangKiTaiKhoan '{}',N'{}','{}',N'{}','{}','Khach'
 SELECT @RESULT AS COL
    """.format (sdt , name , birth , address , password )
    # cursor.execute("{CALL sp_DatLichKham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    cursor.execute (query)
    result_value = cursor.fetchone()[0]
    # Commit the transaction
    conn.commit()

    # Close the connection  
    cursor.close()

    # Check the result value from the stored procedure
    if result_value == 1 :
        print ("thanh cong")
        return jsonify (1)  
    elif result_value == 0:
        print ("that bai")
        return jsonify (0)

@app.route('/query-kiemtra-taikhoan', methods=['GET'])
def kiemtrataikhoan():
    print("SDsds")
    sdt = request.args.get('userInput')
    print ("sdt" , sdt)    
    # Connect to the database
    cursor = conn.cursor()

    # Call the stored procedure to register the user
    # cursor.execute("{CALL sp_DangKiTaiKhoan(?,?,?,?,?,? , ?)}", (sdt, name, birth, address, password, "Khach", result))
    query = """EXEC sp_LayThongTinTuSDT '{}';""".format (sdt  )
    # cursor.execute("{CALL sp_DatLichKham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    cursor.execute (query)
    result_value = cursor.fetchall()
    print ("result" ,result_value[0][0] )
    # Commit the transaction
    conn.commit()

    # Close the connection  
    cursor.close()

    # Check the result value from the stored procedure
    if  result_value[0][0] ==  0:
        print ("chua co thong tin")
        return jsonify (0)  
    else :
        print ("da co thong tin")
        cursor = conn.cursor()
        query = """
        SET NOCOUNT ON;
        DECLARE @TEST BIT
        EXEC @TEST = sp_KiemTraTKTonTai '{}', '{}'
        SELECT @TEST AS COL
        """.format (sdt , "Khach")
        cursor.execute (query)
        result_value = cursor.fetchall()
        conn.commit()
    # Close the connection  
        cursor.close()
        if result_value[0][0] == 0  :
        
            return jsonify (1)
        
        else :
            # tai khoan ton tai roi
            return jsonify (2)
        
        
        
@app.route('/tao_tk_mk', methods=['GET'])
def tao_tk_mk():
    print("SDsds")
    sdt = request.args.get('sdt')
    name = ""
    birth = ""
    address = "" 
    password = request.args.get('password')
    print("dsdasds", sdt, "dsdasds", name, "dsdasds", birth, "dsdasds", address, "dsdasds", password)
    # Connect to the database
    cursor = conn.cursor()
    # Call the stored procedure to register the user
    # cursor.execute("{CALL sp_DangKiTaiKhoan(?,?,?,?,?,? , ?)}", (sdt, name, birth, address, password, "Khach", result))
    query = """
    SET NOCOUNT ON;
    DECLARE @RESULT INT
 EXEC @RESULT = sp_DangKiTaiKhoan '{}',N'{}','{}',N'{}','{}','Khach'
 SELECT @RESULT AS COL
    """.format (sdt , name , birth , address , password )
    # cursor.execute("{CALL sp_DatLichKham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    cursor.execute (query)
    result_value = cursor.fetchone()[0]
    # Commit the transaction
    conn.commit()

    # Close the connection  
    cursor.close()

    # Check the result value from the stored procedure
    if result_value == 1 :
        print ("thanh cong")
        return jsonify (1)  
    elif result_value == 0:
        print ("that bai")
        return jsonify (0)

@app.route('/query_thong_tin', methods=['GET'])
def tim_thong_tin():
    print("SDsds")
    sdt = session.get ('sdt')
    print ("sdt" , sdt)
    # Connect to the database
    cursor = conn.cursor()
    # Call the stored procedure to register the user
    # cursor.execute("{CALL sp_DangKiTaiKhoan(?,?,?,?,?,? , ?)}", (sdt, name, birth, address, password, "Khach", result))
    query = """
    SET NOCOUNT ON;
    EXEC sp_LayThongTinTuSDT '{}'
    """.format (sdt )
    # cursor.execute("{CALL sp_DatLichKham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    cursor.execute (query)
    result_value = cursor.fetchall ()[0]
    # Commit the transaction
    conn.commit()
    # Close the connection  
    cursor.close()
    print ("result_value" , result_value)
    # Check the result value from the stored procedure
    if len (result_value) == 0 :
        print ("that bai")
        return jsonify (0)  
    else :
        return jsonify ({
            "name" : result_value[0],
            "birth" :  result_value[1],
            "place" : result_value[2] 
        }) 
@app.route('/editinformation', methods=['GET'])
def editinformation():
    print("SDsds")
    sdt = session.get ('sdt')
    name = request.args.get('name')
    dob = request.args.get('dob')
    address = request.args.get('address')
    password = session.get ('password')
    print ("sdt" , sdt , name , dob , address , password)
    # Connect to the database
    cursor = conn.cursor()
    # Call the stored procedure to register the user
    # cursor.execute("{CALL sp_DangKiTaiKhoan(?,?,?,?,?,? , ?)}", (sdt, name, birth, address, password, "Khach", result))
    query = """
    SET NOCOUNT ON;
    DECLARE @RESULT INT
    EXEC @RESULT = sp_CapNhatThongTin '{}', N'{}', '{}', N'{}', '{}'
    SELECT @RESULT AS COL
    """.format (sdt , name , dob , address , password )
    # cursor.execute("{CALL sp_DatLichKham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    cursor.execute (query)
    result_value = cursor.fetchall ()[0]
    # Commit the transaction
    conn.commit()
    # Close the connection  
    cursor.close()
    print ("result_value" , result_value)
    # Check the result value from the stored procedure
    if result_value == 0 :
        print ("that bai")
        return jsonify (0)  
    else :
        print ("thanh cong")
        return jsonify (1) 

@app.route('/tao_tai_khoan')
def tao_tai_khoan():
  return render_template('./nhanvien/tao_tai_khoan.html')

@app.route('/xem_ttthuoc')
def xem_ttthuoc():
  return render_template('./nhanvien/xem_ttthuoc.html')

@app.route('/lichkham')
def lichkham():
  return render_template('./nhanvien/lichkham.html')

@app.route('/hosokhambenh')
def hosokhambenh():
  return render_template('./nhanvien/hosokhambenh.html')


#Khach hang
@app.route('/aa')
def dangkitaikhoan():
    return render_template('./khachhang/dangkitaikhoan.html')

@app.route('/user')
def xemttcanhan():
    return render_template('./khachhang/thongtincanhan.html')


@app.route('/datlichhen')
def datlichhen():
    return render_template('./khachhang/datlichhen.html')


@app.route('/xemhsbenhan')
def xemhsbenhan():
    return render_template('./khachhang/xemhsbenhan.html')

@app.route('/xemlichkham')
def xemlichkham():
    return render_template('./khachhang/xemlichkham.html')


if __name__ == '__main__':
    app.run(debug=True)