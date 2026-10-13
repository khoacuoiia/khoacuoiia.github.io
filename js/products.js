function getProductById(productId) {
  return (window.GEARZONE_PRODUCTS || []).find((product) => product.id === productId) || null;
}

function buildProductCard(product) {
  const discount = product.originalPrice > product.price ? Math.round(((product.originalPrice - product.price) / product.originalPrice) * 100) : 0;

  return `
    <article class="product-card">
      <img src="${product.image}" alt="${product.name}">
      <div class="product-card-body">
        <div class="product-meta">
          <span>${product.brand}</span>
          ${discount > 0 ? `<span class="tag">-${discount}%</span>` : '<span class="tag">Hot</span>'}
        </div>
        <h3>${product.name}</h3>
        <div class="product-pricing">
          <span class="product-price">${formatCurrency(product.price)}</span>
          ${product.originalPrice ? `<span class="product-old-price">${formatCurrency(product.originalPrice)}</span>` : ''}
        </div>
        <div class="product-actions">
          <a href="product-detail.html?id=${product.id}" class="btn btn-muted">Xem chi tiết</a>
          <button class="btn btn-primary add-to-cart" data-product-id="${product.id}">Thêm vào giỏ</button>
        </div>
      </div>
    </article>
  `;
}

function renderProductsToContainer(containerId, products) {
  const container = document.getElementById(containerId);
  if (!container) return;

  if (!products.length) {
    container.innerHTML = '<div class="empty-state">Không có sản phẩm phù hợp với điều kiện lọc hiện tại.</div>';
    return;
  }

  container.innerHTML = products.map(buildProductCard).join('');
  bindAddToCartButtons();
}

function bindAddToCartButtons() {
  document.querySelectorAll('.add-to-cart').forEach((button) => {
    button.addEventListener('click', function () {
      const productId = button.getAttribute('data-product-id');
      addToCart(productId, 1);
    });
  });
}

function renderFeaturedProducts() {
  const featured = (window.GEARZONE_PRODUCTS || []).slice(0, 8);
  renderProductsToContainer('featured-products', featured);
}

function renderCategoryCards() {
  const container = document.getElementById('home-categories');
  if (!container) return;

  container.innerHTML = (window.GEARZONE_CATEGORIES || []).slice(0, 8).map((category) => `
    <a href="products.html?category=${encodeURIComponent(category.slug)}" class="category-card">
      <img src="${category.image}" alt="${category.name}">
      <div class="category-card-body">
        <h3>${category.name}</h3>
        <span class="tag">Xem sản phẩm</span>
      </div>
    </a>
  `).join('');
}

function renderCategoryPage() {
  const container = document.getElementById('category-list');
  if (!container) return;

  container.innerHTML = (window.GEARZONE_CATEGORIES || []).map((category) => `
    <a href="products.html?category=${encodeURIComponent(category.slug)}" class="category-card">
      <img src="${category.image}" alt="${category.name}">
      <div class="category-card-body">
        <h3>${category.name}</h3>
        <span class="tag">Xem sản phẩm</span>
      </div>
    </a>
  `).join('');
}

function getFilteredProducts(rawProducts, filters) {
  let products = [...rawProducts];

  if (filters.category) {
    products = products.filter((product) => product.category === filters.category);
  }

  if (filters.maxPrice) {
    products = products.filter((product) => product.price <= Number(filters.maxPrice));
  }

  if (filters.sort === 'asc') {
    products.sort((a, b) => a.price - b.price);
  } else if (filters.sort === 'desc') {
    products.sort((a, b) => b.price - a.price);
  }

  return products;
}

function initProductListingPage() {
  const grid = document.getElementById('product-grid');
  const countEl = document.getElementById('product-count');
  const categoryFilter = document.getElementById('category-filter');
  const priceFilter = document.getElementById('price-filter');
  const sortFilter = document.getElementById('sort-filter');

  if (!grid) return;

  // Render danh mục động từ data thay vì hardcode trong HTML
  if (categoryFilter) {
    const categories = window.GEARZONE_CATEGORIES || [];
    categoryFilter.innerHTML =
      '<option value="">Tất cả</option>' +
      categories.map((cat) => `<option value="${cat.slug}">${cat.name}</option>`).join('');
  }

  function render() {
    const category = getQueryParam('category') || categoryFilter.value || '';
    const filters = {
      category: category || '',
      maxPrice: priceFilter ? priceFilter.value : '',
      sort: sortFilter ? sortFilter.value : ''
    };

    const filtered = getFilteredProducts(window.GEARZONE_PRODUCTS || [], filters);

    if (countEl) {
      countEl.textContent = `${filtered.length} sản phẩm`;
    }

    if (categoryFilter && !categoryFilter.value && category) {
      categoryFilter.value = category;
    }

    renderProductsToContainer('product-grid', filtered);
  }

  if (categoryFilter) {
    categoryFilter.addEventListener('change', render);
  }

  if (priceFilter) {
    priceFilter.addEventListener('change', render);
  }

  if (sortFilter) {
    sortFilter.addEventListener('change', render);
  }

  render();
}

