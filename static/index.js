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

showCreate.addEventListener('click', () => {
    if (showLock.classList.contains('button-active')) {
        showLock.classList.toggle('button-active');
    }  
    if (showMedicineForm.classList.contains('button-active')) {
        showMedicineForm.classList.toggle('button-active');
    }    
    createForm = document.getElementById('create-form');
    if (createForm.style.display !== 'block'){
        hideAll();
        showCreate.classList.toggle('button-active')
        createForm.style.display = 'block';
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
    if (lockForm.style.display !== 'block') {
        hideAll();
        showLock.classList.toggle('button-active')
        lockForm.style.display = 'block';
        lockButton.style.display = 'block';
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
        medicineButton.style.display = 'block';
    }
    else {    
        hideAll();
        medicineButton.style.display = 'none';
        showMedicineForm.classList.toggle('button-active')
    }
}); 


document.getElementById("search").addEventListener("click", function() {
    var searchDiv = document.getElementById("searchDiv");
    var medicineTable = document.getElementById("medicine-table");
    var addMedicineform = document.getElementById("add-table");
    var deleteMedicineform = document.getElementById("delete-table");

    if (deleteMedicineform.style.display !== "none") {
        deleteMedicineform.style.display = "none"
    }

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
    var deleteMedicineform = document.getElementById("delete-table");

    if (deleteMedicineform.style.display !== "none") {
        deleteMedicineform.style.display = "none"
    }

    if (medicineTable.style.display !== "none") {
        medicineTable.style.display = "none"
    }
    addMedicineform.style.display = "block"

    if (searchDiv.style.display === "flex") {
        searchDiv.style.display = "none";
    }
});

document.getElementById("delete").addEventListener("click", function() {
    var searchDiv = document.getElementById("searchDiv");
    var medicineTable = document.getElementById("medicine-table");
    var addMedicineform = document.getElementById("add-table");
    var deleteMedicineform = document.getElementById("delete-table");

    if (medicineTable.style.display !== "none") {
        medicineTable.style.display = "none"
    }

    if (addMedicineform.style.display !== "none") {
        addMedicineform.style.display = "none"
    }

    if (searchDiv.style.display === "flex") {
        searchDiv.style.display = "none";
    }

    deleteMedicineform.style.display = "block"
});

