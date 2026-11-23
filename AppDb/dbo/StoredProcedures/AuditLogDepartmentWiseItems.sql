-- =============================================
-- Author:		Vinuki
-- Create date: 13.03.2024
-- Description:	Audit traillog SP for DepartmentWiseItems
-- =============================================
--AuditLogDepartmentWiseItems 22
create PROCEDURE AuditLogDepartmentWiseItems
	-- Add the parameters for the stored procedure here
	@DepartmentID int
AS
BEGIN
	SET NOCOUNT ON;
	BEGIN TRY
		SELECT 
			DepartmentId, AuditTrailID, TableName, LogDate, StockItemCode, sth.Name As ItemName, dep.Name As DepartmentName,
			CASE WHEN Action = 'I' THEN 'Inserted' WHEN Action = 'D' THEN 'Deleted' END Action, 
			am.UserID, am.Username, am.PropertyId, dh.StockItemId 
		FROM  HotelResWeb_AuditTail..DepartmentWiseItems_History dh
		inner join  HotelResWeb_AuditTail..audittrailMaster am on  am.trailid = dh.AuditTrailID
		left join  HotelResWeb_AuditTail..AuditTrailDetail ad on ad.TrailID = dh.AuditTrailID
		inner join Categlog_vrV2..StockItemHeaders sth on sth.Id = dh.StockItemId 
		inner join Categlog_vrV2..Departments dep on dep.Id = dh.DepartmentId
		where dh.DepartmentId = @DepartmentID
		order by LogDate desc;
	END TRY
	BEGIN CATCH
		
		SELECT 
			ERROR_NUMBER() AS ErrorNumber,
			ERROR_MESSAGE() AS ErrorMessage,
			ERROR_SEVERITY() AS ErrorSeverity,
			ERROR_STATE() AS ErrorState,
			ERROR_PROCEDURE() AS ErrorProcedure,
			ERROR_LINE() AS ErrorLine;
	END CATCH;
END

GO

