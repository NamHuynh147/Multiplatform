-- Chạy file này trong SQL Server Management Studio (SSMS)
IF DB_ID(N'StudentDb') IS NULL CREATE DATABASE StudentDb;
GO
USE StudentDb;
GO

IF OBJECT_ID(N'dbo.Students') IS NULL
CREATE TABLE dbo.Students (
    MaSV      NVARCHAR(20)  NOT NULL PRIMARY KEY,
    HoTen     NVARCHAR(100) NOT NULL,
    AnhBase64 NVARCHAR(MAX) NULL
);
GO

IF OBJECT_ID(N'dbo.Subjects') IS NULL
CREATE TABLE dbo.Subjects (
    MaMon  NVARCHAR(20)  NOT NULL PRIMARY KEY,
    TenMon NVARCHAR(100) NOT NULL,
    CoSo   NVARCHAR(100) NOT NULL
);
GO

-- Dữ liệu mẫu
INSERT INTO dbo.Subjects (MaMon, TenMon, CoSo) VALUES
 (N'FLT01', N'Lập trình Flutter', N'Cơ sở Lê Văn Sỹ');
GO
