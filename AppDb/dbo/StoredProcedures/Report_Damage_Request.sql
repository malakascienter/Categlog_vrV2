-- =============================================
-- Author:		Chiraj
-- Create date: 2018-11-19
-- Description:	Damage Request Report
-- =============================================
CREATE PROCEDURE [dbo].[Report_Damage_Request]
	--@Status Char(1),--report unsaved or saved report
	@User_Id INT,
	@RequestHeader BIGINT--,
	--@PropertyId VARCHAR(2)

AS
BEGIN

	SET NOCOUNT ON;
	DECLARE @Slot INT
	--SELECT @Slot=SlotId FROM DocTypeWiseApprovalSlotsWiseUsers WHERE UserId=@User_Id
	SET @Slot=(SELECT TOP(1)SlotId FROM DocTypeWiseApprovalSlotsWiseUsers AS D INNER JOIN [dbo].[DocTypeWiseApprovalSlots] AS DS ON DS.Id=D.SlotId  WHERE UserId=@User_Id AND DS.DocTypeId=2)
   SELECT  
		DRD.DamageHeaderId AS HeaderId 
		,DRD.Id AS DetailId    
		,DR.UserId
		,DR.DamageReqNo AS RequestNo
		,DR.Remark      
		,DRD.Qty
		,RTRIM(LTRIM(SM.ItemNo)) AS ItemCode
		,SM.Description AS ItemName
		,L.Description AS Location 
		FROM DamageRequestHeader AS DR INNER JOIN DamageReqestDetail AS DRD ON DR.Id=DRD.DamageHeaderId
		INNER JOIN StockMaster AS SM on SM.ItemNo=DRD.ItemCode 
		INNER JOIN Location AS L ON L.Code=DR.LocationId
		WHERE SM.Location=DR.LocationId AND 
		DR.IsTemp=0 AND DR.Id=@RequestHeader
		--ItemCode in(SELECT ItemCode FROM[dbo].[DamageRequestApproval] WHERE  Status = 'P' AND ApproveSlotId=@Slot )
	
END

GO

