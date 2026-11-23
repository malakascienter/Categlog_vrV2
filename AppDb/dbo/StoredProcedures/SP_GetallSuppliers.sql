-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
--[dbo].[SP_GetallSuppliers]  2
--go
CREATE PROCEDURE [dbo].[SP_GetallSuppliers] 
	-- Add the parameters for the stored procedure here
	
	@PropertyID INT

AS
BEGIN
	DECLARE @IsSupplierForAllProperty BIT

	SELECT @IsSupplierForAllProperty = [IsSupplierForAllProperty] FROM Companies WHERE CompanyID = @PropertyID

	IF(@IsSupplierForAllProperty = 1 OR @IsSupplierForAllProperty IS NULL ) 
	BEGIN
		SELECT * FROM dbo.Suppliers WHERE PropertyID = 0
	END
	ELSE
		SELECT * FROM dbo.Suppliers WHERE PropertyID=@PropertyID ORDER BY NAME asc
END

GO

