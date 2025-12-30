using System.ComponentModel.DataAnnotations.Schema;

namespace ShotForge.Api.Models
{
    public class UserFavoritePlayer
    {
        public int Id { get; set; }

        // FK
        public int UserId { get; set; }
        [ForeignKey("UserId")]
        public User User { get; set; }

        public int PlayerId { get; set; }
        [ForeignKey("PlayerId")]
        public Player Player { get; set; }

        // İstersen sonra kullanırsın, şimdilik dursun
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
