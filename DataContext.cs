using Microsoft.EntityFrameworkCore;
using ShotForge.Api.Models; // Player modelimizin olduğu yer

namespace ShotForge.Api.Data
{
    public class DataContext : DbContext
    {
        public DataContext(DbContextOptions<DataContext> options) : base(options)
        {
        }

        public DbSet<Player> Players { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<Shot> Shots { get; set; } 

        public DbSet<Team> Teams { get; set; }
        public DbSet<Game> Games { get; set; }
        public DbSet<Season> Seasons { get; set; }
        public DbSet<Arena> Arenas { get; set; }
        public DbSet<PlayerStat> PlayerStats { get; set; }

        public DbSet<PlayerGameStat> PlayerGameStats { get; set; }
        public DbSet<UserFavoritePlayer> UserFavoritePlayers { get; set; }
    }
}