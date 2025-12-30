using System.ComponentModel.DataAnnotations.Schema;

namespace ShotForge.Api.Models;

public class Game
{
    public int Id { get; set; }
    public DateTime Date { get; set; } = DateTime.UtcNow;

    public int SeasonId { get; set; }
    [ForeignKey("SeasonId")]
    public Season Season { get; set; } = null!;

    // Basit kalsın diye isim string tuttum (istersen FK'ya çevrilir)
    public string HomeTeamName { get; set; } = string.Empty;
    public string AwayTeamName { get; set; } = string.Empty;

    public List<PlayerGameStat> PlayerStats { get; set; } = new();
}
