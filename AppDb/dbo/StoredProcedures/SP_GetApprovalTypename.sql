CREATE PROCEDURE [dbo].[SP_GetApprovalTypename] ( @TxnType INT, @TxnHeaderId INT, @ApprovalTypename VARCHAR(200) OUT, @DocStatus CHAR(1) OUT )

AS
BEGIN

	DECLARE @LevelId  INT,  @Status CHAR(1)=''

		SELECT at.ApprovalTypeName , al.DocStatus, al.ApprovalLevelID INTO #TempApproval
		FROM dbo.ApprovalLogs al
		INNER JOIN dbo.ApprovalTypes at ON al.ApprovalLevelID = at.Id
		WHERE al.TransactionHeaderID = @TxnHeaderId AND TransactionID =  @TxnType 

		--SELECT * FROM #TempApproval


		IF EXISTS(SELECT 1 FROM #TempApproval WHERE DocStatus = 'C')
		BEGIN
		  
			SELECT TOP(1) @ApprovalTypename = at.ApprovalTypeName , @DocStatus  = al.DocStatus, @LevelId = al.ApprovalLevelID
			FROM dbo.ApprovalLogs al
			INNER JOIN dbo.ApprovalTypes at ON al.ApprovalLevelID = at.Id
			WHERE al.TransactionHeaderID = @TxnHeaderId AND TransactionID =   @TxnType   
			AND al.DocStatus = 'P'
			ORDER BY SeqID ASC
			--SELECT @DocStatus '1111'
		END
		IF EXISTS(SELECT 1 FROM #TempApproval WHERE DocStatus = 'C')
		BEGIN
		  
			SELECT TOP(1) @ApprovalTypename = 'Approved' , @DocStatus  = al.DocStatus, @LevelId = al.ApprovalLevelID
			FROM dbo.ApprovalLogs al
			INNER JOIN dbo.ApprovalTypes at ON al.ApprovalLevelID = at.Id
			WHERE al.TransactionHeaderID = @TxnHeaderId AND TransactionID =   @TxnType   
			AND al.DocStatus = 'C'
			ORDER BY SeqID ASC
			--SELECT @DocStatus '1111'
		END


		IF EXISTS(SELECT 1 FROM #TempApproval WHERE DocStatus = 'X')
		BEGIN
		  
			SELECT TOP(1) @ApprovalTypename = at.ApprovalTypeName , @DocStatus  = al.DocStatus, @LevelId = al.ApprovalLevelID
			FROM dbo.ApprovalLogs al
			INNER JOIN dbo.ApprovalTypes at ON al.ApprovalLevelID = at.Id
			WHERE al.TransactionHeaderID = @TxnHeaderId AND TransactionID =  @TxnType
			AND al.DocStatus = 'X'
			ORDER BY SeqID ASC
			--SELECT @DocStatus '2222'
		END

		ELSE
			BEGIN
			
				SELECT TOP(1) @ApprovalTypename = at.ApprovalTypeName , @DocStatus = al.DocStatus, @LevelId = al.ApprovalLevelID
				FROM dbo.ApprovalLogs al
				INNER JOIN dbo.ApprovalTypes at ON al.ApprovalLevelID = at.Id
				WHERE al.TransactionHeaderID = @TxnHeaderId AND TransactionID =  @TxnType 
				AND al.DocStatus = 'P'
				ORDER BY SeqID ASC
				  --SELECT @DocStatus '33333'
			END

END

GO

