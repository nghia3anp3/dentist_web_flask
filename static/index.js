const showCreate = document.querySelector('.show-create');
const showLock = document.querySelector('.show-lock');
const functional = document.querySelectorAll('.functional');
const createButton = document.getElementById('create-button');
const lockButton = document.getElementById('lock-button');


function hideAll() {
    for (const div of functional) {
        div.style.display = 'none';
    }
}

showCreate.addEventListener('click', () => {
    if (showLock.classList.contains('button-active')) {
        showLock.classList.toggle('button-active');
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