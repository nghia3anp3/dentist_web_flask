const daysTag = document.querySelector(".days"),
currentDate = document.querySelector(".current-date"),
prevNextIcon = document.querySelectorAll(".icons span");

// getting new date, current year and month
let date = new Date(),
currYear = date.getFullYear(),
currMonth = date.getMonth();

let has_meeting;

let edit_code;


// storing full name of all months in array
const months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];

async function fetchSchedual(Day, currMonth, currYear) {
    try {
        const response = await fetch(`/get_schedual?day=${Day}&month=${currMonth}&year=${currYear}`);
        const data = await response.json();
        const data_parse = data.data.day //list cua list 

        const showSchedualDiv = document.getElementById('show-schedual');

        showSchedualDiv.innerHTML = '';

        data_parse.forEach(item => {
            const time = item[0];
            const sdt = item[1];

            // Tạo div mới
            const div = document.createElement('div');
            div.classList.add('box'); // Thêm class 'box' cho div

            // Tạo HTML cho phần nội dung của div
            div.innerHTML = `
                <article class="media">
                    <div class="media-left">
                        <figure class="image is-64x64">
                            <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/c/cd/Circle-icons-calendar.svg/800px-Circle-icons-calendar.svg.png" alt="Image">
                        </figure>
                    </div>
                    <div class="media-content">
                        <div class="content">
                            <p>
                                Lịch hẹn
                                <br>
                                <strong>Số điện thoại khách hàng:</strong> ${sdt}
                                <br>
                                <strong>Giờ hẹn:</strong> ${time}h
                            </p>
                        </div>
                    </div>
                </article>
         `;

    // Thêm div vào div show-schedual
    showSchedualDiv.appendChild(div);
});


    } catch (error) {
        console.error('Error:', error);
    }
}

const renderCalendar = () => {
    const dayIds = [];
    let firstDayofMonth = new Date(currYear, currMonth, 1).getDay(), // getting first day of month
    lastDateofMonth = new Date(currYear, currMonth + 1, 0).getDate(), // getting last date of month
    lastDayofMonth = new Date(currYear, currMonth, lastDateofMonth).getDay(), // getting last day of month
    lastDateofLastMonth = new Date(currYear, currMonth, 0).getDate(); // getting last date of previous month
    let liTag = "";

    for (let i = firstDayofMonth; i > 0; i--) { // creating li of previous month last days
        liTag += `<li class="inactive">${lastDateofLastMonth - i + 1}</li>`;
    }

    for (let i = lastDayofMonth; i < 6; i++) { // creating li of next month first days
        liTag += `<li class="inactive">${i - lastDayofMonth + 1}</li>`
    }

    for (let i = 1; i <= lastDateofMonth; i++) { // creating li of all days of current month
        // Thêm ID cho từng ngày
        const dayId = `day_${i}`;
        dayIds.push(dayId);

        // Kiểm tra xem ngày có trong danh sách has_meeting không
        const isMeeting = has_meeting && has_meeting.includes(i) ? "busy-active" : "";
        // Thêm class active và class date_meeting nếu có cuộc họp vào ngày đó
        let isToday = i === date.getDate() && currMonth === new Date().getMonth() 
                    && currYear === new Date().getFullYear() ? "active" : "";
        // Thêm các ngày vào liTag với ID và class tương ứng
        liTag += `<li id="${dayId}" class="${isToday} ${isMeeting}">${i}</li>`;
    }
    currentDate.innerText = `${months[currMonth]} ${currYear}`; // passing current mon and yr as currentDate text
    daysTag.innerHTML = liTag;
    
    const allLiTags = document.querySelectorAll('.days li');

    allLiTags.forEach(li => {
        if (li.classList.contains('busy-active')) {
            li.addEventListener('click', function(event) {
                // var element = document.getElementById('show-schedual');
                // if (element.style.display !== 'block'){
                //     element.style.display = 'block';
                // } else {
                //     element.style.display = 'none';
                // }

                // var medicineForm = document.getElementById('create-form');
                // if (medicineForm.style.display !== 'block'){
                //     medicineForm.style.display = 'none';
                // } else {
                //     medicineForm.style.display = 'none';
                // }

                const textContent = event.target.textContent;
                const schedual_div = document.getElementById('show-schedual')
                const holder = document.getElementById('create-form')
                const holder_2 = document.getElementById('fix-form')

                if (holder.style.display !== 'none'){
                    holder.style.display = 'none'
                }

                if (holder_2.style.display !== 'none'){
                    holder_2.style.display = 'none'
                }
                if (schedual_div.style.display === 'none'){
                    schedual_div.style.display = 'block'
                }

                fetchSchedual(textContent, currMonth+1, currYear);
            
            });
        }
    });
};

