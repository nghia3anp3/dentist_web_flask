from flask import Flask, render_template, redirect, url_for, request, jsonify,session
app = Flask(__name__)

valid_username = "0175"
valid_password = "admin"
logging = False
@app.route('/')
def home():
    return render_template("home.html")

@app.route('/login', methods=['POST'])
def login():
    username = request.form['username']
    password = request.form['password']

    if username == valid_username and password == valid_password:
        return url_for('admin')

    return jsonify({'message': 'Tên người dùng hoặc mật khẩu không đúng'})
    
@app.route('/admin')
def admin():
    return render_template("admin.html")