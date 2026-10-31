 <%@ Page Title="Trang chủ" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="Gearzone._Default" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">

    <!-- BANNER -->
    <section class="banner">
        <div class="container banner-inner">
            <div class="banner-copy">
                <span class="eyebrow">&#9889; Phụ kiện chất lượng</span>
                <h1>Nâng cấp trải nghiệm<br />với phụ kiện đỉnh cao</h1>
                <p>Khám phá bộ sưu tập chuột, bàn phím, tai nghe và phụ kiện công nghệ dành cho học tập, làm việc và gaming.</p>
                <a href="Products.aspx" class="btn btn-primary">&#128270; Khám phá ngay</a>
            </div>
            <div class="banner-image">
                <img src="images/products/aula-f75.jpg" alt="GEARZONE Banner - Phụ kiện máy tính" />
            </div>
        </div>
    </section>

    <!-- SẢN PHẨM NỔI BẬT -->
    <section class="section">
        <div class="container">
            <div class="section-header">
                <h2>&#11088; Sản phẩm nổi bật</h2>
                <a href="Products.aspx">Xem tất cả &#8594;</a>
            </div>
            <div class="product-grid">
                <asp:Repeater ID="rptFeaturedProducts" runat="server">
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
                                    <asp:Button ID="btnAddCart" runat="server" Text="&#128722; Thêm giỏ" CssClass="btn btn-accent btn-sm"
                                        CommandName="AddToCart" CommandArgument='<%# Eval("ProductID") %>' OnCommand="btnAddCart_Command" />
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>

    <!-- DANH MỤC NỔI BẬT -->
    <section class="section" style="background: #fff;">
        <div class="container">
            <div class="section-header">
                <h2>&#128193; Danh mục sản phẩm</h2>
                <a href="Categories.aspx">Xem tất cả &#8594;</a>
            </div>
            <div class="category-grid">
                <a href="Products.aspx?cat=1" class="category-card">
                    <div class="category-card-icon">&#9000;&#65039;</div>
                    <h3>Bàn phím</h3>
                    <p>Bàn phím cơ, gaming</p>
                </a>
                <a href="Products.aspx?cat=2" class="category-card">
                    <div class="category-card-icon">&#128433;&#65039;</div>
                    <h3>Chuột</h3>
                    <p>Chuột gaming, văn phòng</p>
                </a>
                <a href="Products.aspx?cat=3" class="category-card">
                    <div class="category-card-icon">&#127911;</div>
                    <h3>Tai nghe</h3>
                    <p>Tai nghe gaming, bluetooth</p>
                </a>
                <a href="Products.aspx?cat=4" class="category-card">
                    <div class="category-card-icon">&#128247;</div>
                    <h3>Webcam</h3>
                    <p>Webcam HD, Full HD</p>
                </a>
                <a href="Products.aspx?cat=5" class="category-card">
                    <div class="category-card-icon">&#128268;</div>
                    <h3>Hub & Cáp</h3>
                    <p>Hub USB, cáp chuyển đổi</p>
                </a>
            </div>
        </div>
    </section>

</asp:Content>
