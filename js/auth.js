function registerUser(payload) {
  const users = getUsers();
  const existing = users.find((user) => user.username.toLowerCase() === payload.username.toLowerCase());

  if (existing) {
    throw new Error('Tên đăng nhập đã được sử dụng.');
  }

  users.push({
    fullName: payload.fullName,
    email: payload.email,
    username: payload.username,
    password: payload.password
  });

  saveUsers(users);
}

function loginUser(username, password) {
  const users = getUsers();
  const user = users.find((item) => item.username.toLowerCase() === username.toLowerCase() && item.password === password);

  if (!user) {
    throw new Error('Tên đăng nhập hoặc mật khẩu không đúng.');
  }

  setCurrentUser({
    fullName: user.fullName,
    email: user.email,
    username: user.username
  });

  return user;
}

function createOrderFromCart(user, formData) {
  const cart = getCart();
  const items = getCartItemDetails();

  if (!items.length) {
    throw new Error('Giỏ hàng trống.');
  }

  const order = {
    id: `GZ-${Date.now()}`,
    customer: user.fullName,
    phone: formData.phone,
    email: formData.email,
    address: formData.address,
    payment: formData.payment,
    note: formData.note || '',
    createdAt: new Date().toISOString(),
    total: items.reduce((sum, item) => sum + item.price * item.quantity, 0),
    items: items.map((item) => ({
      id: item.id,
      name: item.name,
      quantity: item.quantity,
      price: item.price
    }))
  };

  const orders = getOrders();
  orders.unshift(order);
  saveOrders(orders);
  saveCart([]);
  return order;
}

function renderAccountPage() {
  const profileEl = document.getElementById('account-profile');
  const ordersEl = document.getElementById('account-orders');
  const currentUser = getCurrentUser();

  if (!profileEl || !ordersEl) return;

  if (!currentUser) {
    profileEl.innerHTML = `
      <div class="empty-state">
        <p>Bạn chưa đăng nhập.</p>
        <a href="login.html" class="btn btn-primary" style="margin-top: 12px;">Đăng nhập</a>
      </div>
    `;
    ordersEl.innerHTML = '<div class="empty-state">Chưa có đơn hàng nào.</div>';
    return;
  }

  const orders = getOrders().filter((order) => order.customer === currentUser.fullName || order.email === currentUser.email);

  profileEl.innerHTML = `
    <div class="account-card">
      <h3>Thông tin tài khoản</h3>
      <p><strong>Họ tên:</strong> ${currentUser.fullName}</p>
      <p><strong>Email:</strong> ${currentUser.email}</p>
      <p><strong>Tên đăng nhập:</strong> ${currentUser.username}</p>
      <button class="btn btn-secondary" id="logout-btn">Đăng xuất</button>
    </div>
  `;

  document.getElementById('logout-btn').addEventListener('click', function () {
    clearCurrentUser();
    window.location.href = 'index.html';
  });

  if (!orders.length) {
    ordersEl.innerHTML = '<div class="empty-state">Chưa có đơn hàng nào.</div>';
    return;
  }

  ordersEl.innerHTML = `
    <div class="order-list">
      ${orders.map((order) => `
        <div class="order-card">
          <div class="order-card-header">
            <strong>${order.id}</strong>
            <span class="tag">${formatCurrency(order.total)}</span>
          </div>
          <ul>
            <li>Ngày đặt: ${new Date(order.createdAt).toLocaleString('vi-VN')}</li>
            <li>Phương thức: ${order.payment}</li>
            <li>Địa chỉ: ${order.address}</li>
            <li>Sản phẩm: ${order.items.map((item) => `${item.name} x${item.quantity}`).join(', ')}</li>
          </ul>
        </div>
      `).join('')}
    </div>
  `;
}

function initAuthForms() {
  const registerForm = document.getElementById('register-form');
  if (registerForm) {
    registerForm.addEventListener('submit', function (event) {
      event.preventDefault();

      const formData = new FormData(registerForm);
      const fullName = (formData.get('fullName') || '').trim();
      const email = (formData.get('email') || '').trim();
      const username = (formData.get('username') || '').trim();
      const password = (formData.get('password') || '').trim();
      const confirmPassword = (formData.get('confirmPassword') || '').trim();
      const agree = formData.get('agree') === 'on';

      if (!fullName || !email || !username || !password || !confirmPassword) {
        showToast('Vui lòng điền đầy đủ thông tin.');
        return;
      }

      if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        showToast('Email không hợp lệ.');
        return;
      }

      if (password.length < 6) {
        showToast('Mật khẩu phải có ít nhất 6 ký tự.');
        return;
      }

      if (password !== confirmPassword) {
        showToast('Mật khẩu xác nhận không khớp.');
        return;
      }

      if (!agree) {
        showToast('Bạn cần đồng ý với điều khoản.');
        return;
      }

      try {
        registerUser({ fullName, email, username, password });
        showToast('Đăng ký thành công!');
        setTimeout(() => {
          window.location.href = 'login.html';
        }, 800);
      } catch (error) {
        showToast(error.message || 'Đăng ký thất bại.');
      }
    });
  }

  const loginForm = document.getElementById('login-form');
  if (loginForm) {
    loginForm.addEventListener('submit', function (event) {
      event.preventDefault();

      const formData = new FormData(loginForm);
      const username = (formData.get('username') || '').trim();
      const password = (formData.get('password') || '').trim();

      if (!username || !password) {
        showToast('Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.');
        return;
      }

      try {
        loginUser(username, password);
        showToast('Đăng nhập thành công!');
        setTimeout(() => {
          window.location.href = 'account.html';
        }, 800);
      } catch (error) {
        showToast(error.message || 'Đăng nhập thất bại.');
      }
    });
  }

  const checkoutForm = document.getElementById('checkout-form');
  if (checkoutForm) {
    checkoutForm.addEventListener('submit', function (event) {
      event.preventDefault();

      const user = getCurrentUser();
      if (!user) {
        window.location.href = 'login.html';
        return;
      }

      const formData = new FormData(checkoutForm);
      const payload = {
        fullName: user.fullName,
        email: user.email,
        phone: (formData.get('phone') || '').trim(),
        address: (formData.get('address') || '').trim(),
        payment: formData.get('payment') || 'Thanh toán khi nhận hàng',
        note: (formData.get('note') || '').trim()
      };

      if (!payload.phone || !payload.address) {
        showToast('Vui lòng nhập đầy đủ thông tin giao hàng.');
        return;
      }

      try {
        const order = createOrderFromCart(user, payload);
        showToast(`Đặt hàng thành công! Mã đơn: ${order.id}`);
        setTimeout(() => {
          window.location.href = 'account.html';
        }, 1000);
      } catch (error) {
        showToast(error.message || 'Không thể đặt hàng.');
      }
    });
  }

  if (document.getElementById('account-profile')) {
    renderAccountPage();
  }
}

window.GEARZONE.registerUser = registerUser;
window.GEARZONE.loginUser = loginUser;
window.GEARZONE.createOrderFromCart = createOrderFromCart;
window.GEARZONE.renderAccountPage = renderAccountPage;
window.GEARZONE.initAuthForms = initAuthForms;

window.addEventListener('DOMContentLoaded', function () {
  initAuthForms();
});
