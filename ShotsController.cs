
using Microsoft.AspNetCore.Mvc;
using ShotForge.Api.Data;
using ShotForge.Api.Models;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using CsvHelper;
using CsvHelper.Configuration;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;

[ApiController]
[Route("api/[controller]")]
public class ShotsController : ControllerBase
{
    private readonly DataContext _context;

    public ShotsController(DataContext context)
    {
        _context = context;
    }

    // BİR OYUNCUYA AİT TÜM ŞUTLARI GETİR
    [HttpGet("player/{playerId}")]
    public async Task<ActionResult<IEnumerable<Shot>>> GetShotsForPlayer(int playerId)
    {
        var shots = await _context.Shots.Where(s => s.PlayerId == playerId).ToListAsync();
        return Ok(shots);
    }

    // --- VERİ YÜKLEME VE İŞLEME SİHRİ ---
    [HttpPost("upload/{playerId}")]
    public async Task<IActionResult> UploadShots(int playerId, IFormFile file)
    {
        if (file == null || file.Length == 0)
            return BadRequest("Dosya yüklenmedi.");

        // Oyuncu var mı diye kontrol et
        var player = await _context.Players.FindAsync(playerId);
        if (player == null)
            return NotFound("Oyuncu bulunamadı.");

        var shots = new List<Shot>();

        // CsvHelper konfigürasyonu
        var config = new CsvConfiguration(CultureInfo.InvariantCulture)
        {
            // CSV'de başlık satırı var
            HasHeaderRecord = true,
            // CSV'deki kolon adları ile modeldeki property adları eşleşmiyorsa
            // veya küçük/büyük harf farkı varsa bunu kullan
            PrepareHeaderForMatch = args => args.Header.ToLower(),
        };

        using (var reader = new StreamReader(file.OpenReadStream()))
        using (var csv = new CsvReader(reader, config))
        {
            // CSV'deki satırları oku ve Shot objelerine dönüştür
            var records = csv.GetRecords<dynamic>().ToList();

            foreach (var record in records)
            {
                var shot = new Shot
                {
                    PlayerId = playerId,
                    GameId = Convert.ToInt32(record.game_id),
                    X = Convert.ToDouble(record.x),
                    Y = Convert.ToDouble(record.y),
                    Made = Convert.ToBoolean(Convert.ToInt16(record.made)), // 1'i true, 0'ı false'a çevir
                    ShotType = record.shot_type,
                    Period = Convert.ToInt32(record.period),
                    Clock = record.clock
                };
                shots.Add(shot);
            }
        }

        // Toplu halde veritabanına ekle (Çok daha hızlı)
        await _context.Shots.AddRangeAsync(shots);
        await _context.SaveChangesAsync();

        return Ok(new { message = $"{shots.Count} adet şut başarıyla eklendi." });
    }
}