async function fetchData(currMonth, currYear) {
    try {
        const response = await fetch(`/get_date?month=${currMonth}&year=${currYear}`);
        const data = await response.json();
        has_meeting = data.data;
        renderCalendar();

    } catch (error) {
        console.error('Error:', error);
    }
}

fetchData(currMonth+1, currYear);

document.getElementById('busy-scheduel').addEventListener('click', () =>{
    var element = document.getElementById('busy-scheduel-div');

    if (element.style.display === "none"){
        element.style.display = "block"

    fetch('/get_busy_scheduel', {
        method: 'GET',
        headers: {
          'Content-Type': 'application/json'
        },
      })
      .then(response => {
        if (!response.ok) {
          throw new Error('Network response was not ok');
        }
        return response.json();
      })
      .then(data => {
        var data_receive = data.data
        data_receive.forEach(item => {
            const s_date = item.start_date;
            const s_hour = item.start_hour;
            const e_date = item.end_date;
            const e_hour = item.end_hour;
            const code = item.ma_lich_ban;
            console.log(s_date)

            var element = document.getElementById('busy-scheduel-div')
            element.innerHTML = ""
            // Tạo div mới
            var element_div = document.createElement('div');
            element_div.classList.add('box'); // Thêm class 'box' cho div
            
            // Tạo HTML cho phần nội dung của div
            element_div.innerHTML = `
                <article class="media">
                    <div class="media-left">
                        <figure class="image is-64x64">
                            <img src="https://static.vecteezy.com/system/resources/previews/019/152/947/original/busy-employees-with-busy-scheludes-finish-work-targets-on-time-man-busy-work-schedule-free-png.png" alt="Image">
                        </figure>
                    </div>
                    <div class="media-content">
                        <div class="content">
                            <p>
                                <strong>Lịch bận:</strong> ${code}
                                <br>
                                <strong>Ngày bắt đầu:</strong> ${s_date}
                                ,
                                <strong>Ngày kết thúc:</strong> ${e_date}
                                <br>
                                <strong>Giờ bắt đầu:</strong> ${s_hour} giờ
                                ,
                                <strong>Giờ kết thúc:</strong> ${e_hour} giờ
                            </p>
                        </div>
                    </div>
                </article>
            `;
            element.addEventListener('click', ()=>{
                edit_code = code
                const dialog = document.getElementById('modal');
                dialog.showModal();
            })
            element.appendChild(element_div)
            console.log(element_div)
        });
        
      })
      .catch(error => {
        console.error('There was a problem with the fetch operation:', error);
      });
    }
    else {
        element.style.display = "none"
    }
});

document.getElementById('add-busy-scheduel').addEventListener('click', ()=>{
    const dialog = document.getElementById('modal-add');
    dialog.showModal();
})

prevNextIcon.forEach(icon => { // getting prev and next icons
    icon.addEventListener("click", () => { // adding click event on both icons
        // if clicked icon is previous icon then decrement current month by 1 else increment it by 1
        currMonth = icon.id === "prev" ? currMonth - 1 : currMonth + 1;

        if(currMonth < 0 || currMonth > 11) { // if current month is less than 0 or greater than 11
            // creating a new date of current year & month and pass it as date value
            date = new Date(currYear, currMonth, new Date().getDate());
            currYear = date.getFullYear(); // updating current year with new date year
            currMonth = date.getMonth(); // updating current month with new date month
            fetchData(currMonth+1,currYear);
        } else {
            date = new Date(); // pass the current date as date value
            fetchData(currMonth+1,currYear);
        }
    });
});


