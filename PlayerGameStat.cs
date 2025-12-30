using System.ComponentModel.DataAnnotations.Schema;

namespace ShotForge.Api.Models
{
    public class PlayerGameStat
    {
        public int Id { get; set; }

        // FK
        public int PlayerId { get; set; }
        [ForeignKey("PlayerId")]
        public Player Player { get; set; }

        public int GameId { get; set; }
        [ForeignKey("GameId")]
        public Game Game { get; set; }

        // Statlar (senin istediğinler)
        public int Rebounds { get; set; }
        public int Assists { get; set; }
        public int Fouls { get; set; }

        public int TwoMade { get; set; }
        public int TwoAttempt { get; set; }

        public int ThreeMade { get; set; }
        public int ThreeAttempt { get; set; }

        public int FTMade { get; set; }
        public int FTAttempt { get; set; }
    }
}
