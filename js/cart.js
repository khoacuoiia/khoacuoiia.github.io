function getCartItemDetails() {
  const cart = getCart();
  return cart.map((item) => {
    const product = getProductById(item.id);
    return product ? { ...product, quantity: item.quantity } : null;
  }).filter(Boolean);
}

function renderCartPage() {
  const cartItemsEl = document.getElementById('cart-items');
  const cartSummary = document.getElementById('cart-summary');
  const emptyState = document.getElementById('empty-cart-message');

  if (!cartItemsEl || !cartSummary) return;

  const items = getCartItemDetails();

  if (!items.length) {
    cartItemsEl.innerHTML = '';
    emptyState.style.display = 'block';
    cartSummary.innerHTML = `
      <div class="summary-card">
        <h3>Tổng đơn hàng</h3>
        <div class="summary-row"><span>Tạm tính</span><strong>${formatCurrency(0)}</strong></div>
        <div class="summary-row total"><span>Tổng tiền</span><strong>${formatCurrency(0)}</strong></div>
        <a href="products.html" class="btn btn-primary">Tiếp tục mua sắm</a>
      </div>
    `;
    return;
  }

  emptyState.style.display = 'none';

  cartItemsEl.innerHTML = items.map((item) => `
    <div class="cart-item" data-product-id="${item.id}">
      <img src="${item.image}" alt="${item.name}">
      <div>
        <h3>${item.name}</h3>
        <div class="cart-meta">${item.brand} • ${item.categoryName}</div>
        <div class="cart-actions">
          <div class="cart-qty">
            <button type="button" data-cart-action="minus" data-product-id="${item.id}">−</button>
            <span>${item.quantity}</span>
            <button type="button" data-cart-action="plus" data-product-id="${item.id}">+</button>
          </div>
          <button type="button" class="remove-item" data-product-id="${item.id}">Xóa</button>
        </div>
      </div>
      <strong>${formatCurrency(item.price * item.quantity)}</strong>
    </div>
  `).join('');

  const subtotal = items.reduce((total, item) => total + item.price * item.quantity, 0);
  cartSummary.innerHTML = `
    <div class="summary-card">
      <h3>Tổng đơn hàng</h3>
      <div class="summary-row"><span>Tạm tính</span><strong>${formatCurrency(subtotal)}</strong></div>
      <div class="summary-row"><span>Phí vận chuyển</span><strong>0₫</strong></div>
      <div class="summary-row total"><span>Tổng tiền</span><strong>${formatCurrency(subtotal)}</strong></div>
      <a href="checkout.html" class="btn btn-primary">Tiến hành thanh toán</a>
      <a href="products.html" class="btn btn-muted" style="margin-top:12px;">Tiếp tục mua sắm</a>
    </div>
  `;

  attachCartEvents();
}

function attachCartEvents() {
  document.querySelectorAll('[data-cart-action]').forEach((button) => {
    button.addEventListener('click', function () {
      const productId = button.getAttribute('data-product-id');
      const action = button.getAttribute('data-cart-action');
      updateCartItemQuantity(productId, action === 'plus' ? 1 : -1);
    });
  });

  document.querySelectorAll('.remove-item').forEach((button) => {
    button.addEventListener('click', function () {
      const productId = button.getAttribute('data-product-id');
      removeCartItem(productId);
    });
  });
}

function updateCartItemQuantity(productId, delta) {
  const cart = getCart();
  const target = cart.find((item) => item.id === productId);
  if (!target) return;

  target.quantity += delta;
  if (target.quantity <= 0) {
    const updatedCart = cart.filter((item) => item.id !== productId);
    saveCart(updatedCart);
  } else {
    saveCart(cart);
  }

  renderCartPage();
}

function removeCartItem(productId) {
  const updatedCart = getCart().filter((item) => item.id !== productId);
  saveCart(updatedCart);
  renderCartPage();
  showToast('Đã xóa sản phẩm khỏi giỏ hàng.');
}

window.GEARZONE.renderCartPage = renderCartPage;
window.GEARZONE.updateCartItemQuantity = updateCartItemQuantity;
window.GEARZONE.removeCartItem = removeCartItem;

window.addEventListener('DOMContentLoaded', function () {
  if (document.getElementById('cart-items')) {
    renderCartPage();
  }
});
