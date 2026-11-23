CREATE PROCEDURE [dbo].[SP_GetRecordExitForReconcile]
    (
      @LocationId INT ,
      @StockitemId INT ,
      @Date DATE


    )
AS
    BEGIN
	--IF EXISTS(
	--			SELECT  *
	--			FROM    dbo.StockTransactionHeaders SH
	--					INNER JOIN dbo.StockTransactionDetails SD ON SH.Id = SD.StockTransactionHeaderID
	--			WHERE   SH.LocationID = @LocationId
	--					AND  SH.TransactionDate < @Date 
	--					AND SD.StockItemID = @StockitemId AND TransactionType='AA'
	--		)

	--		BEGIN
	--			SELECT 1
	--		END
                
	--		ELSE 
	--		BEGIN
 --               SELECT 0
	--		END 

	declare @ReconMaxBackDate INT

	SELECT @ReconMaxBackDate = ReconMaxBackDate FROM Companies C
	INNER JOIN Locations L on l.CompanyID = C.CompanyID
	WHERE l.ID= @LocationID

	--SELECT  DATEADD(D,@ReconMaxBackDate*-1, GETDATE()),@DATE

	IF DATEADD(D,@ReconMaxBackDate*-1, GETDATE()) > @DATE
	BEGIN
		SELECT 1
	END 
	ELSE
	BEGIN
		SELECT 0
	END 

    END

GO

