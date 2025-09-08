function login() {
    event.preventDefault(); // prevent form submit (default behavior)
    var email = document.getElementById('email').value;
    var password = document.getElementById('pwd').value;
    var user = localStorage.getItem(email);
    var data = JSON.parse(user);
  
  
    // Kiểm tra email không được bỏ trống
    if (email.trim() === '') {
      alert('Vui lòng nhập email.');
      return false;
    }
  
    // Kiểm tra tính hợp lệ của email
    var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(email)) {
      alert('Vui lòng nhập địa chỉ email hợp lệ.');
      return false;
    }
  
    // Kiểm tra mật khẩu không bỏ trống
    if (password.trim() === '') {
      alert('Vui lòng nhập mật khẩu.');
      return false;
    }
  
    //Kiểm tra email có tồn tại
    if (!data) {
      alert("Email không tồn tại");
      return false;
    }
    // Kiểm tra tính đúng sai của mật khẩu
    if (email == data.email && password != data.password) {
      alert("Sai mật khẩu!");
      return false;
    }
    // Nếu kiểm tra tất cả thành công, cho phép đăng nhập
    if (email == data.email && password == data.password) {
      if (email == 'admin@gmail.com') {
        alert("Bạn đã đăng nhập dưới quyền Admin");
        window.location.href = "Admin/dashboard.html";
      } else {
        alert("Đăng nhập thành công");
        window.location.href = "html_index.html";
      }
    }
    return true;
}
function singup() {
    event.preventDefault(); // prevent form submit (default behavior)
    var username = document.getElementById('username').value;
    var email = document.getElementById('email').value;
    var password = document.getElementById('pwd').value;
    var confirmPassword = document.getElementById('pre-pwd').value;
  
    // Kiểm tra email đã tồn tại
    var existingUser = localStorage.getItem(email);
    if (existingUser) {
      alert('Email đã tồn tại. Vui lòng chọn email khác.');
      return false;
    }
    // Kiểm tra Username không được bỏ trống
    if (username.trim() === '') {
      alert('Vui lòng nhập Tên người dùng.');
      return false;
    }
  
    // Kiểm tra email không được bỏ trống
    if (email.trim() === '') {
      alert('Vui lòng nhập email.');
      return false;
    }
  
    // Kiểm tra tính hợp lệ của email
    var emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(email)) {
      alert('Vui lòng nhập địa chỉ email hợp lệ.');
      return false;
    }
  
    // Kiểm tra mật khẩu đúng và nhập lại mật khẩu giống nhau
    if (password.trim() === '') {
      alert('Vui lòng nhập mật khẩu.');
      return false;
    }
    // Kiểm tra mật khẩu theo định dạng "Abc@123"
    var passwordPattern = /^(?=.*[a-z])(?=.*\d)[A-Za-z\d]{8,}$/;
    if (!passwordPattern.test(password)) {
      alert('Mật khẩu không hợp lệ. Mật khẩu phải có ít nhất 8 kí tự bao gồm chữ và số');
      return false;
    }
    if (password !== confirmPassword) {
      alert('Mật khẩu không khớp. Vui lòng nhập lại mật khẩu.');
      return false;
    }
    var user = {
      username: username,
      email: email,
      password: password,
    };
    var json = JSON.stringify(user);
    localStorage.setItem(email, json);
    // Nếu tất cả kiểm tra đều thành công, cho phép submit form
    alert("Đăng ký thành công");
    window.location.href = "html_login.html";
    return true;
}
function cancel() {
    // Xóa dữ liệu trong các trường input của form
    document.getElementById('email').value = '';
    document.getElementById('pwd').value = '';

    document.getElementById('username').value = '';   
    document.getElementById('pre-pwd').value = '';
    return false;
}
function turnback() {
    window.location.href = "index.html";
}