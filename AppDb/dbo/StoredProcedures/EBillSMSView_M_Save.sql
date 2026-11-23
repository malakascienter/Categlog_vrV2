
CREATE PROCEDURE [dbo].[EBillSMSView_M_Save]
	@BillDetailsJson  NVARCHAR(MAX),
	@OrderId NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 

INSERT INTO [dbo].[EBillSMSView]
           ([BillDetails]
           ,[OrderId]
           ,[SysDate])
     VALUES
           (@BillDetailsJson
           ,@OrderId
           ,GETDATE())
END

GO

