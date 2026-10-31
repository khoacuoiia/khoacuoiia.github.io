<%@ Page Title="Danh mục sản phẩm" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Categories.aspx.cs" Inherits="Gearzone.Categories" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <h1>Danh mục sản phẩm</h1>
                <p>Chọn danh mục phụ kiện bạn quan tâm để tìm sản phẩm phù hợp.</p>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="category-grid-large">
                <asp:Repeater ID="rptCategories" runat="server">
                    <ItemTemplate>
                        <a href='Products.aspx?cat=<%# Eval("CategoryID") %>' class="category-card-large">
                            <div class="category-card-img">
                                <img src='<%# Eval("ImageURL") %>' alt='<%# Eval("CategoryName") %>' />
                            </div>
                            <div class="category-card-content">
                                <h3><%# Eval("CategoryName") %></h3>
                                <p><%# Eval("Description") %></p>
                                <span class="category-count"><%# Eval("ProductCount") %> sản phẩm</span>
                            </div>
                        </a>
                    </ItemTemplate>
                </asp:Repeater>
            </div>
        </div>
    </section>
</asp:Content>
