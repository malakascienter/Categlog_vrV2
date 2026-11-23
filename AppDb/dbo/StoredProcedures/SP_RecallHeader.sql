CREATE PROCEDURE [dbo].[SP_RecallHeader]   
	@headerID int
AS
BEGIN
-----------------------------------------------------------------------------------------
BEGIN TRY 

DECLARE @PropertyId INT, @IsCentralLogin BIT

SELECT @PropertyId = PropertyId FROM RequestHeaders WHERE Id = @headerID
SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID = @PropertyId  


IF(@IsCentralLogin = 1)
BEGIN
	
	SELECT L.Name AS LocationName, D.Name AS DepartmentName, convert(varchar(max),'' ) TransferLocationName, RH.DocumentNo, RH.RequestDate, RH.Id ,RH.RequestType, U.UserName AS RequestedUser ,
			CASE RH.RequestType
				 WHEN 'RP' THEN 'PR Number'
				 WHEN 'RI' THEN 'Issue Request No'
				 WHEN 'RD' THEN 'DR Number'
				 WHEN 'RT' THEN 'TO Number'
				 WHEN 'MR' THEN 'MR Number'
			 END
			 AS DocumentType, RH.TransferLocation
	INTO #TempDataCentral
	FROM dbo.RequestHeaders AS RH
	INNER  JOIN dbo.Locations AS L ON RH.LocationID = L.Id
	Left Outer JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	
	INNER JOIN [dbo].[CentralUsers]  AS U ON RH.UserProfileID = U.Id
	INNER JOIN TransactionTypes TT ON TT.Code =RH.RequestType
	WHERE RH.Id = @headerID
		
	IF OBJECT_ID('tempdb..##TempDataCentral') IS NOT NULL
	BEGIN
		UPDATE #TempDataCentral
		SET TransferLocationName = (SELECT NAME FROM Locations l where l.id =TransferLocation )
		WHERE RequestType='RT'
	END 

	SELECT * FROM #TempDataCentral
	
END
ELSE
BEGIN
	
	SELECT L.Name AS LocationName, D.Name AS DepartmentName, convert(varchar(max),'' ) TransferLocationName, RH.DocumentNo, RH.RequestDate, RH.Id ,RH.RequestType, U.UserName AS RequestedUser ,
			CASE RH.RequestType
				 WHEN 'RP' THEN 'PR Number'
				 WHEN 'RI' THEN 'Issue Request No'
				 WHEN 'RD' THEN 'DR Number'
				 WHEN 'RT' THEN 'TO Number'
				 WHEN 'MR' THEN 'MR Number'
			 END
			 AS DocumentType, RH.TransferLocation
	INTO #TempData
	FROM dbo.RequestHeaders AS RH
	INNER  JOIN dbo.Locations AS L ON RH.LocationID = L.Id
	Left Outer JOIN dbo.Departments AS D ON RH.DepartmentID = D.Id
	
	INNER JOIN dbo.UserMasters AS U ON RH.UserProfileID = U.Id
	INNER JOIN TransactionTypes TT ON TT.Code =RH.RequestType
	WHERE RH.Id = @headerID
	
		
	IF OBJECT_ID('tempdb..#TempData') IS NOT NULL
	BEGIN
		UPDATE #TempData
		SET TransferLocationName = (SELECT NAME FROM Locations l where l.id =TransferLocation )
		WHERE RequestType='RT'
	END 

	SELECT * FROM #TempData
	
END

	
END TRY
BEGIN CATCH
	IF @@TRANCOUNT>0
		DECLARE @ErrorMessage NVARCHAR(4000);  
		DECLARE @ErrorSeverity INT;  
		DECLARE @ErrorState INT;  

		SELECT   
		@ErrorMessage = ERROR_MESSAGE(),  
		@ErrorSeverity = ERROR_SEVERITY(),  
		@ErrorState = ERROR_STATE(); 
		RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);
END CATCH;
-----------------------------------------------------------------------------------------
END

GO

