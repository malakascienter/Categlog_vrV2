
CREATE PROCEDURE [dbo].[Report_MenuMasterWisePrinter]
	 @PropertyId INT

AS
BEGIN
	
	SET NOCOUNT ON;
	
	select itemcode,Description,ItemWisePrinters.PrinterCode,PrinterSetup.Name  AS PrinterName
	from MainMenu inner join ItemWisePrinters
	on mainmenu.itemcode=ItemWisePrinters.MainMenuCode inner join PrinterSetup
	on ItemWisePrinters.PrinterCode = PrinterSetup.Code
	WHERE MainMenu.PropertyId = @PropertyId

END

GO

