using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;

[ApiController]
[Route("api/[controller]")]
public class SeasonsController : ControllerBase
{
    private readonly DataContext _context;
    public SeasonsController(DataContext context) { _context = context; }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Season>>> GetAll()
        => Ok(await _context.Seasons.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<Season>> Get(int id)
    {
        var item = await _context.Seasons.FindAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost]
    public async Task<ActionResult<Season>> Create(Season season)
    {
        _context.Seasons.Add(season);
        await _context.SaveChangesAsync();
        return Ok(season);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.Seasons.FindAsync(id);
        if (item == null) return NotFound();
        _context.Seasons.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
