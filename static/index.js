const showCreate = document.querySelector('.show-create');
const showLock = document.querySelector('.show-lock');
const showMedicineForm = document.querySelector('.show-medicine')
const functional = document.querySelectorAll('.functional');
const createButton = document.getElementById('create-button');
const lockButton = document.getElementById('lock-button');
const medicineButton = document.getElementById('medicine-button');

function hideAll() {
    for (const div of functional) {
        div.style.display = 'none';
    }
}

function edit(element) {
    // Lấy dòng chứa nút đã được click
    const row = element.closest('tr');

    // Lấy các ô dữ liệu từ dòng đã chọn
    const cells = row.querySelectorAll('td');

    // Lấy các giá trị từ các ô dữ liệu
    const mathuoc = cells[0].innerText;
    const tenthuoc = cells[1].innerText;
    const dongia = cells[2].innerText;
    const chidinh = cells[3].innerText;
    const soluongton = cells[4].innerText;
    const ngayhethan = cells[5].innerText;

    // Điền các giá trị từ dòng vào dialog
    document.querySelector('#modal input[type="mathuoc"]').value = mathuoc;
    document.querySelector('#modal input[type="mathuoc"]').readOnly = true;
    document.querySelector('#modal input[type="mathuoc"]').classList.add('field-not-edit');
    document.querySelector('#modal input[type="tenthuoc"]').value = tenthuoc;
    document.querySelector('#modal input[type="dongiathuoc"]').value = dongia;
    document.querySelector('#modal input[type="chidinhthuoc"]').value = chidinh;
    document.querySelector('#modal input[type="soluongton"]').value = soluongton;
    document.querySelector('#modal input[type="ngayhethan"]').value = ngayhethan;

    // Hiển thị dialog
    const dialog = document.getElementById('modal');
    dialog.showModal();
}


function deleteRows() {
    var table = document.getElementById("drugTable");
    var rowCount = table.rows.length;

    // Bắt đầu từ 1 để không xóa hàng đầu tiên (header)
    for (var i = rowCount - 1; i > 0; i--) {
        table.deleteRow(i);
    }
}


function createMedicineRow(code, name, price, indication, quantity, expiryDate) {
    // Tạo một hàng tr (table row) mới
    const newRow = document.createElement('tr');

    // Tạo các ô (table data) chứa giá trị từ các trường đầu vào
    const codeCell = document.createElement('td');
    codeCell.textContent = code;
    newRow.appendChild(codeCell);

    const nameCell = document.createElement('td');
    nameCell.textContent = name;
    newRow.appendChild(nameCell);

    const priceCell = document.createElement('td');
    priceCell.textContent = price;
    newRow.appendChild(priceCell);

    const indicationCell = document.createElement('td');
    indicationCell.textContent = indication;
    newRow.appendChild(indicationCell);

    const quantityCell = document.createElement('td');
    quantityCell.textContent = quantity;
    newRow.appendChild(quantityCell);

    const expiryDateCell = document.createElement('td');
    expiryDateCell.textContent = expiryDate;
    newRow.appendChild(expiryDateCell);

    // Trả về hàng tr mới đã được tạo
    return newRow;
}


showCreate.addEventListener('click', () => {
    if (showLock.classList.contains('button-active')) {
        showLock.classList.toggle('button-active');
    }  
    if (showMedicineForm.classList.contains('button-active')) {
        showMedicineForm.classList.toggle('button-active');
    }    
    createForm = document.getElementById('create-form');
    if (createForm.style.display !== 'flex'){
        hideAll();
        showCreate.classList.toggle('button-active')
        createForm.style.display = 'flex';
        createButton.style.display = 'block';
    }
    else {    
        hideAll();
        createButton.style.display = 'none';
        showCreate.classList.toggle('button-active')
    }
});

