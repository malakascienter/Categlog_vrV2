--EXEC SP_SelectServiceItemList_POS 2
CREATE PROCEDURE [dbo].[SP_SelectServiceItemList_POS]
(
  @customerId AS INT 
)
AS
BEGIN


             SELECT ID,JobNoteNumber,CustomerID 
			 FROM dbo.JobNoteHeader
			 WHERE CustomerID = CASE WHEN @customerId = -1 THEN CustomerID ELSE @customerId END
		  

END

GO

