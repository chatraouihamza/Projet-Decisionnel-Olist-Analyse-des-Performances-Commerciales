--CREATE DATABASE OlistDW;
--GO
USE OlistDW; 
GO


/**
-- 1. DimDate (Mensuelle)
CREATE TABLE dbo.DimDate (
    DateKey INT PRIMARY KEY,         -- = id (Format AAAAMM)
    -- FullDate DATE NOT NULL,       -- Plus strictement nécessaire si on agrège au mois, mais UTILE pour ETL
    Mois TINYINT NOT NULL,           -- = mois
    Annee SMALLINT NOT NULL          -- = year
);
PRINT 'Table DimDate (Mensuelle) créée.';



-- 2. DimLocalisation (Inchangée, toujours basée sur ZipCodePrefix)
CREATE TABLE dbo.DimLocalisation (
    ZipCodePrefix NVARCHAR(10) PRIMARY KEY,
    City NVARCHAR(100),
    State NVARCHAR(10)
);
PRINT 'Table DimLocalisation créée.';

-- 3. DimProduct (Inchangée)
CREATE TABLE dbo.DimProduct (
    ProductID NVARCHAR(50) PRIMARY KEY,
    ProductName NVARCHAR(100),
    ProductWeightGrams INT,
    ProductLengthCM INT,
    ProductHeightCM INT,
    ProductWidthCM INT
);
PRINT 'Table DimProduct créée.';

-- 4. DimCustomer --> SUPPRIMÉE

-- 5. DimSeller --> SUPPRIMÉE

-- 6. DimOrderStatus (Inchangée)
CREATE TABLE dbo.DimOrderStatus (
    OrderStatusKey INT IDENTITY(1,1) PRIMARY KEY,
    Description NVARCHAR(50) NOT NULL,
    CONSTRAINT UQ_DimOrderStatus_Description UNIQUE (Description)
);
PRINT 'Table DimOrderStatus créée.';

-- 7. DimPaymentType (Inchangée)
CREATE TABLE dbo.DimPaymentType (
    PaymentTypeKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentType NVARCHAR(50) NOT NULL,
    CONSTRAINT UQ_DimPaymentType_PaymentType UNIQUE (PaymentType)
);
PRINT 'Table DimPaymentType créée.';



CREATE TABLE dbo.FactOrderItems (
    FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,

    -- Clés étrangères (POINTENT VERS LES PK des Dimensions restantes + Localisation)
    DateKey INT NOT NULL,                   -- -> DimDate.DateKey
    ProductID NVARCHAR(50) NOT NULL,        -- -> DimProduct.ProductID
    LocationZipCodePrefix NVARCHAR(10) NOT NULL, -- -> DimLocalisation.ZipCodePrefix (NOUVEAU LIEN)
    PaymentTypeKey INT NOT NULL,            -- -> DimPaymentType.PaymentTypeKey
    OrderStatusKey INT NOT NULL,            -- -> DimOrderStatus.OrderStatusKey

    -- Mesures
    Quantity INT NOT NULL,
    ItemPrice DECIMAL(10, 2),
    ItemFreightValue DECIMAL(10, 2),
    ReviewScore INT NULL

    -- Pas de contraintes FK définies ici pour le moment
);
PRINT 'Table FactOrderItems créée (version LocationFocus).';



-- Staging_OrderInfo reste utile et inchangée structurellement
CREATE TABLE dbo.Staging_OrderInfo (
    OrderID NVARCHAR(50) PRIMARY KEY,
    CustomerZipCodePrefix NVARCHAR(10) NULL,
    OrderPurchaseTimestamp DATETIME2(3) NULL, -- On garde le timestamp complet ici
    OrderStatus NVARCHAR(50) NULL,
    PrimaryPaymentType NVARCHAR(50) NULL,
    FirstReviewScore INT NULL
);
PRINT 'Table Staging_OrderInfo créée.';



###################################################################"
-- Vider la table avant de la remplir
TRUNCATE TABLE dbo.DimDate;

-- Script pour peupler DimDate au mois
DECLARE @StartDate DATE = '2016-01-01'; -- Début de la période
DECLARE @EndDate DATE = '2018-12-31';   -- Fin de la période

DECLARE @CurrentMonth DATE = DATEADD(month, DATEDIFF(month, 0, @StartDate), 0); -- Premier jour du premier mois

WHILE @CurrentMonth <= @EndDate
BEGIN
    INSERT INTO dbo.DimDate (
        DateKey,
        Mois,
        Annee
        --,FullDate -- Optionnel: Insérer le 1er jour du mois si vous voulez garder une colonne DATE
    )
    SELECT
        (YEAR(@CurrentMonth) * 100) + MONTH(@CurrentMonth), -- AAAAMM
        MONTH(@CurrentMonth),
        YEAR(@CurrentMonth)
        --,@CurrentMonth -- Optionnel: Insérer le 1er jour du mois
        ;

    -- Passer au premier jour du mois suivant
    SET @CurrentMonth = DATEADD(MONTH, 1, @CurrentMonth);
END;
GO
PRINT 'Table DimDate (Mensuelle) peuplée.';

*/



