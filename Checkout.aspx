<%@ Page Title="Thanh toán" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="Gearzone.Checkout" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="page-hero">
        <div class="container page-hero-inner">
            <div>
                <h1>Thanh toán</h1>
                <p>Nhập thông tin giao hàng để hoàn tất đơn hàng.</p>
            </div>
        </div>
    </section>

    <section class="section">
        <div class="container">
            <!-- Thông báo thành công -->
            <asp:Panel ID="pnlSuccess" runat="server" Visible="false" CssClass="success-message">
                <h2>🎉 Đặt hàng thành công!</h2>
                <p>Cảm ơn bạn đã mua hàng tại GEARZONE. Đơn hàng của bạn đang được xử lý.</p>
                <a href="Default.aspx" class="btn btn-accent">Về trang chủ</a>
                <a href="Account.aspx" class="btn btn-outline" style="margin-left:8px;">Xem đơn hàng</a>
            </asp:Panel>

            <!-- Giỏ hàng trống -->
            <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" CssClass="empty-message">
                <h2>Giỏ hàng trống</h2>
                <p>Không có sản phẩm để thanh toán.</p>
                <a href="Products.aspx" class="btn btn-accent">Mua sắm ngay</a>
            </asp:Panel>

            <!-- Form thanh toán -->
            <asp:Panel ID="pnlCheckout" runat="server">
                <div class="checkout-layout">
                    <div class="checkout-form">
                        <h2>Thông tin giao hàng</h2>
                        <asp:Label ID="lblError" runat="server" CssClass="error-text" Visible="false"></asp:Label>

                        <div class="form-group">
                            <label for="txtFullName">Họ và tên *</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Nhập họ tên người nhận"></asp:TextBox>
                            <span id="errName" class="form-error"></span>
                        </div>

                        <div class="form-group">
                            <label for="txtPhone">Số điện thoại *</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Nhập số điện thoại"></asp:TextBox>
                            <span id="errPhone" class="form-error"></span>
                        </div>

                        <div class="form-group">
                            <label for="txtAddress">Địa chỉ giao hàng *</label>
                            <asp:TextBox ID="txtAddress" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="3" placeholder="Nhập địa chỉ chi tiết"></asp:TextBox>
                            <span id="errAddress" class="form-error"></span>
                        </div>

                        <div class="form-group">
                            <label for="txtNote">Ghi chú</label>
                            <asp:TextBox ID="txtNote" runat="server" CssClass="form-control" TextMode="MultiLine" Rows="2" placeholder="Ghi chú thêm (không bắt buộc)"></asp:TextBox>
                        </div>

                        <asp:Button ID="btnPlaceOrder" runat="server" Text="Đặt hàng" CssClass="btn btn-accent" style="width:100%;justify-content:center;"
                            OnClick="btnPlaceOrder_Click" OnClientClick="return validateCheckout();" />
                    </div>

                    <div class="checkout-summary">
                        <h3>Đơn hàng của bạn</h3>
                        <asp:Repeater ID="rptOrderItems" runat="server">
                            <ItemTemplate>
                                <div class="checkout-item">
                                    <img src='<%# Eval("ImageURL") %>' alt='<%# Eval("ProductName") %>' class="checkout-item-img" />
                                    <div class="checkout-item-info">
                                        <span class="checkout-item-name"><%# Eval("ProductName") %></span>
                                        <span class="checkout-item-qty">x<%# Eval("Quantity") %></span>
                                    </div>
                                    <span class="checkout-item-price"><%# string.Format("{0:N0}", Eval("Total")) %> ₫</span>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                        <div class="cart-summary-row cart-summary-total" style="margin-top:16px;padding-top:16px;border-top:1px solid #e2e8f0;">
                            <span>Tổng cộng:</span>
                            <span><asp:Label ID="lblTotal" runat="server"></asp:Label> ₫</span>
                        </div>
                    </div>
                </div>
            </asp:Panel>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ScriptsBody" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script type="text/javascript">
        // Kiểm tra form thanh toán bằng JavaScript DOM
        function validateCheckout() {
            var isValid = true;

            // Lấy giá trị
            var name = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
            var phone = document.getElementById('<%= txtPhone.ClientID %>').value.trim();
            var address = document.getElementById('<%= txtAddress.ClientID %>').value.trim();

            // Reset lỗi
            hideError('errName');
            hideError('errPhone');
            hideError('errAddress');

            // Kiểm tra họ tên
            if (name === '') {
                showError('errName', 'Vui lòng nhập họ tên người nhận');
                isValid = false;
            }

            // Kiểm tra số điện thoại
            if (phone === '') {
                showError('errPhone', 'Vui lòng nhập số điện thoại');
                isValid = false;
            } else if (!/^(0[0-9]{9,10})$/.test(phone)) {
                showError('errPhone', 'Số điện thoại không hợp lệ (bắt đầu bằng 0, 10-11 số)');
                isValid = false;
            }

            // Kiểm tra địa chỉ
            if (address === '') {
                showError('errAddress', 'Vui lòng nhập địa chỉ giao hàng');
                isValid = false;
            }

            return isValid;
        }

        function showError(id, msg) {
            var el = document.getElementById(id);
            el.textContent = msg;
            el.classList.add('show');
        }

        function hideError(id) {
            var el = document.getElementById(id);
            el.textContent = '';
            el.classList.remove('show');
        }
    </script>
</asp:Content>
