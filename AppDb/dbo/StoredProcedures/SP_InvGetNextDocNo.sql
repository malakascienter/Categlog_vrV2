-- =============================================
-- Author:		Nivesh
-- Create date: 2026-01-09
-- Last Modify by	: Nivesh
-- Last Modified date : 2026-01-09
-- Description:	Get nextdocument number
-- =============================================
create     PROCEDURE [dbo].[SP_InvGetNextDocNo]
	@Code VARCHAR(50),
	@DocNo VARCHAR(50) OUTPUT
AS
BEGIN

	DECLARE @NextNo INT
	DECLARE @Length INT
	DECLARE @Prefix NVARCHAR(10)

    IF NOT EXISTS(SELECT 1 FROM [dbo].[DocumentNumbers] WHERE Code = @Code)
    BEGIN
        INSERT INTO [dbo].[DocumentNumbers]
           ([Id]
           ,[Code]
           ,[Prefix]
           ,[NextNo]
           ,[Length]
           ,[PropertyId]
           ,[Description])
     VALUES
           (6
           ,'SRON'
           ,'SRON'
           ,1
           ,10
           ,1
           ,'Stock ReOrder Notification')
    END
	
	SELECT TOP 1 @Prefix = [Prefix],@NextNo=[NextNo],@Length=[Length] FROM [dbo].[DocumentNumbers] WHERE Code = @Code
	SET @DocNo = @Prefix+ right('00000000000000000000000000'+convert(varchar(max),@NextNo),@Length)

END

GO