document.querySelector('.show-create').addEventListener('click', () =>{
    var medicineForm = document.getElementById('create-form');
    if (medicineForm.style.display !== 'block'){
        medicineForm.style.display = 'block';
    }

    else {medicineForm.style.display = 'none';}

    var element = document.getElementById('show-schedual');
    if (element.style.display !== 'none'){
        element.style.display = 'none';
    }

    var fixForm = document.getElementById('fix-form');
    if (fixForm.style.display !== 'none'){
        fixForm.style.display = 'none';
    }
});

document.querySelector('.show-fix').addEventListener('click', () =>{
    var fixForm = document.getElementById('fix-form');
    if (fixForm.style.display !== 'block'){
        fixForm.style.display = 'block';
    }
    else {fixForm.style.display = 'none';}

    var element = document.getElementById('show-schedual');
    if (element.style.display !== 'none'){
        element.style.display = 'none';
    }

    var element_2 = document.getElementById('create-form');
    if (element_2.style.display !== 'none'){
        element_2.style.display = 'none';
    }
});

document.querySelector('.add-pills').addEventListener('click', () =>{
    var elements = document.querySelectorAll('.holder-information');
    elements.forEach(function(element) {
    if (element.querySelector('#medicine-list')){
        if (element.style.display === "none"){
            element.style.display = "block"
        }
        else {element.style.display = "none"};
        }
    });
});

document.querySelector('.add-services').addEventListener('click', () =>{
    var elements = document.querySelectorAll('.holder-information');
    elements.forEach(function(element) {
    if (element.querySelector('#service-list')){
        if (element.style.display === "none"){
            element.style.display = "block"
        }
        else {element.style.display = "none"};
        }
    });
});





document.getElementById('add-row-services').addEventListener('click', function() {
    // Tạo một phần tử div mới
    var newField = document.createElement('div');
    newField.classList.add('columns', 'field');

    // Tạo các phần tử con và thiết lập thuộc tính cho chúng
    var column1 = document.createElement('div');
    column1.classList.add('column');
    column1.style.display = 'flex';
    column1.style.alignItems = 'center';
    column1.innerHTML = `
        <h1 class="function-font">Dịch vụ sử dụng: </h1>
    `;

    var column2 = document.createElement('div');
    column2.classList.add('column');
    column2.style.display = 'flex';
    column2.style.alignItems = 'center';
    column2.style.justifyContent = 'flex-end';
    column2.innerHTML = `
        <div class="select is-primary">
            <select name="dichvu">
            <option>Cạo vôi răng</option>
            <option>Nhổ răng</option>
            <option>Tẩy trắng răng</option>
            <option>Trồng răng</option>
            <option>Niềng răng</option>
            </select>
        </div>
    `;

    var column3 = document.createElement('div');
    column3.classList.add('column', 'is-5');
    column3.style.display = 'flex';
    column3.style.alignItems = 'center';
    column3.style.justifyContent = 'flex-end';
    column3.innerHTML = `
        <button class="custom-button button is-active delete-btn-s">
            <i class="fa-solid fa-trash function-icon" style="font-size: 20px; position: absolute; right: 30px"></i>
        </button> 
    `;

    // Thêm các cột vào div chính
    newField.appendChild(column1);
    newField.appendChild(column2);
    newField.appendChild(column3);

    document.getElementById('service-form').appendChild(newField);

    var deleteBtns = document.querySelectorAll('.delete-btn-s');
        deleteBtns.forEach(function(btn) {
            btn.addEventListener('click', function() {
                var fieldToDelete = btn.closest('.field');
                if (fieldToDelete) {
                    fieldToDelete.remove();
                }
            });
        });
});

