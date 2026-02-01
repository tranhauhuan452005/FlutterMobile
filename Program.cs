using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using PCM.Backend.Data;
using PCM.Backend.Services;
using PCM.Backend.Hubs;
using PCM.Backend.BackgroundServices;

var builder = WebApplication.CreateBuilder(args);

// Add Entity Framework
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
Console.WriteLine($"[DEBUG] Database Connection String: {connectionString}");

if (string.IsNullOrEmpty(connectionString) || connectionString.Contains("server", StringComparison.OrdinalIgnoreCase))
{
    Console.WriteLine("[WARNING] Invalid connection string detected. Falling back to local SQLite file.");
    connectionString = "Data Source=PCMBackend.db";
}

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlite(connectionString));

// Add Identity
builder.Services.AddIdentity<IdentityUser, IdentityRole>(options =>
{
    options.Password.RequireDigit = true;
    options.Password.RequiredLength = 6;
    options.Password.RequireNonAlphanumeric = false;
    options.Password.RequireUppercase = false;
    options.Password.RequireLowercase = false;
    options.User.RequireUniqueEmail = true;
})
.AddEntityFrameworkStores<ApplicationDbContext>()
.AddDefaultTokenProviders();

// Add JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidAudience = builder.Configuration["Jwt:Audience"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["Jwt:Key"]!))
    };
});

// Add Services
builder.Services.AddScoped<IBookingService, BookingService>();
builder.Services.AddScoped<INotificationService, NotificationService>();
builder.Services.AddScoped<ITournamentService, TournamentService>();
builder.Services.AddScoped<IMembershipService, MembershipService>();
builder.Services.AddScoped<IWalletService, WalletService>();
builder.Services.AddScoped<MatchUpdateService>();

// Add Background Services
builder.Services.AddHostedService<BookingCleanupService>();

// Add SignalR
builder.Services.AddSignalR();

builder.Services.AddControllers();

// Enable CORS for mobile app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowMobileApp", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseCors("AllowMobileApp");

app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();
app.MapHub<NotificationHub>("/notificationHub");

// Seed data
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    var userManager = scope.ServiceProvider.GetRequiredService<UserManager<IdentityUser>>();
    var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
    
    // Ensure database is created
    await context.Database.EnsureCreatedAsync();
    
    // Just create basic roles for now
    string[] roles = { "Admin", "Treasurer", "Referee", "Member" };
    foreach (var role in roles)
    {
        if (!await roleManager.RoleExistsAsync(role))
        {
            await roleManager.CreateAsync(new IdentityRole(role));
        }
    }
    
    // Create admin user if not exists
    var adminUser = await userManager.FindByEmailAsync("admin@pcm311.com");
    if (adminUser == null)
    {
        adminUser = new IdentityUser
        {
            UserName = "admin@pcm311.com",
            Email = "admin@pcm311.com",
            EmailConfirmed = true
        };

        await userManager.CreateAsync(adminUser, "Admin@123");
        await userManager.AddToRoleAsync(adminUser, "Admin");
    }
    
    // Create corresponding Member311 record if not exists
    var adminMember = await context.Members.FirstOrDefaultAsync(m => m.Email == "admin@pcm311.com");
    if (adminMember == null)
    {
        adminMember = new PCM.Backend.Entities.Member311
        {
            FullName = "Admin PCM",
            Email = "admin@pcm311.com",
            PhoneNumber = "0123456789",
            DateOfBirth = new DateTime(1990, 1, 1),
            UserId = adminUser.Id,
            JoinDate = DateTime.UtcNow,
            RankLevel = 5.0,
            Status = PCM.Backend.Entities.MemberStatus.Active,
            Tier = PCM.Backend.Entities.MemberTier.Diamond,
            WalletBalance = 10000000,
            TotalSpent = 0,
            Points = 2000,
            MembershipTierId = null,
            CreatedAt = DateTime.UtcNow
        };
        
        context.Members.Add(adminMember);
        await context.SaveChangesAsync();
    }
}

app.Run();

