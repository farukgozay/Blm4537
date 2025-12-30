namespace ShotForge.Api.Models
{
    public class Arena
    {
        public int Id { get; set; }
        public string Name { get; set; } = string.Empty;   // Crypto.com Arena
        public string City { get; set; } = string.Empty;   // Los Angeles
        public int Capacity { get; set; }                  // 19000
    }
}
