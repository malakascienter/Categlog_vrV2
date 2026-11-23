
-- =============================================    
-- Author:  Chiraj    
-- Create date: 2018-7-30    
-- Description: Save Combo Items    
-- =============================================    
CREATE PROCEDURE [dbo].[ComboSetup_M_Save]     
     
@MainMenuCode VARCHAR(6),    
@MenuCode VARCHAR(6),    
@SeqNo INT=0,    
@AddRate DECIMAL =0.00,    
@ActionButtonID INT,    
@AlternativeMenuCodesJson NVARCHAR(MAX),
@AlternativeMenuAddRateJson VARCHAR(MAX),  
@UserId INT,  
@Qty INT ,
@PropertyId	INT
    
AS    
BEGIN TRY    
	BEGIN TRANSACTION 
	    
	DECLARE @Remark NVARCHAR(250)    
	DECLARE @MenuItemID INT;

	CREATE TABLE #TempAlternativeAddRate(
		TempMenuCode	VARCHAR(6),
		TempAddRate		MONEY
	)
       
	SELECT * INTO #TempMenuItemWiseAlternatives    
	FROM  OPENJSON(@AlternativeMenuCodesJson)    
	WITH    
	(    
		AlternativeCode CHAR(6)'$.Code'        
	)   
	
	INSERT INTO #TempAlternativeAddRate(TempMenuCode, TempAddRate)
	SELECT * FROM OPENJSON(@AlternativeMenuAddRateJson)
	WITH
	(
		TempMenuCode	VARCHAR(6)	'$.MainMenuCode',
		TempAddRate		MONEY		'$.AddRate'
	) 
	 

	SELECT @MenuItemID = Id FROM MenuItemWiseAlternatives 
	WHERE MainMenuCode=@MainMenuCode AND @MenuCode=MenuCode AND ActionButtonID=@ActionButtonID;

	SELECT * FROM #TempMenuItemWiseAlternatives      
     
	IF EXISTS( SELECT * FROM MenuItemWiseAlternatives WHERE MainMenuCode=@MainMenuCode AND @MenuCode=MenuCode AND ActionButtonID=@ActionButtonID)    
	BEGIN    
		DELETE FROM MenuItemWiseAlternatives WHERE MainMenuCode=@MainMenuCode AND @MenuCode=MenuCode AND ActionButtonID=@ActionButtonID      
       
		-- audit trail      
		EXEC [dbo].[AuditTrail_InsertToHistory] 'MenuItemWiseAlternatives',@MenuItemID    
		-- end of audit trail     
        
		INSERT INTO MenuItemWiseAlternatives(MainMenuCode, MenuCode, AlternateMenuCode, SeqNo, AddRate, ActionButtonID, Qty)     
		SELECT  @MainMenuCode, @MenuCode, TempMenuCode, '00', CASE WHEN TempAddRate IS NULL THEN 0.00 ELSE TempAddRate END , @ActionButtonID,@Qty 
		--FROM #TempMenuItemWiseAlternatives  TA
		FROM #TempAlternativeAddRate TR   
       
		-- audit trail  	       
		SET @Remark = 'MenuItemWiseAlternatives '+@MainMenuCode+', '+@MenuCode+' created.';    
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'MenuItemWiseAlternatives',@MenuItemID,@UserId,'I',@Remark    
		-- end of audit trail          
	END    
	ELSE    
	BEGIN    
		-- audit trail      
		EXEC [dbo].[AuditTrail_InsertToHistory] 'MenuItemWiseAlternatives',@MenuItemID    
		-- end of audit trail     
    
		INSERT INTO MenuItemWiseAlternatives(MainMenuCode, MenuCode, AlternateMenuCode, SeqNo, AddRate, ActionButtonID, Qty)     
		SELECT  @MainMenuCode, @MenuCode, TempMenuCode, '00',CASE WHEN TempAddRate IS NULL THEN 0.00 ELSE TempAddRate END, @ActionButtonID,@Qty 
		--FROM #TempMenuItemWiseAlternatives 
		FROM #TempAlternativeAddRate TR    
       
		-- audit trail        
		SET @Remark = 'MenuItemWiseAlternatives '+@MainMenuCode+', '+@MenuCode+' created.';    
		EXEC [dbo].[AuditTrail_InsertTableChanges] 'MenuItemWiseAlternatives',@MenuItemID,@UserId,'I',@Remark    
		-- end of audit trail                   
	END    
      
	DROP TABLE #TempMenuItemWiseAlternatives    

UPDATE MAINMENU 
SET IsUpload = 0
WHERE ItemCode = @MainMenuCode and PropertyId = @PropertyId
	
DECLARE @IsActive BIT
SELECT @IsActive = Active FROM MainMenu WHERE ItemCode = @MainMenuCode AND PropertyId = @PropertyId
SET @IsActive = ISNULL(@IsActive,0)
EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@MainMenuCode,@PropertyId
    
	COMMIT TRANSACTION    
	END TRY    
    
	BEGIN CATCH    
		ROLLBACK TRANSACTION 
		DECLARE @ERROR_MSG VARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG,16,1)   
	END CATCH

GO

