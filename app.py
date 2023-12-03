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
    
    
    
    
    
    
    
# @app.route('/check_meeting', methods=['POST'])
# def check_meeting():
#     if request.method == 'POST':
#         data = request.get_json()
#         day = data.get('day')

#         cursor = conn.cursor()
#         query = "SELECT ThoiGianHen, SDT FROM LICHHEN WHERE CONVERT(DATE, ThoiGianHen) = ?"
#         cursor.execute(query, (day,))

#         meetings_on_day = []
#         for row in cursor.fetchall():
#             meeting = {
#                 'ThoiGianHen': row.ThoiGianHen.strftime('%Y-%m-%d %H:%M:%S'),  # Adjust the format as needed
#                 'SDT': row.SDT
#             }
#             meetings_on_day.append(meeting)
        
#         cursor.close()
#         return jsonify(meetings_on_day)


@app.route('/staff')
def dat_lich_hen():
  return render_template('./nhanvien/dat_lich_hen.html')
@app.route('/xuat_hoa_don')
def xuat_hoa_don():
  return render_template('./nhanvien/xuat_hoa_don.html')

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