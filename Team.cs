namespace ShotForge.Api.Models;

public class Team
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;

    // İstersen logo falan da eklenir
    public string? LogoUrl { get; set; }

    public List<Player> Players { get; set; } = new();
}
