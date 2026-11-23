-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2025-07-08
-- Description:	Day End Validation Check SP

-- [dbo].[sp_DayEnd_ValidateSP] 1,'MRB','2026-05-15'

-- =============================================
CREATE PROCEDURE [dbo].[sp_DayEnd_ValidateSP]
	@PropertyID INT,
	@OutletCode varchar(5),
	@TxnDate DATE
AS
BEGIN TRY
	BEGIN TRANSACTION
	SET NOCOUNT ON;

	DECLARE @IsLocationWiseDayendEnable BIT,@DayEndValidationMode CHAR(4),@LocationID INT,@ValidationProcessCode CHAR(1),@IsReconMandatory BIT,@DayEndItemTempId INT
	
	DECLARE @IsValidProcess BIT = 0;

	SELECT @ValidationProcessCode = ISNULL(ValidationProcessCode,'X'),@IsReconMandatory = ISNULL(IsReconMandatory,0)
	FROM DayEnd_Validation_Settings
	WHERE CompanyID = @PropertyID


	SET @IsValidProcess = 0;
	-- Day End 
	IF (@ValidationProcessCode = 'D')
	BEGIN
		SET @IsValidProcess = 1;
	END

	-- Month End 
	ELSE IF (@ValidationProcessCode = 'M')
	BEGIN
		IF (@TxnDate = EOMONTH(@TxnDate))
			SET @IsValidProcess = 1;
	END

	-- Year End 
	ELSE IF (@ValidationProcessCode = 'Y')
	BEGIN
		IF (MONTH(@TxnDate) = 12 AND DAY(@TxnDate) = 31)
			SET @IsValidProcess = 1;
	END
	
	SELECT @LocationID = StockLocationID
	FROM Location_Ref
	WHERE CODE = @OutletCode

	SELECT @IsLocationWiseDayendEnable =IsLocationWiseDayendEnable
	FROM COMPANIES
	WHERE CompanyID =@PropertyID



	IF(@IsValidProcess = 1)
	BEGIN
		IF(@IsLocationWiseDayendEnable = 1)
		BEGIN

			SELECT @DayEndValidationMode = DayEndValidationMode, @DayEndItemTempId = ISNULL(DayEndItemTempId,0)
			FROM Locations
			WHERE ID = @LocationID

			

			IF(@DayEndValidationMode = 'OU')
			BEGIN
				---Checking pending Transfer In 
					--IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS WHERE TRANSACTIONTYPE='TO' AND PropertyID =@PropertyID AND IsTrasferIn=0 
					--AND TransferLocationID =  @LocationID AND TRANSACTIONDATE = @TxnDate)
				IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS AS S1
				LEFT JOIN RequestHeaders RH ON RH.Id = S1.ReferenceID
				WHERE TRANSACTIONTYPE='TO' AND s1.PropertyID =@PropertyID 
				AND IsTrasferIn=0 AND s1.TransferLocationID =  @LocationID 
				AND @TxnDate = CASE WHEN RH.Id IS NULL THEN S1.TransactionDate ELSE CONVERT( DATE,RH.DeliveryDate) END)
					BEGIN
						RAISERROR ( 'Pending Transfer In Found for Selected Location', 16, 1 );  
						ROLLBACK TRANSACTION
					END
				--End

				-- New Validation
			

				  IF (@DayEndItemTempId >0 AND @IsReconMandatory = 1)
					IF EXISTS(
						SELECT 1
						FROM RequestTemplateDetails
						WHERE TemplateHeaderID = @DayEndItemTempId
						AND StockItemHeaderID NOT IN (
							SELECT STD.StockItemID
							FROM StockTransactionHeaders SH
							INNER JOIN StockTransactionDetails STD ON SH.ID = STD.StockTransactionHeaderID
							WHERE SH.LocationID = @LocationID
							AND SH.TransactionDate = @TxnDate
							AND SH.PropertyID = @PropertyID
							AND SH.TransactionType = 'AA'
						)
					)
					BEGIN
						DECLARE @ItemName NVARCHAR(MAX);
						SELECT @ItemName = STRING_AGG(ItemName, ', ')
						FROM (
							SELECT DISTINCT SH.Name AS ItemName
							FROM RequestTemplateDetails RD
							INNER JOIN StockItemHeaders SH 
								ON RD.StockItemHeaderID = SH.Id
							WHERE RD.TemplateHeaderID = @DayEndItemTempId
							AND RD.StockItemHeaderID NOT IN (
								SELECT STD.StockItemID
								FROM StockTransactionHeaders H
								INNER JOIN StockTransactionDetails STD 
									ON H.ID = STD.StockTransactionHeaderID
								WHERE H.LocationID = @LocationID
								AND H.TransactionDate = @TxnDate
								AND H.PropertyID = @PropertyID
								AND H.TransactionType = 'AA'
							)
						) AS x;
					
						DECLARE @ErrorMsg NVARCHAR(MAX);
						SET @ErrorMsg = 'Reconcilation Mandatory Items  for selected location: ' + ISNULL(@ItemName, 'Unknown items');
						RAISERROR (@ErrorMsg, 16, 1);
						ROLLBACK TRANSACTION
					END
				-- End
			
			END

			IF(@DayEndValidationMode = 'ST')
			BEGIN
				---Checking pending Transfer In 

					IF EXISTS (SELECT 1 FROM STOCKTRANSACTIONHEADERS WHERE TRANSACTIONTYPE='TO'AND PropertyID =@PropertyID AND IsTrasferIn=0 AND TransferLocationID =  @LocationID  AND TRANSACTIONDATE = @TxnDate)
					BEGIN
						RAISERROR ( 'Pending Transfer In Found for Selected Location', 16, 1 );  
						ROLLBACK TRANSACTION
					END
				--End

				--Checking Pending Transfer Request
				   IF EXISTS(SELECT 1 FROM RequestHeaders WHERE IsApproved = 1 AND PropertyID = @PropertyID AND LocationID = @LocationID AND DeliveryDate = @TxnDate AND DocumentStatus='P' AND RequestType = 'RT')
				   BEGIN
			   		RAISERROR ( 'Pending Transfer Request In Found for Selected Location', 16, 1 );  
						ROLLBACK TRANSACTION
				   END
				--End
			END
		END
	END

	
	COMMIT TRANSACTION

END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
DECLARE @ErrorMessage NVARCHAR(4000);  
	DECLARE @ErrorSeverity INT;  
	DECLARE @ErrorState INT;  

	SELECT   
    @ErrorMessage = ERROR_MESSAGE(),  
    @ErrorSeverity = ERROR_SEVERITY(),  
    @ErrorState = ERROR_STATE(); 
	RAISERROR (@ErrorMessage,@ErrorSeverity,@ErrorState);

END CATCH

GO

