USE OlistDW; -- Remplacez par le nom de votre base de données si différent
GO
/**
-- ÉTAPE 1 : Supprimer les anciennes contraintes (si elles existent) pour éviter les erreurs
PRINT '--- Suppression des contraintes FK existantes sur FactOrderItems ---';
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimDate' AND parent_object_id = OBJECT_ID('dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimDate;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimProduct' AND parent_object_id = OBJECT_ID('dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimProduct;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimLocalisation' AND parent_object_id = OBJECT_ID('dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimLocalisation;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimPaymentType' AND parent_object_id = OBJECT_ID('dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimPaymentType;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimOrderStatus' AND parent_object_id = OBJECT_ID('dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimOrderStatus;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_FactOrderItems_DimReview' AND parent_object_id = OBJECT_ID('dbo.FactOrderItems'))
    ALTER TABLE dbo.FactOrderItems DROP CONSTRAINT FK_FactOrderItems_DimReview;
GO
*/

ALTER TABLE dbo.FactOrderItems WITH CHECK -- Vérifie les données existantes
ADD CONSTRAINT FK_FactOrderItems_DimDate FOREIGN KEY (DateKey)
REFERENCES dbo.DimDate(DateKey);
PRINT 'Contrainte FK_FactOrderItems_DimDate ajoutée.';

-- Contrainte vers DimProduct
ALTER TABLE dbo.FactOrderItems WITH CHECK
ADD CONSTRAINT FK_FactOrderItems_DimProduct FOREIGN KEY (ProductID)
REFERENCES dbo.DimProduct(ProductID);
PRINT 'Contrainte FK_FactOrderItems_DimProduct ajoutée.';

-- Contrainte vers DimLocalisation
ALTER TABLE dbo.FactOrderItems WITH CHECK
ADD CONSTRAINT FK_FactOrderItems_DimLocalisation FOREIGN KEY (LocationKey)
REFERENCES dbo.DimLocalisation(LocationKey);
PRINT 'Contrainte FK_FactOrderItems_DimLocalisation ajoutée.';

-- Contrainte vers DimPaymentType
ALTER TABLE dbo.FactOrderItems WITH CHECK
ADD CONSTRAINT FK_FactOrderItems_DimPaymentType FOREIGN KEY (PaymentTypeKey)
REFERENCES dbo.DimPaymentType(PaymentTypeKey);
PRINT 'Contrainte FK_FactOrderItems_DimPaymentType ajoutée.';

-- Contrainte vers DimOrderStatus
ALTER TABLE dbo.FactOrderItems WITH CHECK
ADD CONSTRAINT FK_FactOrderItems_DimOrderStatus FOREIGN KEY (OrderStatusKey)
REFERENCES dbo.DimOrderStatus(OrderStatusKey);
PRINT 'Contrainte FK_FactOrderItems_DimOrderStatus ajoutée.';

-- Contrainte vers DimReview (la nouvelle)
ALTER TABLE dbo.FactOrderItems WITH CHECK
ADD CONSTRAINT FK_FactOrderItems_DimReview FOREIGN KEY (ReviewKey)
REFERENCES dbo.DimReview(ReviewKey);
PRINT 'Contrainte FK_FactOrderItems_DimReview ajoutée.';
GO
