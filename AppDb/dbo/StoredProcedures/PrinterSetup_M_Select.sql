
-- =============================================
-- Author:		chiraj	
-- Create date: 2018-10-30
-- Description:	Select Printers
-- =============================================
CREATE PROCEDURE [dbo].[PrinterSetup_M_Select]
	@PropertyId INT
AS
BEGIN
	
	SET NOCOUNT ON;
	SELECT  Id
      ,Code
	  ,Printer
      ,Name
      ,Path
      ,TicketNo
      ,PrintTicket
      ,AlternativePrinter,Active,PropertyId
  FROM PrinterSetup WHERE PropertyId=@PropertyId
   
END

GO

