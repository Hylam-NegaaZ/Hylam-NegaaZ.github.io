/* Hamburger Menu Toggle */
function NavToggle() {
    if (document.querySelector(".nav__link--flex-row")){
        document.querySelector(".nav__link--flex-row").classList.toggle('active');
    }
}
    

/* JS Giỏ hàng */
let cart = []; // Giỏ hàng sẽ lưu tên sản phẩm
const cartCount = document.getElementById("cart-count");
const cartModal = document.getElementById("cart-modal");
const cartItems = document.getElementById("cart-items");
const closeCartButton = document.getElementById("close-cart");

// Hàm thêm sản phẩm vào giỏ hàng
function AddToCart(id) {
    cart.push(id);
    updateCartDisplay();
}

// Cập nhật hiển thị số lượng sản phẩm trong giỏ hàng
function updateCartDisplay() {
    cartCount.textContent = cart.length;
    updateCartItems();
}

// Cập nhật các sản phẩm trong giỏ hàng
function updateCartItems() {
    cartItems.innerHTML = ''; // Xóa danh sách cũ
    cart.forEach(item => {
        const li = document.createElement('li');
        li.textContent = item;
        cartItems.appendChild(li);
    });
}


/* Import Json */
getDataCatalog();

async function getDataCatalog() {
    const itemData = await getData();
    const itemEO = document.querySelectorAll(".page__item--EO");
    for (var itemNumber in itemData) {
        let discountStr = "";
        let discountNum = 1*itemData[itemNumber].discount;
        let priceNum = 1*itemData[itemNumber].price;

        /* Lấy dữ liệu giảm giá (nếu có) */
        if (itemData[itemNumber].discount) {
            discountStr = '<h2 class="item-price" style="color: var(--css-red);">' + (priceNum).toLocaleString() + 'đ&nbsp<span style="font-size: 12px; text-decoration: line-through;">(' + (priceNum+(priceNum*discountNum/100)).toLocaleString() + 'đ)</span></h2>'
        } else {discountStr = '<h2 class="item-price">' + (priceNum).toLocaleString() + 'đ</h2>'} 

        /* sinh mã HTML */
        if (itemData[itemNumber].id)
        itemEO[itemNumber].innerHTML += 
            '<a id="' + itemData[itemNumber].id + '" href="mathang_template.html">'
            + '<figure><img src="' + itemData[itemNumber].images[0] + '" alt="">'
            + '<figcaption>' + itemData[itemNumber].title 
            + discountStr
            + '<div class="item-rating">' + getStars(itemData[itemNumber].rating) + itemData[itemNumber].rating + '/5</div>'
            + '<p class="item-description">' + itemData[itemNumber].description + '</p>'
            + '<a id="c-'+ itemData[itemNumber].id +'" href="#" class="cart-add" onclick=AddToCart("'+ itemData[itemNumber].id +'")><i class="ri-add-fill"></i></a>'
        ;
    }
}
async function getData() {
    const res = await fetch("Assets/js/data.json");
    const data = await res.json();

    return data;
}

/* tự động tạo ra icon sao - Nguồn Stackoverflow có qua chỉnh sửa*/
function getStars(rating) {
    // Round to nearest half
    rating = Math.round(rating * 2) / 2;
    let output = [];
  
    // Append all the filled whole stars
    for (var i = rating; i >= 1; i--)
      output.push('<i class="ri-star-fill"></i>&nbsp;');
  
    // If there is a half a star, append it
    if (i == .5) output.push('<i class="ri-star-half-line"></i>&nbsp;');
  
    // Fill the empty stars
    for (let i = (5 - rating); i >= 1; i--)
      output.push('<i class="ri-star-line"></i>&nbsp;');
  
    return output.join('');
}

/* InnerStar */
function checkStar(rate) {
    document.getElementById("rating").innerHTML += getStars(rate);
}

/* Footer => To-top */
const toTopBtn = document.querySelector(".to-top");
window.addEventListener('scroll', () => {
    if (window.pageYOffset > 50) {
        toTopBtn.classList.add('active');
    } else {
        toTopBtn.classList.remove('active');
    }
})

document.addEventListener('DOMContentLoaded', function() {
    if (toTopBtn) { 
        toTopBtn.addEventListener('click', function(event) {
            event.preventDefault(); 

            window.scrollTo({
                top: 0,
                behavior: 'smooth' 
            });
        });
    }
});