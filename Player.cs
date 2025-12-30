namespace ShotForge.Api.Models;

public class Player
{
    public int Id { get; set; }
    public string Name { get; set; }
    public string Position { get; set; }
    public string Team { get; set; }
    public string ImageUrl { get; set; }

    // --- YENİ İSTATİSTİKLER ---
    public int Rebounds { get; set; }          // Ribaund
    public int Assists { get; set; }           // Asist
    public int Fouls { get; set; }             // Faul

    public int TwoPtMade { get; set; }         // 2 sayı isabet
    public int TwoPtAttempted { get; set; }    // 2 sayı deneme

    public int ThreePtMade { get; set; }       // 3 sayı isabet
    public int ThreePtAttempted { get; set; }  // 3 sayı deneme

    public int FtMade { get; set; }            // Serbest atış isabet
    public int FtAttempted { get; set; }       // Serbest atış deneme

    public int? TeamId { get; set; }
    public Team? TeamRef { get; set; }
}
