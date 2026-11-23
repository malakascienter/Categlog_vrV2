
CREATE PROCEDURE Calculate_ResNetValFor_Fiscal
	@ChargeTypeID INT,
	@DefaultPercentage DECIMAL(18,6),
	@Name VARCHAR(30),
	@DisplayName VARCHAR(30),
	@FiscalNo INT,
	@PropertyId INT
AS
BEGIN
	SET NOCOUNT ON;

	IF OBJECT_ID('tempdb..#TempGroupHeader') IS NOT NULL
    BEGIN
    DROP TABLE #TempGroupHeader
    END   

	CREATE TABLE #TempGroupHeader
	(
		GroupHeaderId INT NOT NULL,

	)

	INSERT INTO #TempGroupHeader(GroupHeaderId) 
	SELECT ChargeHeaderID FROM Gen_ChargeGroupDetail WHERE ChargeTypeID = @ChargeTypeID GROUP BY  ChargeHeaderID



	WHILE EXISTS( SELECT * FROM #TempGroupHeader )
	BEGIN
		DECLARE @GroupHeaderId INT
		DECLARE @ChargeTypeSequence INT
		DECLARE @TotalActualPercentage DECIMAL(18,6)
		DECLARE @ActualPercentage DECIMAL(18,6)

		SELECT TOP(1) @GroupHeaderId = GroupHeaderId  FROM #TempGroupHeader
		SELECT @ChargeTypeSequence = ChargeTypeSequence FROM Gen_ChargeGroupDetail WHERE ChargeTypeID = @ChargeTypeID AND ChargeHeaderID = @GroupHeaderId


			IF EXISTS( SELECT * FROM Gen_ChargeGroupDetail WHERE ChargeTypeSequence < @ChargeTypeSequence AND ChargeHeaderID = @GroupHeaderId )
			BEGIN

				 SELECT @TotalActualPercentage = SUM(ActualPercentage) FROM Gen_ChargeGroupDetail WHERE ChargeTypeSequence < @ChargeTypeSequence AND ChargeHeaderID = @GroupHeaderId 
				 SET @ActualPercentage = (@TotalActualPercentage + 1)*@DefaultPercentage/100

				 UPDATE Gen_ChargeGroupDetail
				 SET ActualPercentage = @ActualPercentage
				 WHERE ChargeTypeID = @ChargeTypeID AND ChargeHeaderID = @GroupHeaderId

			END
			ELSE
			BEGIN

				 SET @ActualPercentage = @DefaultPercentage/100

				 UPDATE Gen_ChargeGroupDetail
				 SET ActualPercentage = @ActualPercentage
				 WHERE ChargeTypeID = @ChargeTypeID AND ChargeHeaderID = @GroupHeaderId

			END

			UPDATE Gen_ChargeGroupHeader
			SET ResNetVal = ISNULL((SELECT SUM(ActualPercentage) FROM Gen_ChargeGroupDetail WHERE ChargeHeaderID = @GroupHeaderId ),0)+1--,
				--Name = @Name
			WHERE ChargeHeaderID = @GroupHeaderId

			UPDATE Gen_ItemChargeGroupHeader
			SET ItemChargeHeaderName = @DisplayName
			WHERE ItemChargeHeaderID = @ChargeTypeID

			EXEC Insert_Sync_MasterDataTransferStatus 'Tax',1,@GroupHeaderId,@PropertyId

			DELETE TOP(1) FROM #TempGroupHeader


	END



END

GO

