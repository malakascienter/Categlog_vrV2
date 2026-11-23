-- =============================================
-- Author:		Chiraj
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[ExecutiveMember_M_Delete]
	@Id INT,
	@UserId INT,
	@PropertyId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @UniqueId BIGINT
	SELECT @UniqueId =  Id FROM POS_ExecutiveMember WHERE MemberID=@Id AND PropertyId=@propertyId
	-- Audit trail ----------------------------		
	EXEC HotelResWeb_AuditTail_WriteToLog 'POS_ExecutiveMember',@UniqueId,'POS','POSEMD','D',@UserId,'','','','','',@PropertyId
	-- End of Audit trail ---------------------

   DELETE FROM POS_ExecutiveMember WHERE MemberID=@Id AND PropertyId=@PropertyId
END

GO

