from flask import Flask, render_template, redirect, url_for, request, jsonify,session, make_response
from flask_session import Session
import pypyodbc as obdc
import time

#BAO2MAI
DRIVER_NAME = 'SQL SERVER'
SERVER_NAME = 'TRONG-NGHIA\MSSQLSERVER01'
DATABASE_NAME = 'HQT_CSDL'

# connection_string = (
#     r'DRIVER={SQL Server};'
#     r'SERVER=DESKTOP-S3ESUI2\BAOSERVER;'
#     r'DATABASE=HQT_CSDL;'
#     r'Trusted_Connection=yes;'
# )
# conn = obdc.connect (connection_string)
# connection_string = f'DRIVER={DRIVER_NAME};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME}'

connection_string = f'DRIVER={DRIVER_NAME};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME}'
conn = obdc.connect(connection_string)
conn2 = obdc.connect(connection_string)
app = Flask(__name__)
app.secret_key = 'nghia1804'

app.config["SESSION_PERMANENT"] = False
app.config["SESSION_TYPE"] = "filesystem"
Session(app)

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

    sdt = request.form['username']
    password = request.form['password']
    
    print (sdt,password)
    #run query
    cursor.execute("{CALL spDang_nhap(?, ?)}", (sdt, password))
    rows = cursor.fetchall()
    cursor.close()

    if (len(rows)>1):
        return jsonify({'warning': 'Tài khoản này có nhiều người dùng! Vui lòng chọn', 'redirect': '/routing'})
    elif rows[0][0]=='Admin':
        session['route'] = 'Admin'
        session['sdt'] = sdt
        return jsonify({'redirect': '/admin'})
    elif rows[0][0] == 'BacSi':
        session['route'] = 'Dentist'
        session['sdt'] = sdt
        return jsonify({'redirect': '/dentist'})  
    elif rows[0][0] == 'NhanVien':
        # session['route'] = 'NhanVien'
        session['sdt'] = sdt
        return jsonify({'redirect': '/staff'})
    elif rows[0][0] == 'Khach':
        # session['route'] = 'Khach'
        session['sdt'] = sdt
        return jsonify({'redirect': '/user'})     
     
    return jsonify({'warning': 'Tên người dùng hoặc mật khẩu không đúng'})

@app.route('/alert')
def alert():
    return render_template("alert.html")

@app.route('/admin')
def admin():
    if session.get('sdt'):
        return render_template("admin.html")
    else:
        return redirect(url_for('alert'))
@app.route('/routing')
def routing():
    return render_template("routing.html")

@app.route('/dentist')
def dentist():
    if session.get('sdt'):
        return render_template("dentist.html")
    else:
        return redirect(url_for('alert'))  

@app.route('/logout', methods = ['GET'])
def logout():
    session.clear()
    return redirect(url_for('home'))

@app.route('/signup')
def signup():
    return render_template('signup.html')

@app.route('/datlich')
def datlich():
    return render_template('datlich.html')

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
    
@app.route('/search', methods=['POST'])
def search():
    data = request.get_json()
    phone = data['phone']
    cursor = conn.cursor()
    cursor.execute("{CALL sp_LayThongTinTuSDT(?)}", (phone,))
    rows = cursor.fetchall()
    if (rows[0][0]==0):
        return jsonify({"message": 'Không tồn tại tài khoản này',
                        "full_name": '',
                        "date": '',
                        "address": ''
                        })
    
    else:
        result = {"full_name": rows[0][0],
                "date": rows[0][1],
                    "address": rows[0][2]
                    }
    return jsonify(result)

@app.route('/query_time_date', methods=['POST'])
def time_date():
    data = request.get_json()
    time = data['time']
    date = data['date']
    cursor = conn.cursor()
    cursor.execute("{CALL sp_TimNhaSiRanh(?,?)}", (time, date))
    rows = cursor.fetchall()
    result = {}
    result["full_name"] = []

    if (len(rows) == 0):
        return {"message": 'Không có bác sĩ nào đang rảnh! Vui lòng chọn lại'}
    for row in rows:
        print(row)
        result['full_name'].append(row[1])
    return jsonify(result)


