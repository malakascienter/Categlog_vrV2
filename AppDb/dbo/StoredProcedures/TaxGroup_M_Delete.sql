

-- =============================================
-- Author:		YASIRU
-- Create date: 30/10/2018
-- Description:	Delete Tax Group
-- =============================================
CREATE PROCEDURE [dbo].[TaxGroup_M_Delete] 
@ChargeHeaderID INT,
@PropertyId INT
AS
BEGIN 
	SET NOCOUNT OFF; 
	IF EXISTS(SELECT * FROM   MainMenu AS A WHERE   EXISTS (SELECT 1 FROM   Gen_ChargeGroupHeader  AS B 
	          INNER JOIN Gen_ChargeGroupDetail as TG on TG.ChargeHeaderID = B.ChargeHeaderID 
			  WHERE  A.ChargeGroupId = B.ChargeHeaderID AND TG.PropertyId=@PropertyId))
	BEGIN
	RAISERROR ('Error!, Record already used in Tax Group Details or Main Menu',16,1  );
	END
	ELSE
	BEGIN
		DELETE FROM [Gen_ChargeGroupHeader] WHERE ChargeHeaderID = @ChargeHeaderID AND PropertyId=@PropertyId
	END
END

GO

