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
    }
}