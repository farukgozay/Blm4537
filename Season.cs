namespace ShotForge.Api.Models;

public class Season
{
    public int Id { get; set; }
    public string Name { get; set; } = "2024-25";

    public List<Game> Games { get; set; } = new();
}
