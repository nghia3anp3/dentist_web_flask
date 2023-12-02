const daysTag = document.querySelector(".days"),
currentDate = document.querySelector(".current-date"),
prevNextIcon = document.querySelectorAll(".icons span");

// getting new date, current year and month
let date = new Date(),
currYear = date.getFullYear(),
currMonth = date.getMonth();

// storing full name of all months in array
const months = ["January", "February", "March", "April", "May", "June", "July",
              "August", "September", "October", "November", "December"];

const renderCalendar = () => {
    let firstDayofMonth = new Date(currYear, currMonth, 1).getDay(), // getting first day of month
    lastDateofMonth = new Date(currYear, currMonth + 1, 0).getDate(), // getting last date of month
    lastDayofMonth = new Date(currYear, currMonth, lastDateofMonth).getDay(), // getting last day of month
    lastDateofLastMonth = new Date(currYear, currMonth, 0).getDate(); // getting last date of previous month
    let liTag = "";

    for (let i = firstDayofMonth; i > 0; i--) { // creating li of previous month last days
        liTag += `<li class="inactive">${lastDateofLastMonth - i + 1}</li>`;
    }

    for (let i = 1; i <= lastDateofMonth; i++) { // creating li of all days of current month
        // adding active class to li if the current day, month, and year matched
        let isToday = i === date.getDate() && currMonth === new Date().getMonth() 
                     && currYear === new Date().getFullYear() ? "active" : "";
        liTag += `<li class="${isToday}">${i}</li>`;
    }

    for (let i = lastDayofMonth; i < 6; i++) { // creating li of next month first days
        liTag += `<li class="inactive">${i - lastDayofMonth + 1}</li>`
    }
    currentDate.innerText = `${months[currMonth]} ${currYear}`; // passing current mon and yr as currentDate text
    daysTag.innerHTML = liTag;

    const allLiTags = document.querySelectorAll('.days li');

    allLiTags.forEach(li => {
        li.addEventListener('click', function() {
            var element = document.getElementById('show-schedual');
            if (element.style.display !== 'block'){
                element.style.display = 'block';
            }
            else {element.style.display = 'none';}
        });
    });
};
renderCalendar();

prevNextIcon.forEach(icon => { // getting prev and next icons
    icon.addEventListener("click", () => { // adding click event on both icons
        // if clicked icon is previous icon then decrement current month by 1 else increment it by 1
        currMonth = icon.id === "prev" ? currMonth - 1 : currMonth + 1;

        if(currMonth < 0 || currMonth > 11) { // if current month is less than 0 or greater than 11
            // creating a new date of current year & month and pass it as date value
            date = new Date(currYear, currMonth, new Date().getDate());
            currYear = date.getFullYear(); // updating current year with new date year
            currMonth = date.getMonth(); // updating current month with new date month
        } else {
            date = new Date(); // pass the current date as date value
        }
        renderCalendar(); // calling renderCalendar function
    });
});


document.querySelector('.show-create').addEventListener('click', () =>{
    var medicineForm = document.getElementById('create-form');
    if (medicineForm.style.display !== 'block'){
        medicineForm.style.display = 'block';
    }
    else {medicineForm.style.display = 'none';}
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
        <input class="input" style="width: 30%;" type="text" placeholder="Mã thuốc">
    `;

    var column2 = document.createElement('div');
    column2.classList.add('column');
    column2.style.display = 'flex';
    column2.style.alignItems = 'center';
    column2.innerHTML = `
        <h1> Số lượng:</h1>
        <input class="input" style="width: 40%;" type="text" placeholder="1">
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

    document.getElementById('medicine-list').appendChild(newField);

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