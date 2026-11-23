-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE SP_GetPendingOutsideOrder
	
AS
BEGIN

	SET NOCOUNT ON;

    SELECT [Id]
      ,[OutsideOrderId]
      ,[AggregatorType]
      ,[PropertyId]
      ,[Outlet]
      ,[OrderStatus]
      ,[IsUpload]
      ,[SysDate]
      ,[EventDetail]
  FROM [dbo].[OutsideOrder]
  WHERE [IsUpload] = 0


END

GO