showLock.addEventListener('click', () => {
    if (showCreate.classList.contains('button-active')) {
        showCreate.classList.toggle('button-active'); 
    }
    if (showMedicineForm.classList.contains('button-active')) {
        showMedicineForm.classList.toggle('button-active'); 
    }
    lockForm = document.getElementById('lock-form');
    if (lockForm.style.display !== 'flex') {
        hideAll();
        showLock.classList.toggle('button-active')
        lockForm.style.display = 'flex';
        lockButton.style.display = 'block';
        const phoneInput = document.querySelector('input[name="phone_lock"]');
        phoneInput.addEventListener('blur', function() {
            const phone = this.value;
            fetch('/search', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ phone: phone }),
            })
            .then(response => response.json())
            .then(data => {
                if (data.message){
                    alert("Không có tài khoản này!");
                }
                    const infoDiv = document.getElementById('update_lock_table'); // Thay 'your_info_div' bằng ID của div bạn muốn đặt dữ liệu vào
                    const infoHTML = `
                    <p>Tên: ${data.full_name}</p>
                    <p>Ngày sinh: ${data.date}</p>
                    <p>Số điện thoại: ${data.address}</p>
                `;
                infoDiv.innerHTML = infoHTML;
            })
            .catch(error => {
                console.error('Error:', error);
            });
        });
        }
    else {    
        hideAll();
        lockButton.style.display = 'none';
        showLock.classList.toggle('button-active')
    }
});  

showMedicineForm.addEventListener('click', () => {
    
    if (showCreate.classList.contains('button-active')) {
        showCreate.classList.toggle('button-active'); 
    }
    if (showLock.classList.contains('button-active')) {
        showLock.classList.toggle('button-active'); 
    }
    medicineForm = document.getElementById('medicine-form');
    if (medicineForm.style.display !== 'block') {
        hideAll();
        showMedicineForm.classList.toggle('button-active')
        medicineForm.style.display = 'block';
        // medicineButton.style.display = 'block';
    }
    else {    
        hideAll();
        // medicineButton.style.display = 'none';
        showMedicineForm.classList.toggle('button-active')
    }

    document.getElementById("show_medicine").addEventListener("click", function() {
        var table = document.getElementById("drugTable");
        var rowCount = table.rows.length;

        if (rowCount>1) {
            deleteRows()
        }
        fetch('/get_entirely_medicine', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.message){
                alert(data.message);
            }
            const infoDiv = document.getElementById('drugTableBody');
            const mathuocArray = data.mathuoc;
            const tenthuocArray = data.tenthuoc;
            const dongiaArray = data.dongia;
            const chidinhArray = data.chidinh;
            const soluongtonArray = data.soluongton;
            const ngayhethanArray = data.ngayhethan;

            for (let i = 0; i < mathuocArray.length; i++) {
                const infoHTML = `
                    <tr onclick="edit(this)" class="row" data-index="${i}">
                        <td>${mathuocArray[i]}</td>
                        <td>${tenthuocArray[i]}</td>
                        <td>${dongiaArray[i]}</td>
                        <td>${chidinhArray[i]}</td>
                        <td>${soluongtonArray[i]}</td>
                        <td>${ngayhethanArray[i]}</td>
                    </tr>
                `;
                infoDiv.innerHTML += infoHTML;
            }

        })
    var searchDiv = document.getElementById("searchDiv");
    var addMedicineform = document.getElementById("add-table");

    if (addMedicineform.style.display !== "none") {
        addMedicineform.style.display = "none"
    }
    if (searchDiv.style.display !== "none") {
        searchDiv.style.display = "none";
    } 

    var medicineTable = document.getElementById("medicine-table");
    medicineTable.style.display = "block"

});

    document.getElementById('searchBar').addEventListener('input', function(){
        var searchString = this.value;
    
        var table = document.getElementById("drugTable");
        var rowCount = table.rows.length;
    
        if (rowCount>1) {
            deleteRows()
        }
        fetch('/get_medicine_by_name', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ namesearch: searchString }),
        })
        .then(response => response.json())
        .then(data => {
            if (data.message){
                alert(data.message);
            }
            const infoDiv = document.getElementById('drugTableBody');
            const mathuocArray = data.mathuoc;
            const tenthuocArray = data.tenthuoc;
            const dongiaArray = data.dongia;
            const chidinhArray = data.chidinh;
            const soluongtonArray = data.soluongton;
            const ngayhethanArray = data.ngayhethan;
            for (let i = 0; i < mathuocArray.length; i++) {
                const infoHTML = `
                <tr onclick="edit(this)" class="row" data-index="${i}">
                        <td>${mathuocArray[i]}</td>
                        <td>${tenthuocArray[i]}</td>
                        <td>${dongiaArray[i]}</td>
                        <td>${chidinhArray[i]}</td>
                        <td>${soluongtonArray[i]}</td>
                        <td>${ngayhethanArray[i]}</td>
                    </tr>
                `;
                infoDiv.innerHTML += infoHTML; // Thêm HTML vào infoDiv
            }
        })
    })
}); 


