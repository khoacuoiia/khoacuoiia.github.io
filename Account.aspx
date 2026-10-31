<%@ Page Title="Tài khoản" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Account.aspx.cs" Inherits="Gearzone.Account" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <h1>Tài khoản của tôi</h1>
                <p>Quản lý thông tin cá nhân và xem lịch sử đơn hàng.</p>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <div class="account-layout">
                <!-- Thông tin cá nhân -->
                <div class="account-info">
                    <h2>Thông tin cá nhân</h2>
                    <asp:Label ID="lblMessage" runat="server" CssClass="success-text" Visible="false"></asp:Label>

                    <div class="form-group">
                        <label>Họ và tên</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label>Email</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" ReadOnly="true"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label>Số điện thoại</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control"></asp:TextBox>
                    </div>

                    <div class="form-group">
                        <label>Địa chỉ</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2"></asp:TextBox>
                    </div>

                    <asp:Button ID="btnUpdate" runat="server" Text="Cập nhật" CssClass="btn btn-accent" OnClick="btnUpdate_Click" />
                    <asp:Button ID="btnLogout" runat="server" Text="Đăng xuất" CssClass="btn btn-outline" OnClick="btnLogout_Click" style="margin-left:8px;" />
                </div>

                <!-- Lịch sử đơn hàng -->
                <div class="account-orders">
                    <h2>Lịch sử đơn hàng</h2>
                    <asp:Panel ID="pnlNoOrders" runat="server" CssClass="empty-message-small">
                        <p>Bạn chưa có đơn hàng nào.</p>
                        <a href="Products.aspx" class="btn btn-outline btn-sm">Mua sắm ngay</a>
                    </asp:Panel>

                    <asp:Repeater ID="rptOrders" runat="server" Visible="false">
                        <ItemTemplate>
                            <div class="order-card">
                                <div class="order-header">
                                    <span>Đơn hàng #<%# Eval("OrderID") %></span>
                                    <span class="order-status"><%# Eval("Status") %></span>
                                </div>
                                <div class="order-body">
                                    <span>Ngày đặt: <%# Eval("OrderDate", "{0:dd/MM/yyyy}") %></span>
                                    <span class="order-total"><%# string.Format("{0:N0}", Eval("TotalAmount")) %> ₫</span>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>
        </div>
    </section>
</asp:Content>