function initSearchPage() {
  const form = document.getElementById('search-page-form');
  const resultContainer = document.getElementById('search-results');
  const keywordInput = document.getElementById('search-input');
  const query = getQueryParam('q');

  if (!resultContainer) return;

  if (keywordInput && query) {
    keywordInput.value = query;
  }

  const searchProducts = (value) => {
    const trimmed = (value || '').trim().toLowerCase();
    const results = !trimmed ? [] : (window.GEARZONE_PRODUCTS || []).filter((product) => {
      const searchable = `${product.name} ${product.brand} ${product.categoryName}`.toLowerCase();
      return searchable.includes(trimmed);
    });

    const heading = document.getElementById('search-heading');
    if (heading) {
      heading.textContent = trimmed ? `Kết quả tìm kiếm cho "${value}"` : 'Tất cả sản phẩm';
    }

    if (!results.length) {
      resultContainer.innerHTML = '<div class="empty-state">Không tìm thấy sản phẩm phù hợp với từ khóa bạn vừa nhập.</div>';
      return;
    }

    renderProductsToContainer('search-results', results);
  };

  if (form) {
    form.addEventListener('submit', function (event) {
      event.preventDefault();
      const value = keywordInput ? keywordInput.value : '';
      const url = new URL(window.location.href);
      url.searchParams.set('q', value.trim());
      window.history.replaceState({}, '', url);
      searchProducts(value);
    });
  }

  searchProducts(query);
}

function initProductDetailPage() {
  const productId = getQueryParam('id');
  const detailContainer = document.getElementById('product-detail');
  const relatedContainer = document.getElementById('related-products');
  if (!detailContainer) return;

  const product = getProductById(productId);
  if (!product) {
    detailContainer.innerHTML = '<div class="empty-state">Sản phẩm bạn yêu cầu không tồn tại hoặc đã bị xóa.</div>';
    return;
  }

  const productHtml = `
    <div class="product-detail-layout">
      <div class="detail-image">
        <img src="${product.image}" alt="${product.name}">
      </div>
      <div class="detail-content">
        <span class="brand">${product.brand}</span>
        <h1>${product.name}</h1>
        <div class="detail-price-row">
          <span class="price">${formatCurrency(product.price)}</span>
          ${product.originalPrice ? `<span class="old-price">${formatCurrency(product.originalPrice)}</span>` : ''}
        </div>
        <div class="product-code">Mã sản phẩm: ${product.code}</div>
        <p>${product.description}</p>
        <div class="detail-actions">
          <div class="quantity-box">
            <button type="button" data-qty-action="minus">−</button>
            <input id="detail-quantity" type="number" min="1" value="1">
            <button type="button" data-qty-action="plus">+</button>
          </div>
          <button type="button" class="btn btn-primary" id="detail-add-to-cart">Thêm vào giỏ</button>
          <a href="products.html" class="btn btn-muted">Quay lại</a>
        </div>
        <ul class="spec-list">
          <li><span>Danh mục</span><strong>${product.categoryName}</strong></li>
          <li><span>Tình trạng</span><strong>Còn hàng</strong></li>
          <li><span>Kho</span><strong>${product.stock} sản phẩm</strong></li>
        </ul>
      </div>
    </div>
  `;

  detailContainer.innerHTML = productHtml;

  const quantityInput = document.getElementById('detail-quantity');
  document.querySelector('[data-qty-action="plus"]').addEventListener('click', () => {
    quantityInput.value = Number(quantityInput.value || 1) + 1;
  });
  document.querySelector('[data-qty-action="minus"]').addEventListener('click', () => {
    const current = Number(quantityInput.value || 1);
    quantityInput.value = current > 1 ? current - 1 : 1;
  });

  document.getElementById('detail-add-to-cart').addEventListener('click', function () {
    const quantity = Number(quantityInput.value || 1);
    addToCart(product.id, quantity);
  });

  if (relatedContainer) {
    const related = (window.GEARZONE_PRODUCTS || []).filter((item) => item.category === product.category && item.id !== product.id).slice(0, 4);
    renderProductsToContainer('related-products', related);
  }
}

window.GEARZONE.renderFeaturedProducts = renderFeaturedProducts;
window.GEARZONE.renderCategoryPage = renderCategoryPage;
window.GEARZONE.initProductListingPage = initProductListingPage;
window.GEARZONE.initSearchPage = initSearchPage;
window.GEARZONE.initProductDetailPage = initProductDetailPage;

window.addEventListener('DOMContentLoaded', function () {
  if (document.getElementById('featured-products')) {
    renderFeaturedProducts();
  }

  if (document.getElementById('home-categories')) {
    renderCategoryCards();
  }

  if (document.getElementById('product-grid')) {
    initProductListingPage();
  }

  if (document.getElementById('search-results')) {
    initSearchPage();
  }

  if (document.getElementById('product-detail')) {
    initProductDetailPage();
  }

  if (document.getElementById('category-list')) {
    renderCategoryPage();
  }
});