--SELECT * FROM [OlistDW].[dbo].[DimOrderStatus];
--SELECT * FROM [OlistDW].[dbo].[DimPaymentType];
--SELECT * FROM [OlistDW].[dbo].[Staging_OrderInfo];
SELECT * FROM [OlistDW].[dbo].[FactOrderItems];
--SELECT * FROM [OlistDW].[dbo].[DimLocalisation]
/**
DROP TABLE dbo.FactOrderItems;


CREATE TABLE dbo.FactOrderItems (
    FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT NOT NULL,
    ProductID NVARCHAR(50) NOT NULL,
    LocationZipCodePrefix NVARCHAR(10) NOT NULL,
    PaymentTypeKey INT NOT NULL,
    OrderStatusKey INT NOT NULL,
    Quantity INT NOT NULL,
    ItemPrice NVARCHAR(50) NULL,         -- << MODIFIÉ EN NVARCHAR
    ItemFreightValue NVARCHAR(50) NULL,  -- << MODIFIÉ EN NVARCHAR
    ReviewScore INT NULL,

    CONSTRAINT FK_FactOrderItems_DimDate FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey),
    CONSTRAINT FK_FactOrderItems_DimProduct FOREIGN KEY (ProductID) REFERENCES dbo.DimProduct(ProductID),
    CONSTRAINT FK_FactOrderItems_DimLocalisation FOREIGN KEY (LocationZipCodePrefix) REFERENCES dbo.DimLocalisation(ZipCodePrefix),
    CONSTRAINT FK_FactOrderItems_DimPaymentType FOREIGN KEY (PaymentTypeKey) REFERENCES dbo.DimPaymentType(PaymentTypeKey),
    CONSTRAINT FK_FactOrderItems_DimOrderStatus FOREIGN KEY (OrderStatusKey) REFERENCES dbo.DimOrderStatus(OrderStatusKey)
);
PRINT 'Table FactOrderItems recréée avec ItemPrice et ItemFreightValue en NVARCHAR.';
*/
/**
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimLocalisation')
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimLocalisation;

-- Supprimer l'ancienne colonne si elle existe
IF EXISTS (SELECT * FROM sys.columns WHERE Name = N'LocationZipCodePrefix' AND Object_ID = Object_ID(N'dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP COLUMN LocationZipCodePrefix;

DROP TABLE [OlistDW].[dbo].[DimLocalisation]
CREATE TABLE dbo.DimLocalisation (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY, -- Clé de substitution auto-incrémentée
    City NVARCHAR(100),
    State NVARCHAR(10),
    CONSTRAINT UQ_DimLocalisation_CityState UNIQUE (City, State) -- Garantit l'unicité de la paire
);
PRINT 'Table DimLocalisation recréée avec LocationKey.';
*/
-- Insérer une ligne pour les localisations inconnues/non applicables