@app.route('/get_entirely_medicine', methods=['POST'])
def get_entirely_medicine():
    cursor = conn.cursor()
    cursor.execute("{CALL sp_LayThongTinKhoThuoc}")
    rows = cursor.fetchall()


    if (len(rows) == 0):
        return {"message": 'Không có dữ liệu'}
    
    result = {
    'mathuoc': [row[0] for row in rows],
    'tenthuoc': [row[1] for row in rows],
    'dongia': [row[2] for row in rows],
    'chidinh': [row[3] for row in rows],
    'soluongton': [row[4] for row in rows],
    'ngayhethan': [row[5] for row in rows]
}

    return jsonify(result)

@app.route('/get_medicine_by_name', methods=['POST'])
def get_medicine_by_name():

    data = request.get_json()
    namesearch = data['namesearch']
    cursor = conn.cursor()
    cursor.execute("{CALL sp_TimThuocBangTen(?)}", (namesearch,))
    rows = cursor.fetchall()

    if (len(rows) == 0):
        return {"message": 'Không có dữ liệu'}
    
    result = {
    'mathuoc': [row[0] for row in rows],
    'tenthuoc': [row[1] for row in rows],
    'dongia': [row[2] for row in rows],
    'chidinh': [row[3] for row in rows],
    'soluongton': [row[4] for row in rows],
    'ngayhethan': [row[5] for row in rows]
}

    return jsonify(result)


@app.route('/admin_create_account', methods=['POST'])
def admin_create_account():
    if request.method == 'POST':
        phone = request.form['phone']
        password = request.form['password']
        full_name = request.form['full_name']
        chuc_nang = request.form['chuc_nang']
        ngay_sinh = request.form['date']
        address = request.form['address']
        if chuc_nang == 'Bác sĩ':
            chuc_nang = 'BacSi'
        else:
            chuc_nang = 'NhanVien'

        cursor = conn.cursor()

        cursor.execute("SELECT * FROM TAIKHOAN WHERE SDT = ? AND LoaiND = ?", (phone,chuc_nang))
        existing_entry = cursor.fetchone()

        if existing_entry:
            cursor.close()
            return jsonify({'status': 'error', 'message': 'Số điện thoại này đã được đăng ký!'})

        cursor.execute("INSERT INTO NGUOIDUNG (SDT, HoTen, NgaySinh, DiaChi) VALUES (?, ?, ?, ?)",
                       (phone, full_name, ngay_sinh, address))   
        cursor.execute("INSERT INTO TAIKHOAN (SDT, LoaiND, MatKhau, TrangThai) VALUES (?, ?, ?, '1')",
                       (phone, chuc_nang, password))
        try:

            conn.commit()
            cursor.close()
            return jsonify({'status': 'success', 'message': 'Đăng ký thành công'})
        except Exception as e:
            error_message = f"Lỗi khi thực hiện commit: {str(e)}"
            cursor.close()
            return jsonify({'status': 'error', 'message': error_message})
    

@app.route('/lock_account', methods=['POST'])
def lock_account():
    phone = request.form['phone_lock']
    cursor = conn.cursor()

    try:
        cursor.execute("SELECT TrangThai FROM TAIKHOAN WHERE SDT = ?", (phone,))
        current_status = cursor.fetchone()

        if current_status and current_status[0] == 0:
            cursor.close()
            return jsonify({'status': 'error', 'message': 'Tài khoản đã bị khóa trước đó'})
        
        cursor.execute("UPDATE TAIKHOAN SET TrangThai = 0 WHERE SDT = ?", (phone,))
        conn.commit()
        cursor.close()
        return jsonify({'status': 'success', 'message': 'Cập nhật thành công'})
    except Exception as e:
        error_message = f"Lỗi khi cập nhật dòng: {str(e)}"
        cursor.close()
        return jsonify({'status': 'error', 'message': error_message})
    
