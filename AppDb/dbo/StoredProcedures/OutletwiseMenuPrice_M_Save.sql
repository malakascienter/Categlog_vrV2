
-- =============================================
-- Author:		BANU
-- Create date: 17/01/2019
-- Description:	SAVE OUTLETWISE MAINMENU PRICE CHANGES
-- =============================================
CREATE PROCEDURE [dbo].[OutletwiseMenuPrice_M_Save] 
	@MainMenuCode	VARCHAR(4),
	@DineInPrice	MONEY,
	@TakeOutPrice	MONEY,
	@DeliveryPrice	MONEY,
	@EffectiveDate	DATETIME,
	@CreatedUserId	INT,
	@IsUpload		BIT,
	@Outlet			VARCHAR(MAX),
	@UserId			INT
AS
BEGIN 
	CREATE TABLE #TempOutlet(
		Code VARCHAR(3)
	)

	INSERT INTO #TempOutlet(Code)
	SELECT * FROM OPENJSON(@Outlet) WITH(
		Code	VARCHAR(3)	'$.Code'
	)

	DECLARE @CurOutlet	VARCHAR(3), @Id INT, @Remark VARCHAR(MAX) 
		
	WHILE EXISTS (SELECT TOP 1 Code FROM #TempOutlet ORDER BY Code)
	BEGIN
		SELECT TOP 1 @CurOutlet = Code FROM #TempOutlet ORDER BY Code 

		IF EXISTS(SELECT 1 FROM OutletwiseMenuItemPrice WHERE MainMenuCode = @MainMenuCode AND Outlet = @CurOutlet)
		BEGIN
			SELECT @Id = Id FROM OutletwiseMenuItemPrice WHERE MainMenuCode = @MainMenuCode AND Outlet = @CurOutlet
			 --audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'OutletwiseMenuItemPrice',@Id
			 --end of audit trail

			UPDATE OutletwiseMenuItemPrice SET DineInPrice = @DineInPrice, TakeOutPrice = @TakeOutPrice, 
					DeliveryPrice = @DeliveryPrice, EffectiveDate = @EffectiveDate, IsUpload = 0,
				LastModifiedUserId = @CreatedUserId, LastModifiedDateTime = GETDATE()
			WHERE MainMenuCode = @MainMenuCode AND Outlet = @CurOutlet

			 --audit trail				
			SET @Remark = 'Outletwise Menu Price '+@MainMenuCode+', '+@CurOutlet+' updated.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'OutletwiseMenuItemPrice',@Id,@UserId,'U',@Remark
			 --end of audit trail
		END
		ELSE
		BEGIN 
			INSERT INTO OutletwiseMenuItemPrice (MainMenuCode, Outlet, DineInPrice, TakeOutPrice, DeliveryPrice,
						EffectiveDate, IsUpload, CreatedUserId, CreatedDateTime,LastModifiedUserId,LastModifiedDateTime)
			VALUES(@MainMenuCode,@CurOutlet,@DineInPrice, @TakeOutPrice,@DeliveryPrice,@EffectiveDate, 0, 
					@CreatedUserId,GETDATE(), @CreatedUserId, GETDATE())

			SELECT @Id = Id FROM OutletwiseMenuItemPrice WHERE MainMenuCode = @MainMenuCode AND Outlet = @CurOutlet				
				
				--audit trail	 
			EXEC [dbo].[AuditTrail_InsertToHistory] 'OutletwiseMenuItemPrice',@Id
				--end of audit trail

				--audit trail				
			SET @Remark = 'Outletwise Menu Price '+@MainMenuCode+'-'+@CurOutlet+' created.';
			EXEC [dbo].[AuditTrail_InsertTableChanges] 'OutletwiseMenuItemPrice',@Id,@UserId,'I',@Remark
				--end of audit trail		

		END

		DELETE FROM #TempOutlet WHERE Code = @CurOutlet 
	END

	DROP TABLE #TempOutlet
END

GO

