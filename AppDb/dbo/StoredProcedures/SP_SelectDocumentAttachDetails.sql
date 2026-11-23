-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2024-09-13
-- Description:	Get Document details for attach view
-- [dbo].[SP_SelectDocumentAttachDetails] 10680,3


-- =============================================
CREATE PROCEDURE [dbo].[SP_SelectDocumentAttachDetails]
@HeaderID INT,
@TransactionType INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @IsAttchmentFound BIT,@ApprovalHeaderID INT,
	 @DocNo VARCHAR(MAX)

	IF EXISTS(SELECT 1 FROM DocumentWiseAttachments WHERE DocId =@HeaderID AND DocTypeID = @TransactionType)
	BEGIN
		SET @IsAttchmentFound =1
	END
	ELSE
	BEGIN
		SET @IsAttchmentFound =0
	END

	IF(@TransactionType = 2)
	BEGIN
		SELECT PH.Id,'PO' Code,2 TransactionID,'Purchase Order' TransactionName,PH.LocationID,LO.Name LocationName,PH.PoNo DocumentNo,@IsAttchmentFound IsAttchmentFound
		FROM PoHeaders PH
		INNER JOIN Locations LO ON PH.LocationID = LO.Id
		WHERE PH.ID = @HeaderID

	END

	IF(@TransactionType = 3)
	BEGIN

		IF EXISTS(SELECT 1 FROM GRNApprovalLog WHERE StockTransactionHeaderID = @HeaderID AND TransactionType = 'GR')
		BEGIN
			SELECT @ApprovalHeaderID = Id ,@DocNo = ApprovalDocNo
			FROM GRNApprovalLog WHERE StockTransactionHeaderID = @HeaderID AND TransactionType = 'GR'

			IF EXISTS(SELECT 1 FROM DocumentWiseAttachments WHERE DocId IN (SELECT ID FROM GRNApprovalLog WHERE ApprovalDocNo = @DocNo AND TransactionType = 'GR')
			AND DocTypeID = 65)
			BEGIN
				SET @IsAttchmentFound =1

			END
			ELSE
			BEGIN
				SET @IsAttchmentFound =0

			END

			SELECT top(1)GA.Id,TR.Code,65 TransactionID,TR.Name TransactionName,GA.LocationId,LO.Name LocationName,GA.ApprovalDocNo DocumentNo,@IsAttchmentFound IsAttchmentFound
			FROM GRNApprovalLog GA
			INNER JOIN TransactionTypes TR ON GA.TransactionType = TR.Code
			INNER JOIN Locations LO ON LO.Id = GA.LocationID
			WHERE StockTransactionHeaderID = @HeaderID

		END
		ELSE
		BEGIN

		IF EXISTS(SELECT 1 FROM DocumentWiseAttachments WHERE DocId =@HeaderID AND DocTypeID = 3)
		BEGIN
			SET @IsAttchmentFound =1
		END
		ELSE
		BEGIN
			SET @IsAttchmentFound =0

		END
			SELECT SH.Id,TR.Code,SH.TransactionID,TR.Name TransactionName,SH.LocationID,LO.Name LocationName,SH.DocumentNo,@IsAttchmentFound IsAttchmentFound
			FROM StockTransactionHeaders SH 
			INNER JOIN TransactionTypes TR ON SH.TransactionType = TR.Code
			INNER JOIN Locations LO ON LO.Id = SH.LocationID
			WHERE SH.ID = @HeaderID
			AND TR.Id = @TransactionType
		END	
	END
END

GO

