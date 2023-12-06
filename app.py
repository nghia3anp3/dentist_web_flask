from flask import Flask, render_template, redirect, url_for, request, jsonify,session, make_response
import pypyodbc as obdc
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
# app.secret_key = 'nghia1804'

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
    cursor.execute("{CALL CheckAccountExists(?, ?)}", (sdt, password))
    rows = cursor.fetchall()
    print(rows[0][0])
    cursor.close()
   
    if rows[0][0]=='Admin':
        # print("after:" ,session)
        return jsonify({'redirect': '/admin'})
    elif rows[0][0] == 'BacSi':
        # print("after:" ,session)
        return jsonify({'redirect': '/dentist'})       
    elif rows[0][0] == 'NhanVien':
        # print("after:" ,session)
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