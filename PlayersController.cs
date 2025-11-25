using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;
using System.Collections.Generic;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;

[ApiController]
[Route("api/[controller]")]
public class PlayersController : ControllerBase
{
    private readonly DataContext _context;

    public PlayersController(DataContext context)
    {
        _context = context;
    }

    // Bütün oyuncuları getiren API
    [HttpGet]
    public async Task<ActionResult<IEnumerable<Player>>> GetPlayers()
    {
        // Veritabanına git ve bütün oyuncuları listele
        var players = await _context.Players.ToListAsync();
        return Ok(players);
    }

    // Yeni oyuncu ekleyen API
    [HttpPost]
    public async Task<ActionResult<Player>> AddPlayer(Player player)
    {
        // Gelen oyuncu bilgisini veritabanına ekle
        _context.Players.Add(player);
        await _context.SaveChangesAsync(); // Değişiklikleri kaydet
        return Ok(player);
    }
    // Controllers/PlayersController.cs içine, diğer metotların altına ekle

[HttpGet("{id}/details")]
public async Task<ActionResult<object>> GetPlayerDetails(int id)
{
    var player = await _context.Players.FindAsync(id);
    if (player == null) return NotFound();
    var shots = await _context.Shots.Where(s => s.PlayerId == id).ToListAsync();

    // 1. Temel İstatistikler (eFG%, TS%)
    double total = shots.Count;
    double makes = shots.Count(s => s.Made);
    double threes = shots.Count(s => s.ShotType.Contains("3PT") && s.Made);
    double eFG = total > 0 ? (makes + 0.5 * threes) / total : 0;
    
    // 2. Hexbin / Heatmap Hesaplama (Profesyonel Dokunuş)
    // Sahayı 10x10'luk bölgelere bölüyoruz.
    var hexbinData = shots
        .GroupBy(s => new { 
            GridX = Math.Floor(s.X / 5) * 5, // 5 birimlik kareler
            GridY = Math.Floor(s.Y / 5) * 5 
        })
        .Select(g => new {
            x = g.Key.GridX,
            y = g.Key.GridY,
            count = g.Count(),
            made = g.Sum(s => s.Made ? 1 : 0),
            efficiency = (double)g.Sum(s => s.Made ? 1 : 0) / g.Count() // Bölge verimliliği
        })
        .ToList();

    return Ok(new { 
        Player = player, 
        Stats = new { Total = total, EFG = eFG * 100 }, 
        Shots = shots, // Noktasal harita için
        Hexbin = hexbinData // Isı haritası için
    });
}

    // Oyuncu silen API
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlayer(int id)
    {
        var player = await _context.Players.FindAsync(id);
        if (player == null)
        {
            return NotFound(); // Oyuncu bulunamadı
        }

        _context.Players.Remove(player);
        await _context.SaveChangesAsync(); // Değişiklikleri kaydet
        return NoContent(); // Başarılı
    }
}