@app.route('/edit_medicine', methods=['POST'])
def edit_medicine():

    mathuoc = request.form.get('mathuoc')
    chidinhthuoc = request.form.get('chidinhthuoc')
    tenthuoc = request.form.get('tenthuoc')
    soluongton = request.form.get('soluongton')
    dongiathuoc = request.form.get('dongiathuoc')
    ngayhethan = request.form.get('ngayhethan')

    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE THUOC SET TenThuoc = ?, DonGia = ?, ChiDinh = ?, SoLuongTon = ?, NgayHetHan = ?  WHERE MaThuoc = ?", (tenthuoc,dongiathuoc,chidinhthuoc,soluongton,ngayhethan,mathuoc))
        conn.commit()
        cursor.close()
        return jsonify({'status': 'success', 'message': 'Cập nhật thành công'})
    except Exception as e:
        error_message = f"Lỗi khi cập nhật dòng: {str(e)}"
        cursor.close()
        return jsonify({'status': 'error', 'message': error_message})
    
@app.route('/delete_medicine', methods=['POST'])
def delete_medicine():
    mathuoc = request.form.get('mathuoc')

    query = """
        SET NOCOUNT ON;
        DECLARE @RESULT INT;
        EXEC @RESULT = sp_XoaThuoc ?;
        SELECT @RESULT AS COL;
    """

    try:
        cursor = conn.cursor()
        cursor.execute(query, (mathuoc,))
        res = cursor.fetchall()[0]
        print(res[0])
        if res[0]==1:
            cursor.commit()
            cursor.close()
            return jsonify({"status":'success',"message": 'Đã xóa thuốc!'})
        else:
            print("that bai")
            cursor.close()
            return jsonify({"status": 'error', "message": 'Đã xảy ra lỗi, vui lòng thử lại!'})
        
    except obdc.Error as e:
        sql_message = e.args[1]
        cursor.rollback()
        return jsonify({"status": 'error', "message": str(sql_message)})
    
    
@app.route('/get_route', methods=['GET'])
def get_route():
    return jsonify(session['route'])
    


@app.route('/add_patient_file', methods=['POST'])
def add_patient_file():
    if not session.get('sdt'):
        return redirect(url_for('alert'))
    
    manhasi = session.get('sdt')
    data = request.json
    print(data)
    sdt = data['sdt']
    tenthuoc = data['tenthuoc']
    soluongthuoc = data['soluongthuoc']
    selectedOption = data['selectedOption']

    cursor = conn2.cursor()
    cursor.execute("SELECT TOP 1 MaHoSo FROM HOSOBENHAN ORDER BY MaHoSo DESC")
    original_code = cursor.fetchone()

    cursor.execute("{CALL sp_TaoHoSoBenhAn (?,?)}", (sdt,manhasi))

    cursor.execute("SELECT TOP 1 MaHoSo FROM HOSOBENHAN ORDER BY MaHoSo DESC")
    after_code = cursor.fetchone()

    if (original_code==after_code):
        return jsonify({'status': 'error', 'message': "Lỗi SĐT!"})
    
    if len(tenthuoc)>0:
        for i in range(len(tenthuoc)):
            query = """
                SET NOCOUNT ON;
                DECLARE @RESULT INT
                EXEC @RESULT = USP_TaoDonThuoc '{}','{}', '{}'
                SELECT @RESULT AS COL
            """.format(after_code[0],tenthuoc[i],soluongthuoc[i])

            cursor.execute(query)
            res = cursor.fetchone()[0]

            if res=='0':
                return jsonify({'status': 'error', 'message': "Lỗi thêm thuốc!"})
            
    if len(selectedOption)>0:
        for item in selectedOption:
            print(item)
            query = """
                SET NOCOUNT ON;
                DECLARE @RESULT INT
                EXEC @RESULT = sp_TaoDonDV '{}', N'{}'
                SELECT @RESULT AS COL
            """.format(after_code[0],item)
            
            cursor.execute(query)
            res = cursor.fetchone()[0]
            print("them dich vu: ",res)
            if res=='0':
                return jsonify({'status': 'error', 'message': "Lỗi thêm dịch vụ!"})
            
    cursor.commit()
    cursor.close()
            
    return jsonify({'status': 'success', 'message': "Đã thêm hồ sơ bệnh án!"})


