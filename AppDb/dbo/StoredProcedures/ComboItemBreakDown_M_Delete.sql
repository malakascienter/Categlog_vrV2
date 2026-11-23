-- =============================================  
-- Author:  Chiraj  
-- Create date: 2018-7-30  
-- Description: ComboItemBreakDown_M_Delete   
-- =============================================  
CREATE  PROCEDURE [dbo].[ComboItemBreakDown_M_Delete]    
@MainMenuCode VARCHAR(4),  
@SubItem VARCHAR(4),  
@UserId INT  ,
@PropertyId INT
AS  
BEGIN   
 DECLARE @Remark NVARCHAR(250)
 DECLARE @Id INT   
 SELECT @Id = Id FROM ComboItemBreakDown WHERE mainmenucode=@MainMenuCode and subItemcode=@SubItem  AND PropertyId = @PropertyId
    
 IF EXISTS(SELECT * FROM ComboItemBreakDown WHERE mainmenucode=@MainMenuCode and subItemcode=@SubItem AND PropertyId = @PropertyId)   
 BEGIN   
    
  -- audit trail    
  EXEC [dbo].[AuditTrail_InsertToHistory] 'ComboItemBreakDown',@Id  
  -- end of audit trail   
  
  DELETE FROM ComboItemBreakDown WHERE mainmenucode=@MainMenuCode and subItemcode=@SubItem  AND PropertyId = @PropertyId
    
  -- audit trail      
  SET @Remark = 'Combo item breakdown '+ CONVERT(VARCHAR,@Id) + ' deleted.';  
  EXEC [dbo].[AuditTrail_InsertTableChanges] 'ComboItemBreakDown',@Id,@UserId,'D',@Remark  
  -- end of audit trail 
  
  -----DELETE DEFAULT MAIN MENU ITEM ALTERNATIVE FOR SWAP
  DELETE FROM MenuItemWiseAlternatives 
  WHERE MainMenuCode = @MainMenuCode 
		AND MenuCode = @SubItem 
		--AND AlternateMenuCode = @SubItem
		--AND ActionButtonID = 5

  ----DELETE MAIN MENU BASED MODIFIERS
  DELETE FROM MenuItemWiseModifier
  WHERE MainMenuCode = @MainMenuCode
  AND ModifierMenuCode = @SubItem
  AND PropertyId = @PropertyId

  ----DELETE MODIFIER BASED MODIFIERS
  DELETE FROM MenuItemWiseModifier
  WHERE MainMenuCode = @SubItem AND PropertyId = @PropertyId
  --AND ModifierMenuCode = @SubItem


 UPDATE MAINMENU 
SET IsUpload = 0
WHERE ItemCode = @MainMenuCode and PropertyId = @PropertyId
	
DECLARE @IsActive BIT
SELECT @IsActive = Active FROM MainMenu WHERE ItemCode = @MainMenuCode AND PropertyId = @PropertyId
SET @IsActive = ISNULL(@IsActive,0)
EXEC Insert_Sync_MasterDataTransferStatus 'MainMenu',@IsActive,@MainMenuCode,@PropertyId

 END   
  
 ELSE  
 BEGIN  
  RAISERROR('Record Not Exists.',16,1)  
 END  
END

GO

