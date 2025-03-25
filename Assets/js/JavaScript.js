/* Biến */
const ComputerWidth = '1024px';
const TabletWidth = '768px';
const PhoneWidth = '480px';


/* Hamburger Menu Toggle */
function NavToggle() {
    if (document.querySelector(".nav__link--flex-row")){
        document.querySelector(".nav__link--flex-row").classList.toggle('active');
    }
}
    

/* function MenuToggle() {                                                <============ BAD METHOD
    var MenuItems = document.querySelectorAll('.menu--hidden');
    for (let i = 0; i < MenuItems.length; i++){
        if (MenuItems[i].style.display === "none"){
            MenuItems[i].style.display = "block";
        } else {
            MenuItems[i].style.display = "none";
        }
    }
}
 */

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
            + '<a id="c-'+ itemData[itemNumber].id +'" href="#" class="cart-add"><i class="ri-add-fill"></i></a>'
        ;
    }
}
async function getData() {
    const res = await fetch("Assets/js/data.json");
    const data = await res.json();

    return data;
}

/* Thanh thông báo */

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