
-- =====================================================
-- PROJE: Musteri Siparis Yonetimi
-- Amac: Musteri ve siparis verilerini yonetmek
-- SQL Server Portfolio Project
-- =====================================================

USE master;
GO

IF DB_ID(N'MusteriSiparisProje') IS NULL
BEGIN
    CREATE DATABASE MusteriSiparisProje;
END;
GO

USE MusteriSiparisProje;
GO

-- 1. MUSTERILER TABLOSU
IF OBJECT_ID(N'dbo.Musteriler', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Musteriler (
        MusteriID INT PRIMARY KEY,
        Ad NVARCHAR(50) NOT NULL,
        Soyad NVARCHAR(50) NOT NULL,
        Eposta NVARCHAR(100) NOT NULL,
        Sehir NVARCHAR(50) NOT NULL,
        CONSTRAINT UQ_Musteriler_Eposta UNIQUE (Eposta)
    );
END;
GO

-- 2. SIPARISLER TABLOSU
IF OBJECT_ID(N'dbo.Siparisler', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Siparisler (
        SiparisID INT PRIMARY KEY,
        MusteriID INT NOT NULL,
        UrunAdi NVARCHAR(100) NOT NULL,
        Tutar DECIMAL(10,2) NOT NULL,
        CONSTRAINT FK_Siparisler_Musteriler
            FOREIGN KEY (MusteriID)
            REFERENCES dbo.Musteriler(MusteriID),
        CONSTRAINT CK_Siparisler_Tutar
            CHECK (Tutar >= 0)
    );
END;
GO

-- 3. ORNEK MUSTERI VERILERI
IF NOT EXISTS (SELECT 1 FROM dbo.Musteriler)
BEGIN
    INSERT INTO dbo.Musteriler
        (MusteriID, Ad, Soyad, Eposta, Sehir)
    VALUES
        (1, N'Ayþe', N'Yýlmaz', 'ayse@example.com', N'Ýzmir'),
        (2, N'Mehmet', N'Demir', 'mehmet@example.com', N'Ankara'),
        (3, N'Zeynep', N'Kaya', 'zeynep@example.com', N'Ýstanbul'),
        (4, N'Elif', N'Çelik', 'elif@example.com', N'Ýzmir');
END;
GO

-- 4. ORNEK SIPARIS VERILERI
IF NOT EXISTS (SELECT 1 FROM dbo.Siparisler)
BEGIN
    INSERT INTO dbo.Siparisler
        (SiparisID, MusteriID, UrunAdi, Tutar)
    VALUES
        (1, 1, N'Klavye', 750.00),
        (2, 1, N'Monitör', 4500.00),
        (3, 1, N'Web Kamera', 900.00),
        (4, 2, N'Fare', 350.00),
        (5, 3, N'Kulaklýk', 1200.00),
        (6, 4, N'USB Bellek', 250.00);
END;
GO

-- 5. INDEKS
IF NOT EXISTS (
    SELECT 1
    FROM sys.indexes
    WHERE name = N'IX_Siparisler_MusteriID'
      AND object_id = OBJECT_ID(N'dbo.Siparisler')
)
BEGIN
    CREATE INDEX IX_Siparisler_MusteriID
    ON dbo.Siparisler(MusteriID);
END;
GO

-- 6. VIEW: 1000 TL VE UZERI SIPARISLER
CREATE OR ALTER VIEW dbo.vw_MusteriSiparisleri
AS
SELECT
    M.MusteriID,
    M.Ad,
    M.Soyad,
    S.UrunAdi,
    S.Tutar
FROM dbo.Musteriler AS M
INNER JOIN dbo.Siparisler AS S
    ON M.MusteriID = S.MusteriID
WHERE S.Tutar >= 1000;
GO

-- 7. STORED PROCEDURE: MUSTERI HARCAMA RAPORU
CREATE OR ALTER PROCEDURE dbo.sp_MusteriHarcamaRaporu
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        M.MusteriID,
        M.Ad,
        M.Soyad,
        COUNT(S.SiparisID) AS SiparisSayisi,
        ISNULL(SUM(S.Tutar), 0) AS ToplamHarcama
    FROM dbo.Musteriler AS M
    LEFT JOIN dbo.Siparisler AS S
        ON M.MusteriID = S.MusteriID
    GROUP BY
        M.MusteriID,
        M.Ad,
        M.Soyad
    ORDER BY ToplamHarcama DESC;
END;
GO

-- 8. RAPORU CALISTIR
EXEC dbo.sp_MusteriHarcamaRaporu;
GO

-- 9. VIEW SONUCLARI
SELECT *
FROM dbo.vw_MusteriSiparisleri;
GO

-- 10. GENEL SATIS ISTATISTIKLERI
SELECT
    COUNT(*) AS ToplamSiparisSayisi,
    SUM(Tutar) AS ToplamSatisTutari,
    AVG(Tutar) AS OrtalamaSiparisTutari
FROM dbo.Siparisler;
GO

-- 11. TABLOLARI KONTROL ET
SELECT * FROM dbo.Musteriler;
SELECT * FROM dbo.Siparisler;
GO



