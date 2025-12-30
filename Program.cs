using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using ShotForge.Api.Data;
using ShotForge.Api.Models;
using Swashbuckle.AspNetCore.Filters;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// 1. DB
builder.Services.AddDbContext<DataContext>(options =>
{
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection"));
});

// 2. CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowReactApp", policy =>
    {
        policy.WithOrigins("http://localhost:3000")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// 3. AUTH
builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(
                    "bu_benim_cok_gizli_anahtarim_artik_cok_daha_uzun_ve_guvenli_en_az_64_karakter_olmali_ki_hata_vermesin_123456789"
                )
            ),
            ValidateIssuer = false,
            ValidateAudience = false
        };
    });

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(options =>
{
    options.AddSecurityDefinition("oauth2", new OpenApiSecurityScheme
    {
        Description = "Authorization: Bearer {token}",
        In = ParameterLocation.Header,
        Name = "Authorization",
        Type = SecuritySchemeType.ApiKey
    });
    options.OperationFilter<SecurityRequirementsOperationFilter>();
});

var app = builder.Build();


// =====================
// DB SEED
// =====================
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<DataContext>();
    context.Database.EnsureCreated();

    var random = new Random();

    // --- OYUNCULAR ---
    if (!context.Players.Any())
    {
        context.Players.AddRange(
            new Player
            {
                Name = "LeBron James",
                Team = "Lakers",
                Position = "SF",
                ImageUrl = "https://cdn.nba.com/headshots/nba/latest/1040x760/2544.png",

                Rebounds = random.Next(7, 13),
                Assists = random.Next(8, 12),
                Fouls = random.Next(1, 4),

                TwoPtAttempted = random.Next(48, 52),
                TwoPtMade = random.Next(15, 35),

                ThreePtAttempted = random.Next(40, 60),
                ThreePtMade = random.Next(15, 35),

                FtAttempted = random.Next(4, 9),
                FtMade = random.Next(2, 8)
            },
            new Player
            {
                Name = "Stephen Curry",
                Team = "Warriors",
                Position = "PG",
                ImageUrl = "https://cdn.nba.com/headshots/nba/latest/1040x760/201939.png",

                Rebounds = random.Next(7, 13),
                Assists = random.Next(8, 12),
                Fouls = random.Next(1, 4),

                TwoPtAttempted = random.Next(48, 52),
                TwoPtMade = random.Next(15, 35),

                ThreePtAttempted = random.Next(40, 60),
                ThreePtMade = random.Next(15, 35),

                FtAttempted = random.Next(4, 9),
                FtMade = random.Next(2, 8)
            },
            new Player
            {
                Name = "Nikola Jokic",
                Team = "Nuggets",
                Position = "C",
                ImageUrl = "https://cdn.nba.com/headshots/nba/latest/1040x760/203999.png",

                Rebounds = random.Next(7, 13),
                Assists = random.Next(8, 12),
                Fouls = random.Next(1, 4),

                TwoPtAttempted = random.Next(48, 52),
                TwoPtMade = random.Next(15, 35),

                ThreePtAttempted = random.Next(40, 60),
                ThreePtMade = random.Next(15, 35),

                FtAttempted = random.Next(4, 9),
                FtMade = random.Next(2, 8)
            },
            new Player
            {
                Name = "Kevin Durant",
                Team = "Suns",
                Position = "PF",
                ImageUrl = "https://cdn.nba.com/headshots/nba/latest/1040x760/201142.png",

                Rebounds = random.Next(7, 13),
                Assists = random.Next(8, 12),
                Fouls = random.Next(1, 4),

                TwoPtAttempted = random.Next(48, 52),
                TwoPtMade = random.Next(15, 35),

                ThreePtAttempted = random.Next(40, 60),
                ThreePtMade = random.Next(15, 35),

                FtAttempted = random.Next(4, 9),
                FtMade = random.Next(2, 8)
            }
        );

        context.SaveChanges();
    }

    // --- ŞUTLAR ---
    var players = context.Players.ToList();

    foreach (var player in players)
    {
        if (!context.Shots.Any(s => s.PlayerId == player.Id))
        {
            for (int i = 0; i < 100; i++)
            {
                context.Shots.Add(new Shot
                {
                    PlayerId = player.Id,
                    GameId = 1,
                    X = (random.NextDouble() * 48) - 24,
                    Y = random.NextDouble() * 35,
                    Made = random.NextDouble() > 0.5,
                    ShotType = "Jump Shot",
                    Period = random.Next(1, 5),
                    Clock = "10:00"
                });
            }
        }
    }

    context.SaveChanges();




    // ✅ TEAMS seed
if (!context.Teams.Any())
{
    context.Teams.AddRange(
        new Team { Name = "Lakers" },
        new Team { Name = "Warriors" },
        new Team { Name = "Nuggets" },
        new Team { Name = "Suns" }
    );
    context.SaveChanges();
}

// ✅ Players -> TeamId eşle (opsiyonel, front kırmaz)
var teams = context.Teams.ToList();
var allPlayers = context.Players.ToList();
bool updated = false;
foreach (var p in allPlayers)
{
    if (p.TeamId == null)
    {
        var t = teams.FirstOrDefault(x => x.Name == p.Team);
        if (t != null)
        {
            p.TeamId = t.Id;
            updated = true;
        }
    }
}
if (updated) context.SaveChanges();

// ✅ SEASON seed
if (!context.Seasons.Any())
{
    context.Seasons.Add(new Season { Name = "2024-25" });
    context.SaveChanges();
}
var season = context.Seasons.First();

// ✅ GAMES seed
if (!context.Games.Any())
{
    context.Games.AddRange(
        new Game { SeasonId = season.Id, Date = DateTime.UtcNow.AddDays(-3), HomeTeamName = "Lakers", AwayTeamName = "Warriors" },
        new Game { SeasonId = season.Id, Date = DateTime.UtcNow.AddDays(-1), HomeTeamName = "Nuggets", AwayTeamName = "Suns" }
    );
    context.SaveChanges();
}

var games = context.Games.ToList();
var rnd = new Random();





}

    




// =====================
// PIPELINE
// =====================
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowReactApp");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();
app.Run();
