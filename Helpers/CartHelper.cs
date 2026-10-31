using System;
using System.Collections.Generic;
using System.Web;

namespace Gearzone.Helpers
{
    /// <summary>
    /// Lớp đại diện cho một sản phẩm trong giỏ hàng
    /// </summary>
    [Serializable]
    public class CartItem
    {
        public int ProductID { get; set; }
        public string ProductName { get; set; }
        public decimal Price { get; set; }
        public int Quantity { get; set; }
        public string ImageURL { get; set; }

        public decimal Total
        {
            get { return Price * Quantity; }
        }
    }

    /// <summary>
    /// Lớp hỗ trợ xử lý giỏ hàng sử dụng Session
    /// </summary>
    public static class CartHelper
    {
        private const string CART_SESSION_KEY = "ShoppingCart";

        // Lấy giỏ hàng từ Session
        public static List<CartItem> GetCart()
        {
            if (HttpContext.Current.Session[CART_SESSION_KEY] == null)
            {
                HttpContext.Current.Session[CART_SESSION_KEY] = new List<CartItem>();
            }
            return (List<CartItem>)HttpContext.Current.Session[CART_SESSION_KEY];
        }

        // Thêm sản phẩm vào giỏ
        public static void AddToCart(int productId, string name, decimal price, string imageUrl, int quantity = 1)
        {
            List<CartItem> cart = GetCart();
            CartItem existing = cart.Find(x => x.ProductID == productId);

            if (existing != null)
            {
                existing.Quantity += quantity;
            }
            else
            {
                cart.Add(new CartItem
                {
                    ProductID = productId,
                    ProductName = name,
                    Price = price,
                    Quantity = quantity,
                    ImageURL = imageUrl
                });
            }
            UpdateCartCount();
        }

        // Cập nhật số lượng
        public static void UpdateQuantity(int productId, int quantity)
        {
            List<CartItem> cart = GetCart();
            CartItem item = cart.Find(x => x.ProductID == productId);
            if (item != null)
            {
                if (quantity <= 0)
                {
                    cart.Remove(item);
                }
                else
                {
                    item.Quantity = quantity;
                }
            }
            UpdateCartCount();
        }

        // Xóa sản phẩm khỏi giỏ
        public static void RemoveFromCart(int productId)
        {
            List<CartItem> cart = GetCart();
            cart.RemoveAll(x => x.ProductID == productId);
            UpdateCartCount();
        }

        // Tính tổng tiền
        public static decimal GetTotal()
        {
            List<CartItem> cart = GetCart();
            decimal total = 0;
            foreach (CartItem item in cart)
            {
                total += item.Total;
            }
            return total;
        }

        // Đếm số sản phẩm
        public static int GetItemCount()
        {
            List<CartItem> cart = GetCart();
            int count = 0;
            foreach (CartItem item in cart)
            {
                count += item.Quantity;
            }
            return count;
        }

        // Xóa toàn bộ giỏ hàng
        public static void ClearCart()
        {
            HttpContext.Current.Session[CART_SESSION_KEY] = new List<CartItem>();
            UpdateCartCount();
        }

        // Cập nhật số lượng hiển thị trên header
        private static void UpdateCartCount()
        {
            HttpContext.Current.Session["CartCount"] = GetItemCount();
        }
    }
}
