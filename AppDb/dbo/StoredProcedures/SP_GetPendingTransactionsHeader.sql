-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 22 September 2023
-- Description:	Loading Pending Transaction Details
--- [dbo].[SP_GetPendingTransactionsHeader]  1,11,4168,21008
-- =============================================
CREATE PROCEDURE [dbo].[SP_GetPendingTransactionsHeader]  
(
	@CompanyId	INT ,
	@TxnTypeId INT,
	@userProfileId INT,
	@HeaderId INT
)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @IsCentralLogin BIT

	SELECT @IsCentralLogin = IsCentralLogin FROM Companies WHERE CompanyID =  @CompanyId

	DECLARE @UserTempTable TABLE(
	Id INT,
	FirstName NVARCHAR(300)
	)

	IF(@IsCentralLogin = 1)
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id,FullName
		FROM [dbo].[CentralUsers]
	END
	ELSE
	BEGIN
		INSERT INTO @UserTempTable
		SELECT Id, FirstName 
		FROM UserMasters
	END

	
    IF(@TxnTypeId IN(1,8,11,14))  ---RD,RP,RI,RT  Purchase Request, Damage Request Note,Transfer Request,Issue Request
	BEGIN
	SELECT LO.Name Location,RH.DocumentNo,CONVERT(varchar,AP.CreatedDate,3) CreatedDate ,'Pending' DocStatus,US.FirstName,ROUND(SUM(RD.RequestedQuantity* RD.UnitPrice), 2)   ValueOfRequest,
	RH.Id TransactionHeaderID,TR.Name TransactionTypeName,ISNULL(NULL, '-') Supplier,ISNULL(DE.Name,'-') DepartmentName,TR.Id TransactionId
	FROM ApprovalLogs AP
	INNER JOIN RequestHeaders RH ON AP.TransactionHeaderID = RH.Id
	INNER JOIN RequestDetails RD ON RD.RequestHeaderID = RH.Id
	INNER JOIN Locations LO ON LO.Id = RH.LocationID
	LEFT JOIN Departments DE ON DE.Id = RH.DepartmentID
	INNER JOIN @UserTempTable US ON AP.CreatedUserID = US.Id
	INNER JOIN TransactionTypes TR ON TR.Id = AP.TransactionID
	WHERE AP.CreatedUserID = @userProfileId 
	AND AP.TransactionID = @TxnTypeId AND AP.IsComplete =0 
	AND AP.DocStatus='P' AND AP.TransactionID NOT IN (2) AND AP.PropertyID = @CompanyId
	AND RH.Id = @HeaderId
	GROUP BY LO.Name,RH.DocumentNo,AP.CreatedDate,US.FirstName,RH.Id ,TR.Name,DE.Name,TR.Id 
	END

	IF(@TxnTypeId = 2) -- PO Purchase Order
	BEGIN
	SELECT LO.Name Location,PH.PoNo DocumentNo, CONVERT(varchar,AP.CreatedDate,3) CreatedDate,'Pending' DocStatus,US.FirstName,ROUND(SUM(PD.RequestedQuantity * PD.UnitPrice),2) ValueOfRequest,
	PH.Id TransactionHeaderID, TR.Name TransactionTypeName,ISNULL(SU.Name, '-')  Supplier,ISNULL(null,'-') DepartmentName,TR.Id TransactionId
	FROM ApprovalLogs AP
	INNER JOIN PoHeaders PH ON PH.Id = AP.TransactionHeaderID
	INNER JOIN PoDetails PD ON PD.PoHeaderID =PH.Id
	INNER JOIN Locations LO ON LO.Id = PH.LocationID
	INNER JOIN @UserTempTable US ON US.Id = AP.CreatedUserID
	INNER JOIN TransactionTypes TR ON TR.Id = AP.TransactionID
	INNER JOIN Suppliers SU ON SU.ID = PH.SupplierID
	WHERE AP.CreatedUserID = @userProfileId AND AP.TransactionID = @TxnTypeId AND AP.IsComplete =0 AND AP.DocStatus='P' AND AP.PropertyID = @CompanyId
	AND PH.Id = @HeaderId
	GROUP BY LO.Name,PH.PoNo,AP.CreatedDate,US.FirstName,PH.Id ,TR.Name,SU.Name,TR.Id 
	END

	IF(@TxnTypeId IN (3,4,5,6,7,9,10,12,13,15,20,68)) --Transactions in Stocktransactionheaders
	BEGIN

	SELECT LO.Name Location,GP.ApprovalDocNo DocumentNo, CONVERT(varchar,GP.CreatedDate,3) CreatedDate ,'Pending' DocStatus,US.FirstName,0 ValueOfRequest,
	GP.Id TransactionHeaderID, TR.Name TransactionTypeName,ISNULL(SU.Name, '-')  Supplier,ISNULL(null,'-') DepartmentName,TR.Id TransactionId
	FROM GRNApprovalLog GP
	INNER JOIN Locations LO ON LO.Id = GP.LocationId
	INNER JOIN @UserTempTable US ON US.Id = GP.CreatedUserId
	INNER JOIN TransactionTypes TR ON TR.Code = GP.TransactionType
	LEFT JOIN Suppliers SU ON SU.ID = GP.SupplierId
	WHERE GP.CreatedUserId =@userProfileId AND GP.ApprovedUserId IS NULL AND GP.ApprovedDateTime IS NULL AND GP.Status ='P' AND TR.Id = @TxnTypeId
	AND GP.Id = @HeaderId
	END
END

GO

