<%@ Page Title="Tìm kiếm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Search.aspx.cs" Inherits="Gearzone.Search" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <h1>Kết quả tìm kiếm</h1>
                <p><asp:Label ID="lblSearchInfo" runat="server"></asp:Label></p>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="product-grid">
                <asp:Repeater ID="rptSearchResults" runat="server">
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
                                    <a href='ProductDetail.aspx?id=<%# Eval("ProductID") %>' class="btn btn-outline btn-sm">Chi tiết</a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlNoResults" runat="server" Visible="false" CssClass="empty-message">
                <h2>Không tìm thấy kết quả</h2>
                <p>Thử tìm với từ khóa khác hoặc duyệt danh mục sản phẩm.</p>
                <a href="Products.aspx" class="btn btn-outline">Xem tất cả sản phẩm</a>
            </asp:Panel>
        </div>
    </section>
</asp:Content>
