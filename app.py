from flask import Flask, render_template, redirect, url_for, request, jsonify,session, make_response
import pypyodbc as obdc

DRIVER_NAME = 'SQL SERVER'
SERVER_NAME = 'TRONG-NGHIA\MSSQLSERVER01'
DATABASE_NAME ='HQT_CSDL'

connection_string = f'DRIVER={DRIVER_NAME};SERVER={SERVER_NAME};DATABASE={DATABASE_NAME}'
conn = obdc.connect(connection_string)
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

    #run query
    cursor.execute("{CALL CheckAccountExists(?, ?)}", (sdt, password))
    rows = cursor.fetchall()
    cursor.close()
    print(rows[0][0])
    if rows[0][0]=='Admin':
        # print("after:" ,session)
        return jsonify({'redirect': '/admin'})
    elif rows[0][0] == 'BacSi':
        # print("after:" ,session)
        return jsonify({'redirect': '/dentist'})        
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
if __name__ == '__main__':
    app.run(debug=True)