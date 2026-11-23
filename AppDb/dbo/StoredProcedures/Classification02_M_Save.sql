
-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date,,>  
-- Description: <Description,,>  
-- =============================================  
CREATE  PROCEDURE [dbo].[Classification02_M_Save]  
	@Id BIGINT,
	@Classification01Id BIGINT,
	@Name VARCHAR(20),
	@Active  BIT,  
	@Operation CHAR(1),  
	@UserId    INT,  
	@PropertyId INT,
	@Prefix VARCHAR(2)
	
AS  
BEGIN  TRY
BEGIN TRANSACTION
	SET NOCOUNT ON;
 
	IF @Operation ='I'  
	BEGIN 
		IF EXISTS (SELECT 1 FROm POS_Classification02 where PropertyId=@PropertyId AND (Name=@Name))         
		BEGIN  
			RAISERROR('Description or Prefix already exists',16,1)  
		END  
		ELSE 
		BEGIN 	
			

			INSERT INTO POS_Classification02(Name,PropertyId,IsUpload,CreatedUserId,CreatedDateTime,Active,Classification01Id,Prefix)
			VALUES (@Name,@PropertyId,0,@UserId,GETDATE(),@Active,@Classification01Id,ISNULL(@Prefix,''))  


		END     
	END    
	ELSE IF @Operation ='U'  
	BEGIN  
		

		IF EXISTS (SELECT 1 FROm POS_Classification02 where PropertyId=@PropertyId AND (Name=@Name) and Id <>@Id)         
		BEGIN  
			RAISERROR('Description or Prefix already exists',16,1)  
		END  
		ELSE
		BEGIN
			
			UPDATE POS_Classification02  
			SET    
			Name = @Name,
			Classification01Id = @Classification01Id,
			Active =@Active,  
			ModifiedUserId=@UserId,
			ModifiedDateTime=GETDATE(),
			IsUpload=0,
			Prefix = ISNULL(@Prefix,'')
			WHERE Id = @Id AND PropertyId=@PropertyId
			
			
			
		END
	END 
		
COMMIT TRANSACTION		
END TRY 
BEGIN CATCH
ROLLBACK TRANSACTION
	INSERT INTO GEN_ErrTable (ErrorNumber,ErrorSeverity,ErrorState,ErrorProcedure,ErrorLine,ErrorMessage)
    VALUES (ERROR_NUMBER(),ERROR_SEVERITY(),ERROR_STATE(),ERROR_PROCEDURE(),ERROR_LINE(),ERROR_MESSAGE())

	DECLARE  @ERRmsg VARCHAR(MAX) =ERROR_MESSAGE()
	RAISERROR(@ERRmsg,16,1)
END CATCH

GO

