<%@ Page Title="Sản phẩm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Products.aspx.cs" Inherits="Gearzone.Products" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <h1 id="pageTitle" runat="server">&#128230; Danh sách sản phẩm GearZone</h1>
                <p>Khám phá phụ kiện máy tính, gaming chính hãng với bộ lọc và tìm kiếm chuẩn phương thức GET.</p>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <!-- Thanh Lọc & Tìm kiếm sử dụng phương thức HTTP GET -->
            <div class="filter-card">
                <div class="filter-card-header">
                    <span class="filter-icon">&#128269;</span>
                    <h3>Bộ lọc & Tìm kiếm (Phương thức HTTP GET)</h3>
                </div>

                <div class="filter-bar-grid">
                    <!-- 1. Tìm kiếm từ khóa (q) -->
                    <div class="filter-group filter-group-search">
                        <label for="txtSearch">&#128270; Từ khóa tìm kiếm:</label>
                        <asp:TextBox ID="txtSearch" runat="server" CssClass="form-control" placeholder="Tên sản phẩm, thương hiệu (Aula, Logitech...)" ClientIDMode="Static"></asp:TextBox>
                    </div>

                    <!-- 2. Danh mục (cat) -->
                    <div class="filter-group">
                        <label for="ddlCategory">&#128193; Danh mục:</label>
                        <asp:DropDownList ID="ddlCategory" runat="server" CssClass="form-control filter-select" ClientIDMode="Static">
                            <asp:ListItem Value="0" Text="-- Tất cả danh mục --" />
                        </asp:DropDownList>
                    </div>

                    <!-- 3. Khoảng giá (price) -->
                    <div class="filter-group">
                        <label for="ddlPrice">&#128178; Mức giá:</label>
                        <asp:DropDownList ID="ddlPrice" runat="server" CssClass="form-control filter-select" ClientIDMode="Static">
                            <asp:ListItem Value="all" Text="-- Tất cả mức giá --" />
                            <asp:ListItem Value="under-500k" Text="Dưới 500.000₫" />
                            <asp:ListItem Value="500k-1m" Text="500.000₫ - 1.000.000₫" />
                            <asp:ListItem Value="1m-2m" Text="1.000.000₫ - 2.000.000₫" />
                            <asp:ListItem Value="over-2m" Text="Trên 2.000.000₫" />
                        </asp:DropDownList>
                    </div>

                    <!-- 4. Sắp xếp (sort) -->
                    <div class="filter-group">
                        <label for="ddlSort">&#9660; Sắp xếp:</label>
                        <asp:DropDownList ID="ddlSort" runat="server" CssClass="form-control filter-select" ClientIDMode="Static">
                            <asp:ListItem Value="default" Text="Mới nhất" />
                            <asp:ListItem Value="price-asc" Text="Giá tăng dần (Thấp -> Cao)" />
                            <asp:ListItem Value="price-desc" Text="Giá giảm dần (Cao -> Thấp)" />
                            <asp:ListItem Value="name" Text="Tên sản phẩm A-Z" />
                        </asp:DropDownList>
                    </div>

                    <!-- 5. Nút Thao tác GET -->
                    <div class="filter-group filter-actions-group">
                        <label>&nbsp;</label>
                        <div class="filter-buttons-row">
                            <button type="button" class="btn btn-primary btn-filter-submit" onclick="submitGetFilter()">
                                &#128269; Lọc dữ liệu
                            </button>
                            <a href="Products.aspx" class="btn btn-outline btn-filter-reset" title="Xóa tất cả tham số trên URL">
                                &#8634; Đặt lại
                            </a>
                        </div>
                    </div>
                </div>

                <!-- Thanh hiển thị các tiêu chí lọc đang kích hoạt (Active filter tags) -->
                <asp:Panel ID="pnlActiveFilters" runat="server" CssClass="active-filters-bar" Visible="false">
                    <span class="active-filters-label">&#9881;&#65039; Đang lọc theo:</span>
                    <asp:Literal ID="litFilterTags" runat="server"></asp:Literal>
                </asp:Panel>
            </div>

            <!-- Header kết quả sản phẩm & URL GET hint -->
            <div class="products-header-info">
                <asp:Label ID="lblProductCount" runat="server" CssClass="product-count-badge"></asp:Label>
                <div class="current-url-hint">
                    <span class="url-badge-method">GET</span>
                    <code>Products.aspx<span id="lblCurrentQuery" runat="server"></span></code>
                </div>
            </div>

            <!-- Danh sách sản phẩm -->
            <div class="product-grid">
                <asp:Repeater ID="rptProducts" runat="server">
                    <ItemTemplate>
                        <div class="product-card">
                            <div class="product-card-image">
                                <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>'>
                                    <img src='<%# Eval("ImageURL") %>' alt='<%# Eval("ProductName") %>' />
                                </a>
                            </div>
                            <div class="product-card-body">
                                <span class="product-card-category"><%# Eval("CategoryName") %></span>
                                <h3 class="product-card-name">
                                    <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>'><%# Eval("ProductName") %></a>
                                </h3>
                                <div class="product-card-price"><%# string.Format("{0:N0}", Eval("Price")) %> ₫</div>
                                <div class="product-card-actions">
                                    <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>' class="btn btn-outline btn-sm">&#128065; Chi tiết</a>
                                    <asp:Button ID="btnAddCart" runat="server" Text="&#128722; Thêm giỏ" CssClass="btn btn-accent btn-sm"
                                        CommandName="AddToCart" CommandArgument='<%# Eval("ProductID") %>' OnCommand="btnAddCart_Command" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <!-- Thông báo khi không có sản phẩm nào -->
            <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="empty-message">
                <div class="empty-icon">&#128270;</div>
                <h2>Không tìm thấy sản phẩm phù hợp</h2>
                <p>Không có sản phẩm nào khớp với tiêu chí lọc và tìm kiếm đã chọn.</p>
                <div style="margin-top: 16px; display: flex; gap: 12px; justify-content: center;">
                    <a href="Products.aspx" class="btn btn-primary">&#8634; Xem tất cả sản phẩm</a>
                </div>
            </asp:Panel>
        </div>
    </section>

    <!-- Script điều hướng URL bằng phương thức HTTP GET chuẩn -->
    <script type="text/javascript">
        function submitGetFilter() {
            var txt = document.getElementById('txtSearch');
            var ddlCat = document.getElementById('ddlCategory');
            var ddlP = document.getElementById('ddlPrice');
            var ddlS = document.getElementById('ddlSort');

            var q = txt ? txt.value.trim() : '';
            var cat = ddlCat ? ddlCat.value : '0';
            var price = ddlP ? ddlP.value : 'all';
            var sort = ddlS ? ddlS.value : 'default';

            var params = [];
            if (q) params.push('q=' + encodeURIComponent(q));
            if (cat && cat !== '0') params.push('cat=' + encodeURIComponent(cat));
            if (price && price !== 'all') params.push('price=' + encodeURIComponent(price));
            if (sort && sort !== 'default') params.push('sort=' + encodeURIComponent(sort));

            var targetUrl = 'Products.aspx' + (params.length > 0 ? ('?' + params.join('&')) : '');
            window.location.href = targetUrl;
        }

        // Tự động submit khi đổi danh mục, khoảng giá hoặc sắp xếp
        document.addEventListener('DOMContentLoaded', function () {
            var ddlCat = document.getElementById('ddlCategory');
            var ddlP = document.getElementById('ddlPrice');
            var ddlS = document.getElementById('ddlSort');
            var txtSearch = document.getElementById('txtSearch');

            if (ddlCat) ddlCat.addEventListener('change', submitGetFilter);
            if (ddlP) ddlP.addEventListener('change', submitGetFilter);
            if (ddlS) ddlS.addEventListener('change', submitGetFilter);

            if (txtSearch) {
                txtSearch.addEventListener('keypress', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        submitGetFilter();
                    }
                });
            }
        });
    </script>
</asp:Content>