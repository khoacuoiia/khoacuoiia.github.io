<%@ Page Title="Giỏ hàng" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Cart.aspx.cs" Inherits="Gearzone.Cart" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <h1>Giỏ hàng</h1>
                <p>Xem lại sản phẩm trước khi thanh toán.</p>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <!-- Giỏ hàng trống -->
            <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" CssClass="empty-message">
                <h2>Giỏ hàng trống</h2>
                <p>Bạn chưa thêm sản phẩm nào vào giỏ hàng.</p>
                <a href="Products.aspx" class="btn btn-accent">Mua sắm ngay</a>
            </asp:Panel>

            <!-- Giỏ hàng có sản phẩm -->
            <asp:Panel ID="pnlCart" runat="server">
                <div class="cart-layout">
                    <div class="cart-items">
                        <asp:Repeater ID="rptCart" runat="server" OnItemCommand="rptCart_ItemCommand">
                            <ItemTemplate>
                                <div class="cart-item" id='cart-item-<%# Eval("ProductID") %>'>
                                    <div class="cart-item-image">
                                        <img src='<%# Eval("ImageURL") %>' alt='<%# Eval("ProductName") %>' />
                                    </div>
                                    <div class="cart-item-info">
                                        <h3 class="cart-item-name"><%# Eval("ProductName") %></h3>
                                        <div class="cart-item-price"><%# string.Format("{0:N0}", Eval("Price")) %> ₫</div>
                                    </div>
                                    <div class="cart-item-quantity">
                                        <asp:Button ID="btnMinus" runat="server" Text="−" CssClass="qty-btn"
                                            CommandName="Decrease" CommandArgument='<%# Eval("ProductID") %>' />
                                        <span class="qty-display"><%# Eval("Quantity") %></span>
                                        <asp:Button ID="btnPlus" runat="server" Text="+" CssClass="qty-btn"
                                            CommandName="Increase" CommandArgument='<%# Eval("ProductID") %>' />
                                    </div>
                                    <div class="cart-item-total">
                                        <%# string.Format("{0:N0}", Eval("Total")) %> ₫
                                    </div>
                                    <asp:Button ID="btnRemove" runat="server" Text="✕" CssClass="cart-item-remove"
                                        CommandName="Remove" CommandArgument='<%# Eval("ProductID") %>'
                                        OnClientClick="return confirm('Bạn có chắc muốn xóa sản phẩm này?');" />
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <div class="cart-summary">
                        <h3>Tóm tắt đơn hàng</h3>
                        <div class="cart-summary-row">
                            <span>Tạm tính:</span>
                            <span><asp:Label ID="lblSubtotal" runat="server"></asp:Label> ₫</span>
                        </div>
                        <div class="cart-summary-row">
                            <span>Phí vận chuyển:</span>
                            <span>Miễn phí</span>
                        </div>
                        <div class="cart-summary-row cart-summary-total">
                            <span>Tổng cộng:</span>
                            <span><asp:Label ID="lblTotal" runat="server"></asp:Label> ₫</span>
                        </div>
                        <a href="Checkout.aspx" class="btn btn-accent" style="width:100%;justify-content:center;margin-top:16px;">Tiến hành thanh toán</a>
                        <a href="Products.aspx" class="btn btn-outline" style="width:100%;justify-content:center;margin-top:8px;">Tiếp tục mua sắm</a>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </section>
</asp:Content>
