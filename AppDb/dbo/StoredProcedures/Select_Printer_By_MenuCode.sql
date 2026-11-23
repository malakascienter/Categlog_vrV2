-- =============================================
-- Author:		Chiraj
-- Create date: 2018-11-1
-- Description:	Select printer by menu item
-- =============================================
CREATE PROCEDURE [dbo].[Select_Printer_By_MenuCode] 
	@MainMenuCode VARCHAR(4),
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT LTRIM(RTRIM(ITP.PrinterCode)) AS Code,PS.Name FROM 
	ItemWisePrinters AS ITP 
	INNER JOIN  PrinterSetup  AS PS ON ITP.PrinterCode=PS.Code   AND PS.PropertyId=ITP.PropertyId
	WHERE 
	ITP.MainMenuCode=@MainMenuCode AND ITP.PropertyId=@PropertyId
END

GO