@app.route('/get_date', methods=['GET'])
def get_date():
    if not session.get('sdt'):
        return redirect(url_for('alert'))
    month = request.args.get('month')
    year = request.args.get('year')
    print(month, year)
    qeury = """
        SELECT DISTINCT DAY(ThoiGianHen) AS ngayHen 
        FROM LICHHEN 
        WHERE MONTH(ThoiGianHen) = {} AND YEAR(ThoiGianHen) = {} AND MaNhaSi = {};
    """.format(month, year, session.get('sdt'))
    cursor = conn.cursor()
    cursor.execute(qeury)
    res = cursor.fetchall()
    dates = []
    for row in res:
        dates.append(row[0])
    print(dates)
    return jsonify({'status': 'success', 'data': dates})

@app.route('/get_schedual', methods=['GET'])
def get_scheduel():
    if not session.get('sdt'):
        return redirect(url_for('alert'))
    month = request.args.get('month')
    year = request.args.get('year')
    day = request.args.get('day')
    qeury = """
        SELECT DATEPART(HOUR, ThoiGianHen) , SDT 
        FROM LICHHEN 
        WHERE DAY(ThoiGianHen) = {} AND MONTH(ThoiGianHen) = {} AND YEAR(ThoiGianHen) = {} AND MaNhaSi = {};
    """.format(day, month, year, session.get('sdt'))
    cursor = conn.cursor()
    cursor.execute(qeury)
    res = cursor.fetchall()

    dict_scheduel ={}
    dict_scheduel['day'] = []
    for item in res:
        temp = []  
        temp.append(item[0])
        temp.append(item[1])
        dict_scheduel['day'].append(temp)

    print(dict_scheduel)
    return jsonify({'status':'success', 'data': dict_scheduel})

@app.route('/get_fix_form', methods=['POST'])
def get_fix_form():
    data = request.json  
    print(data) 
    
    ma_ho_so = data.get('mahoso')
    ten_thuoc = data.get('tenthuoc')
    so_luong = data.get('soluong')
    cursor = conn.cursor()

    query = """
        SET NOCOUNT ON;
        DECLARE @RESULT INT;
        EXEC @RESULT = USP_SuaSoLuongThuoc_DonThuoc ?, ?, ?;
        SELECT @RESULT AS COL;
    """
    
    cursor.execute(query, (ma_ho_so, ten_thuoc, so_luong))
        
    # except obdc.Error as e:
    #     sql_message = e.args[1]
    #     print(sql_message)
    #     if sql_message == '[HY000] [Microsoft][ODBC SQL Server Driver]Connection is busy with results for another hstmt':
    #         time.sleep(5)
    #         cursor.execute(query, (ma_ho_so, ten_thuoc, so_luong))
    res = cursor.fetchall()[0]
    print(res[0])
    if res[0]==1:
        cursor.commit()
        return jsonify({"status":'success',"message": 'Đã sửa số lượng thuốc trong đơn!'})
    else:
        print("that bai")
        cursor.rollback()
        return jsonify({"status": 'error', "message": 'Đã xảy ra lỗi, dữ liệu đã được rollback, vui lòng thử lại!'})


@app.route('/get_busy_scheduel', methods=['GET'])
def get_busy_scheduel():
    qeury = """
        SELECT CAST(NgayGioBatDau AS DATE), DATEPART(HOUR, NgayGioBatDau), CAST(NgayGioKetThuc AS DATE), DATEPART(HOUR, NgayGioKetThuc), MALB
        FROM LICHBAN 
        WHERE MaNhaSi = {};
    """.format(session.get('sdt'))

    cursor = conn.cursor()
    cursor.execute(qeury)
    res = cursor.fetchall()

    busy_schedule = []
    for row in res:
        start_date = row[0]
        start_hour = row[1]
        end_date = row[2]
        end_hour = row[3]
        ma_lich_ban = row[4]

    busy_schedule.append({
        "start_date": start_date,
        "start_hour": start_hour,
        "end_date": end_date,   
        "end_hour": end_hour,
        "ma_lich_ban": ma_lich_ban
    })
    
    return jsonify({"status":'success', "data":busy_schedule})

