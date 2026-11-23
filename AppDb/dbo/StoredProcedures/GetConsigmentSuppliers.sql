-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-06-25
-- Description:	Loading only consigments suppliers
-- [dbo].[GetConsigmentSuppliers] 
-- =============================================
CREATE PROCEDURE [dbo].[GetConsigmentSuppliers]
AS
BEGIN
	SET NOCOUNT ON;
	    
		SELECT ID AS id, Name AS text
		FROM Suppliers SU
		WHERE SU.IsConsigments=1
		AND SU.IsActive=1
END

GO

