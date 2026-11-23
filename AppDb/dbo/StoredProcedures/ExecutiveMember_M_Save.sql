-- =============================================
-- Author:		Chiraj
-- Create date: 2020-06--8
-- Description:	POS_ExecutiveMember
-- =============================================
CREATE PROCEDURE [dbo].[ExecutiveMember_M_Save] 
@MemberName VARCHAR(100),
@EPFNo VARCHAR(10),
@CreditLimit DECIMAL(18,2),
@CreditBalance DECIMAL(18,2),
@Active BIT,
@DiscountPercentage DECIMAL(18,2),
@IsExecutivePrice BIT,
@ChargeHeaderId INT,
@ExecutiveMemberCategoryId INT,
@Operation CHAR(1),  
@UserId    INT,
@PropertyId INT,
@MemberID INT
AS
BEGIN TRY
	SET NOCOUNT ON;
	DECLARE @Id BIGINT
	DECLARE @MemberIDgen INT

	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROM POS_ExecutiveMember where EPFNo=@EPFNo AND PropertyId=@PropertyId)         
		BEGIN  
			RAISERROR('ExecutiveMember EPFNo OR MemberID already exists',16,1)  
		END  
		ELSE
		BEGIN
			SET @MemberIDgen=(SELECT isnull(MAX(MemberID),0)+1  FROM POS_ExecutiveMember)
			INSERT INTO POS_ExecutiveMember(MemberID,MemberName,EPFNo,CreditLimit,CreditBalance,Active,DiscountPercentage,IsExecutivePrice,ChargeHeaderId,CreatedUserId,CreatedDateTime,IsUpload,PropertyId,ExecutiveMemberCategoryId)
			VALUES(@MemberIDgen,@MemberName,@EPFNo,@CreditLimit,@CreditBalance,@Active,@DiscountPercentage,@IsExecutivePrice,@ChargeHeaderId,@userId,GETDATE(),0,@PropertyId,@ExecutiveMemberCategoryId)

			SET @Id = SCOPE_IDENTITY()
			-- Audit trail ----------------------------		
			EXEC HotelResWeb_AuditTail_WriteToLog 'POS_ExecutiveMember',@Id,'POS','POSEMI','I',@UserId,'','','','','',@PropertyId
			-- End of Audit trail ---------------------


		END
	END
	ELSE IF @Operation ='U'
	BEGIN

		IF EXISTS (SELECT 1 FROM POS_ExecutiveMember where EPFNo=@EPFNo AND PropertyId=@PropertyId AND MemberID<>@MemberID)         
		BEGIN  
			RAISERROR('ExecutiveMember EPFNo OR MemberID already exists',16,1)  
		END  

		SELECT @Id =  Id FROM POS_ExecutiveMember WHERE MemberID=@MemberID AND PropertyId=@propertyId
		-- Audit trail ----------------------------		
		EXEC HotelResWeb_AuditTail_WriteToLog 'POS_ExecutiveMember',@Id,'POS','POSEMU','U',@UserId,'','','','','',@PropertyId
		-- End of Audit trail ---------------------


		UPDATE POS_ExecutiveMember SET		
		MemberName=@MemberName,
		EPFNo=@EPFNo ,
		CreditLimit=@CreditLimit,
		CreditBalance=@CreditBalance,
		Active=@Active ,
		DiscountPercentage=@DiscountPercentage,
		IsExecutivePrice=@IsExecutivePrice,
		ChargeHeaderId=@ChargeHeaderId,
		PropertyId=@PropertyId,
		IsUpload=0,
		ExecutiveMemberCategoryId=@ExecutiveMemberCategoryId
		WHERE MemberID=@MemberID AND PropertyId=@propertyId
	END
END TRY
BEGIN CATCH
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

