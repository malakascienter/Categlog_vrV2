-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-05-20
-- Description:	Checking availability for sending supplier PO report

-- [dbo].[SP_SelectFullyUpdatePOs] 24

-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectFullyUpdatePOs]
	@PoheaderID INT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PropertyID INT,@IsSupplierNotification BIT,@CompanyName VARCHAR(MAX),@LocationID INT,@EmailCC VARCHAR(MAX)

	SELECT @PropertyID = PropertyID,@LocationID = LocationID FROM PoHeaders WHERE ID = @PoheaderID

	SELECT  @IsSupplierNotification = IsSupplierNotification,@CompanyName = Name FROM Companies WHERE CompanyID = @PropertyID

SELECT @EmailCC =STUFF((
    SELECT ',' + CU.Email
    FROM TransactionWiseEmails TR
    INNER JOIN CentralUsers CU ON TR.UserID = CU.Id
    WHERE TransactionType = 'PS'
	AND TR.LocationID = @LocationID
    FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '');


	IF(@IsSupplierNotification = 1)
	BEGIN
		IF EXISTS(SELECT 1 FROM PoHeaders WHERE ID = @PoheaderID AND IsApproved=1)
		BEGIN
		SELECT 'TRUE' Result,'RptPrintPO_SupplierMail' ReportName,SU.Name SupplierName,@PoheaderID PoheaderID,SU.Email SupplierEmail,PH.PropertyID,PH.PoNo DocumentNo
		,CONVERT(varchar,CONVERT(date,PH.DocumentDate)) DocumentDate,@CompanyName CompanyName,'Dear '+su.Name+','+' Please find attached document for Purchase Order. Doc No: '+ph.PoNo+'.' MailBody
		,ISNULL(@EmailCC,'') EmailCC
		FROM PoHeaders PH
		INNER JOIN Suppliers SU ON PH.SupplierID = SU.ID
		WHERE PH.ID = @PoheaderID
		END
		ELSE
		BEGIN
		SELECT 'FALSE' Result,'' ReportName,'' SupplierName,0  PoheaderID,'' SupplierEmail,0 PropertyID,'' DocumentNo,'' DocumentDate,'' CompanyName,'' EmailCC
		END
	END
	ELSE
	BEGIN
		SELECT 'FALSE' Result,'' ReportName,'' SupplierName,0  PoheaderID,'' SupplierEmail,0 PropertyID,'' DocumentNo,'' DocumentDate,'' CompanyName,'' EmailCC
	END
	

    

END

GO

