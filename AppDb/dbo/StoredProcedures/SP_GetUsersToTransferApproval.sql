-- =============================================
-- Author:		Vinuki
-- Create date: 20.06.2024
-- Description:	Get users with respect to the given user id and seq id for approval transfering 
-- SP_GetUsersToTransferApproval 1,4168,4,4
-- =============================================
CREATE PROCEDURE SP_GetUsersToTransferApproval (@PropertyID int , @UserID int , @TransactionTypeID int , @LocationID int)

AS
BEGIN
DECLARE @IsCentralLogn BIT 
SELECT @IsCentralLogn = IsCentralLogin FROM Companies WHERE CompanyID = CASE WHEN @PropertyID = -999 THEN CompanyID  ELSE @PropertyID END

CREATE TABLE #tempUserTable(Id INT, UserName NVARCHAR(3000))


IF(@IsCentralLogn = 1)
	BEGIN
		INSERT INTO #tempUserTable
		SELECT Id,Username 
		FROM [dbo].[CentralUsers]
	END
	ELSE 
	BEGIN
		INSERT INTO #tempUserTable
		SELECT Id,Username 
		FROM UserMasters
	END


		select TT.Name as TransactionTypes , At.ApprovalTypeName,
		SeqID,
		UAL.* 
		into #tempData
		from [dbo].[UserWiseApproveLevels] UAL
		INNER JOIN TransactionTypes TT ON UAL.TransactionTypeID = TT.Id
		inner join ApprovalTypes AT on At.Id = ApproveLevelID
		inner join [dbo].[TransactionWiseApprovalTypes] TAL on 
		TAL.TransactionID = UAL.TransactionTypeID AND
		TAL.LocationID = UAL.LocationId AND
		TAL.PropertyID = UAL.PropertyId AND
		TAL.ApprovalTypeID = UAL.ApproveLevelID
		where UAL.PropertyId = @PropertyID
		and UAL.TransactionTypeID = @TransactionTypeID
		and UAL.UserProfileId = @UserID
		and ual.LocationId = @LocationID




		select 
		distinct
		tempUser.Id as UserID , tempUser.UserName 

		from [dbo].[UserWiseApproveLevels] UAL

		
		inner join [dbo].[TransactionWiseApprovalTypes] TAL on 
		TAL.ApprovalTypeID = UAL.ApproveLevelID
		inner join  #tempData tempD on tempD.SeqID = tal.SeqID
		inner join #tempUserTable tempUser on tempUser.Id = ual.UserProfileId
		where ual.UserProfileId != @UserID
		and ual.LocationId = @LocationID
		and ual.TransactionTypeID = @TransactionTypeID
		

	
		


drop table #tempData

drop table #tempUserTable
END

GO

