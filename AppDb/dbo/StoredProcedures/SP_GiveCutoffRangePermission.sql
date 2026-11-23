-- =============================================
-- Author:		Tharuka Sachintha
-- Create date: 2026-06-22
-- Description:	check cut off range permission

-- [dbo].[SP_GiveCutoffRangePermission] 1,58,2,1,4168,1000

-- =============================================
CREATE   PROCEDURE [dbo].[SP_GiveCutoffRangePermission]
	@CompanyId INT,
    @LocationID INT,
    @TransType INT,
    @ApprovalType INT,
    @UserId INT, 
    @CutOffValue DECIMAL(18,6)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @HasApproval BIT, @minvalue DECIMAL(18,6), @maxvalue DECIMAL(18,6);


    SELECT @minvalue = U.RangeFrom, @maxvalue = U.RangeTo
    FROM UserWiseApproveLevels U
    WHERE U.PropertyId = @CompanyId 
    AND U.LocationId = @LocationID 
    AND U.TransactionTypeID = @TransType 
    AND U.ApproveLevelID = @ApprovalType 
    AND U.UserProfileId = @UserId


    SELECT CASE 
       WHEN @minvalue IS NOT NULL 
          AND @CutOffValue BETWEEN @minvalue AND @maxvalue 
          THEN CAST(1 AS BIT)
          ELSE CAST(0 AS BIT)
       END AS HasPermission;

    
END

GO

