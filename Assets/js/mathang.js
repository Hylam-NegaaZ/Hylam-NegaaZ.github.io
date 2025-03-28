/* Tạo HTML từ id sản phẩm */
function getDataDetail() {
    const params = new URL(window.location).searchParams
    let DetailId = params.get("id");

    /* Tìm dữ liệu khớp với id từ file data.json */
    fetch("Assets/js/data.json")
    .then(response => response.json()) // Parse JSON data
    .then(data => {
        const matchingItem = data.find(item => item.id === DetailId); // Find item with matching id

        let discountStr = "";
        let discountNum = 1*matchingItem.discount;
        let priceNum = 1*matchingItem.price;

        let illustrationList = document.querySelector(".product__images .list");
        let illustrationNav = document.querySelector(".product__images .img-nav");

        let interactTitle =  document.querySelector(".interaction__title");
        let interactPrice =  document.querySelector(".interaction__price");
        let interactRate = document.querySelector(".statics__rating")

        let information = document.querySelector(".product__information");

        /* Lấy dữ liệu giảm giá (nếu có) */
        
        if (matchingItem.discount) {
            discountStr = '<h2 class="item-price" style="color: var(--css-red);">' + (priceNum).toLocaleString() + 'đ&nbsp<span style="font-size: 12px; text-decoration: line-through;">(' + (priceNum+(priceNum*discountNum/100)).toLocaleString() + 'đ)</span></h2>'
        } else {discountStr = '<h2 class="item-price">' + (priceNum).toLocaleString() + 'đ</h2>'; interactPrice.style.backgroundColor = "#dbf3fa";} 

        /* Inner HTML */
        matchingItem.images.forEach(imgNum => {
            illustrationList.innerHTML += '<div class="item"><img src="' + imgNum + '" alt="" class=""></div>';
        });

        matchingItem.images.forEach(imgNum => {
            if (matchingItem.images[0] == imgNum) {
                illustrationNav.innerHTML += '<li class="active"><img src="' + imgNum + '" alt="" class=""></li>';
            } else {illustrationNav.innerHTML += '<li><img src="' + imgNum + '" alt="" class=""></li>';}
        });


        interactTitle.innerHTML = matchingItem.title;
        interactPrice.innerHTML = discountStr;
        interactRate.innerHTML = '<span class="item-rating">' + getStars(matchingItem.rating) + matchingItem.rating + '/5</span>';

        information.innerHTML += '<p>' + matchingItem.description + '</p>';
    })
}
getDataDetail();

/* JS slider dành cho sản phẩm */
let list = document.querySelector('.product__images .list');
let items = document.querySelectorAll('.product__images .list .item');
let navImages = document.querySelectorAll('.product__images .img-nav li');
let pbPrev = document.getElementById('pb-prev');
let pbNext = document.getElementById('pb-next');

let active = 0;
let lengthItems = items.length - 1;

/* Điều kiện có ảnh mới bật nút lướt */
if (lengthItems == 0){
    pbPrev.style.display = "none";
    pbNext.style.display = "none";
} else {var refreshSlider = setInterval(()=>{pbNext.click()},5000);}

/* click chuột */
pbNext.onclick = function(){
    if(active + 1 > lengthItems){
        active = 0
    } else active += 1;
    reloadSlider();
}
pbPrev.onclick = function(){
    if(active - 1 < 0){
        active = lengthItems
    } else active -= 1;
    reloadSlider();
}
/* tự động chuyển slide */
function reloadSlider(){
    let checkLeft = items[active].offsetLeft;
    list.style.left = -checkLeft + 'px';

    let lastActiveImg = document.querySelector('.product__images .img-nav li.active');
    lastActiveImg.classList.remove('active');
    navImages[active].classList.add('active');

    clearInterval(refreshSlider);
    refreshSlider = setInterval(()=>{pbNext.click()},5000);
}

/* click vào img để chuyển slide */
navImages.forEach((li,key) => {
    li.addEventListener('click', function(){
        active = key;
        reloadSlider();
    })
})


/* nút tăng giảm số lượng */
const NumInput = document.getElementById('cart-quantity');
function stepper(btn) {
    let idBtn = btn.getAttribute("id");
    let min = NumInput.getAttribute("min");
    let max = NumInput.getAttribute("max");
    let val = NumInput.getAttribute("value");
    
    if (idBtn == "quantity-plus") val = val*1 + 1
    else val = val*1 - 1;
    
    if (val >= min && val <= max){
        NumInput.setAttribute("value", val);
    }
}