@app.route('/edit_scheduel', methods=['POST'])
def edit_scheduel():
    if request.method == 'POST':
        data = request.json  

        manhasi = session.get('sdt')
        code = data['code']
        ngaybatdau = data['ngaybatdau']
        ngayketthuc = data['ngayketthuc']
        giobatdau = data['giobatdau'][:3]+'00'
        gioketthuc = data['gioketthuc'][:3]+'00'
    
    query = """
        SET NOCOUNT ON;
        DECLARE @RESULT INT;
        EXEC @RESULT = sp_CapNhatLichBan ?, ?, ?, ?, ?, ?;
        SELECT @RESULT AS COL;
    """

    try:
        cursor = conn.cursor()
        cursor.execute(query, (manhasi, code, ngaybatdau, giobatdau, ngayketthuc, gioketthuc))
        res = cursor.fetchall()[0]
        print(res[0])
        if res[0]==1:
            cursor.commit()
            cursor.close()
            return jsonify({"status":'success',"message": 'Đã sửa lịch hẹn!'})
        else:
            print("that bai")
            cursor.close()
            return jsonify({"status": 'error', "message": 'Đã xảy ra lỗi, dữ liệu đã được rollback, vui lòng thử lại!'})
        
    except obdc.Error as e:
        sql_message = e.args[1]
        cursor.rollback()
        return jsonify({"status": 'error', "message": str(sql_message)})


@app.route('/add_scheduel', methods=['POST'])
def add_scheduel():
    if request.method == 'POST':
        data = request.json  

        manhasi = session.get('sdt')
        ngaybatdau = data['ngaybatdau']
        ngayketthuc = data['ngayketthuc']
        giobatdau = data['giobatdau'][:3]+'00'
        gioketthuc = data['gioketthuc'][:3]+'00'
    
    query = """
        SET NOCOUNT ON;
        DECLARE @RESULT INT;
        EXEC @RESULT = sp_ThemLichBan ?, ?, ?, ?, ?;
        SELECT @RESULT AS COL;
    """

    try:
        cursor = conn.cursor()
        cursor.execute(query, (manhasi, ngaybatdau, giobatdau, ngayketthuc, gioketthuc))
        res = cursor.fetchall()[0]
        print(res[0])
        if res[0]==1:
            cursor.commit()
            cursor.close()
            return jsonify({"status":'success',"message": 'Đã thêm lịch hẹn!'})
        else:
            print("that bai")
            cursor.close()
            return jsonify({"status": 'error', "message": 'Đã xảy ra lỗi, dữ liệu đã được rollback, vui lòng thử lại!'})
        
    except obdc.Error as e:
        sql_message = e.args[1]
        cursor.rollback()
        return jsonify({"status": 'error', "message": str(sql_message)})
    
@app.route('/add-medicine', methods=['POST'])
def add_medicine():
    tenthuoc = request.form.get('tenthuoc-add')
    dongiathuoc = request.form.get('dongiathuoc-add')
    chidinhthuoc = request.form.get('chidinhthuoc-add')
    soluongton = request.form.get('soluongton-add')
    ngayhethan = request.form.get('ngayhethan-add')

    query = """
        SET NOCOUNT ON;
        DECLARE @RESULT INT;
        EXEC @RESULT = sp_ThemThuoc ?, ?, ?, ?, ?;
        SELECT @RESULT AS COL;
    """

    try:
        cursor = conn.cursor()
        cursor.execute(query, (tenthuoc, dongiathuoc, chidinhthuoc, soluongton, ngayhethan))
        res = cursor.fetchall()[0]
        print(res[0])
        if res[0]==1:
            cursor.commit()
            cursor.close()
            return jsonify({"status":'success',"message": 'Đã thêm thuốc!'})
        else:
            print("that bai")
            cursor.close()
            return jsonify({"status": 'error', "message": 'Đã xảy ra lỗi, vui lòng thử lại!'})
        
    except obdc.Error as e:
        sql_message = e.args[1]
        cursor.rollback()
        return jsonify({"status": 'error', "message": str(sql_message)})
       
