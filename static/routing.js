document.addEventListener('DOMContentLoaded', function() {
    fetch('/get_route')
    .then(response => {
        if (!response.ok) {
            throw new Error('Có lỗi khi gửi yêu cầu.');
        }
        return response.json();
    })
    .then(data => {
        const routesContainer = document.getElementById('route');
        data.forEach(route => {
            const div = document.createElement('div');
            if (route ==="NhanVien") {
                div.textContent = "Nhân Viên";
                div.addEventListener('click',function(){
                    alert('Đang chuyển hướng');
                    location.replace('/nhanvien');
                })
            }
            else if (route =="BacSi") {
                div.textContent = "Bác sĩ";
                div.addEventListener('click',function(){
                    alert('Đang chuyển hướng');
                    location.replace('/dentist');
                })
            }
            else if (route =="KhachHang") {
                div.textContent = "Khách Hàng";
                div.addEventListener('click', function(){
                    alert('Đang chuyển hướng');
                    location.replace('/khachhang');
                })        
            }
            else if (route =="Admin") {
                div.textContent = "Admin";
                div.addEventListener('click', function(){
                    alert('Đang chuyển hướng');
                    location.replace('/admin');
                })
            }
            div.classList.add('box', 'item');
            routesContainer.appendChild(div);
        });
    })
    .catch(error => console.error('Lỗi:', error));
});