document.getElementById("search").addEventListener("click", function() {
    var searchDiv = document.getElementById("searchDiv");
    var medicineTable = document.getElementById("medicine-table");
    var addMedicineform = document.getElementById("add-table");

    if (medicineTable.style.display !== "block") {
        medicineTable.style.display = "block"
    }

    if (addMedicineform.style.display !== "none") {
        addMedicineform.style.display = "none"
    }

    if (searchDiv.style.display === "none") {
        searchDiv.style.display = "flex";
    } else {
        searchDiv.style.display = "none";
    }
});

document.getElementById("add").addEventListener("click", function() {
    var searchDiv = document.getElementById("searchDiv");
    var medicineTable = document.getElementById("medicine-table");
    var addMedicineform = document.getElementById("add-table");

    if (medicineTable.style.display !== "none") {
        medicineTable.style.display = "none"
    }
    addMedicineform.style.display = "flex"

    if (searchDiv.style.display === "flex") {
        searchDiv.style.display = "none";
    }

    if (searchDiv.style.display === "flex") {
        searchDiv.style.display = "none";
    }
});

document.getElementById('medicine-edit-button').addEventListener('click',function(event) {
        event.preventDefault();
        var form = document.getElementById('edit_medicine_form');
        fetch('/edit_medicine', {
            method: 'POST',
            body: new FormData(form),
        })
        .then(response => { 
            if (!response.ok) {
                throw new Error('Network response was not ok');
            }
            return response.json();
        })
        .then(data => {
            // Kiểm tra 'status' trong JSON response từ server
            if (data.status === 'success') {
                alert(data.message); // Hiển thị thông báo thành công
            } else {
                throw new Error(data.message); // Ném lỗi nếu có lỗi từ server
            }
        })
        .catch(error => {
            console.error('Error:', error);
        });
})


document.getElementById('medicine-delete-button').addEventListener('click',function(event) {
    event.preventDefault();
    var form = document.getElementById('edit_medicine_form');
    fetch('/delete_medicine', {
        method: 'POST',
        body: new FormData(form),
    })
    .then(response => { 
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        return response.json();
    })
    .then(data => {
        // Kiểm tra 'status' trong JSON response từ server
        if (data.status === 'success') {
            alert(data.message); // Hiển thị thông báo thành công
        } else {
            throw new Error(data.message); // Ném lỗi nếu có lỗi từ server
        }
    })
    .catch(error => {
        console.error('Error:', error);
    });
})

document.getElementById('add-medicine-button').addEventListener('click', function (event) {
    event.preventDefault();  // Prevent the default form submission

    // Get form data
    form = document.getElementById('add-form')
    var formData = new FormData(form);

    // Send POST request to Flask server
    fetch('/add-medicine', {
        method: 'POST',
        body: formData
    })
    .then(response => response.json())  // Assuming the server responds with JSON
    .then(data => {
        alert(data.message)
    })
    .catch((error) => {
        console.error('Error:', error);
    });
});