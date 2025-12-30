using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;
using System.Collections.Generic;
using System.Threading.Tasks;

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
        var players = await _context.Players.ToListAsync();
        return Ok(players);
    }

    // Yeni oyuncu ekleyen API
    [HttpPost]
    public async Task<ActionResult<Player>> AddPlayer(Player player)
    {
        _context.Players.Add(player);
        await _context.SaveChangesAsync();
        return Ok(player);
    }

    [HttpGet("{id}/details")]
    public async Task<ActionResult<object>> GetPlayerDetails(int id)
    {
        var player = await _context.Players.FindAsync(id);
        if (player == null) return NotFound();

        var shots = await _context.Shots.Where(s => s.PlayerId == id).ToListAsync();

        // 1. Temel İstatistikler (eFG%)
        double total = shots.Count;
        double makes = shots.Count(s => s.Made);
        double threes = shots.Count(s => s.ShotType.Contains("3PT") && s.Made);
        double eFG = total > 0 ? (makes + 0.5 * threes) / total : 0;

        // 2. YENİ İSTATİSTİKLER - Player üzerinden geliyor
        double twoPtPct = player.TwoPtAttempted > 0 ? (double)player.TwoPtMade / player.TwoPtAttempted : 0;
        double threePtPct = player.ThreePtAttempted > 0 ? (double)player.ThreePtMade / player.ThreePtAttempted : 0;
        double ftPct = player.FtAttempted > 0 ? (double)player.FtMade / player.FtAttempted : 0;

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
                efficiency = (double)g.Sum(s => s.Made ? 1 : 0) / g.Count()
            })
            .ToList();

        return Ok(new {
            Player = player,
            Stats = new {
                Total = total,
                EFG = eFG * 100,

                Rebounds = player.Rebounds,
                Assists = player.Assists,
                Fouls = player.Fouls,

                TwoPtMade = player.TwoPtMade,
                TwoPtAttempted = player.TwoPtAttempted,
                TwoPtPct = twoPtPct * 100,

                ThreePtMade = player.ThreePtMade,
                ThreePtAttempted = player.ThreePtAttempted,
                ThreePtPct = threePtPct * 100,

                FtMade = player.FtMade,
                FtAttempted = player.FtAttempted,
                FtPct = ftPct * 100
            },
            Shots = shots,
            Hexbin = hexbinData
        });
    }

    // Oyuncu silen API
    [HttpDelete("{id}")]
    public async Task<IActionResult> DeletePlayer(int id)
    {
        var player = await _context.Players.FindAsync(id);
        if (player == null)
        {
            return NotFound();
        }

        _context.Players.Remove(player);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
