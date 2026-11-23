-- =============================================
-- Author:		<iSURU SRIMAL>
-- Create date: <2022/04/28>
-- Description:	FOR SSRS PRINTS
-- [dbo].[Sp_GetDocumentWiseRptFileNames] 2,4
-- =============================================
CREATE PROCEDURE [dbo].[Sp_GetDocumentWiseRptFileNames] 
@Id INT,
@PropertyID INT
AS
BEGIN

		-- Adedd by Isuru for loading PropertyWise different Print Copies 2024-03-15
		IF EXISTS(SELECT 1 FROM DocumentWiseRptFileName WHERE [TxnTypeId] = @Id AND PropertyID = @PropertyID)
		BEGIN 
			SELECT [RptFilename] AS RptFilename
			FROM [dbo].[DocumentWiseRptFileName]
			WHERE [TxnTypeId] = @Id AND PropertyID = @PropertyID
		END
		ELSE
		BEGIN
			SELECT TOP(1)[RptFilename] AS RptFilename
			FROM [dbo].[DocumentWiseRptFileName]
			WHERE [TxnTypeId] = @Id
		END

END

GO

