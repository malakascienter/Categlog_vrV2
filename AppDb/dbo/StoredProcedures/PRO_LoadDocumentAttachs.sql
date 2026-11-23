-- =============================================
-- Author:		Isuru Pramodya
-- Create date: 2026-02-09
-- Description:	Loading Document attachments
-- =============================================
create PROCEDURE [dbo].[PRO_LoadDocumentAttachs]
	@HeaderID INT,
	@Opeartion VARCHAR(10),
	@DocTypeID INT,
	@CompanyId INT
AS
BEGIN
	SET NOCOUNT ON;

	IF(@Opeartion = 'R')
	BEGIN
		SELECT  DT.ID, DT.DocId, DT.DocTypeID, DT.FileName, CU.UserName
		, DT.CreatedUserID, CONVERT(VARCHAR,CONVERT(DATE,DT.CreatedDate)) CreatedDate
		, DT.IsActive,DT.DisplayFileName
		FROM     PRO_DocumentAttachments DT
		INNER JOIN CentralUsers CU ON CU.ID = DT.CreatedUserID
		WHERE DT.DocId = @HeaderID
		AND DT.DocTypeID = @DocTypeID
		AND DT.CompanyId = @CompanyId
		ORDER BY DT.ID

	END

   
END

GO

