using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;

[ApiController]
[Route("api/[controller]")]
public class GamesController : ControllerBase
{
    private readonly DataContext _context;
    public GamesController(DataContext context) { _context = context; }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Game>>> GetAll()
        => Ok(await _context.Games.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<Game>> Get(int id)
    {
        var item = await _context.Games.FindAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost]
    public async Task<ActionResult<Game>> Create(Game game)
    {
        _context.Games.Add(game);
        await _context.SaveChangesAsync();
        return Ok(game);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.Games.FindAsync(id);
        if (item == null) return NotFound();
        _context.Games.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
