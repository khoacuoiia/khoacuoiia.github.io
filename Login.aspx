<%@ Page Title="Đăng nhập" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Gearzone.Login" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section">
        <div class="container">
            <div class="auth-form-wrapper">
                <div class="auth-form">
                    <h1>Đăng nhập</h1>
                    <p class="auth-subtitle">Chào mừng bạn quay lại GEARZONE</p>

                    <asp:Label ID="lblError" runat="server" CssClass="error-text" Visible="false"></asp:Label>

                    <div class="form-group">
                        <label>Tên đăng nhập hoặc Email</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Nhập tên đăng nhập hoặc email"></asp:TextBox>
                        <span id="errUsername" class="form-error"></span>
                    </div>

                    <div class="form-group">
                        <label>Mật khẩu</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Nhập mật khẩu"></asp:TextBox>
                        <span id="errPassword" class="form-error"></span>
                    </div>

                    <asp:Button ID="btnLogin" runat="server" Text="Đăng nhập" CssClass="btn btn-accent auth-btn"
                        OnClick="btnLogin_Click" OnClientClick="return validateLogin();" />

                    <p class="auth-link">Chưa có tài khoản? <a href="Register.aspx">Đăng ký ngay</a></p>
                </div>
            </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ScriptsBody" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script type="text/javascript">
        function validateLogin() {
            var isValid = true;
            var username = document.getElementById('<%= txtUsername.ClientID %>').value.trim();
            var password = document.getElementById('<%= txtPassword.ClientID %>').value;

            hideError('errUsername');
            hideError('errPassword');

            if (username === '') {
                showError('errUsername', 'Vui lòng nhập tên đăng nhập hoặc email');
                isValid = false;
            }
            if (password === '') {
                showError('errPassword', 'Vui lòng nhập mật khẩu');
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
