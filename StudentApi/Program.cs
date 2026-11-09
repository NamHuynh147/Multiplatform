using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Cho phép app nhận request ảnh base64 lớn
builder.WebHost.ConfigureKestrel(o => o.Limits.MaxRequestBodySize = 50 * 1024 * 1024);
builder.Services.AddDbContext<AppDb>(o =>
    o.UseSqlServer(builder.Configuration.GetConnectionString("Default")));
builder.Services.AddCors(o => o.AddDefaultPolicy(p => p.AllowAnyOrigin().AllowAnyHeader().AllowAnyMethod()));

var app = builder.Build();
app.UseCors();

// ---------- SINH VIÊN ----------
app.MapGet("/api/students", async (AppDb db) => await db.Students.OrderBy(s => s.MaSV).ToListAsync());

// Thêm mới hoặc cập nhật (upsert)
app.MapPost("/api/students", async (AppDb db, Student s) =>
{
    var old = await db.Students.FindAsync(s.MaSV);
    if (old == null) db.Students.Add(s);
    else { old.HoTen = s.HoTen; old.AnhBase64 = s.AnhBase64 ?? old.AnhBase64; }
    await db.SaveChangesAsync();
    return Results.Ok(s);
});

// Nhập danh sách nhiều sinh viên một lần
app.MapPost("/api/students/bulk", async (AppDb db, List<Student> list) =>
{
    foreach (var s in list)
    {
        var old = await db.Students.FindAsync(s.MaSV);
        if (old == null) db.Students.Add(s);
        else old.HoTen = s.HoTen;
    }
    await db.SaveChangesAsync();
    return Results.Ok(new { count = list.Count });
});

app.MapDelete("/api/students/{id}", async (AppDb db, string id) =>
{
    var s = await db.Students.FindAsync(id);
    if (s == null) return Results.NotFound();
    db.Students.Remove(s);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

// ---------- MÔN HỌC ----------
app.MapGet("/api/subjects", async (AppDb db) => await db.Subjects.OrderBy(s => s.MaMon).ToListAsync());

app.MapPost("/api/subjects", async (AppDb db, Subject s) =>
{
    var old = await db.Subjects.FindAsync(s.MaMon);
    if (old == null) db.Subjects.Add(s);
    else { old.TenMon = s.TenMon; old.CoSo = s.CoSo; }
    await db.SaveChangesAsync();
    return Results.Ok(s);
});

app.MapDelete("/api/subjects/{id}", async (AppDb db, string id) =>
{
    var s = await db.Subjects.FindAsync(id);
    if (s == null) return Results.NotFound();
    db.Subjects.Remove(s);
    await db.SaveChangesAsync();
    return Results.NoContent();
});

app.Run("http://0.0.0.0:5000");

// ---------- MODELS + DbContext ----------
public class Student
{
    public string MaSV { get; set; } = "";
    public string HoTen { get; set; } = "";
    public string? AnhBase64 { get; set; }
}

public class Subject
{
    public string MaMon { get; set; } = "";
    public string TenMon { get; set; } = "";
    public string CoSo { get; set; } = "";
}

public class AppDb : DbContext
{
    public AppDb(DbContextOptions<AppDb> o) : base(o) { }
    public DbSet<Student> Students => Set<Student>();
    public DbSet<Subject> Subjects => Set<Subject>();

    protected override void OnModelCreating(ModelBuilder b)
    {
        b.Entity<Student>().ToTable("Students").HasKey(x => x.MaSV);
        b.Entity<Subject>().ToTable("Subjects").HasKey(x => x.MaMon);
    }
}
