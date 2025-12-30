using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;

[ApiController]
[Route("api/[controller]")]
public class PlayerStatsController : ControllerBase
{
    private readonly DataContext _context;
    public PlayerStatsController(DataContext context) { _context = context; }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<PlayerStat>>> GetAll()
        => Ok(await _context.PlayerStats.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<PlayerStat>> Get(int id)
    {
        var item = await _context.PlayerStats.FindAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpGet("player/{playerId}")]
    public async Task<ActionResult<IEnumerable<PlayerStat>>> GetByPlayer(int playerId)
        => Ok(await _context.PlayerStats.Where(x => x.PlayerId == playerId).ToListAsync());

    [HttpPost]
    public async Task<ActionResult<PlayerStat>> Create(PlayerStat stat)
    {
        _context.PlayerStats.Add(stat);
        await _context.SaveChangesAsync();
        return Ok(stat);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.PlayerStats.FindAsync(id);
        if (item == null) return NotFound();
        _context.PlayerStats.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
