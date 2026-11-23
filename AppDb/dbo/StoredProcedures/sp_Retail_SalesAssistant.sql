-- =============================================
-- Author:		YThisen Dewnim
-- Create date: 2026-02-12
-- Description:	The insert,update and the delete of sales assistant
-- =============================================
CREATE PROCEDURE [dbo].[sp_Retail_SalesAssistant]
(
    @Action CHAR(1),       
    @ID INT = NULL,
    @Name NVARCHAR(MAX) = NULL,
    @Code NVARCHAR(200) = NULL,
    @RefNo NVARCHAR(200) = NULL,
    @IsActive BIT = NULL,
    @PropertyID INT = NULL,
    @CreatedUserID INT = NULL,
	@IsUpload BIT = NULL


)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @InsertedID INT

    -- INSERT
   
    IF (@Action = 'I')
    BEGIN
        INSERT INTO dbo.Retail_SalesAssistant
        (
            Name,
            Code,
            RefNo,
            IsActive,
            PropertyID,
            CreatedUserID,
			LastModUserID,
            CreatedDate,
			IsUpload
        )
        VALUES
        (
            @Name,
            @Code,
            @RefNo,
            ISNULL(@IsActive, 1),
            @PropertyID,
            @CreatedUserID,
			@CreatedUserID,
            GETDATE(),
			0
        );

        SELECT SCOPE_IDENTITY() AS ID;

        set @InsertedID  = SCOPE_IDENTITY();
        RETURN;
    END

    -- UPDATE
   
    IF (@Action = 'U')
    BEGIN
    set @InsertedID =  @ID;
        UPDATE dbo.Retail_SalesAssistant
        SET
            Name = @Name,
            Code = @Code,
            RefNo = @RefNo,
            IsActive = @IsActive,
            LastModUserID = @CreatedUserID,
            LastModDate = GETDATE(),
			IsUpload = 0
        WHERE ID = @ID;

 
    END

   		  Declare @LocationJson VARCHAR(MAX)
          SET @LocationJson = (SELECT  Id AS LocationID FROM Locations WHERE IsActive = 1 AND CompanyID = @PropertyID  AND IsSalesLocation=1 FOR JSON PATH,INCLUDE_NULL_VALUES)
          EXEC RT_SYNC_DATA_INSERT @PropertyID,@InsertedID,@Code,'SalesAssistant',@IsActive,0,@LocationJson

END;

GO