# Nhan vien
@app.route('/staff' , methods=['GET', 'POST'])
def dat_lich_hen():
  return render_template('./nhanvien/dat_lich_hen.html' )

@app.route('/xuat_hoa_don', methods=['GET', 'POST'])
def xuat_hoa_don():
    return render_template('./nhanvien/xuat_hoa_don.html')

@app.route('/query-database-xuat_hoa_don', methods=['GET'])
def query_database_xuathoadon():
    user_input = request.args.get('userInput')
    print (user_input)
    # Perform your database query here using the provided user_input

    # Replace the following line with the actual result from your database query
    cursor = conn.cursor ()
    cursor.execute("{CALL Lay_hoa_don_tu_SDT(?)}", (user_input,))
    rows = cursor.fetchall()
    print ("rows: " , rows)
    if len (rows) == 1 :
        return jsonify (0)
    else :
        result_from_database = [{"mahoadon": rows[i][0],
                                "manhasi": rows[i][2],
                                "tennhasi": rows[i][3],
                                "mathuoc": rows[i][4],
                                "tenthuoc": rows[i][5],
                                "soluongthuoc": rows[i][6],
                                "dongia": rows[i][7],
                                "madv": rows[i][8],
                                "tendv": rows[i][9],
                                "soluongdv": rows[i][10],
                                "dongiadichvu":rows[i][11],
                                "tongtien":rows[i][12]} for i in range (len (rows)) ]
                                
                                
        print (result_from_database)
        return jsonify({"hoadon" : result_from_database})
    
@app.route('/query-database-dat-lich-hen', methods=['GET'])
def query_database_datlichhen():
    user_input = request.args.get('userInput')
    print (user_input)
    # Perform your database query here using the provided user_input

    # Replace the following line with the actual result from your database query
    cursor = conn.cursor ()
    cursor.execute("{CALL Lay_thong_tin_tu_SDT(?)}", (user_input,))
    rows = cursor.fetchall()
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
    cursor.execute("{CALL Tim_bac_si_ranh(? , ?)}", (selected_time,selected_date))
    rows = cursor.fetchall()
    print ("rows: " , rows)
    # Perform your logic to query the database and get available doctors
    # Replace the following line with your database query
    
    if len (rows[0]) == 1 :
        return jsonify (0)  
    else :
        available_doctors = [row[1] for row in rows]
        print (available_doctors)
        return jsonify(available_doctors=available_doctors)
    
@app.route('/register_no_info', methods=['POST'])
def register():
    # Get form data from the request
    sdt = request.form.get('sdt')
    name = request.form.get('name')
    birth = request.form.get('birth')
    address = request.form.get('address')

    cursor = conn.cursor ()
    cursor.execute("{CALL Them_nguoi_dung(?, ? ,?, ?)}", (sdt , name, birth, address))
    

    # Return a response (you can customize this based on your needs)
    return "Registration successful!"

@app.route('/register_have_info', methods=['POST'])
def register_info():
    # Get form data from the request
    sdt = request.form.get('sdt')
    
    giokham = request.form.get('giokham')
    ngaykham = request.form.get('ngaykham')
    bacsi = request.form.get('bacsi')
    hoten = ""
    ngaysinh = ""
    diachi = ""
    cursor = conn.cursor ()
    cursor.execute("{CALL Dat_lich_kham(?, ? ,?, ? ,? ,? , ?)}", (sdt ,hoten, ngaysinh, diachi, ngaykham, giokham, bacsi))
    

    # Return a response (you can customize this based on your needs)
    return "Registration successful!"

@app.route('/query-database-thongtinthuoc', methods=['GET'])
def get_tt_thuoc():
    # Retrieve the selected time and date from the request
    ten_thuoc = request.args.get('userInput')
    cursor = conn.cursor ()
    cursor.execute("{CALL Tim_thuoc_bang_ten(? )}", (ten_thuoc,))
    rows = cursor.fetchall()
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