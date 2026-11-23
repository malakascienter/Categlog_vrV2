--=======================--
--Last Modified by		: Nivesh
--Last Modified Date	: 2025-11-04
--=======================--
CREATE PROCEDURE [dbo].[SP_GetDocumentsUploads] 
	@DocId INT,
	@DocType INT
AS
BEGIN

	DECLARE @DocNo VARCHAR(100)
	SELECT  @DocNo = ApprovalDocNo 
	FROM GRNApprovalLog 
	WHERE id = @DocId

	IF(@DocType = 3) -- GRN
	BEGIN
		SELECT DISTINCT  
			DWA.* 
		FROM 
		[dbo].[DocumentWiseAttachments] DWA
		WHERE DWA.DocId=@DocId 
		OR DWA.DocId IN (
			SELECT ID 
			FROM GRNApprovalLog 
			WHERE ApprovalDocNo =@DocNo 
			AND ID <> @DocId
		)
		AND DWA.DocTypeID=@DocType
	END
	ELSE IF (@DocType = 65)
	BEGIN
		SELECT DISTINCT DWA.* 
		FROM [dbo].[DocumentWiseAttachments] DWA
		WHERE DocTypeID = 65
		AND DocId IN (SELECT ID
		FROM GRNApprovalLog
		WHERE ApprovalDocNo = @DocNo
		AND TransactionType = 'GR')
	END
	ELSE
	BEGIN
		SELECT  DWA.* 
		FROM 
		[dbo].[DocumentWiseAttachments] DWA
		WHERE DWA.DocId=@DocId 
	END
END

GO

