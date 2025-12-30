namespace ShotForge.Api.Models
{
    public class PlayerStat
    {
        public int Id { get; set; }

        // FK zorunluluğu olmasın diye navigation koymuyoruz
        public int PlayerId { get; set; }

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
