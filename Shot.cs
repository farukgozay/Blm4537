// Models/Shot.cs
using System.ComponentModel.DataAnnotations.Schema;

namespace ShotForge.Api.Models
{
    public class Shot
    {
        public int Id { get; set; }
        public int GameId { get; set; } // Maç ID'si
        public double X { get; set; } // Şutun X koordinatı
        public double Y { get; set; } // Şutun Y koordinatı
        public bool Made { get; set; } // İsabetli mi? (true/false)
        public string ShotType { get; set; } // Şut tipi (örn: 2PT Jump Shot, 3PT Pull-up)
        public int Period { get; set; } // Periyot
        public string Clock { get; set; } // Maç saati

        // --- En Önemli Kısım: Foreign Key ---
        public int PlayerId { get; set; }
        [ForeignKey("PlayerId")]
        public Player Player { get; set; }


    }
}