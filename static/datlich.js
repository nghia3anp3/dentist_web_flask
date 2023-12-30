const phoneInput = document.querySelector('input[name="phone"]');

phoneInput.addEventListener('blur', function() {
    const phone = this.value;
    fetch('/search', {
      method: 'POST', // Hoặc 'GET' tùy theo cấu hình của Flask
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ phone: phone }), // Gửi dữ liệu đến Flask
    })
    .then(response => response.json())
    .then(data => {
      // Xử lý kết quả từ Flask và hiển thị ở phần kết quả
        const fullNameInput = document.querySelector('input[name="full_name"]');
        const dateInput = document.querySelector('input[name="date"]');
        const addressInput = document.querySelector('input[name="address"]');

        // Gán giá trị từ dữ liệu nhận được vào các input tương ứng
        if (fullNameInput) {
        fullNameInput.value = data.full_name;
        }

        if (dateInput) {
        dateInput.value = data.date;
        }

        if (addressInput) {
        addressInput.value = data.address;
        }
    })
    .catch(error => {
      console.error('Error:', error);
    });
  });


  document.addEventListener('DOMContentLoaded', function() {
    const timeInput = document.querySelector('input[name="time"]');
    const dateInput = document.querySelector('input[name="date_doctor"]');

    let isTimeFilled = false;
    let isDateFilled = false;

    function queryDatabase() {
        const timeValue = timeInput.value;
        const dateValue = dateInput.value;

        // Kiểm tra nếu cả hai trường đã được điền xong thì mới truy vấn database
        if (isTimeFilled && isDateFilled) {
            fetch('/query_time_date', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    time: timeValue,
                    date: dateValue
                })
            })
            .then(response => response.json())
            .then(data => {
                if (data.message) {
                    alert(data.message);
                } else {
                    const infoDiv = document.getElementById('doctor_fields');
                    const selectElement = document.createElement('select'); // Tạo phần tử select
                
                    // Lặp qua mảng data.fullname để thêm các tùy chọn vào select
                    data.full_name.forEach(fullname => {
                        const option = document.createElement('option'); // Tạo phần tử option
                        option.value = fullname; // Gán giá trị cho option từ tên bác sĩ trong fullname
                        option.textContent = fullname; // Đặt nội dung hiển thị của option là tên bác sĩ
                        selectElement.appendChild(option); // Thêm option vào select
                    });
                
                    const infoHTML = `
                        Chọn bác sĩ:
                        <div class="select is-info" style="margin:20px">
                            ${selectElement.outerHTML} <!-- Thêm select vào trong HTML -->
                        </div>
                    `;
                
                    // Thêm HTML vào trong infoDiv
                    infoDiv.innerHTML = infoHTML;
                }                
            })
            .catch(error => {
                console.error('Lỗi:', error);
            });
        }
    }

    timeInput.addEventListener('input', function() {
        if (timeInput.value) {
            isTimeFilled = true;
            queryDatabase();
        } else {
            isTimeFilled = false;
        }
    });

    dateInput.addEventListener('input', function() {
        if (dateInput.value) {
            isDateFilled = true;
            queryDatabase();
        } else {
            isDateFilled = false;
        }
    });
});
