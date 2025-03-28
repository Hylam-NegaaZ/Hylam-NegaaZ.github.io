/* Hamburger Menu Toggle */
function NavToggle() {
    if (document.querySelector(".nav__link--flex-row")){
        document.querySelector(".nav__link--flex-row").classList.toggle('active');
    }
}

/* Import Json */
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
            '<a id="' + itemData[itemNumber].id + '" href="mathang.html" onclick="getId(event)">'
            + '<figure><img src="' + itemData[itemNumber].images[0] + '" alt=""></figure>'
            + '<figcaption>' + itemData[itemNumber].title + '</figcaption>'
            + discountStr
            + '<div class="item-rating">' + getStars(itemData[itemNumber].rating) + itemData[itemNumber].rating + '/5</div>'
            + '<p class="item-description">' + itemData[itemNumber].description + '</p>'
            + '<a id="c-'+ itemData[itemNumber].id +'" href="javascript:void(0);" class="order__to-cart cart-add" onclick="addToCart(\'' + itemData[itemNumber].title  + '\', ' + priceNum + ')"><i class="ri-add-fill"></i></a>'
        ;
    } /*  */
}
async function getData() {
    const res = await fetch("Assets/js/data.json");
    const data = await res.json();

    return data;
}


/* Hàm tự động lấy Id từ thẻ <a> */
function getId(event){
    event.preventDefault();

    const itemLink = event.currentTarget;
    const itemLinkId = itemLink.id;
    const url = new URL(itemLink.href);

    url.searchParams.set('id', itemLinkId);

    window.location.href = url.toString();
}

// thêm vào giỏ hàng
function addToCart(name, price) {
    let cart = JSON.parse(localStorage.getItem("cart")) || [];
    
    // Kiểm tra xem sản phẩm đã có trong giỏ hàng chưa
    let item = cart.find(i => i.name === name);

    if (item) {
        item.quantity++;
    } else {
        cart.push({ name: name, price: price, quantity: 1 });
    }

    // Lưu lại giỏ hàng vào localStorage
    localStorage.setItem("cart", JSON.stringify(cart));

    alert("Sản phẩm đã được thêm vào giỏ hàng!");
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