var builder = WebApplication.CreateBuilder(args);

// Configure to run on port 5001
builder.WebHost.UseUrls("http://localhost:5001");

builder.Services.AddControllers();

// Enable CORS for mobile app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowMobileApp", policy =>
    {
        policy.WithOrigins("http://localhost:8080", "http://localhost:3000", "https://localhost:3001") 
              .AllowAnyMethod()
              .AllowAnyHeader()
              .AllowCredentials();
    });
});

var app = builder.Build();

app.UseCors("AllowMobileApp");

app.UseAuthorization();

app.MapControllers();

app.Run();