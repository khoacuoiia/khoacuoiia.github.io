<%@ Page Title="Chi tiết sản phẩm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ProductDetail.aspx.cs" Inherits="Gearzone.ProductDetail" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section">
        <div class="container">
            <asp:Panel ID="pnlNotFound" runat="server" Visible="false" CssClass="empty-message">
                <h2>&#128533; Không tìm thấy sản phẩm</h2>
                <p>Sản phẩm bạn tìm không tồn tại hoặc đã bị xóa.</p>
                <a href="Products.aspx" class="btn btn-outline">&#8592; Quay lại danh sách sản phẩm</a>
            </asp:Panel>

            <asp:Panel ID="pnlProduct" runat="server">
                <!-- Breadcrumb -->
                <div class="breadcrumb">
                    <a href="Default.aspx">Trang chủ</a> &raquo;
                    <a href="Products.aspx">Sản phẩm</a> &raquo;
                    <span><asp:Label ID="lblBreadcrumb" runat="server"></asp:Label></span>
                </div>

                <div class="product-detail">
                    <!-- Gallery ảnh sản phẩm (5 ảnh offline) -->
                    <div class="product-gallery">
                        <div class="gallery-main">
                            <asp:Image ID="imgProduct" runat="server" CssClass="detail-img" ClientIDMode="Static" />
                        </div>
                        <div class="gallery-thumbnails">
                            <asp:Repeater ID="rptThumbnails" runat="server">
                                <ItemTemplate>
                                    <div class='thumbnail-item <%# Convert.ToBoolean(Eval("IsMain")) ? "active" : "" %>'
                                         onclick="switchGalleryImage(this, '<%# Eval("ImageURL") %>')">
                                        <img src='<%# Eval("ImageURL") %>' alt='<%# Eval("Caption") %>' />
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>

                    <!-- Thông tin mua hàng -->
                    <div class="product-detail-info">
                        <span class="product-card-category" style="font-size:0.9rem;">
                            <asp:Label ID="lblCategory" runat="server"></asp:Label>
                        </span>
                        <h1 class="product-detail-name">
                            <asp:Label ID="lblProductName" runat="server"></asp:Label>
                        </h1>
                        <div class="product-detail-price">
                            <asp:Label ID="lblPrice" runat="server"></asp:Label> &#8363;
                        </div>

                        <div class="product-detail-meta">
                            <div class="meta-item">
                                <span class="meta-icon">&#128230;</span>
                                <span>Tình trạng: <strong><asp:Label ID="lblStock" runat="server"></asp:Label></strong></span>
                            </div>
                            <div class="meta-item">
                                <span class="meta-icon">&#128666;</span>
                                <span>Vận chuyển: <strong>Miễn phí toàn quốc cho đơn từ 500k</strong></span>
                            </div>
                            <div class="meta-item">
                                <span class="meta-icon">&#128260;</span>
                                <span>Đổi trả: <strong>1 đổi 1 trong 30 ngày nếu lỗi kỹ thuật</strong></span>
                            </div>
                            <div class="meta-item">
                                <span class="meta-icon">&#128737;&#65039;</span>
                                <span>Bảo hành: <strong>Chính hãng 12 - 24 tháng</strong></span>
                            </div>
                        </div>

                        <div class="product-detail-actions">
                            <div class="quantity-control">
                                <label>Số lượng:</label>
                                <button type="button" class="qty-btn" onclick="changeQty(-1)">&#8722;</button>
                                <input type="text" id="txtQuantity" value="1" class="qty-input" readonly />
                                <button type="button" class="qty-btn" onclick="changeQty(1)">&#43;</button>
                            </div>
                            <asp:HiddenField ID="hdnQuantity" runat="server" Value="1" />
                            <asp:Button ID="btnAddToCart" runat="server" Text="&#128722; Thêm vào giỏ hàng" CssClass="btn btn-accent btn-lg" OnClick="btnAddToCart_Click" />
                        </div>
                    </div>
                </div>

                <!-- Cam kết chất lượng -->
                <div class="trust-banner">
                    <div class="trust-item">
                        <span class="trust-icon">&#9989;</span>
                        <div class="trust-text">
                            <h4>100% Chính hãng</h4>
                            <p>Nhập khẩu chính ngạch</p>
                        </div>
                    </div>
                    <div class="trust-item">
                        <span class="trust-icon">&#9889;</span>
                        <div class="trust-text">
                            <h4>Giao siêu tốc</h4>
                            <p>Nội thành trong 2 giờ</p>
                        </div>
                    </div>
                    <div class="trust-item">
                        <span class="trust-icon">&#128736;&#65039;</span>
                        <div class="trust-text">
                            <h4>Hỗ trợ kỹ thuật</h4>
                            <p>Tư vấn setup miễn phí</p>
                        </div>
                    </div>
                    <div class="trust-item">
                        <span class="trust-icon">&#128179;</span>
                        <div class="trust-text">
                            <h4>Thanh toán linh hoạt</h4>
                            <p>COD, chuyển khoản, thẻ</p>
                        </div>
                    </div>
                </div>

                <!-- Lưới 2 cột: Mô tả chi tiết & Bảng thông số kỹ thuật -->
                <div class="product-details-grid">
                    <!-- Cột 1: Mô tả chi tiết -->
                    <div class="product-desc-card">
                        <div class="card-header-badge">
                            <span>&#128196;</span>
                            <span>Mô tả sản phẩm</span>
                        </div>
                        <div class="product-desc-content">
                            <asp:Literal ID="litDescription" runat="server"></asp:Literal>
                        </div>
                    </div>

                    <!-- Cột 2: Thông số kỹ thuật chi tiết -->
                    <div class="product-specs-card">
                        <div class="card-header-badge">
                            <span>&#9881;&#65039;</span>
                            <span>Thông số kỹ thuật chi tiết</span>
                        </div>
                        <div class="product-specs-content">
                            <table class="specs-table">
                                <tbody>
                                    <asp:Literal ID="litSpecifications" runat="server"></asp:Literal>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Sản phẩm liên quan -->
                <asp:Panel ID="pnlRelated" runat="server">
                    <div class="section-header" style="margin-top:48px;">
                        <h2>&#128304; Sản phẩm liên quan</h2>
                    </div>
                    <div class="product-grid">
                        <asp:Repeater ID="rptRelated" runat="server">
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
                                        <div class="product-card-price"><%# string.Format("{0:N0}", Eval("Price")) %> &#8363;</div>
                                        <div class="product-card-actions">
                                            <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>' class="btn btn-outline btn-sm">&#128065; Chi tiết</a>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
            </asp:Panel>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ScriptsBody" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script type="text/javascript">
        function changeQty(delta) {
            var input = document.getElementById('txtQuantity');
            var hidden = document.getElementById('<%= hdnQuantity.ClientID %>');
            var current = parseInt(input.value) || 1;
            var newVal = current + delta;
            if (newVal < 1) newVal = 1;
            if (newVal > 99) newVal = 99;
            input.value = newVal;
            hidden.value = newVal;
        }

        function switchGalleryImage(thumbElement, imgUrl) {
            var mainImg = document.getElementById('imgProduct');
            if (mainImg) {
                mainImg.style.opacity = '0.3';
                setTimeout(function () {
                    mainImg.src = imgUrl;
                    mainImg.style.opacity = '1';
                }, 150);
            }
            var allThumbs = document.querySelectorAll('.thumbnail-item');
            allThumbs.forEach(function (el) {
                el.classList.remove('active');
            });
            thumbElement.classList.add('active');
        }
    </script>
</asp:Content>