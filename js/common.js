window.GEARZONE = window.GEARZONE || {};

const STORAGE_KEYS = {
  cart: 'gearzone_cart',
  currentUser: 'gearzone_current_user',
  users: 'gearzone_users',
  orders: 'gearzone_orders'
};

function formatCurrency(value) {
  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
    maximumFractionDigits: 0
  }).format(value || 0);
}

function getCart() {
  try {
    const raw = localStorage.getItem(STORAGE_KEYS.cart);
    return raw ? JSON.parse(raw) : [];
  } catch (error) {
    return [];
  }
}

function saveCart(cart) {
  localStorage.setItem(STORAGE_KEYS.cart, JSON.stringify(cart));
  updateCartCounter();
}

function updateCartCounter() {
  const cart = getCart();
  const totalItems = cart.reduce((sum, item) => sum + Number(item.quantity || 0), 0);
  const cartCountEls = document.querySelectorAll('#cart-count');
  cartCountEls.forEach((el) => {
    el.textContent = totalItems;
  });
}

function addToCart(productId, quantity) {
  const product = window.GEARZONE_PRODUCTS.find((item) => item.id === productId);
  if (!product) {
    showToast('Sản phẩm không tồn tại.');
    return;
  }

  const cart = getCart();
  const existingIndex = cart.findIndex((item) => item.id === productId);
  const qty = Number(quantity || 1);

  if (existingIndex >= 0) {
    cart[existingIndex].quantity += qty;
  } else {
    cart.push({ id: product.id, quantity: qty });
  }

  saveCart(cart);
  showToast(`${product.name} đã được thêm vào giỏ hàng.`);
}

function getCurrentUser() {
  try {
    const raw = localStorage.getItem(STORAGE_KEYS.currentUser);
    return raw ? JSON.parse(raw) : null;
  } catch (error) {
    return null;
  }
}

function setCurrentUser(user) {
  localStorage.setItem(STORAGE_KEYS.currentUser, JSON.stringify(user));
}

function clearCurrentUser() {
  localStorage.removeItem(STORAGE_KEYS.currentUser);
}

function getUsers() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEYS.users)) || [];
  } catch (error) {
    return [];
  }
}

function saveUsers(users) {
  localStorage.setItem(STORAGE_KEYS.users, JSON.stringify(users));
}

function getOrders() {
  try {
    return JSON.parse(localStorage.getItem(STORAGE_KEYS.orders)) || [];
  } catch (error) {
    return [];
  }
}

function saveOrders(orders) {
  localStorage.setItem(STORAGE_KEYS.orders, JSON.stringify(orders));
}

function showToast(message) {
  const toast = document.getElementById('toast');
  if (!toast) return;
  toast.textContent = message;
  toast.classList.add('show');
  clearTimeout(window.GEARZONE.toastTimer);
  window.GEARZONE.toastTimer = setTimeout(() => {
    toast.classList.remove('show');
  }, 2200);
}

function setActiveNav() {
  const currentPath = window.location.pathname.split('/').pop() || 'index.html';
  const navLinks = document.querySelectorAll('.main-nav a');
  navLinks.forEach((link) => {
    const href = link.getAttribute('href');
    if (href === currentPath) {
      link.classList.add('active');
    }
  });
}

function setupHeaderSearch() {
  const form = document.querySelector('.header-search');
  if (!form) return;

  form.addEventListener('submit', function (event) {
    event.preventDefault();
    const input = form.querySelector('input[name="q"]');
    const value = (input.value || '').trim();
    if (!value) {
      showToast('Vui lòng nhập từ khóa tìm kiếm.');
      return;
    }
    window.location.href = `search.html?q=${encodeURIComponent(value)}`;
  });
}

function getQueryParam(name) {
  const params = new URLSearchParams(window.location.search);
  return params.get(name) || '';
}

window.GEARZONE.getCart = getCart;
window.GEARZONE.saveCart = saveCart;
window.GEARZONE.addToCart = addToCart;
window.GEARZONE.getCurrentUser = getCurrentUser;
window.GEARZONE.setCurrentUser = setCurrentUser;
window.GEARZONE.clearCurrentUser = clearCurrentUser;
window.GEARZONE.getOrders = getOrders;
window.GEARZONE.saveOrders = saveOrders;
window.GEARZONE.showToast = showToast;
window.GEARZONE.formatCurrency = formatCurrency;

document.addEventListener('DOMContentLoaded', function () {
  setActiveNav();
  setupHeaderSearch();
  updateCartCounter();
});
