using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Data;
using ShotForge.Api.Models;

[ApiController]
[Route("api/[controller]")]
public class TeamsController : ControllerBase
{
    private readonly DataContext _context;
    public TeamsController(DataContext context) { _context = context; }

    [HttpGet]
    public async Task<ActionResult<IEnumerable<Team>>> GetAll()
        => Ok(await _context.Teams.ToListAsync());

    [HttpGet("{id}")]
    public async Task<ActionResult<Team>> Get(int id)
    {
        var item = await _context.Teams.FindAsync(id);
        if (item == null) return NotFound();
        return Ok(item);
    }

    [HttpPost]
    public async Task<ActionResult<Team>> Create(Team team)
    {
        _context.Teams.Add(team);
        await _context.SaveChangesAsync();
        return Ok(team);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> Delete(int id)
    {
        var item = await _context.Teams.FindAsync(id);
        if (item == null) return NotFound();
        _context.Teams.Remove(item);
        await _context.SaveChangesAsync();
        return NoContent();
    }
}
