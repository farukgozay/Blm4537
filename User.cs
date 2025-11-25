namespace ShotForge.Api.Models;

public class User
{
    public int Id { get; set; }
    public string Username { get; set; } = string.Empty; // Boş string ile başlatıyoruz
    public string PasswordHash { get; set; } = string.Empty; // Hata vermesin diye
}