/**
IF OBJECT_ID('dbo.Staging_OrderInfo', 'U') IS NOT NULL
    DROP TABLE dbo.Staging_OrderInfo;
GO
CREATE TABLE dbo.Staging_OrderInfo (
    OrderID NVARCHAR(50) PRIMARY KEY,
    CustomerCity NVARCHAR(100) NULL,    -- << MODIFIÉ
    CustomerState NVARCHAR(10) NULL,     -- << MODIFIÉ
    OrderPurchaseTimestamp DATETIME2(3) NULL,
    OrderStatus NVARCHAR(50) NULL,
    PrimaryPaymentType NVARCHAR(50) NULL,
    FirstReviewScore INT NULL
);
PRINT 'Table Staging_OrderInfo recréée avec CustomerCity et CustomerState.';
*/
/**
-- Supprimer l'ancienne contrainte FK si elle existe (adaptez le nom si besoin)
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimLocalisation')
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimLocalisation;

-- Supprimer l'ancienne colonne si elle existe
IF EXISTS (SELECT * FROM sys.columns WHERE Name = N'LocationZipCodePrefix' AND Object_ID = Object_ID(N'dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP COLUMN LocationZipCodePrefix;

-- Ajouter la nouvelle colonne pour la clé de substitution
ALTER TABLE dbo.FactOrderItems ADD LocationKey INT NULL; -- Mettre NULL pour l'instant, on ajoutera NOT NULL et FK après chargement

PRINT 'Colonne LocationZipCodePrefix remplacée par LocationKey INT dans FactOrderItems.';
*/
/**
ALTER TABLE dbo.Staging_OrderInfo
ALTER COLUMN CustomerState NVARCHAR(50) NULL
ALTER TABLE dbo.Staging_OrderInfo
ALTER COLUMN CustomerCity NVARCHAR(50) NULL;
*/
/**

ALTER TABLE dbo.FactOrderItems
ADD CONSTRAINT FK_FactOrderItems_DimDate FOREIGN KEY (DateKey) REFERENCES dbo.DimDate(DateKey);

ALTER TABLE dbo.FactOrderItems
ADD CONSTRAINT FK_FactOrderItems_DimProduct FOREIGN KEY (ProductID) REFERENCES dbo.DimProduct(ProductID);

ALTER TABLE dbo.FactOrderItems
ADD CONSTRAINT FK_FactOrderItems_DimLocalisation FOREIGN KEY (LocationZipCodePrefix) REFERENCES dbo.DimLocalisation(ZipCodePrefix);

ALTER TABLE dbo.FactOrderItems
ADD CONSTRAINT FK_FactOrderItems_DimPaymentType FOREIGN KEY (PaymentTypeKey) REFERENCES dbo.DimPaymentType(PaymentTypeKey);

ALTER TABLE dbo.FactOrderItems
ADD CONSTRAINT FK_FactOrderItems_DimOrderStatus FOREIGN KEY (OrderStatusKey) REFERENCES dbo.DimOrderStatus(OrderStatusKey);

PRINT 'Contraintes FOREIGN KEY ajoutées à FactOrderItems.';
*/








/**
IF OBJECT_ID('dbo.FactOrderItems', 'U') IS NOT NULL
    DROP TABLE dbo.FactOrderItems;
GO

-- Créer la table FactOrderItems avec la nouvelle structure
CREATE TABLE dbo.FactOrderItems (
    FactKey BIGINT IDENTITY(1,1) PRIMARY KEY,   -- Clé de substitution pour la ligne de fait elle-même

    -- Clés étrangères vers les dimensions
    DateKey INT NOT NULL,                       -- Réfère à DimDate.DateKey (AAAAMM)
    ProductID NVARCHAR(50) NOT NULL,            -- Réfère à DimProduct.ProductID
    LocationKey INT NOT NULL,                   -- Réfère à DimLocalisation.LocationKey (NOUVELLE CLÉ)
    PaymentTypeKey INT NOT NULL,                -- Réfère à DimPaymentType.PaymentTypeKey
    OrderStatusKey INT NOT NULL,                -- Réfère à DimOrderStatus.OrderStatusKey

    -- Mesures
    Quantity INT NOT NULL,
    ItemPrice NVARCHAR(50) NULL,                -- Stocké en texte, sera converti dans Power BI
    ItemFreightValue NVARCHAR(50) NULL,         -- Stocké en texte, sera converti dans Power BI
    ReviewScore INT NULL                        -- Peut être NULL si pas d'avis

    -- Les contraintes FOREIGN KEY seront ajoutées après le chargement ou à la fin du package maître SSIS
);
PRINT 'Table FactOrderItems créée avec la colonne LocationKey INT.';

*/