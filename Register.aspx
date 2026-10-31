<%@ Page Title="Đăng ký" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="Gearzone.Register" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="section">
        <div class="container">
            <div class="auth-form-wrapper">
                <div class="auth-form">
                    <h1>Đăng ký tài khoản</h1>
                    <p class="auth-subtitle">Tạo tài khoản để mua sắm tại GEARZONE</p>

                    <asp:Label ID="lblError" runat="server" CssClass="error-text" Visible="false"></asp:Label>
                    <asp:Label ID="lblSuccess" runat="server" CssClass="success-text" Visible="false"></asp:Label>

                    <div class="form-group">
                        <label>Họ và tên *</label>
                        <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control" placeholder="Nhập họ và tên"></asp:TextBox>
                        <span id="errFullName" class="form-error"></span>
                    </div>

                    <div class="form-group">
                        <label>Tên đăng nhập *</label>
                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control" placeholder="Nhập tên đăng nhập"></asp:TextBox>
                        <span id="errUsername" class="form-error"></span>
                    </div>

                    <div class="form-group">
                        <label>Email *</label>
                        <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="Nhập email"></asp:TextBox>
                        <span id="errEmail" class="form-error"></span>
                    </div>

                    <div class="form-group">
                        <label>Mật khẩu * (tối thiểu 6 ký tự)</label>
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Nhập mật khẩu"></asp:TextBox>
                        <span id="errPassword" class="form-error"></span>
                    </div>

                    <div class="form-group">
                        <label>Xác nhận mật khẩu *</label>
                        <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="form-control" placeholder="Nhập lại mật khẩu"></asp:TextBox>
                        <span id="errConfirmPassword" class="form-error"></span>
                    </div>

                    <div class="form-group">
                        <label>Số điện thoại</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="form-control" placeholder="Nhập số điện thoại (không bắt buộc)"></asp:TextBox>
                        <span id="errPhone" class="form-error"></span>
                    </div>

                    <asp:Button ID="btnRegister" runat="server" Text="Đăng ký" CssClass="btn btn-accent auth-btn"
                        OnClick="btnRegister_Click" OnClientClick="return validateRegister();" />

                    <p class="auth-link">Đã có tài khoản? <a href="Login.aspx">Đăng nhập</a></p>
                </div>
            </div>
        </div>
    </section>
</asp:Content>

<asp:Content ID="ScriptsBody" ContentPlaceHolderID="ScriptsContent" runat="server">
    <script type="text/javascript">
        // Kiểm tra form đăng ký bằng JavaScript DOM
        function validateRegister() {
            var isValid = true;
            var fields = ['errFullName', 'errUsername', 'errEmail', 'errPassword', 'errConfirmPassword', 'errPhone'];
            for (var i = 0; i < fields.length; i++) {
                hideError(fields[i]);
            }

            var fullName = document.getElementById('<%= txtFullName.ClientID %>').value.trim();
            var username = document.getElementById('<%= txtUsername.ClientID %>').value.trim();
            var email = document.getElementById('<%= txtEmail.ClientID %>').value.trim();
            var password = document.getElementById('<%= txtPassword.ClientID %>').value;
            var confirmPassword = document.getElementById('<%= txtConfirmPassword.ClientID %>').value;
            var phone = document.getElementById('<%= txtPhone.ClientID %>').value.trim();

            // Họ tên
            if (fullName === '') {
                showError('errFullName', 'Vui lòng nhập họ và tên');
                isValid = false;
            }

            // Tên đăng nhập
            if (username === '') {
                showError('errUsername', 'Vui lòng nhập tên đăng nhập');
                isValid = false;
            } else if (username.length < 3) {
                showError('errUsername', 'Tên đăng nhập phải có ít nhất 3 ký tự');
                isValid = false;
            }

            // Email
            if (email === '') {
                showError('errEmail', 'Vui lòng nhập email');
                isValid = false;
            } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
                showError('errEmail', 'Email không đúng định dạng');
                isValid = false;
            }

            // Mật khẩu
            if (password === '') {
                showError('errPassword', 'Vui lòng nhập mật khẩu');
                isValid = false;
            } else if (password.length < 6) {
                showError('errPassword', 'Mật khẩu phải có ít nhất 6 ký tự');
                isValid = false;
            }

            // Xác nhận mật khẩu
            if (confirmPassword === '') {
                showError('errConfirmPassword', 'Vui lòng xác nhận mật khẩu');
                isValid = false;
            } else if (password !== confirmPassword) {
                showError('errConfirmPassword', 'Mật khẩu xác nhận không khớp');
                isValid = false;
            }

            // Số điện thoại (không bắt buộc nhưng nếu có thì phải hợp lệ)
            if (phone !== '' && !/^0[0-9]{9,10}$/.test(phone)) {
                showError('errPhone', 'Số điện thoại không hợp lệ');
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
