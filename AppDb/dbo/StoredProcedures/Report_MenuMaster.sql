
CREATE PROCEDURE [dbo].[Report_MenuMaster]
	 @Outlet    VARCHAR(5),
	 @PropertyId INT

AS
BEGIN
	
	SET NOCOUNT ON;
	
	SELECT M.ItemCode,'' AS ReferenceNo,M.FullName,C.Description AS Category,
	(SELECT TOP 1 FullName FROM MainMenu WHERE ItemCode =M.PreviousMenuCode AND PropertyId=@PropertyId ) AS PreviousMenuItem,
	(SELECT TOP 1 Name FROM ItemCategory WHERE Id = M.ItemCategory AND PropertyId = @PropertyId )  AS Mealtype,
	(SELECT TOP 1 Name FROM POSItemTypes WHERE Code = M.ItemType   AND PropertyId = @PropertyId  ) AS ItemType,
	0 AS Price,
	CASE WHEN M.Active = 1 THEN 'YES'
	ELSE 'NO' END AS Active,	
	CASE WHEN M.IsMainPage = 1 THEN 'YES'
	ELSE 'NO' END AS MainPage,
	(
				SELECT TOP 1		PS.Name AS 'Printer' 
				FROM		ItemWisePrinters AS IP 
				INNER JOIN	printersetup as ps ON ps.Code=IP.PrinterCode 
				WHERE		MainMenuCode=M.ItemCode AND IP.PropertyId=@PropertyId 
				
			)AS Printer
	FROM MainMenu M INNER JOIN POS_OutletWiseMenuItems P ON M.ItemCode = P.MenuCode AND M.PropertyId = P.PropertyId
	INNER	JOIN Category C ON C.Code = M.Category  AND C.PropertyId=M.PropertyId
	WHERE P.OutletCode  IN (SELECT * FROM STRING_SPLIT(@Outlet,','))  AND M.PropertyId=@PropertyId AND P.PropertyId = @PropertyId AND C.PropertyId = @PropertyId

END

GO

