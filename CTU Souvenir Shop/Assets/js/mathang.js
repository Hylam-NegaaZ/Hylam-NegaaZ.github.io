/* JS slider dành cho sản phẩm */
let list = document.querySelector('.product__images .list');
let items = document.querySelectorAll('.product__images .list .item');
let navImages = document.querySelectorAll('.product__images .img-nav li');
let pbPrev = document.getElementById('pb-prev');
let pbNext = document.getElementById('pb-next');

let active = 0;
let lengthItems = items.length - 1;

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
let refreshSlider = setInterval(()=>{pbNext.click()},5000);

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