document.getElementById('add').addEventListener('click', function() {
    // Tạo một phần tử div mới
    var newField = document.createElement('div');
    newField.classList.add('columns', 'field');

    // Tạo các phần tử con và thiết lập thuộc tính cho chúng
    var column1 = document.createElement('div');
    column1.classList.add('column', 'is-7');
    column1.style.display = 'flex';
    column1.style.alignItems = 'center';
    column1.innerHTML = `
        <h1> Mã thuốc:</h1>
        <input class="input" style="width: 30%;" type="text" placeholder="Mã thuốc" name="tenthuoc[]">
    `;

    var column2 = document.createElement('div');
    column2.classList.add('column');
    column2.style.display = 'flex';
    column2.style.alignItems = 'center';
    column2.innerHTML = `
        <h1> Số lượng:</h1>
        <input class="input" style="width: 40%;" type="text" placeholder="1" name="soluongthuoc[]">
    `;

    var column3 = document.createElement('div');
    column3.classList.add('column', 'is-2');
    column3.style.display = 'flex';
    column3.style.alignItems = 'center';
    column3.innerHTML = `
        <button class="custom-button button is-active delete-btn">
            <i class="fa-solid fa-trash function-icon" style="font-size: 20px; margin-left: 25px;"></i>
        </button> 
    `;

    // Thêm các cột vào div chính
    newField.appendChild(column1);
    newField.appendChild(column2);
    newField.appendChild(column3);

    var medicineForm = document.getElementById('medicine-form');
    if (medicineForm) {
        medicineForm.appendChild(newField);
        // Gọi hàm attachAutocomplete để áp dụng autocomplete cho input mới tạo
        var newInputs = newField.getElementsByTagName('input');
        if (newInputs && newInputs.length > 0) {
            var maThuocInput = newInputs[0];
            maThuocInput.addEventListener('input', function() {
                attachAutocomplete(maThuocInput);
            });
        }
    }

    var deleteBtns = document.querySelectorAll('.delete-btn');
        deleteBtns.forEach(function(btn) {
            btn.addEventListener('click', function() {
                var fieldToDelete = btn.closest('.field');
                if (fieldToDelete) {
                    fieldToDelete.remove();
                }
            });
        });
});
function attachAutocomplete(element) {
    $(element).autocomplete({
        source: function(request, response) {
            var dataToSend = {
                namesearch: request.term
            };

            $.ajax({
                url: '/get_medicine_by_name',
                method: 'POST',
                contentType: 'application/json',
                data: JSON.stringify(dataToSend),
                success: function(data) {
                    var tenthuocList = data.tenthuoc;
                    var trimmedTenthuocList = tenthuocList.map(function(item) {
                        return item.trim();
                    });
                    response(trimmedTenthuocList);
                },
                error: function(error) {
                    console.error('Đã có lỗi xảy ra: ', error);
                }
            });
        },
        minLength: 2
    });
}


document.getElementById('scheduel-edit-button').addEventListener('click', function(event) {
    event.preventDefault(); 

    const ngayBatDau = document.querySelector('input[name="ngaybatdau"]').value;
    const ngayKetThuc = document.querySelector('input[name="ngayketthuc"]').value;
    const gioBatDau = document.querySelector('input[name="giobatdau"]').value;
    const gioKetThuc = document.querySelector('input[name="gioketthuc"]').value;

    // console.log(edit_code)
    const data = {
        code: edit_code,
        ngaybatdau: ngayBatDau,
        ngayketthuc: ngayKetThuc,
        giobatdau: gioBatDau,
        gioketthuc: gioKetThuc
    };
    fetch('/edit_scheduel', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data) // Chuyển đổi object thành chuỗi JSON để gửi đi
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(result => {
        alert(result.message)
    })
    .catch(error => {
        console.error('There was a problem with the fetch operation:', error);
    });
});


document.getElementById('scheduel-add-button').addEventListener('click', function(event) {
    event.preventDefault(); 

    const ngayBatDau = document.querySelector('input[name="ngaybatdau-add"]').value;
    const ngayKetThuc = document.querySelector('input[name="ngayketthuc-add"]').value;
    const gioBatDau = document.querySelector('input[name="giobatdau-add"]').value;
    const gioKetThuc = document.querySelector('input[name="gioketthuc-add"]').value;

    // console.log(edit_code)
    const data = {
        ngaybatdau: ngayBatDau,
        ngayketthuc: ngayKetThuc,
        giobatdau: gioBatDau,
        gioketthuc: gioKetThuc
    };
    fetch('/add_scheduel', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data) // Chuyển đổi object thành chuỗi JSON để gửi đi
    })
    .then(response => {
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(result => {
        alert(result.message)
    })
    .catch(error => {
        console.error('There was a problem with the fetch operation:', error);
    });
});
