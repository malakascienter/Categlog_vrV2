CREATE PROCEDURE [dbo].[Sync_spInsertKOTBOT]
@PropertyId INT,
@KotBotNo VARCHAR(10),
@OrderDate DATETIME,
@OutletID VARCHAR(3),
@KotXml VARCHAR(MAX)

AS
SET DATEFORMAT DMY
DECLARE @tKottXmlXml XML


SET @tKottXmlXml =  REPLACE(@KotXml,'encoding="utf-8"','encoding="ISO-8859-9"') 

DELETE FROM POS_KotBot WHERE KotBotNo = @KotBotNo AND OrderDate = @OrderDate AND OutletID = @OutletID AND PropertyId = @PropertyId

INSERT INTO POS_KotBot
		(PropertyId, KotBotNo, KotBotDateTime, OrderNo, OrderDate, OrderType, TableID, WaiterID, OutletID, PrinterCode, 
		MenuItemID, KOTName, KOTQuantity, VoidQuantity, ItemSequence, SortSeq, IsVoid, VoidDateTime, 
        AuthorizedUser, SysDate, IsServe, ServeTime)

SELECT	@PropertyId,
		KotBot.element.value('@KotBotNo','VARCHAR(10)'), 
		CONVERT(DATETIME,KotBot.element.value('@KotBotDateTime','VARCHAR(30)'),103),
		KotBot.element.value('@OrderNo','VARCHAR(10)'), 
		CONVERT(DATETIME,KotBot.element.value('@OrderDate','VARCHAR(30)'),103),
		KotBot.element.value('@OrderType','VARCHAR(1)'), 
		KotBot.element.value('@TableID','INT'), 
		KotBot.element.value('@WaiterID','VARCHAR(10)'), 
		KotBot.element.value('@OutletID','VARCHAR(10)'), 
		KotBot.element.value('@PrinterCode','VARCHAR(2)'), 
		KotBot.element.value('@MenuItemID','VARCHAR(10)'), 
		KotBot.element.value('@KOTName','VARCHAR(250)'), 
		KotBot.element.value('@KOTQuantity','MONEY'), 
		KotBot.element.value('@VoidQuantity','MONEY'), 
		KotBot.element.value('@ItemSequence','INT'), 
		KotBot.element.value('@SortSeq','INT'), 
		KotBot.element.value('@IsVoid','BIT'), 
		CONVERT(DATETIME,KotBot.element.value('@VoidDateTime','VARCHAR(30)'),103),
		KotBot.element.value('@AuthorizedUser','VARCHAR(20)'), 
		CONVERT(DATETIME,KotBot.element.value('@SysDate','VARCHAR(30)'),103),
		KotBot.element.value('@IsServe','BIT'), 
		CONVERT(DATETIME,KotBot.element.value('@ServeTime','VARCHAR(30)'),103)
FROM	@tKottXmlXml.nodes('/root/KotBot/KotBot') AS KotBot(element)

GO

