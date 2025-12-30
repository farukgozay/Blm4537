using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;

[ApiController]
[Route("api/[controller]")]
public class ArenasController : ControllerBase
{
    private readonly DataContext _context;
    public ArenasController(DataContext context) { _context = context; }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Arena>>> GetAll()
        => Ok(await _context.Arenas.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<Arena>> Get(int id)
    {
        var item = await _context.Arenas.FindAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost]
    public async Task<ActionResult<Arena>> Create(Arena arena)
    {
        _context.Arenas.Add(arena);
        await _context.SaveChangesAsync();
        return Ok(arena);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.Arenas.FindAsync(id);
        if (item == null) return NotFound();
        _context.Arenas.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
